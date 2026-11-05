// Brom's smithy (rm_village_smithy), the thatched house with the sword sign in the village. Build with:
// node tools/rooms/build.js rm_village_smithy. Brom works at his anvil (T: tools and weapons, upgrades); the furnace
// smelts ore into bars (E). He sleeps in the back corner.
const {interior} = require("../interior.js");
module.exports = interior({
	w: 18, h: 12, door: 8, wall: "stone", floor: "stone",
	exit: {room: "rm_gracetower", x: 496, y: 532},
	furniture: [
		{is: "swords", at: [5, 1]}, {is: "axe", at: [6, 1]}, {is: "shield", at: [7, 1]}, {is: "window_wood", at: [9, 1]},
		{is: "bows", at: [12, 1]},
		{is: "weapon_rack", at: [6, 2]}, {is: "barrels", at: [10, 3]}, {is: "crate_tall", at: [12, 2]},
		{is: "armour", at: [1, 8]}, {is: "chest", at: [5, 10]}, {is: "chest2", at: [6, 10]}, {is: "cask", at: [1, 10]},
		// Brom's corner
		{is: "bed_big", at: [14, 2]}, {is: "drawers", at: [16, 2]}, {is: "table_small", at: [15, 7]}, {is: "stool", at: [16, 7]},
	],
	instances: [{obj: "obj_furnace", x: 80, y: 172}],
	spots: {brom_work: [8, 5], brom_bed: [14, 5], shop_a: [7, 8], shop_b: [10, 8]},
});
