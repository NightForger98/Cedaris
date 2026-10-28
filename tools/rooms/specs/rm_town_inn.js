// The Brindle Inn (rm_town_inn), inside Brindlemoor's hall. Build with: node tools/rooms/build.js rm_town_inn
// Lysa keeps the bar in the west half (T in her dialogue: meals); tables by the windows in the east half.
const {interior, keeper} = require("../interior.js");
module.exports = interior({
	w: 22, h: 14, door: 10, wall: "panel", floor: "wood",
	exit: {room: "rm_town", x: 1056, y: 340},
	furniture: [
		// Behind the bar: shelves on the wall, barrels closing it off
		{is: "shelf_dishes", at: [1, 2]}, {is: "shelf_books", at: [2, 2]}, {is: "cupboard", at: [3, 2]},
		{is: "clock", at: [5, 1]}, {is: "dish_shelf", at: [6, 2]}, {is: "drawers", at: [7, 2]},
		{is: "barrels", at: [8, 3]},
		{is: "counter", repeat: [9, 1], at: [1, 5]},
		{is: "bottles", at: [2, 5]}, {is: "plates", at: [5, 5]}, {is: "jars", at: [7, 5]}, {is: "lantern", at: [9, 5]},
		// The dining room
		{is: "window", at: [12, 1]}, {is: "painting", at: [14, 1]}, {is: "window", at: [17, 1]}, {is: "stove_pipe", at: [20, 1]},
		{is: "table", at: [13, 4]}, {is: "stool", at: [12, 5]}, {is: "stool", at: [15, 5]},
		{is: "table", at: [18, 4]}, {is: "stool", at: [17, 5]}, {is: "stool", at: [20, 5]},
		{is: "table", at: [13, 8]}, {is: "stool", at: [12, 9]}, {is: "stool", at: [15, 9]},
		{is: "table", at: [18, 8]}, {is: "stool", at: [17, 9]}, {is: "stool", at: [20, 9]},
		{is: "candle", at: [13, 5]}, {is: "plates", at: [18, 5]}, {is: "bowl", at: [19, 9]},
		// By the door
		{is: "table_round", at: [3, 9]}, {is: "chair_left", at: [2, 9]}, {is: "chair_right", at: [4, 9]},
		{is: "cask", at: [1, 11]}, {is: "plant", at: [8, 12]}, {is: "plant_big", at: [20, 12]},
	],
	instances: [keeper("woman", 4, 4)],
	points: {bar: [144, 240]},   // in front of the bar
});
