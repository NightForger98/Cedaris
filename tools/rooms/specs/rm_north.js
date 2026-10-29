// North Road (rm_north), the empty land north of the village and east of Brindlemoor. Build with:
// node tools/rooms/build.js rm_north
// 68 x 44 cells, the same height as Brindlemoor. For now only the road: in from Brindlemoor's east lane (rows 12-13),
// then south down to the village's north road. The room sits on the world map right of the town and above the
// village, so the south exit lines up 400px right of the village's road (see tools/rooms/worldmap.js).
//
// The village river comes up from the bottom edge (cols 57-59, just right of the village's cols 44-46 once the
// 400px offset is added) and bends east, leaving by the right edge (rows 27-29) - a quarter circle round (68, 40).
//
// The cliff along the north edge (from the farm, which moved below Hollow Vale): the ladder is only scenery for now,
// and the cave is the way into the mine (obj_mine_door; you climb back out here). Rocks and ore turn up on the dirt
// under the cliff (areas cliff_west and cliff_east, see resource_areas in scripts/gathering).
//
// Map: . grass  , dirt  ~ water  X cliff (solid)
const W = 68, H = 44;
const map = [];
for(let r = 0; r < H; r++){
	let row = "";
	for(let c = 0; c < W; c++){
		const lane = (r === 12 || r === 13) && c <= 54;      // west to Brindlemoor
		const down = (c >= 52 && c <= 54) && r >= 12;        // south to the village
		const d = Math.hypot(c - 68, r - 40);
		const bend = c <= 68 && r <= 41 && d >= 8.0 && d <= 12.2;  // the bend: 4 cells wide (the tiles need water 2+ thick)
		const up = r > 40 && c >= 57 && c <= 59;                  // straight on down to the village
		const cliff = r <= 3, foot = r >= 4 && r <= 6, toCave = (c === 30 || c === 31) && r >= 7 && r <= 11;
		row += cliff ? "X" : (bend || up) ? "~" : (lane || down || foot || toCave) ? "," : ".";
	}
	map.push(row);
}

const woods = require("../woods.js"), taken = new Set();

module.exports = {
	seed: 77,
	map,
	things: [
		{is: "cliff", at: [0, 0]}, {is: "cliff_ladder", at: [12, 0]}, {is: "cliff", at: [18, 0]}, {is: "cliff_cave", at: [30, 0]},
		{is: "cliff", at: [32, 0]}, {is: "cliff", at: [44, 0]}, {is: "cliff", at: [56, 0]},
		// Trees between the cliff and the lane, and a wide meadow of copses south of it
		...woods(map, [0, 7, 28, 11], 4, 31, undefined, taken), ...woods(map, [34, 7, 67, 11], 5, 32, undefined, taken),
		...woods(map, [0, 15, 50, 43], 30, 33, undefined, taken), ...woods(map, [56, 15, 67, 43], 6, 34, undefined, taken),
		{is: "stump", at: [20, 20]}, {is: "signpost", at: [55, 14]},
	],
	scatter: [
		{on: ".", density: 0.04, seed: 7, pieces: [{is: "leaves", weight: 4}, {is: "leaves2", weight: 4}, {is: "sprout", weight: 2}]},
		{on: "~", density: 0.06, seed: 8, pieces: [{is: "lilypads"}, {is: "lilypads2"}]},
	],
	instances: [
		{obj: "obj_plyr", x: 64, y: 416},
		{obj: "camera", x: 64, y: 416},
		{obj: "obj_mine_door", x: 992, y: 140},
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
		cave: [992, 168],          // climbing out of the mine
	},
	areas: {
		cliff_west: [1, 4, 27, 6],   // rocks and ore under the cliff, either side of the cave
		cliff_east: [34, 4, 66, 6],
		meadow_w: [2, 15, 50, 42],   // wood, stones and forage south of the lane
		meadow_e: [56, 15, 66, 26],  // east of the road, above the river
	},
};
