// scripts/room_walk: where villagers can walk in every built room, and its doors, for their schedules (scripts/people
// finds routes over these at runtime). Written by build.js after building; reads the built rooms, so it always
// matches what's in the game.
//
// For each room: its size in cells, a grid of walking costs ("0" blocked, "1" roads, cobbles, sand and floors,
// "3" grass, "9" field soil - so people keep to the roads and off your crops), and its exits [x, y, room, tx, ty]:
// the trigger's centre, and where it puts you in the other room.
const fs = require("fs");
const path = require("path");
const {root, readYy} = require("./yy.js");
const T = require("./tiles.js");

const CELL = 32;
const MOVED = {};   // {room: {point: [x, y]}}: points moved to reachable ground (build.js writes them to room_layout)
// Objects that stand in the way though they aren't collision boxes (one cell under their origin)
const BLOCKERS = ["obj_furnace", "obj_crafting_table", "obj_shipping_bin", "obj_quest_board", "obj_kitchen"];

function roomWalk(name, spec){
	const room = readYy(`rooms/${name}/${name}.yy`);
	const W = room.roomSettings.Width / CELL, H = room.roomSettings.Height / CELL;
	const legend = Object.assign({}, T.legend, spec.legend || {});
	const cost = new Array(W * H);
	for(let y = 0; y < H; y++) for(let x = 0; x < W; x++){
		if(spec.base === "none"){ cost[y * W + x] = 1; continue; }
		const ch = (spec.map[y] && spec.map[y][x]) || spec.pad || ".";
		const t = (legend[ch] || {}).terrain;
		cost[y * W + x] = (t === "dirt" || t === "path" || t === "sand" || t === "shore" || ch === "b") ? 1 : t === "soil" ? 9 : 3;
	}
	const doors = [];
	const insts = [];
	const walkLayers = ls => ls.forEach(l => { if(l.instances) insts.push(...l.instances); walkLayers(l.layers || []); });
	walkLayers(room.layers);
	for(const i of insts){
		const o = i.objectId.name;
		if(o === "obj_col_box"){
			// A box covers the cells whose centres are inside it
			const w = 16 * i.scaleX, h = 16 * i.scaleY;
			const c1 = Math.ceil((i.x - w / 2) / CELL - 0.5), c2 = Math.floor((i.x + w / 2) / CELL - 0.5);
			const r1 = Math.ceil((i.y - h / 2) / CELL - 0.5), r2 = Math.floor((i.y + h / 2) / CELL - 0.5);
			for(let y = Math.max(0, r1); y <= Math.min(H - 1, r2); y++) for(let x = Math.max(0, c1); x <= Math.min(W - 1, c2); x++) cost[y * W + x] = 0;
		} else if(BLOCKERS.includes(o)){
			const cx = Math.floor(i.x / CELL), cy = Math.floor((i.y - 1) / CELL);
			if(cx >= 0 && cy >= 0 && cx < W && cy < H) cost[cy * W + cx] = 0;
		} else if(o === "obj_transition" && i.hasCreationCode){
			const code = fs.readFileSync(path.join(root, "rooms", name, `InstanceCreationCode_${i.name}.gml`), "utf8");
			const m = k => (code.match(new RegExp(k + "\\s*=\\s*([\\w.]+)")) || [])[1];
			doors.push([i.x, i.y, m("targetRoom"), +m("targetX"), +m("targetY")]);
		}
	}
	return {W, H, cost, doors};
}

// Every named point should be reachable from every door (a villager standing there could never leave otherwise)
function checkReach(name, spec, w){
	const free = (x, y) => x >= 0 && y >= 0 && x < w.W && y < w.H && w.cost[y * w.W + x] > 0;
	const near = (px, py) => {
		let best = null, bd = 1e9;
		const cx = Math.floor(px / CELL), cy = Math.floor(py / CELL);
		for(let y = cy - 2; y <= cy + 2; y++) for(let x = cx - 2; x <= cx + 2; x++)
			if(free(x, y)){ const d = Math.hypot(x * CELL + 16 - px, y * CELL + 16 - py); if(d < bd){ bd = d; best = [x, y]; } }
		return best;
	};
	if(w.doors.length === 0) return;
	const start = near(w.doors[0][0], w.doors[0][1]);
	if(!start){ console.warn(`  ${name}: its first door is walled in`); return; }
	const seen = new Uint8Array(w.W * w.H), q = [start];
	seen[start[1] * w.W + start[0]] = 1;
	while(q.length){
		const [x, y] = q.shift();
		for(const [dx, dy] of [[1, 0], [-1, 0], [0, 1], [0, -1]]){
			const nx = x + dx, ny = y + dy;
			if(free(nx, ny) && !seen[ny * w.W + nx]){ seen[ny * w.W + nx] = 1; q.push([nx, ny]); }
		}
	}
	const check = (label, px, py) => {
		const c = near(px, py);
		if(!c || !seen[c[1] * w.W + c[0]]) console.warn(`  ${name}: ${label} (${px}, ${py}) can't be reached from the door`);
	};
	// a point that can't be reached moves to the nearest ground that can (the spec's points are shared with
	// build.js's room_layout, which is written after this)
	for(const [k, [px, py]] of Object.entries(spec.points || {})){
		const c = near(px, py);
		if(c && seen[c[1] * w.W + c[0]]) continue;
		const cx = Math.floor(px / CELL), cy = Math.floor(py / CELL);
		let best = null, bd = 1e9;
		for(let y = Math.max(0, cy - 40); y <= Math.min(w.H - 1, cy + 40); y++) for(let x = Math.max(0, cx - 40); x <= Math.min(w.W - 1, cx + 40); x++)
			if(seen[y * w.W + x]){ const d = Math.hypot(x - cx, y - cy); if(d < bd){ bd = d; best = [x, y]; } }
		if(best){ (MOVED[name] = MOVED[name] || {})[k] = [best[0] * CELL + 16, best[1] * CELL + 16]; console.log(`  ${name}: ${k} moved ${bd.toFixed(1)} cells to reachable ground`); }
		else check(k, px, py);
	}
	for(const d of w.doors) check("door to " + d[2], d[0], d[1]);
}

function writeWalk(){
	const specs = fs.readdirSync(path.join(__dirname, "specs")).filter(f => f.endsWith(".js")).sort();
	let body = "";
	for(const f of specs){
		const name = f.replace(/\.js$/, "");
		if(!fs.existsSync(path.join(root, "rooms", name, name + ".yy"))) continue;
		const spec = require(path.join(__dirname, "specs", f));
		const w = roomWalk(name, spec);
		checkReach(name, spec, w);
		const doors = w.doors.map(d => `[${d[0]}, ${d[1]}, "${d[2]}", ${d[3]}, ${d[4]}]`).join(", ");
		body += `\t\t${name}: {w: ${w.W}, h: ${w.H}, doors: [${doors}],\n\t\t\tgrid: "${w.cost.join("")}"},\n`;
	}
	const gml = `// Generated by tools/rooms/walk.js (run by tools/rooms/build.js) from the built rooms - don't edit by hand.
// Where villagers can walk: each room's size in cells, its exits [x, y, room, arrive x, arrive y], and a grid of
// walking costs, one digit per 32px cell row by row ("0" blocked, "1" roads and floors, "3" grass, "9" field soil).

function room_walk(){
	static t = {
${body}	};
	return t;
}
`;
	const dir = path.join(root, "scripts", "room_walk");
	fs.mkdirSync(dir, {recursive: true});
	fs.writeFileSync(path.join(dir, "room_walk.gml"), gml);
	const yy = path.join(dir, "room_walk.yy");
	if(!fs.existsSync(yy)){
		fs.writeFileSync(yy, `{\n  "$GMScript":"v1",\n  "%Name":"room_walk",\n  "isCompatibility":false,\n  "isDnD":false,\n  "name":"room_walk",\n  "parent":{\n    "name":"Scripts",\n    "path":"folders/Scripts.yy",\n  },\n  "resourceType":"GMScript",\n  "resourceVersion":"2.0",\n}`);
		const yypPath = path.join(root, "CedarAndSea.yyp");
		let yyp = fs.readFileSync(yypPath, "utf8");
		const nl = yyp.includes("\r\n") ? "\r\n" : "\n";
		const entry = '    {"id":{"name":"room_walk","path":"scripts/room_walk/room_walk.yy",},},';
		if(!yyp.includes(entry)){ yyp = yyp.replace('"resources":[' + nl, '"resources":[' + nl + entry + nl); fs.writeFileSync(yypPath, yyp); }
	}
}

module.exports = {writeWalk, roomWalk, MOVED};

if(require.main === module) writeWalk();
