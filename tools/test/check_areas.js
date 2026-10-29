// How much of each resource spawn area (resource_areas in scripts/gathering) is road (a path or cobbles on the map),
// blocked, or free ground.
// Rocks and trees spawned on a road could block a villager's route.
//   node tools/test/check_areas.js
const fs = require("fs");
const gml = fs.readFileSync("scripts/gathering/gathering.gml", "utf8");
const walk = fs.readFileSync("scripts/room_walk/room_walk.gml", "utf8");
const grid = {};
for(const m of walk.matchAll(/(\w+): \{w: (\d+), h: (\d+), doors: [^\n]*\n\t*grid: "([0-9]+)"/g)) grid[m[1]] = {w: +m[2], h: +m[3], g: m[4]};
for(const m of gml.matchAll(/room: "(\w+)", cells: layout_cells\("\w+", "(\w+)"\)/g)){
	const [, room, area] = m, spec = require("../rooms/specs/" + room + ".js"), a = spec.areas[area];
	if(!a){ console.log(`${room}.${area}: MISSING AREA`); continue; }
	const G = grid[room]; let road = 0, blocked = 0, free = 0;
	for(let y = a[1]; y <= a[3]; y++) for(let x = a[0]; x <= a[2]; x++){
		const c = G.g[y * G.w + x], ch = (spec.map[y] || "")[x];
		if(c === "0") blocked++; else if(ch === "," || ch === ":" || ch === "b") road++; else free++;
	}
	const n = road + blocked + free;
	console.log(`${(room + "." + area).padEnd(24)} ${String(n).padStart(4)} cells: ${free} free, ${road} road${road ? " <--" : ""}, ${blocked} blocked`);
}
