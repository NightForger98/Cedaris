// Wren's ranch (rm_valley_ranch), the thatched hut at the top of Hollow Vale. Build with:
// node tools/rooms/build.js rm_valley_ranch. Wren sells livestock (T: animals) over the counter (open at its east
// end); she and Pip, her ranch hand, sleep in the back.
const {interior} = require("../interior.js");
module.exports = interior({
	w: 18, h: 12, door: 8, wall: "stone", floor: "wood",
	exit: {room: "rm_ovenswindow", x: 1008, y: 788},
	furniture: [
		{is: "shelf_low", at: [1, 2]}, {is: "pots", at: [2, 3]}, {is: "window_wood", at: [3, 1]}, {is: "antlers", at: [6, 1]},
		{is: "counter", repeat: [7, 1], at: [1, 5]},
		{is: "sacks", at: [2, 5]}, {is: "bowl", at: [5, 5]},
		{is: "barrels", at: [9, 3]}, {is: "bed_small", at: [12, 2]}, {is: "bed", at: [15, 2]},
		{is: "table", at: [12, 6]}, {is: "stool", at: [11, 7]}, {is: "stool", at: [14, 7]},
		{is: "sacks", at: [1, 9], solid: [[0, 0, 1, 1]]}, {is: "cask", at: [2, 9]}, {is: "spinning_wheel", at: [5, 8]},
		{is: "plant", at: [16, 10]},
	],
	spots: {wren_work: [4, 4], wren_bed: [15, 5], pip_bed: [12, 5], shop_a: [3, 7], ranch_table: [12, 9]},
});
