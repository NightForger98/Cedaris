// A building from the library (tools/rooms/buildings.json) placed in a room spec, with the way in at its door.
//
//   const house = require("../house.js");
//   const inn = house("brick_hall", [27, 1], "rm_town_inn");
//   things: [inn.thing], instances: [inn.transition], and the interior's exit: inn.out
//
// door: the doorway's middle in pixels (where the exit goes); out: where you stand coming back out (just below it,
// facing down) - give it to the interior spec's exit. Without a room it's only the building (no way in).
const path = require("path");
const library = require("./buildings.json");

module.exports = function house(name, at, room){
	const b = library[name];
	if(!b) throw new Error("no building " + name + " in tools/rooms/buildings.json");
	const d = b.door || [Math.floor(b.src[2] / 2), b.src[3] - 1];
	const x = (at[0] + d[0]) * 32 + 16, y = (at[1] + d[1]) * 32 + 16;
	const h = {thing: {is: name, at}, door: [x, y], out: [x, y + 36]};
	if(room){
		const inside = require(path.join(__dirname, "specs", room + ".js")).points.door;
		h.transition = {obj: "obj_transition", x, y, sx: 2, sy: 1,
			code: `targetRoom = ${room};\ntargetX = ${inside[0]};\ntargetY = ${inside[1]};\nPlayerFacingBefore = dir.up;\nPlayerFacingAfter = dir.up;`};
	}
	return h;
};
