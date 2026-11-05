// Elda's house (rm_village_elda), the cream house with the potion sign in the village's north-west. Build with:
// node tools/rooms/build.js rm_village_elda. An herbalist's home: drying herbs, books, plants everywhere.
const {interior} = require("../interior.js");
module.exports = interior({
	w: 16, h: 11, door: 7, wall: "stone", floor: "wood",
	exit: {room: "rm_frere", x: 560, y: 532},
	furniture: [
		{is: "bed_small", at: [1, 2]}, {is: "bookshelf", at: [3, 2]}, {is: "shelf_books", at: [4, 2]}, {is: "window", at: [6, 1]},
		{is: "painting", at: [9, 1]}, {is: "shelf_dishes", at: [12, 2]}, {is: "stove", at: [13, 2]}, {is: "pots", at: [14, 3]},
		{is: "table", at: [7, 5]}, {is: "stool", at: [6, 6]}, {is: "stool", at: [9, 6]}, {is: "potions", at: [7, 6]},
		{is: "plant_big", at: [1, 9]}, {is: "flowers", at: [3, 8]}, {is: "flower_box", at: [14, 7]}, {is: "tree_pot", at: [11, 9]},
		{is: "plant", at: [14, 9]},
	],
	spots: {elda_bed: [1, 5], elda_table: [7, 8]},
});
