// Thorne's carpentry (rm_valley_carpentry), the workshop in the woods of Hollow Vale, east of the path. Build with:
// node tools/rooms/build.js rm_valley_carpentry. Thorne sells timber and stone (T) over the counter (open at its
// east end); benches, tools and stacked wood fill the shop; his bed is in the back corner.
const {interior} = require("../interior.js");
module.exports = interior({
	w: 18, h: 12, door: 8, wall: "stone", floor: "wood",
	exit: {room: "rm_victoryhill", x: 1008, y: 724},
	furniture: [
		{is: "axe", at: [1, 1]}, {is: "bows", at: [2, 1]}, {is: "window_wood", at: [4, 1]}, {is: "clock", at: [7, 1]},
		{is: "weapon_rack", at: [8, 2]},
		{is: "counter", repeat: [7, 1], at: [1, 5]},
		{is: "rope", at: [2, 5]}, {is: "scroll", at: [5, 5]},
		{is: "table", at: [10, 3]}, {is: "barrels", at: [1, 8]}, {is: "crate_tall", at: [3, 8]}, {is: "crate_tall", at: [4, 8]},
		{is: "table", at: [11, 7]}, {is: "chest", at: [13, 10]},
		{is: "bed", at: [15, 2]}, {is: "drawers", at: [14, 2]}, {is: "lamp", at: [16, 7]},
	],
	spots: {thorne_work: [4, 4], thorne_bed: [15, 5], rowan_work: [9, 7], shop_a: [6, 7]},
});
