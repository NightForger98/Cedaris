// The world map (M in game): the outdoor rooms drawn small and laid out as they join, as one sprite (spr_world_map),
// and scripts/world_map with where each room and each building with a door sits on it.
//
//   node tools/rooms/worldmap.js            (run it again after changing an outdoor room)
//
// Rooms are placed on the world's 5 x 5 grid (tools/world/world.js): each column as wide as its widest room, each row
// as tall as its tallest, every room centred in its cell. A building is any house-like thing (it has a door) with an exit at its door.
const fs = require("fs");
const path = require("path");
const {execFileSync} = require("child_process");
const {root, readYy} = require("./yy.js");
const {writePng, newImage, blit} = require("./png.js");
const {renderRoom, tilesetImage} = require("./render.js");
const {roomWalk} = require("./walk.js");
const T = require("./tiles.js");

const SCALE = 0.25;        // map pixels per room pixel
const GAP = 64;            // room pixels between neighbouring rooms
// Cedar & Sea: the outdoor rooms are the blueprint's (tools/world2), each where it lies in the world; the farm keeps
// its own room, drawn at the blueprint's farm
const W2 = require("../world2/areas_build.js");
const OUTDOORS = ["rm_1", ...Object.keys(W2.all().rooms)];
const FARM_AT = [45, 148];   // the farm's top-left in world tiles (design/map/areas.json, The Farm)

const spec = n => require(path.join(__dirname, "specs", n + ".js"));
const size = n => { const r = readYy(`rooms/${n}/${n}.yy`); return [r.roomSettings.Width, r.roomSettings.Height]; };

// Place the outdoor rooms where they lie in the world (room pixels: world tiles x 32)
function layout(){
	const pos = {};
	for(const n of OUTDOORS){
		if(n === "rm_1"){ pos[n] = [FARM_AT[0] * 32, FARM_AT[1] * 32]; continue; }
		const f = W2.all().frames[n];
		pos[n] = [f.ox * 32, f.oy * 32];
	}
	return pos;
}
// (the old 5 x 5 grid layout, before the merge)
function layoutGrid(GRID){
	const cols = GRID[0].map((_, c) => Math.max(...GRID.map(row => size(row[c])[0])));
	const rows = GRID.map(row => Math.max(...row.map(n => size(n)[1])));
	const pos = {};
	let y = 0;
	GRID.forEach((row, r) => {
		let x = 0;
		row.forEach((n, c) => {
			const [w, h] = size(n);
			pos[n] = [x + Math.floor((cols[c] - w) / 2), y + Math.floor((rows[r] - h) / 2)];
			x += cols[c] + GAP;
		});
		y += rows[r] + GAP;
	});
	return pos;
}

// Average each SCALE block of pixels (a plain nearest-pixel shrink turns grass into noise)
function shrink(img){
	const k = Math.round(1 / SCALE), w = Math.ceil(img.w / k), h = Math.ceil(img.h / k), out = newImage(w, h);
	for(let y = 0; y < h; y++) for(let x = 0; x < w; x++){
		const sum = [0, 0, 0, 0];
		let n = 0;
		for(let j = 0; j < k; j++) for(let i = 0; i < k; i++){
			const sx = x * k + i, sy = y * k + j;
			if(sx >= img.w || sy >= img.h) continue;
			const o = (sy * img.w + sx) * 4;
			for(let c = 0; c < 4; c++) sum[c] += img.px[o + c];
			n++;
		}
		out.px.set(sum.map(v => Math.round(v / n)), (y * w + x) * 4);
	}
	return out;
}


function build(){
	const pos = layout();
	const xs = Object.entries(pos).map(([n, [x]]) => [x, x + size(n)[0]]).flat();
	const ys = Object.entries(pos).map(([n, [, y]]) => [y, y + size(n)[1]]).flat();
	const x0 = Math.min(...xs), y0 = Math.min(...ys);
	const W = Math.ceil((Math.max(...xs) - x0) * SCALE), H = Math.ceil((Math.max(...ys) - y0) * SCALE);
	const map = newImage(W, H);
	const at = ([x, y]) => [Math.round((x - x0) * SCALE), Math.round((y - y0) * SCALE)];

	const rooms = {};
	for(const [n, p] of Object.entries(pos)){
		const full = renderRoom(n, {instances: false});
		if(n !== "rm_1"){
			const f = W2.all().frames[n];
			for(let y = 0; y < full.h; y++) for(let x = 0; x < full.w; x++){
				if(W2.owner(f.ox + Math.floor(x / 32), f.oy + Math.floor(y / 32)) !== n) full.px[(y * full.w + x) * 4 + 3] = 0;
			}
		}
		const img = shrink(full);
		const [mx, my] = at(p);
		for(let y = 0; y < img.h; y++) for(let x = 0; x < img.w; x++){
			const s = (y * img.w + x) * 4;
			if(img.px[s + 3] < 128) continue;
			const tx = mx + x, ty = my + y;
			if(tx < 0 || ty < 0 || tx >= map.w || ty >= map.h) continue;
			const d = (ty * map.w + tx) * 4;
			for(let c = 0; c < 3; c++) map.px[d + c] = img.px[s + c];
			map.px[d + 3] = 255;
		}
		rooms[n] = [mx, my, img.w, img.h];
	}

	// Buildings: an exit to an indoor room at a house's door; that room and the rooms inside it map to the door
	const buildings = [], inside = {};
	for(const n of OUTDOORS){
		const sp = spec(n), [ox, oy] = pos[n];
		for(const [x, y, b] of roomWalk(n, sp).doors){
			if(OUTDOORS.includes(b)) continue;
			const cx = Math.floor(x / 32), cy = Math.floor(y / 32);
			const thing = (sp.things || []).map(t => Object.assign({}, T.things[t.is] || {}, t)).find(t => {
				if(!t.door) return false;
				const ddx = cx - t.at[0] - t.door[0];
				return (ddx === 0 || ddx === 1) && t.at[1] + t.door[1] === cy; // double doors span two cells
			});
			const [dx, dy] = at([ox + x, oy + y]);
			inside[b] = [dx, dy];
			if(!thing) continue;
			const st = thing.stamp ? JSON.parse(fs.readFileSync(path.join(__dirname, "stamps", thing.stamp + ".json"), "utf8"))
				: {w: thing.src[2], h: thing.src[3]};
			const [bx, by] = at([ox + thing.at[0] * 32, oy + thing.at[1] * 32]);
			buildings.push({room: b, rect: [bx, by, Math.round(st.w * 32 * SCALE), Math.round(st.h * 32 * SCALE)]});
		}
	}
	// Rooms reached from inside another (upstairs) map to the same door
	for(const b of Object.keys(inside)) for(const [, , c] of roomWalk(b, spec(b)).doors) if(!inside[c] && !OUTDOORS.includes(c)) inside[c] = inside[b];
	// The mine's cave, under the cliff on Beacon Hill
	const cave = spec("rm_mountain").points.cave;   // (Beacon Hill's cave, on the Mountain)
	inside.rm_mine = at([pos.rm_mountain[0] + cave[0], pos.rm_mountain[1] + cave[1]]);

	fs.mkdirSync(path.join(root, "build"), {recursive: true});
	const png = path.join(root, "build", "world_map.png");
	writePng(png, map);
	execFileSync("node", [path.join(root, "tools", "sprite_import.js"), png, "spr_world_map", "UI"], {stdio: "inherit"});

	const fmt = o => Object.entries(o).map(([k, v]) => `${k}: [${v.join(", ")}]`).join(", ");
	const gml = `// Generated by tools/rooms/worldmap.js from the built rooms - don't edit by hand.
// The world map (spr_world_map, ${W} x ${H}): map pixels are room pixels x ${SCALE}. rooms: where each outdoor room's
// top-left is on the map, and its size there [x, y, w, h]; buildings: the buildings you can go into, by the room
// inside [x, y, w, h]; inside: where an indoor room's door is on the map [x, y] (the mine: its cave).

function world_map(){
	static t = {
		scale: ${SCALE}, w: ${W}, h: ${H},
		rooms: {${fmt(rooms)}},
		inside: {${fmt(inside)}},
		buildings: [
${buildings.map(b => `\t\t\t{room: "${b.room}", rect: [${b.rect.join(", ")}]},`).join("\n")}
		],
	};
	return t;
}
`;
	const dir = path.join(root, "scripts", "world_map");
	fs.mkdirSync(dir, {recursive: true});
	fs.writeFileSync(path.join(dir, "world_map.gml"), gml);
	const yy = path.join(dir, "world_map.yy");
	if(!fs.existsSync(yy)){
		fs.writeFileSync(yy, `{\n  "$GMScript":"v1",\n  "%Name":"world_map",\n  "isCompatibility":false,\n  "isDnD":false,\n  "name":"world_map",\n  "parent":{\n    "name":"Scripts",\n    "path":"folders/Scripts.yy",\n  },\n  "resourceType":"GMScript",\n  "resourceVersion":"2.0",\n}`);
		const yypPath = path.join(root, "CedarAndSea.yyp");
		let yyp = fs.readFileSync(yypPath, "utf8");
		const nl = yyp.includes("\r\n") ? "\r\n" : "\n";
		const entry = '    {"id":{"name":"world_map","path":"scripts/world_map/world_map.yy",},},';
		if(!yyp.includes(entry)){ yyp = yyp.replace('"resources":[' + nl, '"resources":[' + nl + entry + nl); fs.writeFileSync(yypPath, yyp); }
	}
	console.log(`world map: ${W} x ${H}, ${buildings.length} buildings`);
}

build();
