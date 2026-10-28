// Hollow Vale (rm_valley), through the woods south of the farm. Build with: node tools/rooms/build.js rm_valley
// 60 x 44 cells. A wild green valley: the path comes down from the farm past Wren's ranch (rm_valley_ranch, where
// Pip works too); Thorne's carpentry stands in the woods east of the path (rm_valley_carpentry); a river runs down
// the east side with a bridge to the wildflower meadow beyond; a lake in the south-west (river fish, see fishing).
//
// Map: . grass  , dirt  ~ water  b water under the bridge (walkable)
// Where you arrive inside a house: its interior spec's door point
const inside = r => require("./" + r + ".js").points.door;

module.exports = {
	seed: 55,
	map: [
		".....................,,,..............~~~...................",
		".....................,,,..............~~~...................",
		".....................,,,..............~~~...................",
		".....................,,,..............~~~...................",
		".....................,,,..............~~~...................",
		".....................,,,..............~~~...................",
		".....................,,,..............~~~...................",
		".....................,,,..............~~~...................",
		".....................,,,..............~~~...................",
		"..........,,,,,,,,,,,,,,..............~~~...................",
		"..........,,,,,,,,,,,,,,..............~~~...................",
		"..........,,..........,,..............~~~...................",
		"..........,,..........,,.......,,.....~~~...................",
		"..........,,..........,,.......,,.....~~~...................",
		"..........,,..........,,.......,,.....~~~...................",
		"..........,,..........,,.......,,.....~~~...................",
		"..........,,..........,,.......,,.....~~~...................",
		"..........,,..........,,.......,,.....~~~...................",
		"..........,,..........,,.......,,.....~~~...................",
		"......................,,,,,,,,,,,,,,,,bbb,,,,,,,,,,.........",
		"......................,,,,,,,,,,,,,,,,bbb,,,,,,,,,,.........",
		"......................................~~~...................",
		"......................................~~~...................",
		"......................................~~~...................",
		"......................................~~~...................",
		"......................................~~~...................",
		"......................................~~~...................",
		".....~~~~~~~~.........................~~~...................",
		"....~~~~~~~~~~........................~~~...................",
		"....~~~~~~~~~~........................~~~...................",
		"....~~~~~~~~~~........................~~~...................",
		"....~~~~~~~~~~........................~~~...................",
		"....~~~~~~~~~~........................~~~...................",
		"....~~~~~~~~~~........................~~~...................",
		"....~~~~~~~~~~........................~~~...................",
		"......~~~~~~..........................~~~...................",
		"......................................~~~...................",
		"......................................~~~...................",
		"......................................~~~...................",
		"......................................~~~...................",
		"......................................~~~...................",
		"......................................~~~...................",
		"......................................~~~...................",
		"......................................~~~...................",
	],

	things: [
		// Wren's ranch, with her garden and sheep pen
		{is: "house_thatch", at: [4, 0]},
		{is: "picket", at: [13, 12]}, {is: "picket", at: [16, 12]}, {is: "hay_bale", at: [17, 14]},
		{is: "clothesline", at: [1, 11]}, {is: "barrel", at: [3, 12]}, {is: "bucket", at: [14, 15]},

		// Thorne's carpentry in the woods, with its lumber yard
		{is: "house_thatch", at: [25, 2]}, {is: "sign_sword", at: [29, 10]},
		{is: "barrels", at: [33, 12]}, {is: "stump", at: [35, 14]}, {is: "crate_open", at: [27, 12]}, {is: "wheelbarrow", at: [28, 14]},

		// The bridge over the river
		{is: "bridge", at: [38, 19]}, {is: "signpost", at: [36, 18]},

		// The lake
		{is: "cattails", at: [3, 30]}, {is: "cattails", at: [14, 31]}, {is: "cattails", at: [9, 36]},

		// Trees: old woods along the edges, copses in the meadows
		{is: "pine", at: [22, 0]}, {is: "oak", at: [17, 0]}, {is: "pine", at: [36, 15]},
		{is: "pine", at: [43, 0]}, {is: "oak", at: [47, 1]}, {is: "pine", at: [52, 0]}, {is: "oak", at: [56, 2]},
		{is: "sapling", at: [24, 14]},
		{is: "pine", at: [44, 8]}, {is: "oak", at: [50, 10]}, {is: "bush_big2", at: [55, 14]},
		{is: "oak", at: [25, 25]}, {is: "pine", at: [30, 27]}, {is: "sapling", at: [33, 24]},
		{is: "oak", at: [44, 26]}, {is: "pine", at: [49, 24]}, {is: "oak", at: [54, 28]}, {is: "bush_big", at: [46, 32]},
		{is: "pine", at: [0, 38]}, {is: "oak", at: [16, 39]}, {is: "pine", at: [20, 37]}, {is: "oak", at: [24, 40]},
		{is: "pine", at: [29, 38]}, {is: "oak", at: [33, 40]}, {is: "pine", at: [42, 38]}, {is: "oak", at: [46, 40]},
		{is: "pine", at: [51, 38]}, {is: "oak", at: [55, 40]}, {is: "pine", at: [58, 36]},
	],

	scatter: [
		{on: ".", density: 0.07, seed: 10, pieces: [{is: "leaves", weight: 4}, {is: "leaves2", weight: 4}, {is: "mushrooms", weight: 2}, {is: "toadstool"}, {is: "sprout", weight: 2}]},
		{on: "~", density: 0.06, seed: 11, pieces: [{is: "lilypads"}, {is: "lilypads2"}]},
	],

	instances: [
		{obj: "obj_plyr", x: 704, y: 72},
		{obj: "camera", x: 704, y: 72},
		// The ranch's and the carpentry's doors
		{obj: "obj_transition", x: 336, y: 304, sx: 2, sy: 1,
		 code: `targetRoom = rm_valley_ranch;
targetX = ${inside("rm_valley_ranch")[0]};
targetY = ${inside("rm_valley_ranch")[1]};
PlayerFacingBefore = dir.up;
PlayerFacingAfter = dir.up;`},
		{obj: "obj_transition", x: 1008, y: 368, sx: 2, sy: 1,
		 code: `targetRoom = rm_valley_carpentry;
targetX = ${inside("rm_valley_carpentry")[0]};
targetY = ${inside("rm_valley_carpentry")[1]};
PlayerFacingBefore = dir.up;
PlayerFacingAfter = dir.up;`},
		// Back up the path to the farm
		{obj: "obj_transition", x: 704, y: 16, sx: 6, sy: 2,
		 code: "targetRoom = rm_1;\ntargetX = 736;\ntargetY = 1208;\nPlayerFacingBefore = dir.up;\nPlayerFacingAfter = dir.up;"},
	],

	points: {
		path_north: [704, 72],   // coming down from the farm
		// Where villagers spend the day (their schedules in scripts/people)
		pasture: [520, 440],     // Pip, minding the sheep pen
		yard: [1060, 470],       // the carpentry's lumber yard
		hunt: [1600, 720],       // Hask, across the bridge
		herbs: [420, 760],       // the west meadow
		riverbank: [1180, 760],
	},
	areas: {
		west: [1, 21, 36, 26],   // the meadows west of the river (clear of the carpentry's yard and path)
		east: [42, 4, 58, 36],   // the wildflower meadow beyond the bridge
	},
};
