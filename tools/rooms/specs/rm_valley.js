// Hollow Vale (rm_valley), through the woods south of the farm. Build with: node tools/rooms/build.js rm_valley
// 77 x 65 cells: as wide as the farm above it (its west edge lines up with the farm's and Brindlemoor's) and as tall
// as South Road beside it. The path comes down from the farm, past Wren's ranch on the right (rm_valley_ranch, where
// Pip works too) and Thorne's carpentry on the left (rm_valley_carpentry), over the river on a plank bridge to the
// wildflower meadow in the south; the lake is up in the north-west (river fish, see fishing). The river runs right
// across: in from South Road (east edge, rows 38-40) and on west through the coast into the sea.
// Two more roads: a lane east from the path to South Road (rows 28-29, above the river), and from the meadow below
// the river a road west to the far end of the coast (rows 51-52) - the only way onto that part of the beach.
//
// Map: . grass  , dirt  ~ water  b water under the bridge (walkable)
// Where you arrive inside a house: its interior spec's door point
const inside = r => require("./" + r + ".js").points.door;

const W = 77, H = 65, O = 17;   // O: how far the first vale (44 wide) moved right when the vale grew west
// The lake: [row, first col, last col]
const lake = [[4, 9, 15], [5, 9, 16], [6, 8, 16], [7, 8, 16], [8, 8, 16], [9, 8, 16], [10, 8, 16], [11, 8, 16], [12, 9, 16], [13, 9, 15]];
const map = [];
for(let r = 0; r < H; r++){
	const row = Array(W).fill(".");
	const put = (c1, c2, ch) => { for(let c = c1; c <= c2; c++) row[c] = ch; };
	for(const [lr, c1, c2] of lake) if(lr === r) put(c1 + O, c2 + O, "~");
	if(r >= 38 && r <= 40) put(0, W - 1, "~");                    // the river
	if(r <= 52) put(39, 41, (r >= 38 && r <= 40) ? "b" : ",");    // the path, down from the farm and over the bridge
	if(r === 12 || r === 13) put(42, 52, ",");                   // the ranch's lane
	if(r === 26 || r === 27) put(29, 38, ",");                   // the carpentry's lane
	if(r === 28 || r === 29) put(42, W - 1, ",");                // east to South Road
	if(r === 51 || r === 52) put(0, 38, ",");                    // west to the far end of the coast
	map.push(row.join(""));
}

// The woods along the bottom: two staggered rows of trees right across
const woods = [];
for(let c = 0; c < W - 1; c += 3){
	woods.push({is: (c % 2) ? "pine" : "oak", at: [c, 55 + (c % 2)]});
	woods.push({is: (c % 2) ? "oak" : "pine", at: [c + 1, 59 + ((c + 1) % 2)]});
}

module.exports = {
	seed: 55,
	map,

	things: [
		// Wren's ranch, with her garden and sheep pen below
		{is: "house_thatch", at: [45, 2]},
		{is: "picket", at: [46, 16]}, {is: "picket", at: [50, 16]}, {is: "hay_bale", at: [54, 15]},
		{is: "clothesline", at: [57, 12]}, {is: "barrel", at: [43, 9]}, {is: "bucket", at: [49, 18]},

		// Thorne's carpentry, with its lumber yard below
		{is: "house_thatch", at: [23, 16]}, {is: "sign_sword", at: [27, 24]},
		{is: "barrels", at: [31, 29]}, {is: "stump", at: [34, 30]}, {is: "crate_open", at: [25, 29]}, {is: "wheelbarrow", at: [26, 30]},

		// The bridge: planks over the river, three wide
		{src: [17, 20, 1, 1], repeat: [3, 3], at: [39, 38]}, {is: "signpost", at: [42, 36]},

		// The lake
		{is: "cattails", at: [34, 6]}, {is: "cattails", at: [24, 10]}, {is: "cattails", at: [29, 14]},

		// Trees: old woods along the edges, copses in the meadows
		{is: "pine", at: [17, 0]}, {is: "oak", at: [20, 1]}, {is: "pine", at: [35, 0]}, {is: "oak", at: [58, 0]},
		{is: "pine", at: [17, 15]}, {is: "oak", at: [18, 22]}, {is: "pine", at: [19, 31]}, {is: "sapling", at: [36, 31]},
		{is: "oak", at: [58, 20]}, {is: "pine", at: [60, 32]}, {is: "sapling", at: [44, 24]}, {is: "oak", at: [53, 31]},
		{is: "pine", at: [46, 32]},
		{is: "pine", at: [18, 42]}, {is: "oak", at: [23, 45]}, {is: "bush_big", at: [29, 43]}, {is: "pine", at: [33, 45]},
		{is: "oak", at: [47, 43]}, {is: "pine", at: [52, 47]}, {is: "bush_big2", at: [57, 43]}, {is: "oak", at: [44, 50]},
		// The west woods
		{is: "pine", at: [0, 0]}, {is: "oak", at: [3, 1]}, {is: "pine", at: [8, 0]}, {is: "oak", at: [12, 2]},
		{is: "oak", at: [2, 8]}, {is: "pine", at: [10, 6]}, {is: "sapling", at: [14, 11]}, {is: "oak", at: [5, 15]},
		{is: "pine", at: [12, 19]}, {is: "oak", at: [3, 24]}, {is: "pine", at: [9, 30]}, {is: "bush_big", at: [13, 33]},
		{is: "pine", at: [2, 42]}, {is: "oak", at: [8, 44]}, {is: "pine", at: [13, 45]},
		// The east side
		{is: "oak", at: [62, 2]}, {is: "pine", at: [66, 0]}, {is: "oak", at: [70, 3]}, {is: "pine", at: [74, 1]},
		{is: "pine", at: [64, 10]}, {is: "oak", at: [70, 12]}, {is: "pine", at: [74, 18]}, {is: "oak", at: [63, 20]},
		{is: "pine", at: [67, 31]}, {is: "oak", at: [72, 32]}, {is: "bush_big2", at: [69, 22]},
		{is: "oak", at: [64, 43]}, {is: "pine", at: [70, 45]}, {is: "oak", at: [74, 48]},
		...woods,
	],

	scatter: [
		{on: ".", density: 0.07, seed: 10, pieces: [{is: "leaves", weight: 4}, {is: "leaves2", weight: 4}, {is: "mushrooms", weight: 2}, {is: "toadstool"}, {is: "sprout", weight: 2}]},
		{on: "~", density: 0.06, seed: 11, pieces: [{is: "lilypads"}, {is: "lilypads2"}]},
	],

	instances: [
		{obj: "obj_plyr", x: 1296, y: 72},
		{obj: "camera", x: 1296, y: 72},
		// The ranch's and the carpentry's doors
		{obj: "obj_transition", x: 1648, y: 368, sx: 2, sy: 1,
		 code: `targetRoom = rm_valley_ranch;\ntargetX = ${inside("rm_valley_ranch")[0]};\ntargetY = ${inside("rm_valley_ranch")[1]};\nPlayerFacingBefore = dir.up;\nPlayerFacingAfter = dir.up;`},
		{obj: "obj_transition", x: 944, y: 816, sx: 2, sy: 1,
		 code: `targetRoom = rm_valley_carpentry;\ntargetX = ${inside("rm_valley_carpentry")[0]};\ntargetY = ${inside("rm_valley_carpentry")[1]};\nPlayerFacingBefore = dir.up;\nPlayerFacingAfter = dir.up;`},
		// Back up the path to the farm
		{obj: "obj_transition", x: 1296, y: 16, sx: 6, sy: 2,
		 code: "targetRoom = rm_1;\ntargetX = 1280;\ntargetY = 1208;\nPlayerFacingBefore = dir.up;\nPlayerFacingAfter = dir.up;"},
		// East along the lane to South Road, west along the road below the river to the coast
		{obj: "obj_transition", x: 2456, y: 928, sx: 1, sy: 4,
		 code: "targetRoom = rm_south;\ntargetX = 64;\ntargetY = 608;\nPlayerFacingBefore = dir.right;\nPlayerFacingAfter = dir.right;"},
		{obj: "obj_transition", x: 8, y: 1664, sx: 1, sy: 4,
		 code: "targetRoom = rm_beach;\ntargetX = 1480;\ntargetY = 4480;\nPlayerFacingBefore = dir.left;\nPlayerFacingAfter = dir.left;"},
	],

	points: {
		path_north: [1296, 72],  // coming down from the farm
		road_east: [2400, 928],  // in from South Road
		road_west: [64, 1664],   // in from the coast
		// Where villagers spend the day (their schedules in scripts/people)
		pasture: [1600, 600],    // Pip, minding the sheep pen
		yard: [944, 1000],       // the carpentry's lumber yard
		hunt: [1444, 1560],      // Hask, across the bridge
		herbs: [804, 1140],      // the meadow by the river, west
		riverbank: [1664, 1180],
	},
	areas: {
		west: [43, 18, 59, 26],     // the meadow east of the path, north of the lane (clear of the ranch and its pen)
		east: [2, 42, 75, 49],      // the wildflower meadow beyond the bridge
		east_low: [43, 31, 75, 36], // between the lane and the river
		woods_w: [1, 2, 15, 36],    // the west woods
	},
};
