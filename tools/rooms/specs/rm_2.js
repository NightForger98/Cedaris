// The village (rm_2). Build with: node tools/rooms/build.js rm_2
// 56 x 50 cells of 32px. Thatched cottages ([LPC] Thatched-roof Cottage, dressed with the medieval village
// decorations; the building library in tools/buildings). The hall - twin cottages joined by a gateway - stands on the
// north side of a cobbled square (the notice board is by it); Elda's little cottage is in the north-west, Brom's smithy
// (the long cottage with double doors, torches and a banner) and Mara's general store (the tall one with market
// awnings) along a lane in the south, and below them a second lane with Aunt Hesta and Tobin's L-shaped cottage and
// Rowan's. Every door but the hall's leads inside (rm_village_*). The road west goes to the Crossroads; the river runs
// down the east side, with the bridge to Whisperwood (obj_path draws it).
//
// Map: . grass  , dirt  : cobbles  ~ water. See tools/rooms/tiles.js for the rest.
// Where you arrive inside a house: its interior spec's door point
const house = require("../house.js");

const H = {
	hall: house("cottage_twin", [15, 1]),
	elda: house("cottage_small", [2, 4], "rm_village_elda"),
	smithy: house("cottage_long", [3, 22], "rm_village_smithy"),
	store: house("cottage_shop", [17, 23], "rm_village_store"),
	hesta: house("cottage_L", [4, 37], "rm_village_hesta"),
	rowan: house("plain_tall", [19, 38], "rm_village_rowan"),
};

const W = 56, HH = 50;
const map = [];
for(let r = 0; r < HH; r++){
	const row = Array(W).fill(".");
	const put = (c1, c2, r1, r2, ch) => { if(r >= r1 && r <= r2) for(let c = c1; c <= c2; c++) row[c] = ch; };
	put(39, 41, 0, 9, ",");      // the road north
	put(14, 41, 10, 21, ":");    // the square
	put(0, 13, 17, 18, ",");     // the road west
	put(42, 43, 17, 18, ",");    // to the bridge
	put(18, 20, 9, 9, ":");      // the hall's door
	put(4, 6, 10, 16, ",");      // Elda's
	put(31, 33, 22, 49, ",");    // the road south
	put(2, 33, 33, 34, ",");     // the first lane: the smithy and the store
	put(5, 7, 31, 32, ",");      // the smithy's door
	put(19, 21, 32, 32, ",");    // the store's
	put(8, 33, 47, 48, ",");     // the second lane: Hesta's and Rowan's
	put(6, 8, 44, 46, ",");      // Hesta's door
	put(44, 46, 0, 49, "~");     // the river
	map.push(row.join(""));
}

module.exports = {
	seed: 22,
	map,

	things: [
		// The hall and the houses, with Elda's potion sign and the smithy's sword sign
		...Object.values(H).map(h => h.thing),
		{is: "sign_potion", at: [1, 7]}, {is: "sign_sword", at: [2, 27]},

		// The square: a statue in the middle, the notice board by the hall door, barrels and a cart
		{is: "statue", at: [27, 15]},
		{is: "board_notes", at: [30, 10]},
		{is: "barrels", at: [36, 10]}, {is: "barrel", at: [38, 10]}, {is: "hay_cart", at: [37, 19]},
		{is: "crate_open", at: [15, 10]}, {is: "chest", at: [16, 10]},
		{is: "signpost", at: [13, 16]},

		// Gardens and yards
		{is: "clothesline", at: [10, 32]}, {is: "barrel", at: [16, 29]}, {is: "wheelbarrow", at: [0, 29]},
		{is: "bush_big", at: [33, 2]}, {is: "bush_big2", at: [36, 3]}, {is: "well", at: [34, 13]},
		{is: "sapling", at: [40, 24]}, {is: "oak", at: [36, 26]}, {is: "pine", at: [40, 29]},
		{is: "cattails", at: [43, 4]}, {is: "cattails", at: [43, 27]}, {is: "cattails", at: [47, 12]},

		// Whisperwood's edge across the river
		{is: "pine", at: [48, 0]}, {is: "pine", at: [51, 2]}, {is: "oak", at: [53, 0]}, {is: "pine", at: [49, 6]},
		{is: "oak", at: [52, 8]}, {is: "pine", at: [54, 11]}, {is: "pine", at: [48, 21]}, {is: "oak", at: [51, 22]},
		{is: "pine", at: [54, 24]}, {is: "pine", at: [48, 28]}, {is: "oak", at: [51, 30]}, {is: "pine", at: [54, 31]},
		{is: "sapling", at: [53, 16]}, {is: "bush_big", at: [49, 15]},
		{is: "pine", at: [48, 36]}, {is: "oak", at: [52, 39]}, {is: "pine", at: [49, 44]}, {is: "oak", at: [53, 46]},

		// The south lane
		{is: "pine", at: [0, 38]}, {is: "oak", at: [1, 44]}, {is: "pine", at: [36, 37]}, {is: "oak", at: [39, 41]},
		{is: "sapling", at: [36, 45]}, {is: "bush_big2", at: [40, 47]}, {is: "barrel", at: [17, 44]}, {is: "hay_roll", at: [27, 44]},
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
		// The houses' doors (rm_village_*)
		...Object.values(H).filter(h => h.transition).map(h => h.transition),
		// The road north (North Road, rm_north)
		{obj: "obj_transition", x: 1296, y: 8, sx: 6, sy: 1,
		 code: "targetRoom = rm_north;\ntargetX = 1696;\ntargetY = 1336;\nPlayerFacingBefore = dir.up;\nPlayerFacingAfter = dir.up;"},
		// The road south (South Road, rm_south)
		{obj: "obj_transition", x: 1040, y: 1592, sx: 6, sy: 1,
		 code: "targetRoom = rm_south;\ntargetX = 1040;\ntargetY = 72;\nPlayerFacingBefore = dir.down;\nPlayerFacingAfter = dir.down;"},
		// The road west to the Crossroads
		{obj: "obj_transition", x: 8, y: 576, sx: 1, sy: 4,
		 code: "targetRoom = rm_cross;\ntargetX = 2400;\ntargetY = 576;\nPlayerFacingBefore = dir.left;\nPlayerFacingAfter = dir.left;"},
	],

	points: {
		road_west: [64, 576],    // arriving from the Crossroads
		road_north: [1296, 72],  // arriving from North Road
		road_south: [1040, 1536], // arriving from South Road
		bridge: [1370, 592],     // back from Whisperwood
		crowd: [560, 400],       // where visitors stand on a festival day (a 4-wide grid from here)
		river: [1456, 0],        // lanterns float down from here on Lantern Night
		// Where villagers spend the day (their schedules in scripts/people)
		board: [1010, 410], riverbank: [1370, 280], riverbank_b: [1370, 860],
		square_a: [700, 560], square_b: [800, 620], square_c: [1100, 520], square_d: [600, 650], square_e: [1180, 640],
		square_f: [900, 450], lane: [600, 1100],
	},
	areas: {
		square: [14, 10, 41, 21],  // the cobbled square: bunting on festival days
	},
	// Where each house's door lets you out (the interiors' exits; tools/rooms/sync_exits.js)
	exits: Object.fromEntries(Object.entries(H).map(([k, h]) => [k, h.out])),
};
