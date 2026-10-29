// The outfitter (rm_town_outfitter), the house with the sword sign in Brindlemoor's north-east. Build with:
// node tools/rooms/build.js rm_town_outfitter. Bryn sells clothes and armour over a counter (its west end lifts), and
// lives in the corner past the shop floor.
const {interior} = require("../interior.js");
module.exports = interior({
	w: 23, h: 12, door: 8, wall: "stone", floor: "parquet",
	exit: {room: "rm_town", x: 1520, y: 340},
	furniture: [
		{is: "swords", at: [2, 1]}, {is: "bows", at: [3, 1]}, {is: "axe", at: [4, 1]}, {is: "shield", at: [7, 1]},
		{is: "shield", at: [10, 1]}, {is: "window_wood", at: [12, 1]}, {is: "swords", at: [15, 1]},
		// Behind the counter: armour on stands, a rack of spears
		{is: "armour", at: [1, 3]}, {is: "armour", at: [11, 3]}, {is: "weapon_rack", at: [16, 3]},
		{is: "counter", repeat: [15, 1], at: [2, 5]},
		{is: "sacks", at: [2, 5]}, {is: "books", at: [6, 5]}, {is: "scroll", at: [10, 5]}, {is: "lantern", at: [14, 5]},
		// The shop floor
		{is: "weapon_rack", at: [1, 8]}, {is: "barrels", at: [14, 8]}, {is: "chest", at: [2, 10]}, {is: "chest2", at: [3, 10]},
		{is: "crate_tall", at: [16, 7]},
		// Bryn's corner
		{is: "window", at: [18, 1]}, {is: "bed", at: [19, 2]}, {is: "drawers", at: [21, 2]}, {is: "plant", at: [21, 10]},
	],
	spots: {bryn_work: [8, 4], bryn_bed: [19, 5], shop_a: [6, 7], shop_b: [11, 8]},
});
