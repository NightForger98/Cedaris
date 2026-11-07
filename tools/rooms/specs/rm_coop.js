// rm_coop: inside the farm's coop (scripts/farm_buildings, scripts/animals) - the chickens roost here at night, and
// stay in out of the rain and the winter. Build with: node tools/rooms/build.js rm_coop
const {interior} = require("../interior.js");
module.exports = interior({w: 12, h: 9, door: 5, wall: "panel", floor: "wood",
	exit: {room: "rm_1", x: 2048, y: 868},
	furniture: [{is: "sacks", at: [1, 3]}, {is: "barrels", at: [9, 2]}, {is: "lantern", at: [5, 2]}, {is: "window_wood", at: [3, 1]}],
	areas: {pen: [2, 4, 8, 6]}});
