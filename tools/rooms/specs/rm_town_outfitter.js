// The outfitter (rm_town_outfitter), the house with the sword sign in Brindlemoor's north-east. Build with:
// node tools/rooms/build.js rm_town_outfitter. Bryn sells clothes and armour over a counter the width of the shop.
const {interior, keeper} = require("../interior.js");
module.exports = interior({
	w: 18, h: 12, door: 8, wall: "stone", floor: "parquet",
	exit: {room: "rm_town", x: 1776, y: 404},
	furniture: [
		{is: "swords", at: [2, 1]}, {is: "bows", at: [3, 1]}, {is: "axe", at: [4, 1]}, {is: "shield", at: [7, 1]},
		{is: "shield", at: [10, 1]}, {is: "window_wood", at: [12, 1]}, {is: "swords", at: [15, 1]},
		// Behind the counter: armour on stands, a rack of spears
		{is: "armour", at: [1, 3]}, {is: "armour", at: [11, 3]}, {is: "weapon_rack", at: [16, 3]},
		{is: "counter", repeat: [16, 1], at: [1, 5]},
		{is: "sacks", at: [2, 5]}, {is: "books", at: [6, 5]}, {is: "scroll", at: [10, 5]}, {is: "lantern", at: [14, 5]},
		// The shop floor
		{is: "weapon_rack", at: [1, 7]}, {is: "barrels", at: [15, 8]}, {is: "chest", at: [2, 10]}, {is: "chest2", at: [3, 10]},
		{is: "crate_tall", at: [16, 7]}, {is: "plant", at: [14, 10]},
	],
	instances: [keeper("man", 8, 4)],
});
