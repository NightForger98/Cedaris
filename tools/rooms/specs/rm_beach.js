// The Saltmere Coast (rm_beach), west of the farm. Build with: node tools/rooms/build.js rm_beach
// 48 x 40 cells. The sea fills the west; a beach runs down the coast with a pier out into the water (fish from its
// end: sea fish, see fishing); grass and scrub behind it, Old Marlo's hut (rm_beach_hut) by the road, and the road east back to the farm.
//
// Map: ~ sea  _ sand  . grass  , dirt  b the pier (over the sea, walkable)
// Where you arrive inside a house: its interior spec's door point
const inside = r => require("./" + r + ".js").points.door;

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
	map: [
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
	],

	things: [
		// The pier: planks over the sea, two wide
		{src: [17, 20, 1, 1], repeat: [10, 2], at: [4, 17]},

		// Along the beach: a fisher's camp, driftwood
		{is: "barrels", at: [16, 14]}, {is: "crate_open", at: [18, 15]}, {is: "chest", at: [19, 15]},
		{is: "rope_fence", at: [15, 21]}, {is: "clothesline", at: [20, 21]}, {is: "bucket", at: [15, 16]},
		{is: "stump", at: [22, 9]}, {is: "stump", at: [17, 30]}, {is: "signpost2", at: [25, 16]},

		// Marlo's hut
		{is: "house_thatch", at: [32, 4]}, {is: "barrel", at: [31, 13]}, {is: "rope_fence", at: [41, 14]},

		// Behind the beach: trees and bushes
		{is: "pine", at: [29, 2]}, {is: "oak", at: [45, 1]}, {is: "bush_big", at: [45, 9]}, {is: "bush_big2", at: [30, 23]}, {is: "oak", at: [36, 24]},
		{is: "pine", at: [42, 22]}, {is: "pine", at: [31, 31]}, {is: "oak", at: [38, 33]}, {is: "pine", at: [45, 31]},
		{is: "sapling", at: [28, 14]},
	],

	scatter: [
		{on: ".", density: 0.05, seed: 9, pieces: [{is: "leaves", weight: 4}, {is: "leaves2", weight: 4}, {is: "sprout", weight: 2}]},
	],

	instances: [
		{obj: "obj_plyr", x: 1480, y: 576},
		{obj: "camera", x: 1480, y: 576},
		// Marlo's door
		{obj: "obj_transition", x: 1232, y: 432, sx: 2, sy: 1,
		 code: `targetRoom = rm_beach_hut;
targetX = ${inside("rm_beach_hut")[0]};
targetY = ${inside("rm_beach_hut")[1]};
PlayerFacingBefore = dir.up;
PlayerFacingAfter = dir.up;`},
		// The road east to the farm
		{obj: "obj_transition", x: 1528, y: 576, sx: 1, sy: 4,
		 code: "targetRoom = rm_1;\ntargetX = 56;\ntargetY = 576;\nPlayerFacingBefore = dir.right;\nPlayerFacingAfter = dir.right;"},
	],

	points: {
		road_east: [1480, 576],   // arriving from the farm
		pier_end: [160, 576],
		pier_b: [256, 560],      // a second rod on the pier
		camp: [560, 520],        // the fisher's camp on the sand
	},
	areas: {
		shore: [14, 1, 28, 38],   // stones and scrub on the sand and behind it
	},
};
