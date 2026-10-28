// Hollow Vale (rm_valley), through the woods south of the farm. Build with: node tools/rooms/build.js rm_valley
// 44 x 60 cells: the old 60 x 44 vale turned a quarter clockwise so its river runs across. The path comes down from
// the farm, past Wren's ranch on the right (rm_valley_ranch, where Pip works too) and Thorne's carpentry on the left
// (rm_valley_carpentry), over the river on a plank bridge to the wildflower meadow in the south; the lake is up in
// the north-west (river fish, see fishing). The buildings stand upright, so they were placed again rather than turned.
//
// Map: . grass  , dirt  ~ water  b water under the bridge (walkable)
// Where you arrive inside a house: its interior spec's door point
const inside = r => require("./" + r + ".js").points.door;

const W = 44, H = 60;
// The lake (the old south-west one, turned): [row, first col, last col]
const lake = [[4, 9, 15], [5, 9, 16], [6, 8, 16], [7, 8, 16], [8, 8, 16], [9, 8, 16], [10, 8, 16], [11, 8, 16], [12, 9, 16], [13, 9, 15]];
const map = [];
for(let r = 0; r < H; r++){
	const row = Array(W).fill(".");
	const put = (c1, c2, ch) => { for(let c = c1; c <= c2; c++) row[c] = ch; };
	for(const [lr, c1, c2] of lake) if(lr === r) put(c1, c2, "~");
	if(r >= 38 && r <= 40) put(0, W - 1, "~");                 // the river
	if(r <= 50) put(22, 24, (r >= 38 && r <= 40) ? "b" : ",");  // the path, down from the farm and over the bridge
	if(r === 12 || r === 13) put(25, 35, ",");                // the ranch's lane
	if(r === 26 || r === 27) put(12, 21, ",");                // the carpentry's lane
	map.push(row.join(""));
}

module.exports = {
	seed: 55,
	map,

	things: [
		// Wren's ranch, with her garden and sheep pen below
		{is: "house_thatch", at: [28, 2]},
		{is: "picket", at: [29, 16]}, {is: "picket", at: [33, 16]}, {is: "hay_bale", at: [37, 15]},
		{is: "clothesline", at: [40, 12]}, {is: "barrel", at: [26, 9]}, {is: "bucket", at: [32, 18]},

		// Thorne's carpentry, with its lumber yard below
		{is: "house_thatch", at: [6, 16]}, {is: "sign_sword", at: [10, 24]},
		{is: "barrels", at: [14, 29]}, {is: "stump", at: [17, 30]}, {is: "crate_open", at: [8, 29]}, {is: "wheelbarrow", at: [9, 30]},

		// The bridge: planks over the river, three wide
		{src: [17, 20, 1, 1], repeat: [3, 3], at: [22, 38]}, {is: "signpost", at: [25, 36]},

		// The lake
		{is: "cattails", at: [17, 6]}, {is: "cattails", at: [7, 10]}, {is: "cattails", at: [12, 14]},

		// Trees: old woods along the edges, copses in the meadows
		{is: "pine", at: [0, 0]}, {is: "oak", at: [3, 1]}, {is: "pine", at: [18, 0]}, {is: "oak", at: [41, 0]},
		{is: "pine", at: [0, 15]}, {is: "oak", at: [1, 24]}, {is: "pine", at: [2, 31]}, {is: "sapling", at: [19, 31]},
		{is: "oak", at: [41, 20]}, {is: "pine", at: [41, 27]}, {is: "sapling", at: [27, 24]}, {is: "oak", at: [36, 30]},
		{is: "pine", at: [29, 32]},
		{is: "pine", at: [1, 42]}, {is: "oak", at: [6, 45]}, {is: "bush_big", at: [12, 43]}, {is: "pine", at: [16, 48]},
		{is: "oak", at: [30, 43]}, {is: "pine", at: [35, 47]}, {is: "bush_big2", at: [40, 43]}, {is: "oak", at: [27, 51]},
		{is: "pine", at: [0, 54]}, {is: "oak", at: [4, 56]}, {is: "pine", at: [9, 54]}, {is: "oak", at: [14, 56]},
		{is: "pine", at: [19, 54]}, {is: "oak", at: [24, 56]}, {is: "pine", at: [30, 55]}, {is: "oak", at: [35, 56]},
		{is: "pine", at: [41, 54]},
	],

	scatter: [
		{on: ".", density: 0.07, seed: 10, pieces: [{is: "leaves", weight: 4}, {is: "leaves2", weight: 4}, {is: "mushrooms", weight: 2}, {is: "toadstool"}, {is: "sprout", weight: 2}]},
		{on: "~", density: 0.06, seed: 11, pieces: [{is: "lilypads"}, {is: "lilypads2"}]},
	],

	instances: [
		{obj: "obj_plyr", x: 752, y: 72},
		{obj: "camera", x: 752, y: 72},
		// The ranch's and the carpentry's doors
		{obj: "obj_transition", x: 1104, y: 368, sx: 2, sy: 1,
		 code: `targetRoom = rm_valley_ranch;\ntargetX = ${inside("rm_valley_ranch")[0]};\ntargetY = ${inside("rm_valley_ranch")[1]};\nPlayerFacingBefore = dir.up;\nPlayerFacingAfter = dir.up;`},
		{obj: "obj_transition", x: 400, y: 816, sx: 2, sy: 1,
		 code: `targetRoom = rm_valley_carpentry;\ntargetX = ${inside("rm_valley_carpentry")[0]};\ntargetY = ${inside("rm_valley_carpentry")[1]};\nPlayerFacingBefore = dir.up;\nPlayerFacingAfter = dir.up;`},
		// Back up the path to the farm
		{obj: "obj_transition", x: 752, y: 16, sx: 6, sy: 2,
		 code: "targetRoom = rm_1;\ntargetX = 736;\ntargetY = 1208;\nPlayerFacingBefore = dir.up;\nPlayerFacingAfter = dir.up;"},
	],

	points: {
		path_north: [752, 72],   // coming down from the farm
		// Where villagers spend the day (their schedules in scripts/people)
		pasture: [1056, 600],    // Pip, minding the sheep pen
		yard: [400, 1000],       // the carpentry's lumber yard
		hunt: [900, 1560],       // Hask, across the bridge
		herbs: [260, 1140],      // the meadow by the river, west
		riverbank: [1120, 1180],
	},
	areas: {
		west: [26, 20, 42, 36],  // the meadow east of the path, north of the river (clear of the ranch and its pen)
		east: [2, 42, 41, 52],   // the wildflower meadow beyond the bridge
	},
};
