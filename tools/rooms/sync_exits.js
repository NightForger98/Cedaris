// Point each house interior's exit at its door outside, from the outdoor spec's exits ({key: [x, y]}) and which
// interior each door leads to. Run after moving houses in an outdoor room:
//   node tools/rooms/sync_exits.js rm_town rm_2 rm_valley rm_beach
const fs = require("fs");
const path = require("path");
for(const room of process.argv.slice(2)){
	const specPath = path.join(__dirname, "specs", room + ".js");
	const spec = require(specPath), exits = spec.exits || {};
	for(const inst of spec.instances){
		if(inst.obj !== "obj_transition") continue;
		const to = (inst.code.match(/targetRoom = (\w+);/) || [])[1];
		const file = path.join(__dirname, "specs", to + ".js");
		if(!to || !fs.existsSync(file)) continue;
		const out = Object.values(exits).find(([x, y]) => x === inst.x && y === inst.y + 36);
		if(!out) continue;
		let s = fs.readFileSync(file, "utf8");
		const re = new RegExp(String.raw`exit: \{room: "` + room + String.raw`", x: \d+, y: \d+\}`);
		if(!re.test(s)) continue;
		s = s.replace(re, `exit: {room: "${room}", x: ${out[0]}, y: ${out[1]}}`);
		fs.writeFileSync(file, s);
		console.log(`${to}: exit to ${room} ${out}`);
	}
}
