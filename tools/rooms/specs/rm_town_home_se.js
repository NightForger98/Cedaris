// Ida the baker and her son Fen (rm_town_home_se, the cream house in the south-east). node tools/rooms/build.js rm_town_home_se
const {interior} = require("../interior.js");
module.exports = interior({
	w: 16, h: 11, door: 7, wall: "paper", floor: "checker",
	exit: {room: "rm_town", x: 1680, y: 1268},
	furniture: [
		{is: "cupboard", at: [1, 2]}, {is: "shelf_low", at: [2, 2]}, {is: "drawers", at: [3, 2]}, {is: "window", at: [5, 1]}, {is: "portrait", at: [8, 1]},
		{is: "bed_small", at: [10, 2]}, {is: "bed", at: [13, 2]},
		{is: "table", at: [5, 5]}, {is: "stool", at: [4, 6]}, {is: "stool", at: [7, 6]}, {is: "bowl", at: [5, 6]},
		{is: "plant", at: [1, 9]}, {is: "vase", at: [14, 9]}, {is: "flower_box", at: [1, 6]},
	],
	spots: {ida_bed: [13, 5], fen_bed: [10, 5], ida_home: [5, 8], fen_home: [9, 7]},
});
