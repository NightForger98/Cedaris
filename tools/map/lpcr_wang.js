// The LPC Revised terrain's corner rules (its Tiled wangset "Summer Terrain", art/lpc_revised/*.tsx - the four season
// sheets share one layout) as a table for tools/rooms/build.js groundLayer: for each tile its four corners' terrains
// (NW, NE, SW, SE; "" = none), so the builder can pick, for any four cells, the tiles that draw them.
//   node tools/map/lpcr_wang.js    -> art/lpc_revised/wang.json
const fs = require("fs"), path = require("path");
const DIR = path.join(__dirname, "..", "..", "art", "lpc_revised");
const x = fs.readFileSync(path.join(DIR, "lpc-tileset-terrain-summer.tsx"), "utf8");
const a = x.indexOf('<wangset name="Summer Terrain"'), ws = x.slice(a, x.indexOf("</wangset>", a));
const names = [...ws.matchAll(/<wangcolor name="([^"]+)"/g)].map(m => m[1].toLowerCase().replace(/ /g, "_"));
const tiles = [...ws.matchAll(/<wangtile tileid="(\d+)" wangid="([^"]+)"/g)].map(m => {
	const w = m[2].split(",").map(Number);
	return {id: +m[1], c: [w[7], w[1], w[5], w[3]].map(i => names[i - 1] || "")};
});
fs.writeFileSync(path.join(DIR, "wang.json"), JSON.stringify({names, columns: 64, tiles}));
console.log(`wang.json: ${tiles.length} tiles, terrains ${names.join(", ")}`);
