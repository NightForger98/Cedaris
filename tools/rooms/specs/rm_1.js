// The farm (rm_1), at the foot of Hollow Vale. Build with: node tools/rooms/build.js rm_1
// 77 x 40 cells of 32px. The path comes down from the vale at the top to the lane across the farm. The farmhouse is in
// the west and the field in the middle (both where they always were, so saves keep their crops); the barn with its silo
// stands in the north-east with the coop and the granary below it round the pasture, the windmill and a beehive shed
// in the north-west, the pond in the west meadow and woods along the south. Only you live here. Buildings from the farm
// pack ([LPC] Farm, the building library in tools/buildings) apart from the farmhouse (the cottage kit).
//
// Map: . grass  , dirt  = field soil  ~ water. See tools/rooms/tiles.js for the rest.
const W = 77, H = 40;
// The pond: [row, first col, last col]
const pond = [[23, 6, 11], [24, 5, 12], [25, 4, 13], [26, 4, 13], [27, 4, 13], [28, 5, 12], [29, 6, 11]];
const map = [];
for(let r = 0; r < H; r++){
	const row = Array(W).fill(".");
	const put = (c1, c2, ch) => { for(let c = c1; c <= c2; c++) row[c] = ch; };
	if(r <= 16) put(39, 41, ",");                  // the path down from the vale
	if(r === 17 || r === 18) put(15, 75, ",");     // the lane across the farm
	if(r === 19) put(18, 34, ",");                 // in front of the farmhouse
	if(r >= 14 && r <= 16) put(59, 75, ",");       // the barnyard
	if(r >= 21 && r <= 31) put(35, 58, "=");       // the field
	for(const [pr, c1, c2] of pond) if(pr === r) put(c1, c2, "~");
	map.push(row.join(""));
}

module.exports = {
	seed: 11,
	map,

	things: [
		// Home
		{is: "farmhouse", at: [19, 7]},
		{is: "barrels", at: [32, 13]}, {is: "barrel", at: [18, 14]}, {is: "wheelbarrow", at: [32, 9]},
		{is: "hay_bale", at: [17, 19]}, {is: "clothesline", at: [20, 20]},

		// The field: a scarecrow, and the cart at its corner
		{is: "scarecrow", at: [46, 25]}, {is: "hay_cart", at: [35, 19]},

		// The barn and its silo, an open shed beside them
		{is: "barn", at: [61, 2]}, {is: "silo", at: [57, 7]}, {is: "shed", at: [50, 1]},
		// The coop and the granary, and the pasture between them and the woods (fenced along the bottom)
		{is: "coop", at: [60, 19]}, {is: "granary", at: [70, 19]},
		{is: "picket", at: [60, 32]}, {is: "picket", at: [63, 32]}, {is: "picket", at: [66, 32]}, {is: "picket", at: [69, 32]},
		{is: "picket", at: [72, 32]}, {is: "hay_bale", at: [74, 28]}, {is: "bucket", at: [69, 29]},

		// The windmill and the beehive shed, in the north-west
		{is: "windmill", at: [3, 1]}, {is: "bee_shed", at: [11, 2]}, {is: "outhouse", at: [16, 3]},

		// The pond
		{is: "cattails", at: [3, 25]}, {is: "cattails", at: [14, 27]},

		// Woods along the south edge, and a few trees around the edges
		{is: "pine", at: [17, 34]}, {is: "oak", at: [19, 35]}, {is: "pine", at: [22, 33]}, {is: "oak", at: [25, 36]},
		{is: "pine", at: [28, 34]}, {is: "sapling", at: [30, 36]}, {is: "oak", at: [32, 35]}, {is: "pine", at: [35, 34]},
		{is: "oak", at: [36, 36]}, {is: "pine", at: [39, 34]}, {is: "pine", at: [42, 35]}, {is: "oak", at: [44, 35]},
		{is: "pine", at: [47, 33]}, {is: "sapling", at: [50, 36]}, {is: "oak", at: [52, 35]}, {is: "pine", at: [55, 34]},
		{is: "oak", at: [58, 36]}, {is: "pine", at: [61, 35]}, {is: "oak", at: [64, 35]}, {is: "pine", at: [67, 34]},
		{is: "oak", at: [70, 36]}, {is: "pine", at: [73, 34]}, {is: "pine", at: [75, 35]},
		{is: "oak", at: [0, 34]}, {is: "pine", at: [3, 33]}, {is: "oak", at: [6, 35]}, {is: "pine", at: [9, 34]}, {is: "oak", at: [12, 36]},
		{is: "pine", at: [15, 33]}, {is: "oak", at: [17, 22]}, {is: "pine", at: [34, 1]}, {is: "oak", at: [45, 2]},
		{is: "pine", at: [0, 16]}, {is: "oak", at: [75, 16]},
	],

	scatter: [
		{on: ".", density: 0.05, seed: 3, pieces: [{is: "leaves", weight: 4}, {is: "leaves2", weight: 4}, {is: "mushrooms"}, {is: "sprout", weight: 2}]},
		{on: "~", density: 0.08, seed: 5, pieces: [{is: "lilypads"}, {is: "lilypads2"}]},
	],

	instances: [
		{obj: "obj_plyr", x: 816, y: 592},
		{obj: "camera", x: 816, y: 592},
		{obj: "obj_crafting_table", x: 1150, y: 360},
		{obj: "obj_shipping_bin", x: 1084, y: 520},
		// The farmhouse door
		{obj: "obj_transition", x: 816, y: 528, sx: 2, sy: 1,
		 code: "targetRoom = rm_12;\ntargetX = 160;\ntargetY = 472;\nPlayerFacingBefore = dir.up;\nPlayerFacingAfter = dir.up;"},
		// Up the path to Hollow Vale
		{obj: "obj_transition", x: 1296, y: 16, sx: 6, sy: 2,
		 code: "targetRoom = rm_valley;\ntargetX = 1296;\ntargetY = 2008;\nPlayerFacingBefore = dir.up;\nPlayerFacingAfter = dir.up;"},
	],

	// Named spots for scripts (scripts/room_layout): points in pixels, areas in cells [c1, r1, c2, r2]
	points: {
		start: [816, 592],       // a new game, in front of the farmhouse
		door: [816, 564],        // back out of the farmhouse
		path_north: [1296, 72],  // down from the vale
	},
	areas: {
		meadow: [42, 8, 49, 15],     // weeds and bushes by the path
		west: [18, 21, 33, 31],      // the grass west of the field
		woods: [18, 32, 33, 33],     // a young wood at the woods' edge, west of the field
		pasture: [60, 28, 75, 31],   // where animals roam
		field: [35, 21, 58, 31],
		far_west: [1, 15, 15, 21],   // the meadow between the windmill and the pond
	},
};
