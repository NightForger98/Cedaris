// rm_mayor: the town hall by Beirut's square (tools/world2/areas_build.js cityPlaces) - the Mayor's office, where he
// sells plots of land (scripts/pshops), and his rooms behind it. Build with: node tools/rooms/build.js rm_mayor
const {interior} = require("../interior.js");
const [room, x, y] = require("../../world2/areas_build.js").exits().mayor;
// (w 14, h 10, door 6: you arrive at [224, 280], areas_build's MAYOR_IN)
module.exports = interior({w: 14, h: 10, door: 6, wall: "paper", floor: "parquet",
	exit: {room, x, y},
	furniture: [{is: "table", at: [5, 3]}, {is: "chair", at: [6, 2]}, {is: "bookshelf", at: [1, 1]}, {is: "shelf_books", at: [2, 1]},
		{is: "portrait", at: [4, 1]}, {is: "window", at: [8, 1]}, {is: "bed", at: [11, 2]}, {is: "drawers", at: [10, 1]},
		{is: "plant_big", at: [1, 7]}, {is: "flowers", at: [12, 6]}, {is: "notice", at: [3, 1]}],
	spots: {mayor_work: [6, 6], mayor_bed: [10, 6], guest: [3, 6]}});
