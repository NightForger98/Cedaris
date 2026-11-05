// Aunt Hesta and Tobin's house (rm_village_hesta), the cream house on the village's south lane. Build with:
// node tools/rooms/build.js rm_village_hesta. A warm family kitchen; two beds.
const {interior} = require("../interior.js");
module.exports = interior({
	w: 16, h: 11, door: 7, wall: "stone", floor: "wood",
	exit: {room: "rm_sthereza", x: 720, y: 596},
	furniture: [
		{is: "kitchen_sink", at: [1, 2]}, {is: "stove", at: [2, 2]}, {is: "oven", at: [3, 3]}, {is: "shelf_dishes", at: [4, 2]},
		{is: "window", at: [6, 1]}, {is: "clock", at: [9, 1]}, {is: "bed_small", at: [11, 2]}, {is: "bed", at: [13, 2]},
		{is: "table", at: [5, 5]}, {is: "stool", at: [4, 6]}, {is: "stool", at: [7, 6]}, {is: "bowl", at: [5, 6]}, {is: "candle", at: [6, 6]},
		{is: "spinning_wheel", at: [10, 7]}, {is: "flowers", at: [1, 8]}, {is: "plant", at: [14, 9]},
	],
	spots: {hesta_bed: [13, 5], tobin_bed: [11, 5], hesta_home: [3, 5], tobin_home: [9, 5]},
});
