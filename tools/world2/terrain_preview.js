// Preview Cedar & Sea's ground drawn with the PixelLab terrain tilesets (art/terrain_pl): Wang corner tiles in a dual
// grid - each drawn tile sits on the corner where four map cells meet and shows those four cells' terrains. A tileset
// holds two terrains (lower / upper); where a tile's corners have a pair with no tileset, or three or more terrains,
// the less important ones give way (to grass, or to whichever of the pair is near). Cliffs, buildings and props are
// left out: this is the ground alone.
//
//   node tools/world2/terrain_preview.js <season> <out.png> [x1 y1 x2 y2] [scale]
//     season: spring | summer | autumn | winter; the box in world tiles (default: the whole world); scale: pixels a
//     tile in the picture (32 = full size, 8 = a quarter)
const fs = require("fs");
const path = require("path");
const {readPng, writePng, newImage} = require("../rooms/png.js");
const ROOT = path.join(__dirname, "..", "..");
const DIR = path.join(ROOT, "art", "terrain_pl");
const G = JSON.parse(fs.readFileSync(path.join(ROOT, "design", "map", "world_grid.json"), "utf8"));
const M = G.M || 30;

const [season = "summer", out = "terrain_preview.png", ...rest] = process.argv.slice(2);
const box = rest.length >= 4 ? rest.slice(0, 4).map(Number) : [-M, -M, G.rows[0].length - M - 1, G.rows.length - M - 1];
const S = rest.length >= 5 ? Number(rest[4]) : 8;

// Blueprint kind -> ground terrain
const KIND = {D: "deep", S: "deep", s: "shallow", "~": "shallow", p: "shallow", _: "sand", r: "rock", ".": "grass", m: "grass",
	F: "grass", P: "grass", C: "rock", c: "rock", "1": "grass", "2": "grass", "3": "rock", "4": "snow", ":": "road", ",": "dirt",
	q: "concrete", "=": "dirt", B: "grass", u: "trail", z: "trail", t: "trail"};
// The tilesets: [file, lower terrain, upper terrain]
const SETS = [
	[`t_${season}_dirt`, "grass", "dirt"], [`t_${season}_road`, "grass", "road"], [`t_${season}_sand`, "grass", "sand"],
	[`t_${season}_trail`, "grass", "trail"], [`t_${season}_concrete`, "grass", "concrete"],
	["t_water_shore", "shallow", "sand"], ["t_water_deep", "deep", "shallow"],
	["t_mountain_rock", "grass", "rock"], ["t_mountain_snow", "rock", "snow"],
].filter(([f]) => fs.existsSync(path.join(DIR, f + ".png")));
const tiles = {};   // "a|b" -> {sheet, T, byCorners: {"NW,NE,SW,SE as 0/1 upper": index}}
for(const [f, lo, up] of SETS){
	const meta = JSON.parse(fs.readFileSync(path.join(DIR, f + ".json"), "utf8")), sheet = readPng(path.join(DIR, f + ".png"));
	const by = {};
	for(const t of meta.tiles){ const c = t.corners; by[["NW", "NE", "SW", "SE"].map(k => c[k] === "upper" ? 1 : 0).join("")] = t.k; }
	tiles[lo + "|" + up] = {sheet, T: meta.tile, by, lo, up};
}
const pairOf = (a, b) => tiles[a + "|" + b] ? [a, b] : tiles[b + "|" + a] ? [b, a] : null;
// Which way a terrain gives way when its pair has no tileset: towards its neighbour in this chain
const GIVE = {deep: "shallow", shallow: "sand", sand: "grass", dirt: "grass", road: "grass", trail: "grass", concrete: "grass", rock: "grass", snow: "rock"};
const RANK = {deep: 0, shallow: 1, sand: 2, grass: 3, rock: 4, snow: 5, dirt: 6, trail: 6, road: 7, concrete: 7};

const terr = (x, y) => KIND[(G.rows[y + M] || "")[x + M]] || "deep";
const [x1, y1, x2, y2] = box, W = x2 - x1 + 1, H = y2 - y1 + 1;
const img = newImage(W * S, H * S);
const put = (set, idx, X, Y) => {   // tile idx of a set, drawn S x S at (X, Y)
	const {sheet, T} = set, sx = (idx % 4) * T, sy = Math.floor(idx / 4) * T;
	for(let y = 0; y < S; y++) for(let x = 0; x < S; x++){
		const ox = X + x, oy = Y + y;
		if(ox < 0 || oy < 0 || ox >= img.w || oy >= img.h) continue;
		const s = ((sy + Math.floor(y * T / S)) * sheet.w + sx + Math.floor(x * T / S)) * 4, d = (oy * img.w + ox) * 4;
		for(let c = 0; c < 4; c++) img.px[d + c] = sheet.px[s + c];
	}
};
let fallbacks = 0;
// The dual grid: the tile for corner (x, y) covers the four cells x-1..x, y-1..y and sits half a cell up and left
for(let y = y1; y <= y2 + 1; y++) for(let x = x1; x <= x2 + 1; x++){
	let c = [terr(x - 1, y - 1), terr(x, y - 1), terr(x - 1, y), terr(x, y)];   // NW NE SW SE
	// down to at most two terrains that have a tileset together
	for(let guard = 0; guard < 6; guard++){
		const u = [...new Set(c)];
		if(u.length === 1 || (u.length === 2 && pairOf(u[0], u[1]))) break;
		// the least important terrain here gives way
		const weakest = u.sort((a, b) => (c.filter(t => t === a).length - c.filter(t => t === b).length) || (RANK[a] - RANK[b]))[0];
		c = c.map(t => t === weakest ? (GIVE[t] || "grass") : t);
		fallbacks++;
	}
	const u = [...new Set(c)];
	let set, key;
	if(u.length === 1){
		const p = Object.values(tiles).find(t => t.lo === u[0]) || Object.values(tiles).find(t => t.up === u[0]);
		if(!p) continue;
		set = p; key = (p.lo === u[0]) ? "0000" : "1111";
	} else {
		const pr = pairOf(u[0], u[1]);
		if(!pr) continue;
		set = tiles[pr[0] + "|" + pr[1]]; key = c.map(t => t === pr[1] ? 1 : 0).join("");
	}
	const idx = set.by[key];
	if(idx === undefined) continue;
	put(set, idx, (x - x1) * S - S / 2, (y - y1) * S - S / 2);
}
writePng(out, img);
console.log(`${out}: ${img.w} x ${img.h}, ${season}, ${SETS.length} tilesets, ${fallbacks} corners gave way`);
