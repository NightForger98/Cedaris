// Write the new world's room specs (thin wrappers over tools/world/room.js and interiors.js), check the links agree
// on both sides, and point the reused old interiors' exits at their new doors.
//   node tools/world/make_specs.js
const fs = require("fs");
const path = require("path");
const {ROOMS, GRID} = require("./world.js");
const {NEW, REUSED} = require("./interior_data.js");
const room = require("./room.js");
const SPECS = path.join(__dirname, "..", "rooms", "specs");
const OPP = {l: "r", r: "l", t: "b", b: "t"};

let bad = 0;
for(const id of GRID.flat()){
	for(const [s, k] of Object.entries(ROOMS[id].links || {})){
		const n = room.neighbour(id, s);
		if(!n){ console.log(`${id}: ${s} leads off the map`); bad++; continue; }
		if(k === "rocks" || k === "trees") continue;   // blocked: scenery on this side only
		const back = (ROOMS[n].links || {})[OPP[s]];
		if(back !== k){ console.log(`${id} ${s}=${k} but ${n} ${OPP[s]}=${back}`); bad++; }
	}
}
if(bad) process.exit(1);

const write = (name, body) => {
	const file = path.join(SPECS, name + ".js");
	fs.writeFileSync(file, body);
};
for(const id of []){   // (the old outdoor rooms - replaced by tools/world2's)
	write(id, `// ${ROOMS[id].name} (${id}): generated from the world data - edit tools/world/world.js, not this file.\n` +
		`// Build with: node tools/rooms/build.js ${id}\nmodule.exports = require("../../world/room.js").spec("${id}");\n`);
}
for(const id of Object.keys(NEW)){
	write(id, `// ${id}: a new-world interior - edit tools/world/interior_data.js, not this file.\n` +
		`// Build with: node tools/rooms/build.js ${id}\nmodule.exports = require("../../world/interiors.js")("${id}");\n`);
}

// The reused interiors' exits
for(const [r, [outdoor, key]] of Object.entries(REUSED)){
	const file = path.join(SPECS, r + ".js");
	let s = fs.readFileSync(file, "utf8");
	const ex = require("../world2/areas_build.js").exits()[key];
	if(!ex) throw new Error(`no door for ${key} in the new world`);
	const re = /exit: \{room: "\w+", x: \d+, y: \d+\}/;
	if(!re.test(s)) throw new Error(`${r}: no exit to re-point`);
	s = s.replace(re, `exit: {room: "${ex[0]}", x: ${ex[1]}, y: ${ex[2]}}`);
	fs.writeFileSync(file, s);
}
console.log(`specs: ${Object.keys(NEW).length} new interiors, ${Object.keys(REUSED).length} re-pointed`);
require("../world2/pshop_specs.js");   // the shops on the plots for sale (scripts/pshops)
