// The dark brown road (the old LPC sheet's "path" terrain, TS_terrain block at 18,0: 3 x 6 tiles) cut into a small
// tileset a season - spring a touch greener, summer as it is, autumn warmer, winter frosted with specks of snow - all
// laid out alike (block at 0,0), so scripts/ground swaps them with the season like the ground.
//   node tools/map/road_seasons.js [--import]   -> art/road_seasons/road_<season>.png (TS_road_<season>)
const fs = require("fs"), path = require("path");
const {execFileSync} = require("child_process");
const {readPng, writePng, newImage} = require("../rooms/png.js");
const ROOT = path.join(__dirname, "..", "..");
const sheetDir = path.join(ROOT, "sprites", "spr_tile_terrain");
const sheet = readPng(path.join(sheetDir, fs.readdirSync(sheetDir).find(f => f.endsWith(".png"))));
const OUT = path.join(ROOT, "art", "road_seasons");
fs.mkdirSync(OUT, {recursive: true});
const hash = (x, y) => { let h = (x * 374761393 + y * 668265263) | 0; h = (h ^ (h >>> 13)) * 1274126177 | 0; return ((h ^ (h >>> 16)) >>> 0) / 4294967296; };
const tone = {
	spring: (r, g, b) => [r * 0.96, g * 1.04 + 4, b * 0.96],
	summer: (r, g, b) => [r, g, b],
	autumn: (r, g, b) => [r * 1.06 + 6, g * 0.98, b * 0.86],
	winter: (r, g, b, x, y) => { const l = (r + g + b) / 3, k = 0.38 + (l > 110 ? 0.12 : 0);
		let o = [r + (232 - r) * k, g + (240 - g) * k, b + (248 - b) * k];
		if(hash(x, y) < 0.06) o = [246, 250, 255];   // snow specks
		return o; },
};
for(const [season, f] of Object.entries(tone)){
	const o = newImage(3 * 32, 6 * 32);
	for(let y = 0; y < o.h; y++) for(let x = 0; x < o.w; x++){
		const s = (y * sheet.w + 18 * 32 + x) * 4, d = (y * o.w + x) * 4;
		const a = sheet.px[s + 3];
		const [r, g, b] = a ? f(sheet.px[s], sheet.px[s + 1], sheet.px[s + 2], x, y) : [0, 0, 0];
		o.px[d] = Math.max(0, Math.min(255, Math.round(r))); o.px[d + 1] = Math.max(0, Math.min(255, Math.round(g)));
		o.px[d + 2] = Math.max(0, Math.min(255, Math.round(b))); o.px[d + 3] = a;
	}
	const file = path.join(OUT, `road_${season}.png`);
	writePng(file, o);
	if(process.argv.includes("--import")) execFileSync(process.execPath, [path.join(ROOT, "tools", "rooms", "tileset_import.js"), file, "road_" + season], {stdio: "inherit"});
}
console.log("road_<season>.png written");
