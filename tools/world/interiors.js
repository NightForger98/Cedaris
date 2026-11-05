// Specs for the new world's new interiors (tools/world/interior_data.js NEW), with their exits at their doors
// outside (from the outdoor room that has them, tools/world/room.js).
//   specs/<room>.js:  module.exports = require("../../world/interiors.js")("<room>");
const {interior} = require("../rooms/interior.js");
const {NEW} = require("./interior_data.js");
const {ROOMS} = require("./world.js");

module.exports = function(room){
	const p = NEW[room];
	const [outdoor, b] = Object.entries(ROOMS).map(([id, R]) => [id, (R.buildings || []).find(x => x.room === room)]).find(([, x]) => x) || [];
	if(!outdoor) throw new Error(room + " isn't behind any door in tools/world/world.js");
	const out = require("./room.js").spec(outdoor).exits[b.key];
	return interior(Object.assign({}, p, {exit: {room: outdoor, x: out[0], y: out[1]}}));
};
