// Brindlemoor (rm_town), the town north of the Crossroads. Build with: node tools/rooms/build.js rm_town
// 64 x 44 cells. A colonial town ([LPC] Colonial Buildings, from the building library in tools/buildings) round a big
// cobbled square: the long brick hall with its clock tower at the head of the square is Lysa's Brindle Inn, the
// bay-windowed shop Bryn's Outfitters, the small brick house with the potion sign Morga's Apothecary; the homes are
// Edwin's tall hall with the arched window (he keeps the notices), Nell the weaver's white clapboard house, Hask the
// hunter's sturdy brick house and Ida and her son Fen's tall gabled one. A clock tower stands in the square; Posy
// sells flowers from the market stall. The main street runs south to the Crossroads, the lane east to North Road.
//
// Map: . grass  : cobbles
const house = require("../house.js");

const H = {
	inn: house("brick_hall", [27, 1], "rm_town_inn"),
	edwin: house("brick_arch", [2, 0], "rm_town_home_nw"),
	bryn: house("brick_bay", [44, 3], "rm_town_outfitter"),
	morga: house("brick_small", [7, 18], "rm_town_apothecary"),
	nell: house("clapboard", [50, 17], "rm_town_home_e"),
	hask: house("brick_hip", [4, 30], "rm_town_home_sw"),
	ida: house("brick_gable", [50, 30], "rm_town_home_se"),
};

const W = 64, Hh = 44;
const map = [];
for(let r = 0; r < Hh; r++){
	const row = Array(W).fill(".");
	const put = (c1, c2, r1, r2) => { if(r >= r1 && r <= r2) for(let c = c1; c <= c2; c++) row[c] = ":"; };
	put(16, 47, 12, 27);   // the square
	put(5, 63, 12, 13);    // the lane across, east to North Road
	put(30, 32, 10, 11);   // up to the inn
	put(5, 5, 11, 11);     // Edwin's door
	put(47, 47, 10, 11);   // Bryn's
	put(8, 15, 24, 25);    // Morga's
	put(48, 55, 24, 25);   // Nell's
	put(30, 33, 28, 43);   // the main street, south to the Crossroads
	put(7, 29, 37, 38);    // Hask's lane
	put(34, 52, 39, 40);   // Ida's lane
	map.push(row.join(""));
}

module.exports = {
	seed: 33,
	map,

	things: [
		...Object.values(H).map(h => h.thing),
		{is: "sign_inn", at: [33, 8]}, {is: "sign_sword", at: [43, 8]}, {is: "sign_potion", at: [6, 21]},

		// The square: the clock tower, the statue, the notice board, Posy's flower stall and a market stall
		{is: "clock_tower", at: [44, 14]}, {is: "statue", at: [31, 18]}, {is: "board_notes", at: [35, 12]},
		{is: "stall_white", at: [21, 12]}, {is: "stall_stripe", at: [17, 20]}, {is: "fruit_table", at: [38, 24]},
		{is: "barrels", at: [27, 14]}, {is: "barrel", at: [40, 15]}, {is: "bucket", at: [18, 19]},

		// Trees round the edges of town
		{is: "oak", at: [13, 1]}, {is: "pine", at: [19, 2]}, {is: "oak", at: [39, 1]}, {is: "pine", at: [55, 1]},
		{is: "oak", at: [60, 3]}, {is: "bush_big", at: [11, 7]}, {is: "bush_big2", at: [60, 15]}, {is: "pine", at: [0, 15]},
		{is: "oak", at: [1, 22]}, {is: "oak", at: [61, 26]}, {is: "pine", at: [14, 29]}, {is: "oak", at: [19, 31]},
		{is: "pine", at: [24, 30]}, {is: "sapling", at: [27, 33]}, {is: "oak", at: [36, 30]}, {is: "pine", at: [41, 31]},
		{is: "sapling", at: [45, 33]}, {is: "bush_big", at: [16, 40]}, {is: "pine", at: [0, 40]}, {is: "oak", at: [58, 40]},
		{is: "pine", at: [62, 37]}, {is: "oak", at: [24, 41]}, {is: "pine", at: [38, 41]},
	],

	scatter: [
		{on: ".", density: 0.05, seed: 8, pieces: [{is: "leaves", weight: 4}, {is: "leaves2", weight: 4}, {is: "mushrooms"}, {is: "sprout", weight: 2}]},
	],

	instances: [
		{obj: "obj_plyr", x: 1040, y: 1320},
		{obj: "camera", x: 1040, y: 1320},
		// East along the lane to North Road (rm_north)
		{obj: "obj_transition", x: 2040, y: 416, sx: 1, sy: 4,
		 code: "targetRoom = rm_north;\ntargetX = 64;\ntargetY = 416;\nPlayerFacingBefore = dir.right;\nPlayerFacingAfter = dir.right;"},
		// Down the main street to the Crossroads
		{obj: "obj_transition", x: 1024, y: 1392, sx: 8, sy: 2,
		 code: "targetRoom = rm_cross;\ntargetX = 1040;\ntargetY = 72;\nPlayerFacingBefore = dir.down;\nPlayerFacingAfter = dir.down;"},
		// The doors
		...Object.values(H).map(h => h.transition),
	],

	points: {
		street_south: [1040, 1320],   // coming up the street from the Crossroads
		inn_door: H.inn.out, outfitter_door: H.bryn.out, apothecary_door: H.morga.out,
		// Where the townsfolk spend the day (their schedules in scripts/people)
		watch: [1088, 1250],     // Garrick, at the top of the street down to the Crossroads
		stall: [736, 600],       // Posy's flowers, in front of her stall
		square_a: [880, 720], square_b: [960, 760], square_c: [1300, 560], square_d: [1180, 820], square_e: [760, 820],
		square_f: [1120, 480], board: [1150, 430],
	},
	areas: {
		square: [16, 12, 47, 27],
	},
	// Where each house's door lets you out (the interiors' exits): node -e 'console.log(require("./tools/rooms/specs/rm_town.js").exits)'
	exits: Object.fromEntries(Object.entries(H).map(([k, h]) => [k, h.out])),
};
