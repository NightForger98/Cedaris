// rm_barn: inside the farm's barn (scripts/farm_buildings, scripts/animals) - the cows and sheep sleep here, and
// stay in out of the rain and the winter. Build with: node tools/rooms/build.js rm_barn
const {interior} = require("../interior.js");
module.exports = interior({w: 16, h: 11, door: 7, wall: "panel", floor: "wood",
	exit: {room: "rm_1", x: 2160, y: 484},
	furniture: [{is: "barrels", at: [1, 2]}, {is: "sacks", at: [3, 3]}, {is: "sacks", at: [4, 3]}, {is: "pump", at: [6, 1]},
		{is: "rope", at: [9, 1]}, {is: "lantern", at: [10, 2]}, {is: "cask", at: [12, 2]}, {is: "crate_tall", at: [14, 2]},
		{is: "window_wood", at: [7, 1]}],
	areas: {pen: [3, 5, 12, 8]}});
