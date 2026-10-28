// The village (rm_2). Build with: node tools/rooms/build.js rm_2
// 56 x 36 cells of 32px. The hall stands on the north side of a cobbled square (the notice board is by its door);
// Elda's house is in the north-west, Thorne's and a neighbour's along a lane in the south. The road west goes back
// to the farm; the river runs down the east side, with the bridge to Whisperwood (obj_path draws it).
//
// Map: . grass  , dirt  : cobbles  ~ water. See tools/rooms/tiles.js for the rest.
module.exports = {
	seed: 22,
	map: [
		"............................................~~~.........",
		"............................................~~~.........",
		"............................................~~~.........",
		"............................................~~~.........",
		"............................................~~~.........",
		"............................................~~~.........",
		"............................................~~~.........",
		"............................................~~~.........",
		"............................................~~~.........",
		"............................................~~~.........",
		"..............::::::::::::::::::::::::::::..~~~.........",
		"..............::::::::::::::::::::::::::::..~~~.........",
		"..............::::::::::::::::::::::::::::..~~~.........",
		".......,,,....::::::::::::::::::::::::::::..~~~.........",
		".......,,,....::::::::::::::::::::::::::::..~~~.........",
		".......,,,....::::::::::::::::::::::::::::..~~~.........",
		".......,,,....::::::::::::::::::::::::::::..~~~.........",
		",,,,,,,,,,,,,,::::::::::::::::::::::::::::,,~~~.........",
		",,,,,,,,,,,,,,::::::::::::::::::::::::::::,,~~~.........",
		"..............::::::::::::::::::::::::::::..~~~.........",
		"..............::::::::::::::::::::::::::::..~~~.........",
		"..............::::::::::::::::::::::::::::..~~~.........",
		"...............................,,,..........~~~.........",
		"...............................,,,..........~~~.........",
		"...............................,,,..........~~~.........",
		"...............................,,,..........~~~.........",
		"...............................,,,..........~~~.........",
		"...............................,,,..........~~~.........",
		"...............................,,,..........~~~.........",
		"...............................,,,..........~~~.........",
		"...............................,,,..........~~~.........",
		"........,,,....................,,,..........~~~.........",
		"........,,,....................,,,..........~~~.........",
		"..,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,..........~~~.........",
		"..,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,..........~~~.........",
		"............................................~~~.........",
	],

	things: [
		// The hall, its top against the room's edge (the captured art has no roof peak), and the houses
		{is: "village_hall", at: [20, 0]}, {is: "sign_inn", at: [25, 7]},
		{is: "house_cream", at: [2, 3]}, {is: "sign_potion", at: [7, 11]},
		{is: "house_thatch", at: [3, 21]},
		{is: "house_cream_thatch", at: [18, 23]},

		// The square: a statue in the middle, the notice board by the hall door, barrels and a cart
		{is: "statue", at: [27, 15]},
		{is: "board_notes", at: [30, 10]},
		{is: "barrels", at: [36, 10]}, {is: "barrel", at: [38, 10]}, {is: "hay_cart", at: [37, 19]},
		{is: "crate_open", at: [15, 10]}, {is: "chest", at: [16, 10]},
		{is: "signpost", at: [13, 16]},

		// Gardens and yards
		{is: "clothesline", at: [10, 32]}, {is: "barrel", at: [16, 29]}, {is: "wheelbarrow", at: [0, 29]},
		{is: "bush_big", at: [33, 2]}, {is: "bush_big2", at: [36, 3]}, {is: "oak", at: [16, 2]},
		{is: "sapling", at: [40, 24]}, {is: "oak", at: [36, 26]}, {is: "pine", at: [40, 29]},
		{is: "cattails", at: [43, 4]}, {is: "cattails", at: [43, 27]}, {is: "cattails", at: [47, 12]},

		// Whisperwood's edge across the river
		{is: "pine", at: [48, 0]}, {is: "pine", at: [51, 2]}, {is: "oak", at: [53, 0]}, {is: "pine", at: [49, 6]},
		{is: "oak", at: [52, 8]}, {is: "pine", at: [54, 11]}, {is: "pine", at: [48, 21]}, {is: "oak", at: [51, 22]},
		{is: "pine", at: [54, 24]}, {is: "pine", at: [48, 28]}, {is: "oak", at: [51, 30]}, {is: "pine", at: [54, 31]},
		{is: "sapling", at: [53, 16]}, {is: "bush_big", at: [49, 15]},
	],

	scatter: [
		{on: ".", density: 0.05, seed: 4, pieces: [{is: "leaves", weight: 4}, {is: "leaves2", weight: 4}, {is: "mushrooms"}, {is: "toadstool"}, {is: "sprout", weight: 2}]},
		{on: "~", density: 0.06, seed: 6, pieces: [{is: "lilypads"}, {is: "lilypads2"}]},
	],

	instances: [
		{obj: "obj_plyr", x: 64, y: 576},
		{obj: "camera", x: 64, y: 576},
		{obj: "obj_quest_board", x: 976, y: 362},
		{obj: "obj_path", x: 1416, y: 592},
		{obj: "obj_npc_womantest", x: 352, y: 470},
		{obj: "obj_npc_mantest", x: 416, y: 1080},
		// The road back to the farm
		{obj: "obj_transition", x: 8, y: 576, sx: 1, sy: 4,
		 code: "targetRoom = rm_1;\ntargetX = 1856;\ntargetY = 576;\nPlayerFacingBefore = dir.left;\nPlayerFacingAfter = dir.left;"},
	],

	points: {
		road_west: [64, 576],    // arriving from the farm
		bridge: [1370, 592],     // back from Whisperwood
		crowd: [560, 400],       // where visitors stand on a festival day (a 4-wide grid from here)
		river: [1456, 0],        // lanterns float down from here on Lantern Night
	},
	areas: {
		square: [14, 10, 41, 21],  // the cobbled square: bunting on festival days
	},
};
