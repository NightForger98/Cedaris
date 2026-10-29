// Nell the weaver's home (rm_town_home_e, the stone house in the east). node tools/rooms/build.js rm_town_home_e
const {interior} = require("../interior.js");
module.exports = interior({
	w: 16, h: 11, door: 7, wall: "panel", floor: "parquet",
	exit: {room: "rm_town", x: 1776, y: 788},
	furniture: [
		{is: "kitchen_sink", at: [1, 2]}, {is: "stove", at: [2, 2]}, {is: "shelf_dishes", at: [3, 2]},
		{is: "window", at: [5, 1]}, {is: "painting", at: [8, 1]}, {is: "cupboard", at: [11, 2]}, {is: "spinning_wheel", at: [9, 4]}, {is: "bed_big", at: [13, 2]},
		{is: "table", at: [3, 5]}, {is: "stool", at: [2, 6]}, {is: "stool", at: [5, 6]},
		{is: "plates", at: [4, 6]},
		{is: "sofa", at: [11, 7]}, {is: "plant_big", at: [14, 9]}, {is: "flowers", at: [1, 8]},
	],
	spots: {nell_bed: [13, 5], nell_wheel: [9, 6]},
});
