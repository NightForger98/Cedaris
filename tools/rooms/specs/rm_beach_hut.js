// Old Marlo's hut (rm_beach_hut), behind the beach on the Saltmere Coast. Build with:
// node tools/rooms/build.js rm_beach_hut. A fisher's one-room hut: nets, a cask, a stove.
const {interior} = require("../interior.js");
module.exports = interior({
	w: 14, h: 10, door: 6, wall: "stone", floor: "wood",
	exit: {room: "rm_sunset", x: 1232, y: 628},
	furniture: [
		{is: "bed_small", at: [1, 2]}, {is: "window", at: [4, 1]}, {is: "stove", at: [7, 2]}, {is: "pots", at: [8, 3]},
		{is: "barrels", at: [10, 3]}, {is: "rope", at: [12, 2], solid: [[0, 1, 1, 1]]},
		{is: "table_round", at: [4, 6]}, {is: "chair_left", at: [3, 6]}, {is: "chair_right", at: [5, 6]}, {is: "lantern", at: [4, 6]},
		{is: "cask", at: [12, 7]}, {is: "chest", at: [1, 8]},
	],
	spots: {marlo_bed: [1, 5], marlo_home: [4, 7]},
});
