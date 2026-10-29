// The Crossroads (rm_cross), where the farm used to be, before it moved below Hollow Vale. Build with:
// node tools/rooms/build.js rm_cross
// 77 x 40 cells, the farm's old size and place on the map. Empty for now: only the roads, which keep the farm's old
// lines - west to Saltmere Coast and east to the village (rows 17-18), north up Brindlemoor's main street (cols
// 32-33), and south down to Hollow Vale (cols 39-41).
//
// Map: . grass  , dirt
const W = 77, H = 40;
const map = [];
for(let r = 0; r < H; r++){
	let row = "";
	for(let c = 0; c < W; c++){
		const road = r === 17 || r === 18;
		const north = (c === 32 || c === 33) && r < 17;
		const south = c >= 39 && c <= 41 && r > 18;
		row += (road || north || south) ? "," : ".";
	}
	map.push(row);
}

module.exports = {
	seed: 99,
	map,
	things: [],
	scatter: [
		{on: ".", density: 0.05, seed: 3, pieces: [{is: "leaves", weight: 4}, {is: "leaves2", weight: 4}, {is: "mushrooms"}, {is: "sprout", weight: 2}]},
	],
	instances: [
		{obj: "obj_plyr", x: 1040, y: 576},
		{obj: "camera", x: 1040, y: 576},
		{obj: "obj_transition", x: 1040, y: 8, sx: 4, sy: 1,
		 code: "targetRoom = rm_town;\ntargetX = 1040;\ntargetY = 1320;\nPlayerFacingBefore = dir.up;\nPlayerFacingAfter = dir.up;"},
		{obj: "obj_transition", x: 8, y: 576, sx: 1, sy: 4,
		 code: "targetRoom = rm_beach;\ntargetX = 1480;\ntargetY = 2048;\nPlayerFacingBefore = dir.left;\nPlayerFacingAfter = dir.left;"},
		{obj: "obj_transition", x: 2456, y: 576, sx: 1, sy: 4,
		 code: "targetRoom = rm_2;\ntargetX = 48;\ntargetY = 576;\nPlayerFacingBefore = dir.right;\nPlayerFacingAfter = dir.right;"},
		{obj: "obj_transition", x: 1296, y: 1272, sx: 6, sy: 1,
		 code: "targetRoom = rm_valley;\ntargetX = 1296;\ntargetY = 72;\nPlayerFacingBefore = dir.down;\nPlayerFacingAfter = dir.down;"},
	],
	points: {
		road_north: [1040, 72],    // down Brindlemoor's street
		road_west: [56, 576],      // in from the coast
		road_east: [2400, 576],    // in from the village
		road_south: [1296, 1208],  // up from Hollow Vale
	},
	areas: {},
};
