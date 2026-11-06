// The ground atlases: one tileset a season (TS_ground_spring / summer / autumn / winter) built from the PixelLab Wang
// tilesets in art/terrain_pl, every season laid out the same, so a room built with the summer one changes season by
// swapping its tileset (scripts/ground: tilemap_tileset). Each terrain pair is a 4 x 4 block of 32 px tiles; within a
// block a tile's place is its corners read as a number - NW, NE, SW, SE, 1 where the corner is the pair's upper
// terrain (0: all lower, 15: all upper). Blocks, four to a row:
//   0 grass|dirt  1 grass|road  2 grass|sand  3 grass|trail  4 grass|concrete  5 shallow|sand  6 deep|shallow
//   7 grass|rock  8 rock|snow
// ("grass" is snow in winter.)  Writes art/terrain_pl/atlas/ground_<season>.png and, with --import, the tilesets.
//   node tools/map/ground_atlas.js [--import]
const fs = require("fs");
const path = require("path");
const {execFileSync} = require("child_process");
const {readPng, writePng, newImage} = require("../rooms/png.js");
const ROOT = path.join(__dirname, "..", ".."), DIR = path.join(ROOT, "art", "terrain_pl"), OUT = path.join(DIR, "atlas");
const SEASONS = ["spring", "summer", "autumn", "winter"];
const PAIRS = [["grass", "dirt"], ["grass", "road"], ["grass", "sand"], ["grass", "trail"], ["grass", "concrete"],
	["shallow", "sand"], ["deep", "shallow"], ["grass", "rock"], ["rock", "snow"]];
// [file, invert]: the tileset a block comes from in a season; invert swaps its lower and upper
const source = (season, b) => {
	const g = ["dirt", "road", "sand", "trail", "concrete"];
	if(b < 5) return [`t_${season}_${g[b]}`, false];
	if(b === 5) return ["t_water_shore", false];
	if(b === 6) return ["t_water_deep", false];
	if(b === 7) return season === "winter" ? ["t_mountain_snow", true] : [season === "summer" ? "t_mountain_rock" : `t_${season}_rock`, false];
	return ["t_mountain_snow", false];
};
const T = 32, COLS = 4;
fs.mkdirSync(OUT, {recursive: true});
for(const season of SEASONS){
	const rows = Math.ceil(PAIRS.length / COLS), atlas = newImage(COLS * 4 * T, rows * 4 * T);
	PAIRS.forEach((pair, b) => {
		const [file, invert] = source(season, b);
		const sheet = readPng(path.join(DIR, file + ".png")), meta = JSON.parse(fs.readFileSync(path.join(DIR, file + ".json"), "utf8"));
		for(const t of meta.tiles){
			let key = ["NW", "NE", "SW", "SE"].reduce((v, k, i) => v | ((t.corners[k] === "upper") ? 8 >> i : 0), 0);
			if(invert) key = 15 - key;
			const sx = (t.k % 4) * T, sy = Math.floor(t.k / 4) * T;
			const dx = ((b % COLS) * 4 + key % 4) * T, dy = (Math.floor(b / COLS) * 4 + Math.floor(key / 4)) * T;
			for(let y = 0; y < T; y++) for(let x = 0; x < T; x++){
				const s = ((sy + y) * sheet.w + sx + x) * 4, d = ((dy + y) * atlas.w + dx + x) * 4;
				for(let c = 0; c < 3; c++) atlas.px[d + c] = sheet.px[s + c];
				atlas.px[d + 3] = 255;   // opaque: ground covers everything
			}
		}
	});
	const f = path.join(OUT, `ground_${season}.png`);
	writePng(f, atlas);
	console.log(`${f}: ${atlas.w} x ${atlas.h}`);
	if(process.argv.includes("--import")) execFileSync(process.execPath, [path.join(ROOT, "tools", "rooms", "tileset_import.js"), f, "ground_" + season], {stdio: "inherit"});
}
module.exports = {PAIRS, COLS};
