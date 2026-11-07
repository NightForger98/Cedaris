// The inside of a player-run shop on a plot (scripts/pshops; plots: tools/world2/areas_build.js): a counter with your
// employee behind it (spot "staff_work"), shelves, and the stock crate (obj_pshop_crate) where you leave the raw
// materials. Its way out is the plot's door.
//   specs/rm_pshop_<id>.js:  module.exports = require("../../world2/pshop_room.js")("<id>");
// (tools/world2/pshop_specs.js writes those, one per plot; run by tools/world/make_specs.js)
const {interior} = require("../rooms/interior.js");
const A = require("./areas_build.js");

module.exports = function(pid){
	const ex = A.exits()["pshop_" + pid];
	if(!ex) throw new Error("no plot " + pid);
	const [room, x, y] = ex;
	// (w 14, h 10, door 6: you arrive at [224, 280], areas_build's PSHOP_IN)
	return interior({w: 14, h: 10, door: 6, wall: "panel", floor: "parquet",
		exit: {room, x, y},
		furniture: [{is: "counter", at: [3, 4], repeat: [6, 1]}, {is: "shelf_open", at: [1, 1]}, {is: "shelf_dishes", at: [2, 1]},
			{is: "cupboard", at: [11, 1]}, {is: "shelf_low", at: [12, 1]}, {is: "window", at: [5, 1]}, {is: "barrels", at: [1, 6]},
			{is: "chest", at: [11, 6]}, {is: "plant", at: [12, 6]}, {is: "lamp", at: [12, 4]}],
		instances: [{obj: "obj_pshop_crate", x: 11 * 32 + 16, y: 6 * 32 + 30, code: `plot = "${pid}";`}],
		spots: {staff_work: [5, 3], customer: [6, 6], browse: [9, 7]}});
};
