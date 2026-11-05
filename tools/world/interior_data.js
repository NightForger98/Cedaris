// The new world's interiors: the ones made for it (NEW, built by tools/world/interiors.js from these params) and
// the old ones it reuses (their own specs in tools/rooms/specs, re-pointed at their new doors by relink.js).
// Spots ([col, row] floor cells) are where villagers stand: "<room>.<spot>" in scripts/schedules.
const fs = require("fs");
const path = require("path");

// A family home: a bed each (spots <who>_bed), a table, a stove
function home(beds, o = {}){
	const at = [[1, 2], [3, 2], [5, 2], [1, 6]], front = [[1, 5], [3, 5], [5, 5], [3, 7]];
	const furniture = [
		{is: "window", at: [8, 1]}, {is: "stove", at: [11, 2]}, {is: "shelf_dishes", at: [12, 2]},
		{is: "table", at: [9, 5]}, {is: "stool", at: [8, 6]}, {is: "stool", at: [11, 6]}, {is: "plant", at: [12, 8]},
	];
	const spots = {home: [8, 4], table: [9, 8]};
	beds.forEach((who, i) => {
		furniture.push({is: i === 3 ? "bed_small" : (i === 0 && beds.length > 1 ? "bed_big" : "bed"), at: at[i]});
		spots[who + "_bed"] = front[i];
	});
	return Object.assign({w: 14, h: 10, door: 6, wall: "stone", floor: "wood", furniture, spots}, o);
}

// A shop: a counter across the back with the keepers behind it (spots <who>_work), goods round the walls
function shop(keepers, goods, o = {}){
	const furniture = [{is: "counter", at: [3, 4], repeat: [6, 1]}, ...goods];
	const spots = {customer: [6, 7], browse: [12, 7]};
	keepers.forEach((who, i) => { spots[who + "_work"] = [4 + i * 3, 3]; });
	return Object.assign({w: 16, h: 11, door: 7, wall: "panel", floor: "parquet", furniture, spots}, o);
}

const NEW = {
	// Homes
	rm_home_goldcrest: home(["cassius", "liora"], {wall: "paper", floor: "parquet"}),
	rm_home_whitlow: home(["mara", "clara"], {wall: "paper", floor: "wood"}),
	rm_home_gullwater: home(["marlo", "nerissa"], {wall: "stone", floor: "wood"}),
	rm_home_kassar: home(["zenya", "ayla"], {wall: "blue", floor: "wood"}),
	rm_home_tawil: home(["bryn", "dikhaj"], {wall: "stone", floor: "stone"}),
	rm_home_ward: home(["aldous", "alaric"], {wall: "stone", floor: "stone"}),
	rm_lighthouse: home(["coralie"], {w: 10, h: 10, door: 4,
		furniture: [{is: "bed", at: [1, 2]}, {is: "stove_pipe", at: [7, 1]}, {is: "lamp", at: [4, 3]}, {is: "chest", at: [8, 8]}, {is: "rope", at: [5, 2]}],
		spots: {coralie_bed: [1, 5], coralie_work: [5, 4], home: [7, 6], table: [2, 7]}}),
	rm_witch_tower: home(["morga", "rook"], {wall: "stone", floor: "stone",
		furniture: [{is: "bed", at: [1, 2]}, {is: "bed_small", at: [3, 2]}, {is: "cask", at: [8, 2]}, {is: "shelf_open", at: [9, 2]},
			{is: "bookshelf", at: [10, 2]}, {is: "stove", at: [12, 2]}, {is: "table_round2", at: [9, 5]}, {is: "skull", at: [12, 5]},
			{is: "potions", at: [8, 7]}, {is: "candle", at: [11, 8]}],
		spots: {morga_bed: [1, 5], rook_bed: [3, 5], morga_work: [10, 7], home: [6, 4], table: [11, 7]}}),

	// The hotel: Yubaba's counter in front, two family beds and three guest beds behind
	rm_hotel: {w: 20, h: 12, door: 9, wall: "paper", floor: "checker",
		furniture: [{is: "bed_big", at: [1, 2]}, {is: "bed", at: [3, 2]}, {is: "bed", at: [12, 2]}, {is: "bed", at: [14, 2]}, {is: "bed", at: [16, 2]},
			{is: "window", at: [6, 1]}, {is: "painting", at: [8, 1]}, {is: "counter", at: [5, 6], repeat: [5, 1]}, {is: "sofa", at: [13, 7]},
			{is: "plant_big", at: [1, 10]}, {is: "plant_big", at: [18, 10]}, {is: "lamp", at: [11, 6]}],
		spots: {yubaba_bed: [1, 5], boh_bed: [3, 5], yubaba_work: [7, 5], boh_work: [12, 9], home: [9, 4], guest_a: [12, 5], guest_b: [16, 5]}},

	// Shops and workplaces
	rm_guild: shop(["hask", "alaric"], [{is: "weapon_rack", at: [1, 2]}, {is: "bows", at: [2, 1]}, {is: "swords", at: [11, 1]},
		{is: "shield", at: [12, 1]}, {is: "armour", at: [10, 7]}, {is: "notice", at: [6, 1]}, {is: "barrels", at: [13, 2]}, {is: "table", at: [2, 7]}],
		{w: 18, wall: "stone", floor: "stone", spots_extra: {board: [8, 8]}}),
	rm_bank: shop(["cassius"], [{is: "chest", at: [1, 3]}, {is: "chest2", at: [2, 3]}, {is: "drawers", at: [11, 2]}, {is: "drawers", at: [12, 2]},
		{is: "clock", at: [8, 1]}, {is: "portrait", at: [13, 1]}, {is: "plant_big", at: [14, 9]}], {wall: "paper", floor: "checker"}),
	rm_toolstore: shop(["mara", "zenya"], [{is: "axe", at: [1, 1]}, {is: "shelf_open", at: [11, 2]}, {is: "shelf_low", at: [12, 2]},
		{is: "barrels", at: [13, 3]}, {is: "crate_tall", at: [1, 6]}, {is: "rope", at: [10, 2]}, {is: "sacks", at: [12, 6]}], {wall: "panel", floor: "wood"}),
	rm_bakery: shop(["sera"], [{is: "oven", at: [11, 2]}, {is: "stove", at: [12, 2]}, {is: "dish_shelf", at: [13, 2]}, {is: "plates", at: [5, 4]},
		{is: "bowl", at: [7, 4]}, {is: "table_round", at: [11, 7]}, {is: "stool", at: [12, 7]}, {is: "sacks", at: [1, 7]}], {wall: "blue", floor: "wood"}),
	rm_flowershop: shop(["posy"], [{is: "flowers", at: [1, 6]}, {is: "flower_box", at: [2, 6]}, {is: "flowers", at: [13, 6]}, {is: "plant_big", at: [11, 2]},
		{is: "tree_pot", at: [12, 2]}, {is: "plant", at: [13, 2]}, {is: "vase", at: [5, 4]}], {wall: "paper", floor: "wood"}),
	rm_furniture: shop(["rowan"], [{is: "sofa", at: [11, 6]}, {is: "cupboard", at: [11, 2]}, {is: "drawers", at: [12, 2]}, {is: "bookshelf", at: [13, 2]},
		{is: "table_round2", at: [2, 6]}, {is: "chair", at: [1, 7]}, {is: "chair_right", at: [3, 7]}, {is: "painting", at: [1, 1]}], {w: 17, wall: "panel", floor: "parquet"}),
	rm_hospital: shop(["alban", "marigold"], [{is: "bed_small", at: [11, 2]}, {is: "bed_small", at: [13, 2]}, {is: "shelf_books", at: [1, 2]},
		{is: "potions", at: [5, 4]}, {is: "jars", at: [7, 4]}, {is: "plant", at: [1, 9]}, {is: "pump", at: [10, 2]}], {w: 18, wall: "blue", floor: "checker"}),
	rm_library: shop(["edwin"], [{is: "bookshelf", at: [1, 2]}, {is: "shelf_books", at: [2, 2]}, {is: "bookshelf", at: [11, 2]}, {is: "shelf_books", at: [12, 2]},
		{is: "bookshelf", at: [13, 2]}, {is: "table", at: [11, 6]}, {is: "books", at: [5, 4]}, {is: "scroll", at: [7, 4]}, {is: "candle", at: [12, 7]}],
		{wall: "panel", floor: "parquet", spots_extra: {reading: [10, 8], wynn_study: [13, 9]}}),
	// The old church: an altar (the long table) at the top, benches
	rm_church: {w: 18, h: 14, door: 8, wall: "stone", floor: "stone",
		furniture: [{is: "table", at: [8, 3]}, {is: "candle", at: [8, 4]}, {is: "candle", at: [9, 4]}, {is: "portrait", at: [8, 1]},
			{is: "window", at: [3, 1]}, {is: "window", at: [13, 1]}, {is: "stool", at: [3, 8], repeat: [4, 1]}, {is: "stool", at: [11, 8], repeat: [4, 1]},
			{is: "stool", at: [3, 10], repeat: [4, 1]}, {is: "stool", at: [11, 10], repeat: [4, 1]}, {is: "flowers", at: [1, 3]}, {is: "flowers", at: [16, 3]}],
		spots: {aldous_work: [9, 6], pew_a: [5, 9], pew_b: [12, 9], pew_c: [5, 11], pew_d: [12, 11]}},
};
for(const s of Object.values(NEW)) if(s.spots_extra){ Object.assign(s.spots, s.spots_extra); delete s.spots_extra; }

// Old interiors reused in the new world: which outdoor room and building key their door is now
const REUSED = {
	rm_town_inn: ["rm_downtown", "tavern"],
	rm_village_smithy: ["rm_gracetower", "smithy"],
	rm_town_home_se: ["rm_beaconhill", "ironvein"],
	rm_town_home_nw: ["rm_ovenswindow", "quill"],
	rm_valley_ranch: ["rm_ovenswindow", "meadowlark"],
	rm_village_rowan: ["rm_victoryhill", "oakhart"],
	rm_valley_carpentry: ["rm_victoryhill", "mill"],
	rm_beach_hut: ["rm_whitesand", "shack"],
	rm_town_home_e: ["rm_dahya", "larkspun"],
	rm_town_outfitter: ["rm_dahya", "clothes"],
	rm_town_home_sw: ["rm_resolve", "silverbough"],
	rm_town_apothecary: ["rm_resolve", "potions"],
	rm_village_hesta: ["rm_sthereza", "nighthome"],
	rm_village_store: ["rm_sthereza", "seeds"],
	rm_village_elda: ["rm_frere", "frere"],
};

// Where you arrive inside a room through its door
function doorPoint(room){
	const n = NEW[room];
	if(n) return [(n.door + 1) * 32, n.h * 32 - 40];
	const file = path.join(__dirname, "..", "rooms", "specs", room + ".js");
	if(!fs.existsSync(file)) throw new Error("no interior " + room);
	return require(file).points.door;
}

module.exports = {NEW, REUSED, doorPoint};
