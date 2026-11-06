// The Brindle Inn (rm_town_inn), inside Brindlemoor's hall. Build with: node tools/rooms/build.js rm_town_inn
// Lysa keeps the bar in the west (T in her dialogue: meals; Ida bakes behind it in the mornings); tables by the
// windows in the middle; the lodging in the east, where Lysa, Posy, Garrick and Father Aldous sleep. The bar's east end is open.
const {interior} = require("../interior.js");
module.exports = interior({
	w: 29, h: 14, door: 10, wall: "paper", floor: "parquet",
	exit: {room: "rm_beirut", x: 2192, y: 532},
	furniture: [
		// Behind the bar: shelves on the wall
		{is: "shelf_dishes", at: [1, 2]}, {is: "shelf_books", at: [2, 2]}, {is: "cupboard", at: [3, 2]},
		{is: "clock", at: [5, 1]}, {is: "dish_shelf", at: [6, 2]}, {is: "drawers", at: [7, 2]},
		{is: "counter", repeat: [8, 1], at: [1, 5]},
		{is: "bottles", at: [2, 5]}, {is: "plates", at: [5, 5]}, {is: "jars", at: [7, 5]},
		{is: "barrels", at: [10, 3]},
		// The dining room
		{is: "window", at: [12, 1]}, {is: "painting", at: [14, 1]}, {is: "window", at: [17, 1]}, {is: "stove_pipe", at: [20, 1]},
		{is: "table", at: [13, 4]}, {is: "stool", at: [12, 5]}, {is: "stool", at: [15, 5]},
		{is: "table", at: [18, 4]}, {is: "stool", at: [17, 5]}, {is: "stool", at: [20, 5]},
		{is: "table", at: [13, 8]}, {is: "stool", at: [12, 9]}, {is: "stool", at: [15, 9]},
		{is: "table", at: [18, 8]}, {is: "stool", at: [17, 9]}, {is: "stool", at: [20, 9]},
		{is: "candle", at: [13, 5]}, {is: "plates", at: [18, 5]}, {is: "bowl", at: [19, 9]},
		// By the door
		{is: "table_round", at: [3, 9]}, {is: "chair_left", at: [2, 9]}, {is: "chair_right", at: [4, 9]},
		{is: "cask", at: [1, 11]}, {is: "plant", at: [8, 12]},
		// The lodging
		{is: "bed", at: [22, 2]}, {is: "bed_small", at: [24, 2]}, {is: "bed", at: [26, 2]},
		{is: "bed_small", at: [25, 8]},   // Father Aldous, who has no house yet
		{is: "chest", at: [27, 6]}, {is: "drawers", at: [23, 7], solid: [[0, 0, 1, 2]]}, {is: "plant_big", at: [27, 12]},
	],
	spots: {
		lysa_work: [4, 4], ida_work: [7, 4], bar_a: [3, 6], bar_b: [6, 6], door_table: [3, 10],
		table_a: [12, 6], table_b: [15, 6], table_c: [17, 6], table_d: [20, 6],
		table_e: [12, 10], table_f: [15, 10], table_g: [17, 10], table_h: [20, 10],
		lysa_bed: [22, 5], posy_bed: [24, 5], garrick_bed: [26, 5], aldous_bed: [25, 11],
	},
	points: {bar: [144, 240]},   // in front of the bar
});
