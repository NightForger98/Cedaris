// The farm (rm_1), at the foot of Hollow Vale. Build with: node tools/rooms/build.js rm_1
// 77 x 40 cells of 32px. The path comes down from the vale at the top to the lane across the farm. The farmhouse is in
// the west and the field in the middle (both where they always were, so saves keep their crops); the barn with its silo
// stands in the north-east with the coop and the granary below it round the pasture, the windmill and a beehive shed
// in the north-west, the pond in the west meadow and woods along the south. Only you live here. Buildings from the farm
// pack ([LPC] Farm, the building library in tools/buildings) apart from the farmhouse (the cottage kit).
//
// Map: . grass  , dirt  = field soil  ~ water. See tools/rooms/tiles.js for the rest.
const W = 77, H = 40;
// The ways out to the Outskirts (north) and the Sunset Coast (west): where you arrive there comes from the new world
// (tools/world2: farmArrive)
const world2 = require("../../world2/areas_build.js");
const way = (x, y, sx, sy, to, side, face) => {
	const [room2, tx, ty] = world2.farmArrive(side === "b" ? "t" : "l");
	to = room2;
	return {obj: "obj_transition", x, y, sx, sy,
		code: `targetRoom = ${to};\ntargetX = ${tx};\ntargetY = ${ty};\nPlayerFacingBefore = dir.${face};\nPlayerFacingAfter = dir.${face};`};
};
// The pond: [row, first col, last col]
const pond = [[23, 6, 11], [24, 5, 12], [25, 4, 13], [26, 4, 13], [27, 4, 13], [28, 5, 12], [29, 6, 11]];
const map = [];
for(let r = 0; r < H; r++){
	const row = Array(W).fill(".");
	const put = (c1, c2, ch) => { for(let c = c1; c <= c2; c++) row[c] = ch; };
	if(r <= 16) put(39, 41, ":");                  // the road down from Wing Hill
	if(r === 17 || r === 18) put(0, 75, ",");      // the lane across the farm, and west to South Beach
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
		// (the farmhouse is an obj_building, in instances: it grows with its upgrades)
		{is: "barrels", at: [33, 14]}, {is: "barrel", at: [20, 15]}, {is: "wheelbarrow", at: [33, 10]},
		{is: "hay_bale", at: [17, 19]}, {is: "clothesline", at: [20, 20]},

		// The field: a scarecrow, and the cart at its corner
		{is: "scarecrow", at: [46, 25]}, {is: "hay_cart", at: [35, 19]},

		// The barn and its silo, an open shed beside them
		// (the barn, silo, shed and coop are obj_buildings in instances: they grow with their upgrades)
		// The coop and the granary, and the pasture between them and the woods (fenced along the bottom)
		{is: "prop_farm_granary", at: [70, 24]},
		{is: "picket", at: [60, 32]}, {is: "picket", at: [63, 32]}, {is: "picket", at: [66, 32]}, {is: "picket", at: [69, 32]},
		{is: "picket", at: [72, 32]}, {is: "hay_bale", at: [74, 28]}, {is: "bucket", at: [69, 29]},

		// The windmill and the beehive shed, in the north-west
		{is: "windmill", at: [3, 1]}, {is: "prop_farm_bee_shed", at: [12, 4]}, {is: "prop_farm_outhouse", at: [16, 3]},

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
		{is: "oak", at: [75, 16]},
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
		// The farmhouse (PixelLab, art/ai_houses/farmhouse_1-4): the stage for its upgrades (house_level 0-3), its door
		// always over x 816 (the door below) and its foot on y 544. Its collision is made to fit the stage: the bottom
		// two rows of cells under it, but the door's.
		{obj: "obj_building", x: 0, y: 544,
		 code: "var _l = clamp(house_level(), 0, 3);\nsprite_index = [spr_house_farmhouse_1, spr_house_farmhouse_2, spr_house_farmhouse_3, spr_house_farmhouse_4][_l];\nx = 816 - [78, 78, 96, 62][_l];\nvar _c1 = floor(x / 32), _c2 = floor((x + sprite_get_width(sprite_index) - 8) / 32);\nfor(var _c = _c1; _c <= _c2; _c++) if(_c != 25){ var _b = instance_create_depth(_c * 32 + 16, 512, 0, obj_col_box); _b.image_xscale = 2; _b.image_yscale = 4; _b.visible = false; }"},
		// The barn, coop, shed and silo (PixelLab, scripts/farm_buildings): each at its stage (Rowan sells the next),
		// standing on the middle of its old foot
		{obj: "obj_building", x: 0, y: 0, code: "farm_building_setup(\"barn\", 2160, 448);"},
		{obj: "obj_building", x: 0, y: 0, code: "farm_building_setup(\"coop\", 2048, 832);"},
		{obj: "obj_building", x: 0, y: 0, code: "farm_building_setup(\"shed\", 1696, 192);"},
		{obj: "obj_building", x: 0, y: 0, code: "farm_building_setup(\"silo\", 1856, 416);"},
		// The farmhouse door
		{obj: "obj_transition", x: 816, y: 528, sx: 2, sy: 1,
		 code: "targetRoom = rm_12;\ntargetX = 160;\ntargetY = 472;\nPlayerFacingBefore = dir.up;\nPlayerFacingAfter = dir.up;"},
		// Up the road to Wing Hill, west along the lane to South Beach (tools/world/room.js works out where you arrive)
		way(1296, 16, 6, 2, "rm_winghill", "b", "up"),
		way(8, 576, 1, 4, "rm_southbeach", "r", "left"),
	],

	// Named spots for scripts (scripts/room_layout): points in pixels, areas in cells [c1, r1, c2, r2]
	points: {
		start: [816, 592],       // a new game, in front of the farmhouse
		door: [816, 564],        // back out of the farmhouse
		path_north: [1296, 72],  // down from Wing Hill
		road_t: [1296, 72],
		road_l: [64, 576],       // in from South Beach
	},
	areas: {
		meadow: [42, 8, 49, 15],     // weeds and bushes by the path
		west: [18, 21, 33, 31],      // the grass west of the field
		woods: [18, 32, 33, 33],     // a young wood at the woods' edge, west of the field
		pasture: [60, 28, 75, 31],   // where animals roam
		field: [35, 21, 58, 31],
		far_west: [1, 20, 14, 22],   // the meadow between the lane and the pond
	},
};
