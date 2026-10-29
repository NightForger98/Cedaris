// South Road (rm_south), the empty land south of the village and east of Hollow Vale. Build with:
// node tools/rooms/build.js rm_south
// 56 x 55 cells: the village's width, from under the village down to the bottom of Hollow Vale. For now only the road
// and the river. The village's south road comes in at the top (cols 31-33), runs down and turns west, leaving by the
// left edge (rows 18-19) for the lane into the vale. The village river comes in at the top (cols 44-46), runs down the
// east side and turns west below the road, leaving by the left edge (rows 28-30) into the vale's river.
//
// Map: . grass  , dirt  ~ water
const W = 56, H = 55;
const map = [];
for(let r = 0; r < H; r++){
	let row = "";
	for(let c = 0; c < W; c++){
		const down = c >= 31 && c <= 33 && r <= 19;          // down from the village
		const west = (r === 18 || r === 19) && c <= 33;      // west to the vale
		// The river: down at cols 44-46, then west at rows 28-30
		const river = (c >= 44 && c <= 46 && r <= 30) || (r >= 28 && r <= 30 && c <= 46);
		row += river ? "~" : (down || west) ? "," : ".";
	}
	map.push(row);
}

module.exports = {
	seed: 88,
	map,
	things: [],
	scatter: [
		{on: ".", density: 0.05, seed: 12, pieces: [{is: "leaves", weight: 4}, {is: "leaves2", weight: 4}, {is: "mushrooms"}, {is: "sprout", weight: 2}]},
		{on: "~", density: 0.06, seed: 13, pieces: [{is: "lilypads"}, {is: "lilypads2"}]},
	],

	instances: [
		{obj: "obj_plyr", x: 1040, y: 72},
		{obj: "camera", x: 1040, y: 72},
		// Up the road to the village, west along it into Hollow Vale
		{obj: "obj_transition", x: 1040, y: 8, sx: 6, sy: 1,
		 code: "targetRoom = rm_2;\ntargetX = 1040;\ntargetY = 1536;\nPlayerFacingBefore = dir.up;\nPlayerFacingAfter = dir.up;"},
		{obj: "obj_transition", x: 8, y: 608, sx: 1, sy: 4,
		 code: "targetRoom = rm_valley;\ntargetX = 2400;\ntargetY = 928;\nPlayerFacingBefore = dir.left;\nPlayerFacingAfter = dir.left;"},
	],

	points: {
		road_north: [1040, 72],  // in from the village
		road_west: [64, 608],    // in from Hollow Vale
	},
	areas: {},
};
