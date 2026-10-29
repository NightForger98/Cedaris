// The Saltmere Coast (rm_beach), west of the farm. Build with: node tools/rooms/build.js rm_beach
// 48 x 153 cells: the coast runs the whole west side of the map, from level with Brindlemoor's top down to the bottom
// of Hollow Vale. The sea fills the west; a beach runs down the coast with a pier out into the water (fish from its end:
// sea fish, see fishing); grass and scrub behind it, Old Marlo's hut (rm_beach_hut) by the road, and the road east to the
// farm (rows 63-64). Woods line the east edge, open only where a way leads through: the farm road, the vale's river
// (rows 126-128, which crosses the coast into the sea and cuts it in two) and the road from the vale's meadow below the
// river (rows 139-140) - the only way onto the far south of the coast.
// The first coast (48 x 40) is rows 46-85 (OLD_TOP), unchanged.
//
// Map: ~ sea  _ sand  . grass  , dirt  b the pier (over the sea, walkable)
// Where you arrive inside a house: its interior spec's door point
const inside = r => require("./" + r + ".js").points.door;

const W = 48, H = 153, OLD_TOP = 46;
const old = [
		"~~~~~~~~~~~~~~____________......................",
		"~~~~~~~~~~~~~~____________......................",
		"~~~~~~~~~~~~~~____________......................",
		"~~~~~~~~~~~~~~____________......................",
		"~~~~~~~~~~~~~~______________....................",
		"~~~~~~~~~~~~~~______________....................",
		"~~~~~~~~~~~~________________....................",
		"~~~~~~~~~~~~________________....................",
		"~~~~~~~~~~~~________________....................",
		"~~~~~~~~~~~~________________....................",
		"~~~~~~~~~~~~________________....................",
		"~~~~~~~~~~~~________________....................",
		"~~~~~~~~~~~~~~____________......................",
		"~~~~~~~~~~~~~~____________......................",
		"~~~~~~~~~~~~~~____________............,,........",
		"~~~~~~~~~~~~~~____________............,,........",
		"~~~~~~~~~~~~~~____________............,,........",
		"~~~~bbbbbbbbbb__________,,,,,,,,,,,,,,,,,,,,,,,,",
		"~~~~bbbbbbbbbb__________,,,,,,,,,,,,,,,,,,,,,,,,",
		"~~~~~~~~~~~~~~____________......................",
		"~~~~~~~~~~~~~~____________......................",
		"~~~~~~~~~~~~~~____________......................",
		"~~~~~~~~~~~~~~____________......................",
		"~~~~~~~~~~~~~~____________......................",
		"~~~~~~~~~~~~~~____________......................",
		"~~~~~~~~~~~~~~____________......................",
		"~~~~~~~~~~~~~_____________......................",
		"~~~~~~~~~~~~~_____________......................",
		"~~~~~~~~~~~~~_______________....................",
		"~~~~~~~~~~~~~_______________....................",
		"~~~~~~~~~~~~~_______________....................",
		"~~~~~~~~~~~~~_______________....................",
		"~~~~~~~~~~~~~_______________....................",
		"~~~~~~~~~~~~~_______________....................",
		"~~~~~~~~~~~~~~____________......................",
		"~~~~~~~~~~~~~~____________......................",
		"~~~~~~~~~~~~~~____________......................",
		"~~~~~~~~~~~~~~____________......................",
		"~~~~~~~~~~~~~~____________......................",
		"~~~~~~~~~~~~~~____________......................",
];
const ROAD = [63, 64], RIVER = [126, 128], VALE_ROAD = [139, 140];
const map = [];
for(let r = 0; r < H; r++){
	if(r >= OLD_TOP && r < OLD_TOP + old.length){ map.push(old[r - OLD_TOP]); continue; }
	// The shore wanders a little: the sea 12-15 wide, the sand 12-14
	const sea = 13 + Math.round(1.5 * Math.sin(r / 7)), sand = sea + 12 + Math.round(Math.sin(r / 5 + 1));
	let row = "";
	for(let c = 0; c < W; c++){
		if(r >= RIVER[0] && r <= RIVER[1]) row += "~";
		else if(c < sea) row += "~";
		else if(c < sand) row += "_";
		else if(r >= VALE_ROAD[0] && r <= VALE_ROAD[1]) row += ",";
		else row += ".";
	}
	map.push(row);
}

// The woods along the east edge, open where a way leads through
const gaps = [ROAD, RIVER, VALE_ROAD];
const clear = (r1, r2) => gaps.every(([a, b]) => r2 < a - 1 || r1 > b + 1);
const treeline = [];
for(let r = -2; r < H; r += 3){
	if(clear(Math.max(r, 0), r + 4)) treeline.push({is: "pine", at: [46, r]});
	if(clear(r + 1, r + 4) && r + 1 >= 0) treeline.push({is: (r % 2) ? "oak" : "pine", at: [43 + (r % 2 ? 0 : 1), r + 1]});
}


module.exports = {
	seed: 44,
	base: "sea",
	legend: {
		"~": {terrain: "sea", solid: true, water: true},
		"b": {terrain: "sea", water: true, busy: true},
		"_": {terrain: "shore"},
		".": {terrain: "grass", under: ["shore"]},
		",": {terrain: "dirt", under: ["shore"]},
	},
	map,

	things: [
		// The pier: planks over the sea, two wide
		{src: [17, 20, 1, 1], repeat: [10, 2], at: [4, 63]},

		// Along the beach: a fisher's camp, driftwood
		{is: "barrels", at: [16, 60]}, {is: "crate_open", at: [18, 61]}, {is: "chest", at: [19, 61]},
		{is: "rope_fence", at: [15, 67]}, {is: "clothesline", at: [20, 67]}, {is: "bucket", at: [15, 62]},
		{is: "stump", at: [22, 55]}, {is: "stump", at: [17, 76]}, {is: "signpost2", at: [25, 62]},

		// Marlo's hut
		{is: "plain_small", at: [36, 54]}, {is: "barrel", at: [34, 59]}, {is: "rope_fence", at: [41, 60]},

		// Behind the beach: trees and bushes
		{is: "pine", at: [29, 48]}, {is: "bush_big2", at: [30, 69]}, {is: "oak", at: [36, 70]},
		{is: "pine", at: [42, 68]}, {is: "pine", at: [31, 77]}, {is: "oak", at: [38, 79]}, 
		{is: "sapling", at: [28, 60]},

		// The new coast north and south: driftwood, scrub and trees behind the sand
		{is: "stump", at: [20, 12]}, {is: "bush_big", at: [31, 6]}, {is: "oak", at: [36, 18]}, {is: "pine", at: [30, 30]},
		{is: "sapling", at: [38, 38]}, {is: "stump", at: [18, 100]}, {is: "oak", at: [32, 92]}, {is: "pine", at: [37, 104]},
		{is: "bush_big2", at: [30, 114]}, {is: "sapling", at: [35, 120]}, {is: "oak", at: [31, 145]}, {is: "stump", at: [21, 147]},
		...treeline,
	],

	scatter: [
		{on: ".", density: 0.05, seed: 9, pieces: [{is: "leaves", weight: 4}, {is: "leaves2", weight: 4}, {is: "sprout", weight: 2}]},
	],

	instances: [
		{obj: "obj_plyr", x: 1480, y: 2048},
		{obj: "camera", x: 1480, y: 2048},
		// Marlo's door
		{obj: "obj_transition", x: 1232, y: 1904, sx: 2, sy: 1,
		 code: `targetRoom = rm_beach_hut;
targetX = ${inside("rm_beach_hut")[0]};
targetY = ${inside("rm_beach_hut")[1]};
PlayerFacingBefore = dir.up;
PlayerFacingAfter = dir.up;`},
		// The road from Hollow Vale's meadow, below the river
		{obj: "obj_transition", x: 1528, y: 4480, sx: 1, sy: 4,
		 code: "targetRoom = rm_valley;\ntargetX = 64;\ntargetY = 1664;\nPlayerFacingBefore = dir.right;\nPlayerFacingAfter = dir.right;"},
		// The road east to the farm
		{obj: "obj_transition", x: 1528, y: 2048, sx: 1, sy: 4,
		 code: "targetRoom = rm_cross;\ntargetX = 56;\ntargetY = 576;\nPlayerFacingBefore = dir.right;\nPlayerFacingAfter = dir.right;"},
	],

	points: {
		road_east: [1480, 2048],   // arriving from the farm
		pier_end: [160, 2048],
		pier_b: [256, 2032],      // a second rod on the pier
		camp: [560, 1992],        // the fisher's camp on the sand
		road_vale: [1480, 4480], // in from Hollow Vale
	},
	areas: {
		shore: [14, 47, 28, 84],   // stones and scrub on the sand and behind it
		shore_north: [14, 1, 28, 44],
		shore_south: [14, 88, 28, 124],
		shore_far: [14, 130, 28, 150], // below the river, reached from the vale
	},
};
