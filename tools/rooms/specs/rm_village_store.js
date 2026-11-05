// Mara's general store (rm_village_store), the cream house on the village's lane. Build with:
// node tools/rooms/build.js rm_village_store. Mara sells the season's seeds over the counter (open at its east
// end); sacks, barrels and shelves of goods; she lives in the corner past the shop floor.
const {interior} = require("../interior.js");
module.exports = interior({
	w: 20, h: 12, door: 8, wall: "stone", floor: "wood",
	exit: {room: "rm_sthereza", x: 1200, y: 596},
	furniture: [
		{is: "shelf_dishes", at: [1, 2]}, {is: "shelf_low", at: [2, 2]}, {is: "shelf_open", at: [3, 2]}, {is: "window", at: [5, 1]},
		{is: "shelf_books", at: [7, 2]}, {is: "dish_shelf", at: [8, 2]}, {is: "clock", at: [10, 1]},
		{is: "counter", repeat: [9, 1], at: [1, 5]},
		{is: "sacks", at: [2, 5]}, {is: "jars", at: [4, 5]}, {is: "bowl", at: [6, 5]}, {is: "bottles", at: [8, 5]},
		// The shop floor
		{is: "barrels", at: [12, 3]}, {is: "crate_tall", at: [1, 8]}, {is: "sacks", at: [2, 10], solid: [[0, 0, 1, 1]]},
		{is: "sacks", at: [3, 10], solid: [[0, 0, 1, 1]]}, {is: "flowers", at: [12, 8]}, {is: "plant", at: [13, 10]},
		// Mara's corner
		{is: "bed_small", at: [15, 2]}, {is: "drawers", at: [17, 2]}, {is: "flower_box", at: [18, 6]}, {is: "vase", at: [18, 10]},
	],
	spots: {mara_work: [5, 4], mara_bed: [15, 5], shop_a: [5, 7], shop_b: [9, 8], shop_c: [11, 7]},
});
