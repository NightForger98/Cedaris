// The world map (M in game): the outdoor rooms drawn small and laid out as they join, as one sprite (spr_world_map),
// and scripts/world_map with where each room and each building with a door sits on it.
//
//   node tools/rooms/worldmap.js            (run it again after changing an outdoor room)
//
// Rooms are placed by their exits: the farm at the middle, and each room through an exit on an edge of the room it
// was reached from (the exit's offset lines up the two sides). Whisperwood is built while the game runs, so the map
// shows it as woods east of the village. A building is any house-like thing (it has a door) with an exit at its door.
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
const OUTDOORS = ["rm_1", "rm_2", "rm_town", "rm_beach", "rm_valley"];
const FOREST = {w: 48 * 32, h: 30 * 32};   // FOREST_W x FOREST_H in scripts/forest

const spec = n => require(path.join(__dirname, "specs", n + ".js"));
const size = n => { const r = readYy(`rooms/${n}/${n}.yy`); return [r.roomSettings.Width, r.roomSettings.Height]; };

// Place the outdoor rooms by walking their exits out from the farm
function layout(){
	const pos = {rm_1: [0, 0]}, queue = ["rm_1"];
	while(queue.length){
		const a = queue.shift(), [aw, ah] = size(a);
		for(const [x, y, b, tx, ty] of roomWalk(a, spec(a)).doors){
			if(!OUTDOORS.includes(b) || pos[b]) continue;
			const [bw, bh] = size(b), [ax, ay] = pos[a];
			if(x < 64) pos[b] = [ax - bw - GAP, ay + y - ty];
			else if(x > aw - 64) pos[b] = [ax + aw + GAP, ay + y - ty];
			else if(y < 64) pos[b] = [ax + x - tx, ay - bh - GAP];
			else pos[b] = [ax + x - tx, ay + ah + GAP];
			queue.push(b);
		}
	}
	const [vw] = size("rm_2");
	pos.rm_forest = [pos.rm_2[0] + vw + GAP, pos.rm_2[1]];
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

// Whisperwood for the map: grass thick with pines (the real wood is generated in the game)
function forestImage(){
	const img = newImage(FOREST.w, FOREST.h, [46, 110, 52, 255]);
	const ts = tilesetImage("TS_terrain"), [c, r, w, h] = T.things.pine.src;
	let s = 99;
	const rand = () => (s = (s * 16807) % 2147483647) / 2147483647;
	for(let k = 0; k < 160; k++)
		blit(img, ts.img, c * 32, r * 32, w * 32, h * 32, Math.floor(rand() * (FOREST.w - 64)), Math.floor(rand() * (FOREST.h - 160)));
	return img;
}

function build(){
	const pos = layout();
	const xs = Object.entries(pos).map(([n, [x]]) => [x, x + (n === "rm_forest" ? FOREST.w : size(n)[0])]).flat();
	const ys = Object.entries(pos).map(([n, [, y]]) => [y, y + (n === "rm_forest" ? FOREST.h : size(n)[1])]).flat();
	const x0 = Math.min(...xs), y0 = Math.min(...ys);
	const W = Math.ceil((Math.max(...xs) - x0) * SCALE), H = Math.ceil((Math.max(...ys) - y0) * SCALE);
	const map = newImage(W, H);
	const at = ([x, y]) => [Math.round((x - x0) * SCALE), Math.round((y - y0) * SCALE)];

	const rooms = {};
	for(const [n, p] of Object.entries(pos)){
		const img = shrink(n === "rm_forest" ? forestImage() : renderRoom(n, {instances: false}));
		const [mx, my] = at(p);
		blit(map, img, 0, 0, img.w, img.h, mx, my);
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
			const st = JSON.parse(fs.readFileSync(path.join(__dirname, "stamps", thing.stamp + ".json"), "utf8"));
			const [bx, by] = at([ox + thing.at[0] * 32, oy + thing.at[1] * 32]);
			buildings.push({room: b, rect: [bx, by, Math.round(st.w * 32 * SCALE), Math.round(st.h * 32 * SCALE)]});
		}
	}
	// Rooms reached from inside another (upstairs) map to the same door
	for(const b of Object.keys(inside)) for(const [, , c] of roomWalk(b, spec(b)).doors) if(!inside[c] && !OUTDOORS.includes(c)) inside[c] = inside[b];
	// The mine's cave on the farm
	const cave = spec("rm_1").points.cave;
	inside.rm_mine = at([pos.rm_1[0] + cave[0], pos.rm_1[1] + cave[1]]);

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
		const yypPath = path.join(root, "NewHarvest.yyp");
		let yyp = fs.readFileSync(yypPath, "utf8");
		const nl = yyp.includes("\r\n") ? "\r\n" : "\n";
		const entry = '    {"id":{"name":"world_map","path":"scripts/world_map/world_map.yy",},},';
		if(!yyp.includes(entry)){ yyp = yyp.replace('"resources":[' + nl, '"resources":[' + nl + entry + nl); fs.writeFileSync(yypPath, yyp); }
	}
	console.log(`world map: ${W} x ${H}, ${buildings.length} buildings`);
}

build();
