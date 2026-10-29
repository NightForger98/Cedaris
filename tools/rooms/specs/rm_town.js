// Brindlemoor (rm_town), the town up the cliff ladder north of the farm. Build with: node tools/rooms/build.js rm_town
// 64 x 44 cells. The town hall stands over a cobbled square in the middle; six houses around it, each with a lane to
// the square; the main street runs south to the top of the farm's ladder. Garrick keeps the watch. Every door leads
// inside (rm_town_*): the hall is Lysa's inn, the sword sign the outfitter, the potion sign the apothecary, the rest homes
// (Edwin, Nell, Hask, and Ida with her son Fen). Posy sells flowers in the square; Garrick keeps the watch.
//
// Map: . grass  : cobbles
module.exports = {
	seed: 33,
	map: [
		"................................................................",
		"................................................................",
		"................................................................",
		"................................................................",
		"................................................................",
		"................................................................",
		"................................................................",
		"................................................................",
		"................................................................",
		"................................................................",
		"...............................:::..............................",
		"...............................:::..............................",
		".......:::::::::::::::::::::::::::::::::::::::::::::::::::::::::",
		".......:::::::::::::::::::::::::::::::::::::::::::::::::::::::::",
		"................::::::::::::::::::::::::::::::::................",
		"................::::::::::::::::::::::::::::::::................",
		"................::::::::::::::::::::::::::::::::................",
		"................::::::::::::::::::::::::::::::::................",
		"................::::::::::::::::::::::::::::::::................",
		"................::::::::::::::::::::::::::::::::................",
		"................::::::::::::::::::::::::::::::::................",
		"................::::::::::::::::::::::::::::::::................",
		"................::::::::::::::::::::::::::::::::................",
		"................::::::::::::::::::::::::::::::::................",
		"................::::::::::::::::::::::::::::::::................",
		"................::::::::::::::::::::::::::::::::................",
		".......::::::::::::::::::::::::::::::::::::::::::::::::::.......",
		".......::::::::::::::::::::::::::::::::::::::::::::::::::.......",
		"..............................::::..............................",
		"..............................::::..............................",
		"..............................::::..............................",
		"..............................::::..............................",
		"..............................::::..............................",
		"..............................::::..............................",
		"..............................::::..............................",
		"..............................::::..............................",
		"..............................::::..............................",
		"..............................::::..............................",
		"..............................::::..............................",
		"..............................::::..............................",
		".........::::::::::::::::::::::::::::::::::::::::::::...........",
		".........::::::::::::::::::::::::::::::::::::::::::::...........",
		"..............................::::..............................",
		"..............................::::..............................",
	],

	things: [
		// The town hall (its roof against the room's top edge), and the houses
		{is: "village_hall", at: [25, 0]}, {is: "sign_inn", at: [29, 7]},
		{is: "house_cream", at: [2, 2]}, {is: "house_thatch", at: [49, 2]}, {is: "sign_sword", at: [53, 10]},
		{is: "house_cream_thatch", at: [2, 16]}, {is: "farmhouse", at: [49, 16]}, {is: "sign_potion", at: [7, 24]},
		{is: "house_thatch", at: [4, 30]}, {is: "house_cream", at: [45, 30]},

		// The square: a statue, the notice board, a market of carts, barrels and crates
		{is: "statue", at: [31, 18]},
		{is: "board_notes", at: [35, 12]}, {is: "signpost", at: [29, 26]},
		{is: "hay_cart", at: [19, 14]}, {is: "barrels", at: [23, 14]}, {is: "crate_open", at: [25, 15]}, {is: "chest", at: [26, 15]},
		{is: "hay_cart", at: [41, 22]}, {is: "barrels", at: [38, 23]}, {is: "barrel", at: [45, 14]}, {is: "barrel", at: [46, 15]},
		{is: "rope_fence", at: [19, 24]}, {is: "rope_fence", at: [22, 24]},
		{is: "wheelbarrow", at: [43, 13]}, {is: "bucket", at: [18, 19]},

		// Gardens and the edges of town
		{is: "clothesline", at: [9, 15]}, {is: "clothesline", at: [52, 29]},
		{is: "oak", at: [16, 1]}, {is: "pine", at: [20, 2]}, {is: "oak", at: [41, 1]}, {is: "pine", at: [45, 3]},
		{is: "bush_big", at: [0, 13]}, {is: "bush_big2", at: [60, 16]}, {is: "oak", at: [61, 27]}, {is: "pine", at: [0, 26]},
		{is: "oak", at: [18, 34]}, {is: "pine", at: [24, 33]}, {is: "sapling", at: [27, 35]}, {is: "oak", at: [36, 34]},
		{is: "pine", at: [40, 33]}, {is: "sapling", at: [36, 30]}, {is: "bush_big", at: [19, 29]}, {is: "bush_big2", at: [41, 29]},
		{is: "pine", at: [0, 40]}, {is: "oak", at: [59, 40]}, {is: "pine", at: [62, 37]},
	],

	scatter: [
		{on: ".", density: 0.05, seed: 8, pieces: [{is: "leaves", weight: 4}, {is: "leaves2", weight: 4}, {is: "mushrooms"}, {is: "sprout", weight: 2}]},
	],

	instances: [
		{obj: "obj_plyr", x: 1024, y: 1320},
		{obj: "camera", x: 1024, y: 1320},
		// East along the lane to North Road (rm_north)
		{obj: "obj_transition", x: 2040, y: 416, sx: 1, sy: 4,
		 code: "targetRoom = rm_north;\ntargetX = 64;\ntargetY = 416;\nPlayerFacingBefore = dir.right;\nPlayerFacingAfter = dir.right;"},
		// Down the main street to the Crossroads
		{obj: "obj_transition", x: 1024, y: 1392, sx: 8, sy: 2,
		 code: "targetRoom = rm_cross;\ntargetX = 1040;\ntargetY = 72;\nPlayerFacingBefore = dir.down;\nPlayerFacingAfter = dir.down;"},
		// The doors: the hall is the inn, the sword sign the outfitter, the potion sign the apothecary, the rest homes
		...[["rm_town_inn", 1056, 304, 4, 352, 408], ["rm_town_home_nw", 272, 368, 2, 256, 312],
		    ["rm_town_outfitter", 1776, 368, 2, 288, 344], ["rm_town_apothecary", 272, 816, 2, 256, 344],
		    ["rm_town_home_e", 1776, 816, 2, 256, 312], ["rm_town_home_sw", 336, 1264, 2, 256, 312],
		    ["rm_town_home_se", 1648, 1264, 2, 256, 312]].map(([to, x, y, sx, tx, ty]) => ({obj: "obj_transition", x, y, sx, sy: 1,
			code: `targetRoom = ${to};\ntargetX = ${tx};\ntargetY = ${ty};\nPlayerFacingBefore = dir.up;\nPlayerFacingAfter = dir.up;`})),
	],

	points: {
		street_south: [1024, 1320],   // coming up the ladder from the farm
		inn_door: [1056, 340], outfitter_door: [1776, 404], apothecary_door: [272, 852],
		// Where the townsfolk spend the day (their schedules in scripts/people)
		watch: [1088, 1250],     // Garrick, at the top of the street down to the farm
		stall: [736, 600],       // Posy's flowers, by the market carts
		square_a: [880, 720], square_b: [960, 760], square_c: [1300, 560], square_d: [1180, 820], square_e: [760, 820],
		square_f: [1120, 480], board: [1150, 430],
	},
	areas: {
		square: [16, 12, 47, 27],
	},
};
