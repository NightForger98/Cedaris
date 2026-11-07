// The farmhouse, upstairs (rm_123): your bedroom. Build with: node tools/rooms/build.js rm_123
// One stamp (captured from the first version of this room); the map says where you can walk. The bed in the art is
// the bed you sleep in (obj_bed stands on it, without drawing its placeholder), so you wake up here (BED_ROOM).
//
// Map: . floor  # solid
module.exports = {
	base: "none",
	legend: {".": {}, "#": {solid: true}},
	map: [
		"###################",
		"###################",
		"###################",
		"...........#.######",   // (the floor above the sofa is open: the way from the stairs to the bed)
		".......##........##",
		".......##.........#",
		"......####..##....#",
		"......####..##.####",
		"#.....#.....#.....#",
		"#.....########....#",
	],

	things: [
		{stamp: "house_upstairs", crop: [1, 1, 19, 10], at: [0, 0]},
	],

	instances: [
		{obj: "obj_plyr", x: 96, y: 180},
		{obj: "camera", x: 96, y: 180},
		{obj: "obj_bed", x: 560, y: 112, code: "art = false; // the bed is in the room's tiles"},
		// The stairs down
		{obj: "obj_transition", x: 96, y: 112, sx: 4, sy: 2,
		 code: "targetRoom = rm_12;\ntargetX = 160;\ntargetY = 180;\nPlayerFacingBefore = dir.up;\nPlayerFacingAfter = dir.down;"},
	],

	points: {
		stairs: [96, 180],   // coming up from downstairs
	},
};
