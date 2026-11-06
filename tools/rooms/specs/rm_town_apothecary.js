// The apothecary (rm_town_apothecary), the house with the potion sign in Brindlemoor's west. Build with:
// node tools/rooms/build.js rm_town_apothecary. Morga sells spell scrolls, staves, herbs and tonics over a counter
// (open at its east end), and sleeps in the corner past it.
const {interior} = require("../interior.js");
module.exports = interior({
	w: 21, h: 12, door: 7, wall: "paper", floor: "checker",
	exit: {room: "rm_outskirts", x: 2672, y: 1044},
	furniture: [
		// Shelves of jars and books behind the counter, and the still
		{is: "shelf_books", at: [1, 2]}, {is: "bookshelf", at: [2, 2]}, {is: "shelf_dishes", at: [3, 2]},
		{is: "clock", at: [5, 1]}, {is: "notice", at: [6, 1]}, {is: "stove_pipe", at: [9, 1]},
		{is: "cupboard", at: [11, 2]}, {is: "bookshelf", at: [12, 2]}, {is: "shelf_books", at: [13, 2]},
		{is: "counter", repeat: [13, 1], at: [1, 5]},
		{is: "potions", at: [2, 5]}, {is: "bottles", at: [5, 5]}, {is: "bowl", at: [9, 5]}, {is: "candle", at: [10, 5]},
		{is: "jars", at: [12, 5]},
		// The front of the shop
		{is: "flowers", at: [1, 8]}, {is: "table_small", at: [3, 9]}, {is: "skull", at: [3, 9]},
		{is: "flower_box", at: [13, 8]}, {is: "sacks", at: [1, 10], solid: [[0, 0, 1, 1]]},
		// Morga's corner
		{is: "window", at: [16, 1]}, {is: "bed_small", at: [17, 2]}, {is: "dish_shelf", at: [19, 2]}, {is: "plant_big", at: [19, 10]},
	],
	spots: {morga_work: [7, 4], morga_bed: [17, 5], shop_a: [5, 7], shop_b: [10, 8]},
});
