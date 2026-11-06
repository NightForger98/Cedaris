// Edwin the scribe's home (rm_town_home_nw, the cream house in the north-west). node tools/rooms/build.js rm_town_home_nw
const {interior} = require("../interior.js");
module.exports = interior({
	w: 16, h: 11, door: 7, wall: "blue", floor: "parquet",
	exit: {room: "rm_beirut", x: 3344, y: 1652},
	furniture: [
		{is: "bed", at: [1, 2]}, {is: "cupboard", at: [3, 2]}, {is: "shelf_low", at: [4, 2]}, {is: "window", at: [6, 1]}, {is: "clock", at: [9, 1]},
		{is: "bookshelf", at: [11, 2]}, {is: "drawers", at: [12, 2]}, {is: "stove", at: [14, 2]},
		{is: "table", at: [6, 5]}, {is: "stool", at: [5, 6]}, {is: "stool", at: [8, 6]}, {is: "candle", at: [6, 6]},
		{is: "plant", at: [1, 9]}, {is: "vase", at: [14, 9]}, {is: "lamp", at: [3, 4]},
	],
	spots: {edwin_bed: [1, 5], edwin_desk: [6, 8]},
});
