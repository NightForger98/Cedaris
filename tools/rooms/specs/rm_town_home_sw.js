// Hask the hunter's home (rm_town_home_sw, the thatched house in the south-west). node tools/rooms/build.js rm_town_home_sw
const {interior} = require("../interior.js");
module.exports = interior({
	w: 16, h: 11, door: 7, wall: "stone", floor: "wood",
	exit: {room: "rm_town", x: 240, y: 1204},
	furniture: [
		{is: "bed_small", at: [1, 2]}, {is: "pump", at: [4, 1]}, {is: "window_wood", at: [6, 1]}, {is: "antlers", at: [9, 1]},
		{is: "weapon_rack", at: [11, 2]}, {is: "cask", at: [12, 2]}, {is: "barrels", at: [13, 3]},
		{is: "table_round", at: [7, 5]}, {is: "chair_left", at: [6, 5]}, {is: "chair_right", at: [8, 5]},
		{is: "chest", at: [1, 9]}, {is: "tree_pot", at: [14, 9]}, {is: "lamp", at: [4, 5]},
	],
	spots: {hask_bed: [1, 5], hask_home: [7, 7]},
});
