// Rowan's house (rm_village_rowan), the thatched house on the village's south lane. Build with:
// node tools/rooms/build.js rm_village_rowan. A fence-mender's place: tools on the wall, wood stacked by the stove.
const {interior} = require("../interior.js");
module.exports = interior({
	w: 16, h: 11, door: 7, wall: "stone", floor: "wood",
	exit: {room: "rm_victoryhill", x: 720, y: 596},
	furniture: [
		{is: "bed", at: [1, 2]}, {is: "drawers", at: [3, 2]}, {is: "window_wood", at: [5, 1]}, {is: "axe", at: [8, 1]},
		{is: "antlers", at: [9, 1]}, {is: "weapon_rack", at: [11, 2]}, {is: "stove", at: [13, 2]}, {is: "barrels", at: [13, 4]},
		{is: "table_round", at: [7, 6]}, {is: "chair_left", at: [6, 6]}, {is: "chair_right", at: [8, 6]},
		{is: "chest", at: [1, 9]}, {is: "crate_tall", at: [14, 8]}, {is: "plant", at: [11, 9]},
	],
	spots: {rowan_bed: [1, 5], rowan_home: [7, 7]},
});
