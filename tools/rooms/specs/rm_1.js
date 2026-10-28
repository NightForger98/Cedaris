// The farm (rm_1). Build with: node tools/rooms/build.js rm_1
// 60 x 40 cells of 32px. The cliff with the mine's cave runs along the north; Brom's smithy is by the cave; the
// farmhouse is in the west, the field in the middle, the pond in the north-east, the pasture in the south-east and
// woods along the south. The road east leads to the village.
//
// Map: . grass  , dirt  = field soil  ~ water  X cliff (solid). See tools/rooms/tiles.js for the rest.
module.exports = {
	seed: 11,
	map: [
		"XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
		"XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
		"XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
		"XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
		",,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,",
		",,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,",
		",,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,",
		"..............................,,,,,,,,,.......~~~~~~~.......",
		"..............................,,,,,,,,,......~~~~~~~~~~.....",
		"..............................,,,,,,,,,......~~~~~~~~~~.....",
		".............................................~~~~~~~~~~.....",
		".............................................~~~~~~~~~~.....",
		".............................................~~~~~~~~~~.....",
		"...............................................~~~~~~.......",
		"............................................................",
		"............................................................",
		"............................................................",
		".,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,",
		".,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,",
		".,,,,,,,,,,,,,,,,,..........................................",
		"............................................................",
		"..................========================..................",
		"..................========================..................",
		"..................========================..................",
		"..................========================..................",
		"..................========================..................",
		"..................========================..................",
		"..................========================..................",
		"..................========================..................",
		"..................========================..................",
		"..................========================..................",
		"..................========================..................",
		"............................................................",
		"............................................................",
		"............................................................",
		"............................................................",
		"............................................................",
		"............................................................",
		"............................................................",
		"............................................................",
	],

	things: [
		// The cliff along the north edge, with the cave in it
		{is: "cliff", at: [0, 0]}, {is: "cliff", at: [12, 0]}, {is: "cliff_cave", at: [24, 0]},
		{is: "cliff", at: [26, 0]}, {is: "cliff", at: [38, 0]}, {is: "cliff", at: [50, 0]},

		// Home
		{is: "farmhouse", at: [2, 7]},
		{is: "barrels", at: [15, 13]}, {is: "barrel", at: [1, 14]}, {is: "wheelbarrow", at: [15, 9]},
		{is: "hay_bale", at: [0, 19]}, {is: "clothesline", at: [3, 20]},

		// Brom's smithy yard
		{is: "barrels", at: [37, 6]}, {is: "crate_open", at: [30, 7]}, {is: "chest", at: [29, 7]},

		// The field: a scarecrow, and the cart at its corner
		{is: "scarecrow", at: [29, 25]}, {is: "hay_cart", at: [18, 19]},

		// The pond
		{is: "cattails", at: [44, 9]}, {is: "cattails", at: [55, 11]},

		// The pasture, fenced top and bottom
		{is: "picket", at: [44, 20]}, {is: "picket", at: [47, 20]}, {is: "picket", at: [53, 20]}, {is: "picket", at: [56, 20]},
		{is: "picket", at: [44, 32]}, {is: "picket", at: [47, 32]}, {is: "picket", at: [50, 32]}, {is: "picket", at: [53, 32]},
		{is: "picket", at: [56, 32]}, {is: "hay_bale", at: [57, 23]}, {is: "bucket", at: [56, 26]},

		// Woods along the south edge, and a few trees around the edges
		{is: "pine", at: [0, 34]}, {is: "oak", at: [2, 35]}, {is: "pine", at: [5, 33]}, {is: "oak", at: [8, 36]},
		{is: "pine", at: [11, 34]}, {is: "sapling", at: [13, 36]}, {is: "oak", at: [15, 35]}, {is: "pine", at: [18, 34]},
		{is: "oak", at: [21, 36]}, {is: "pine", at: [24, 34]}, {is: "oak", at: [27, 35]}, {is: "pine", at: [30, 33]},
		{is: "sapling", at: [33, 36]}, {is: "oak", at: [35, 35]}, {is: "pine", at: [38, 34]}, {is: "oak", at: [41, 36]},
		{is: "pine", at: [44, 35]}, {is: "oak", at: [47, 35]}, {is: "pine", at: [50, 34]}, {is: "oak", at: [53, 36]},
		{is: "pine", at: [56, 34]}, {is: "pine", at: [58, 35]},
		{is: "bush_big", at: [57, 6]}, {is: "bush_big2", at: [41, 7]}, {is: "oak", at: [0, 22]}, {is: "pine", at: [57, 10]},
	],

	scatter: [
		{on: ".", density: 0.05, seed: 3, pieces: [{is: "leaves", weight: 4}, {is: "leaves2", weight: 4}, {is: "mushrooms"}, {is: "sprout", weight: 2}]},
		{on: "~", density: 0.08, seed: 5, pieces: [{is: "lilypads"}, {is: "lilypads2"}]},
	],

	instances: [
		{obj: "obj_plyr", x: 272, y: 592},
		{obj: "camera", x: 272, y: 592},
		{obj: "obj_mine_door", x: 800, y: 140},
		{obj: "obj_npc_blacksmith", x: 1024, y: 256},
		{obj: "obj_furnace", x: 1128, y: 264},
		{obj: "obj_crafting_table", x: 1064, y: 312},
		{obj: "obj_shipping_bin", x: 540, y: 520},
		{obj: "obj_npc_seller", x: 720, y: 520},
		{obj: "obj_npc_mantest", x: 640, y: 664},
		{obj: "obj_npc_womantest", x: 1350, y: 560},
		// The farmhouse door, the road to the village
		{obj: "obj_transition", x: 272, y: 528, sx: 2, sy: 1,
		 code: "targetRoom = rm_12;\ntargetX = 350;\ntargetY = 570;\nPlayerFacingBefore = dir.up;\nPlayerFacingAfter = dir.up;"},
		{obj: "obj_transition", x: 1912, y: 576, sx: 1, sy: 4,
		 code: "targetRoom = rm_2;\ntargetX = 48;\ntargetY = 576;\nPlayerFacingBefore = dir.right;\nPlayerFacingAfter = dir.right;"},
	],

	// Named spots for scripts (scripts/room_layout): points in pixels, areas in cells [c1, r1, c2, r2]
	points: {
		start: [272, 592],      // a new game, in front of the farmhouse
		door: [272, 564],       // back out of the farmhouse
		cave: [800, 168],       // climbing out of the mine
		road_east: [1856, 576], // arriving from the village
	},
	areas: {
		cliff_west: [2, 4, 21, 6],    // rocks and ore under the cliff, either side of the cave
		cliff_east: [28, 4, 57, 6],
		meadow: [16, 8, 28, 15],      // weeds and bushes between the house and the smithy
		west: [1, 21, 16, 31],        // the grass west of the field
		woods: [1, 32, 16, 34],       // a young wood at the woods' edge, west of the field
		pasture: [44, 22, 56, 30],    // where animals roam
		field: [18, 21, 41, 31],
	},
};
