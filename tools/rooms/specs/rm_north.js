// North Road (rm_north), the empty land north of the village and east of Brindlemoor. Build with:
// node tools/rooms/build.js rm_north
// 68 x 44 cells, the same height as Brindlemoor. For now only the road: in from Brindlemoor's east lane (rows 12-13),
// then south down to the village's north road. The room sits on the world map right of the town and above the
// village, so the south exit lines up 400px right of the village's road (see tools/rooms/worldmap.js).
//
// Map: . grass  , dirt
const W = 68, H = 44;
const map = [];
for(let r = 0; r < H; r++){
	let row = "";
	for(let c = 0; c < W; c++){
		const lane = (r === 12 || r === 13) && c <= 54;      // west to Brindlemoor
		const down = (c >= 52 && c <= 54) && r >= 12;        // south to the village
		row += (lane || down) ? "," : ".";
	}
	map.push(row);
}

module.exports = {
	seed: 77,
	map,
	things: [],
	scatter: [
		{on: ".", density: 0.04, seed: 7, pieces: [{is: "leaves", weight: 4}, {is: "leaves2", weight: 4}, {is: "sprout", weight: 2}]},
	],
	instances: [
		{obj: "obj_plyr", x: 64, y: 416},
		{obj: "camera", x: 64, y: 416},
		// West to Brindlemoor's east lane
		{obj: "obj_transition", x: 8, y: 416, sx: 1, sy: 4,
		 code: "targetRoom = rm_town;\ntargetX = 1984;\ntargetY = 416;\nPlayerFacingBefore = dir.left;\nPlayerFacingAfter = dir.left;"},
		// South to the village's north road
		{obj: "obj_transition", x: 1712, y: 1400, sx: 6, sy: 1,
		 code: "targetRoom = rm_2;\ntargetX = 1296;\ntargetY = 72;\nPlayerFacingBefore = dir.down;\nPlayerFacingAfter = dir.down;"},
	],
	points: {
		road_west: [64, 416],      // arriving from Brindlemoor
		road_south: [1696, 1336],  // arriving from the village
	},
	areas: {},
};
