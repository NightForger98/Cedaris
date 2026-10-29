// The farm (rm_1). Build with: node tools/rooms/build.js rm_1
// 77 x 40 cells of 32px (widened 17 to the west so its west edge lines up with Brindlemoor and Hollow Vale). The cliff with the mine's cave runs along the north, a yard with your workbench by the cave;
// the farmhouse is in the west, the field in the middle, the pond in the north-east, the pasture in the south-east and
// woods along the south. The road east leads to the village. Only you live here: villagers cross the farm on their
// way between the town, the village, the coast and the vale (see the schedules in scripts/people).
//
// Map: . grass  , dirt  = field soil  ~ water  X cliff (solid). See tools/rooms/tiles.js for the rest.
module.exports = {
	seed: 11,
	map: [
		"XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX,XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
		"XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX,XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
		"XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX,XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
		"XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX,XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
		",,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,",
		",,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,",
		",,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,",
		"...............................................,,,,,,,,,.......~~~~~~~.......",
		"...............................................,,,,,,,,,......~~~~~~~~~~.....",
		"...............................................,,,,,,,,,......~~~~~~~~~~.....",
		"..............................................................~~~~~~~~~~.....",
		"..............................................................~~~~~~~~~~.....",
		"..............................................................~~~~~~~~~~.....",
		"................................................................~~~~~~.......",
		".............................................................................",
		".............................................................................",
		".............................................................................",
		",,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,",
		",,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,",
		"..................,,,,,,,,,,,,,,,,,..........................................",
		".............................................................................",
		"...................................========================..................",
		"...................................========================..................",
		"...................................========================..................",
		"...................................========================..................",
		"...................................========================..................",
		"...................................========================..................",
		"...................................========================..................",
		"...................................========================..................",
		"...................................========================..................",
		"...................................========================..................",
		"...................................========================..................",
		".......................................,,....................................",
		".......................................,,....................................",
		".......................................,,....................................",
		".......................................,,....................................",
		".......................................,,....................................",
		".......................................,,....................................",
		".......................................,,....................................",
		".......................................,,....................................",
	],

	things: [
		// The cliff along the north edge: the ladder up to Brindlemoor (the town), and the cave into the mine
		{is: "cliff", at: [0, 0]}, {is: "cliff", at: [5, 0]}, {is: "cliff", at: [17, 0]}, {is: "cliff_ladder", at: [29, 0]}, {is: "cliff", at: [35, 0]}, {is: "cliff_cave", at: [41, 0]},
		{is: "cliff", at: [43, 0]}, {is: "cliff", at: [55, 0]}, {is: "cliff", at: [67, 0]},

		// Home
		{is: "farmhouse", at: [19, 7]},
		{is: "barrels", at: [32, 13]}, {is: "barrel", at: [18, 14]}, {is: "wheelbarrow", at: [32, 9]},
		{is: "hay_bale", at: [17, 19]}, {is: "clothesline", at: [20, 20]},

		// The yard under the cliff, by the workbench
		{is: "barrels", at: [54, 6]}, {is: "crate_open", at: [47, 7]}, {is: "chest", at: [46, 7]},

		// The field: a scarecrow, and the cart at its corner
		{is: "scarecrow", at: [46, 25]}, {is: "hay_cart", at: [35, 19]},

		// The pond
		{is: "cattails", at: [61, 9]}, {is: "cattails", at: [72, 11]},

		// The pasture, fenced top and bottom
		{is: "picket", at: [61, 20]}, {is: "picket", at: [64, 20]}, {is: "picket", at: [70, 20]}, {is: "picket", at: [73, 20]},
		{is: "picket", at: [61, 32]}, {is: "picket", at: [64, 32]}, {is: "picket", at: [67, 32]}, {is: "picket", at: [70, 32]},
		{is: "picket", at: [73, 32]}, {is: "hay_bale", at: [74, 23]}, {is: "bucket", at: [73, 26]},

		// Woods along the south edge, and a few trees around the edges
		{is: "pine", at: [17, 34]}, {is: "oak", at: [19, 35]}, {is: "pine", at: [22, 33]}, {is: "oak", at: [25, 36]},
		{is: "pine", at: [28, 34]}, {is: "sapling", at: [30, 36]}, {is: "oak", at: [32, 35]}, {is: "pine", at: [35, 34]},
		{is: "oak", at: [36, 36]}, {is: "pine", at: [42, 35]}, {is: "oak", at: [44, 35]}, {is: "pine", at: [47, 33]},
		{is: "sapling", at: [50, 36]}, {is: "oak", at: [52, 35]}, {is: "pine", at: [55, 34]}, {is: "oak", at: [58, 36]},
		{is: "pine", at: [61, 35]}, {is: "oak", at: [64, 35]}, {is: "pine", at: [67, 34]}, {is: "oak", at: [70, 36]},
		{is: "pine", at: [73, 34]}, {is: "pine", at: [75, 35]},
		// The west strip: woods along the south, a few trees by the road to the coast
		{is: "oak", at: [0, 34]}, {is: "pine", at: [3, 33]}, {is: "oak", at: [6, 35]}, {is: "pine", at: [9, 34]}, {is: "oak", at: [12, 36]},
		{is: "pine", at: [15, 33]}, {is: "oak", at: [2, 9]}, {is: "pine", at: [8, 7]}, {is: "bush_big", at: [12, 12]}, {is: "oak", at: [5, 22]},
		{is: "bush_big", at: [74, 6]}, {is: "bush_big2", at: [58, 7]}, {is: "oak", at: [17, 22]}, {is: "pine", at: [74, 10]},
	],

	scatter: [
		{on: ".", density: 0.05, seed: 3, pieces: [{is: "leaves", weight: 4}, {is: "leaves2", weight: 4}, {is: "mushrooms"}, {is: "sprout", weight: 2}]},
		{on: "~", density: 0.08, seed: 5, pieces: [{is: "lilypads"}, {is: "lilypads2"}]},
	],

	instances: [
		{obj: "obj_plyr", x: 816, y: 592},
		{obj: "camera", x: 816, y: 592},
		{obj: "obj_mine_door", x: 1344, y: 140},
		{obj: "obj_crafting_table", x: 1608, y: 312},
		{obj: "obj_shipping_bin", x: 1084, y: 520},
		// The farmhouse door, the road to the village
		{obj: "obj_transition", x: 816, y: 528, sx: 2, sy: 1,
		 code: "targetRoom = rm_12;\ntargetX = 160;\ntargetY = 472;\nPlayerFacingBefore = dir.up;\nPlayerFacingAfter = dir.up;"},
		{obj: "obj_transition", x: 2456, y: 576, sx: 1, sy: 4,
		 code: "targetRoom = rm_2;\ntargetX = 48;\ntargetY = 576;\nPlayerFacingBefore = dir.right;\nPlayerFacingAfter = dir.right;"},
		// Up the ladder to Brindlemoor, the road west to the coast, the path south to Hollow Vale
		{obj: "obj_transition", x: 1040, y: 16, sx: 2, sy: 2,
		 code: "targetRoom = rm_town;\ntargetX = 1040;\ntargetY = 1320;\nPlayerFacingBefore = dir.up;\nPlayerFacingAfter = dir.up;"},
		{obj: "obj_transition", x: 8, y: 576, sx: 1, sy: 4,
		 code: "targetRoom = rm_beach;\ntargetX = 1480;\ntargetY = 2048;\nPlayerFacingBefore = dir.left;\nPlayerFacingAfter = dir.left;"},
		{obj: "obj_transition", x: 1280, y: 1272, sx: 4, sy: 1,
		 code: "targetRoom = rm_valley;\ntargetX = 1280;\ntargetY = 72;\nPlayerFacingBefore = dir.down;\nPlayerFacingAfter = dir.down;"},
	],

	// Named spots for scripts (scripts/room_layout): points in pixels, areas in cells [c1, r1, c2, r2]
	points: {
		start: [816, 592],      // a new game, in front of the farmhouse
		door: [816, 564],       // back out of the farmhouse
		cave: [1344, 168],       // climbing out of the mine
		road_east: [2400, 576], // arriving from the village
		ladder: [1040, 152],     // down the ladder from the town
		road_west: [56, 576],    // arriving from the coast
		path_south: [1280, 1208],// back from the valley
	},
	areas: {
		cliff_west: [19, 4, 38, 6],    // rocks and ore under the cliff, either side of the cave
		cliff_east: [45, 4, 74, 6],
		meadow: [33, 8, 45, 15],      // weeds and bushes between the house and the yard
		west: [18, 21, 33, 31],        // the grass west of the field
		woods: [18, 32, 33, 34],       // a young wood at the woods' edge, west of the field
		pasture: [61, 22, 73, 30],    // where animals roam
		field: [35, 21, 58, 31],
		far_west: [1, 20, 15, 31],   // the west strip, between the road and the woods
	},
};
