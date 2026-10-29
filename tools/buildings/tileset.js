// Pack the building library into one tile sheet: the sprite spr_tile_buildings and its tileset TS_buildings (32px
// tiles), and tools/rooms/buildings.json - each building's place on the sheet, its door, and which rows are solid
// (the foot, up to the door) and which draw over the player walking behind it (the rows above the foot).
// Called by library.js --tileset.
const fs = require("fs");
const path = require("path");
const crypto = require("crypto");
const {execFileSync} = require("child_process");
const L = require("./lib.js");
const T = 32, COLS = 64;   // a 2048px wide sheet
const root = path.join(__dirname, "../..");

module.exports = function(all){
	// Shelf packing, tallest first, in whole tiles
	const order = all.slice().sort((a, b) => b.h - a.h || b.w - a.w);
	let x = 0, y = 0, shelf = 0;
	const place = {};
	for(const b of order){
		if(x + b.w > COLS){ x = 0; y += shelf; shelf = 0; }
		place[b.name] = [x, y];
		x += b.w; shelf = Math.max(shelf, b.h);
	}
	const rows = y + shelf, sheet = L.newImage(COLS * T, Math.ceil(rows / 4) * 4 * T);
	const lib = {};
	for(const b of all){
		const [c, r] = place[b.name];
		L.draw(sheet, b.img, 0, 0, b.img.w, b.img.h, c * T, r * T);
		const doorRow = b.door ? b.door[1] : b.h - 1, top = Math.max(0, doorRow - b.foot + 1);
		const solid = [[0, top, b.w, doorRow - top]];
		if(b.door){
			if(b.door[0] > 0) solid.push([0, doorRow, b.door[0], 1]);
			if(b.door[0] < b.w - 1) solid.push([b.door[0] + 1, doorRow, b.w - b.door[0] - 1, 1]);
		} else solid.push([0, doorRow, b.w, 1]);
		lib[b.name] = {src: [c, r, b.w, b.h], tileset: "TS_buildings", above: top, solid: solid.filter(s => s[2] > 0 && s[3] > 0)};
		if(b.door) lib[b.name].door = b.door;
	}
	const png = path.join(root, "build/buildings/buildings_sheet.png");
	L.writePng(png, sheet);
	fs.writeFileSync(path.join(root, "tools/rooms/buildings.json"), JSON.stringify(lib, null, "\t") + "\n");

	// The sprite, then the tileset made from it (TS_town's .yy as the template)
	execFileSync("node", [path.join(root, "tools/sprite_import.js"), png, "spr_tile_buildings", "setTiles"], {stdio: "inherit"});
	const dir = path.join(root, "tilesets/TS_buildings");
	fs.mkdirSync(dir, {recursive: true});
	let yy = fs.readFileSync(path.join(root, "tilesets/TS_town/TS_town.yy"), "utf8")
		.replaceAll("TS_town", "TS_buildings").replaceAll("spr_tile_town", "spr_tile_buildings")
		.replace(/"out_columns":\d+/, '"out_columns":' + COLS)
		.replace(/"tile_count":\d+/, '"tile_count":' + COLS * (sheet.h / T));
	fs.writeFileSync(path.join(dir, "TS_buildings.yy"), yy);
	const yypPath = path.join(root, "NewHarvest.yyp");
	let yyp = fs.readFileSync(yypPath, "utf8");
	const nl = yyp.includes("\r\n") ? "\r\n" : "\n";
	const entry = '    {"id":{"name":"TS_buildings","path":"tilesets/TS_buildings/TS_buildings.yy",},},';
	if(!yyp.includes(entry)) yyp = yyp.replace('"resources":[' + nl, '"resources":[' + nl + entry + nl);
	fs.writeFileSync(yypPath, yyp);
	console.log(`TS_buildings: ${COLS} x ${sheet.h / T} tiles, ${all.length} buildings`);
};
