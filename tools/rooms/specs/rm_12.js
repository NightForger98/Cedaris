// The farmhouse, downstairs (rm_12). Build with: node tools/rooms/build.js rm_12
// The furnished floor is one stamp (captured from the first version of this room); the map only says where you can
// walk. Every piece of furniture is under the player and solid over all of its art, so you're never drawn behind
// a table or a chair - the first version had the furniture layers above the player.
// Kitchen and dining room in the east, the hearth in the middle nook, stairs up (rm_123) in the north-west, the
// door out to the farm at the bottom.
//
// Map: . floor  # solid
module.exports = {
	base: "none",
	legend: {".": {}, "#": {solid: true}},
	map: [
		"###################",
		"###################",
		"###################",
		"####.......########",
		"..........#....####",
		"####..#####....####",
		"####..#####..##....",
		"####..#####..##...#",
		"##........#.####..#",
		"##.......##.####..#",
		"..##.###.##..##...#",
		"#.##.###.##########",
		"#.....#..##########",
		"#..#.....####.#####",
		"#.............#####",
		"#...............###",
	],

	things: [
		{stamp: "house_ground", crop: [1, 1, 19, 16], at: [0, 0]},
	],

	instances: [
		{obj: "obj_plyr", x: 160, y: 472},
		{obj: "camera", x: 160, y: 472},
		{obj: "obj_kitchen", x: 304, y: 268},
		// The front door, and the stairs up
		{obj: "obj_transition", x: 160, y: 496, sx: 4, sy: 2,
		 code: "targetRoom = rm_1;\ntargetX = 272;\ntargetY = 564;\nPlayerFacingBefore = dir.down;\nPlayerFacingAfter = dir.down;"},
		{obj: "obj_transition", x: 160, y: 112, sx: 4, sy: 2,
		 code: "targetRoom = rm_123;\ntargetX = 96;\ntargetY = 180;\nPlayerFacingBefore = dir.up;\nPlayerFacingAfter = dir.down;"},
	],

	points: {
		door: [160, 472],     // coming in from the farm
		stairs: [160, 180],   // coming down from upstairs
	},
};
