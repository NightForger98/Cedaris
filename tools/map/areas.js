// The merging proposal: the nine new rooms (big areas) the old 25 become, drawn over the new map - each area tinted,
// its border drawn, its name and size (in tiles) on it.
//   node tools/map/areas.js   (after node tools/map/blueprint.js)
// Writes design/map/areas.json (each area: the rectangles it's made of, in world tiles, and the old rooms in it) and
// design/map/areas_proposal.png.
const fs = require("fs");
const path = require("path");
const {readPng, writePng} = require("../rooms/png.js");
const {text} = require("./font.js");
const OUT = path.join(__dirname, "..", "..", "design", "map");
const M = 30, S = 4;

// Each area as rectangles [x1, y1, x2, y2] in world tiles (inclusive); later areas don't take tiles an earlier one has
const AREAS = [
	{name: "Bunny Island", rects: [[46, -30, 94, -9]], old: [], col: [255, 170, 200], label: [70, -24]},   // by ferry only
	{name: "Phoenix Bay", rects: [[14, -20, 128, 15], [128, -20, 180, 18]], old: ["rm_manara (its lighthouse stays in town)", "rm_starsand", "rm_hangar"], col: [120, 210, 255], label: [150, 8]},
	{name: "Beirut", rects: [[0, 16, 136, 95]], old: ["rm_wellshead", "rm_redstreet", "rm_downtown", "rm_gracetower", "rm_verdun", "rm_uptown", "rm_ovenswindow", "rm_manara", "rm_pigeonrocks"], col: [255, 210, 90]},
	{name: "The Mountain", rects: [[180, -24, 250, 17], [137, 18, 250, 85], [137, 86, 152, 95]], old: ["rm_plummet", "rm_beaconhill", "rm_victoryhill"], col: [200, 150, 110]},
	{name: "Sunset Coast", rects: [[0, 96, 44, 199]], old: ["rm_whitesand", "rm_olivebay", "rm_southbeach"], col: [255, 236, 150]},
	{name: "The Outskirts", rects: [[45, 96, 152, 147]], old: ["rm_winghill", "rm_dahya", "rm_resolve"], col: [170, 230, 120]},
	{name: "Whispering Woods", rects: [[153, 86, 250, 147], [201, 148, 250, 199]], old: ["rm_yarzeh"], col: [90, 200, 120]},
	{name: "The Farm", rects: [[45, 148, 99, 199]], old: ["rm_1"], col: [230, 160, 90]},
	{name: "The Countryside", rects: [[100, 148, 200, 199]], old: ["rm_sthereza", "rm_frere", "rm_abda"], col: [210, 140, 230]},
];

// Which area each tile is in
const W = 250 + M + 2, H = 200 + M + 2, owner = Array.from({length: H}, () => Array(W).fill(-1));
AREAS.forEach((a, i) => { for(const [x1, y1, x2, y2] of a.rects) for(let y = y1; y <= y2; y++) for(let x = x1; x <= x2; x++){
	const gx = x + M, gy = y + M;
	if(gx >= 0 && gy >= 0 && gx < W && gy < H && owner[gy][gx] === -1) owner[gy][gx] = i;
} });

const P = readPng(path.join(OUT, "world_blueprint_plain.png"));
const put = (x, y, c, a) => { if(x < 0 || y < 0 || x >= P.w || y >= P.h) return; const k = (y * P.w + x) * 4; for(let q = 0; q < 3; q++) P.px[k + q] = Math.round(P.px[k + q] * (1 - a) + c[q] * a); };
// A light tint over each area, and a solid border (3 px) where it meets another area or the open sea
for(let gy = 0; gy < H; gy++) for(let gx = 0; gx < W; gx++){
	const o = owner[gy][gx];
	if(o === -1) continue;
	const c = AREAS[o].col;
	for(let dy = 0; dy < S; dy++) for(let dx = 0; dx < S; dx++) put(gx * S + dx, gy * S + dy, c, 0.16);
	const nb = [[1, 0], [-1, 0], [0, 1], [0, -1]];
	for(const [ox, oy] of nb){
		const n = (owner[gy + oy] || [])[gx + ox];
		if(n === o) continue;
		for(let t = 0; t < S; t++) for(let w = 0; w < 2; w++){
			const px = gx * S + (ox === 1 ? S - 1 - w : ox === -1 ? w : t), py = gy * S + (oy === 1 ? S - 1 - w : oy === -1 ? w : t);
			put(px, py, [20, 16, 14], 0.9);
		}
	}
}
// Names and sizes, at each area's middle (its biggest rectangle's)
const info = [];
AREAS.forEach((a, i) => {
	let n = 0, x1 = 1e9, y1 = 1e9, x2 = -1e9, y2 = -1e9;
	for(let gy = 0; gy < H; gy++) for(let gx = 0; gx < W; gx++) if(owner[gy][gx] === i){ n++; x1 = Math.min(x1, gx); y1 = Math.min(y1, gy); x2 = Math.max(x2, gx); y2 = Math.max(y2, gy); }
	const big = a.rects.slice().sort((p, q) => (q[2] - q[0]) * (q[3] - q[1]) - (p[2] - p[0]) * (p[3] - p[1]))[0];
	const lx = a.label ? a.label[0] : (big[0] + big[2]) / 2, ly = a.label ? a.label[1] : (big[1] + big[3]) / 2;
	const cx = (lx + M) * S, cy = (ly + M) * S;
	text(P, a.name, cx, cy - 16, 3, [255, 245, 200]);
	text(P, (x2 - x1 + 1) + " x " + (y2 - y1 + 1) + " tiles", cx, cy + 10, 2, [255, 255, 255]);
	info.push({name: a.name, rects: a.rects, size: [x2 - x1 + 1, y2 - y1 + 1], tiles: n, old: a.old});
});
// The ways through: wherever a road, lane, bridge, rail, square or beach crosses the border between two areas. Paths
// should match the map (Stardew's most common complaint is ways that don't): exactly these, and nowhere else. Each is
// drawn as a ring with the two areas' numbers, and listed in areas.json.
const BP = readPng(path.join(OUT, "world_blueprint.png"));
const KIND = {"170,168,160": "road", "196,164,106": "lane", "120,84,52": "pier", "92,78,64": "rail", "210,200,180": "plaza",
	"236,214,140": "sand", "176,162,136": "rocky", "214,204,184": "stairs"};
const walk = (gx, gy) => { if(gx < 0 || gy < 0 || gx >= BP.w || gy >= BP.h) return false; const k = (gy * BP.w + gx) * 4;
	return !!KIND[BP.px[k] + "," + BP.px[k + 1] + "," + BP.px[k + 2]]; };
const cross = [];
for(let gy = 0; gy < H - 1; gy++) for(let gx = 0; gx < W - 1; gx++){
	const o = owner[gy][gx];
	if(o === -1 || !walk(gx, gy)) continue;
	for(const [ox, oy] of [[1, 0], [0, 1]]){
		const n = owner[gy + oy][gx + ox];
		if(n !== -1 && n !== o && walk(gx + ox, gy + oy)) cross.push({gx, gy, a: Math.min(o, n), b: Math.max(o, n)});
	}
}
// Crossings of the same pair of areas within 4 tiles of each other are one way through
const ways = [];
for(const c of cross){
	const w = ways.find(q => q.a === c.a && q.b === c.b && q.pts.some(p => Math.abs(p.gx - c.gx) + Math.abs(p.gy - c.gy) <= 4));
	if(w) w.pts.push(c); else ways.push({a: c.a, b: c.b, pts: [c]});
}
for(const w of ways){
	const cx = w.pts.reduce((t, p) => t + p.gx, 0) / w.pts.length, cy = w.pts.reduce((t, p) => t + p.gy, 0) / w.pts.length;
	w.at = [Math.round(cx) - M, Math.round(cy) - M];
	const px = Math.round((cx + 0.5) * S), py = Math.round((cy + 0.5) * S);
	for(let dy = -8; dy <= 8; dy++) for(let dx = -8; dx <= 8; dx++){ const d = Math.hypot(dx, dy);
		if(d <= 8 && d >= 5.5) put(px + dx, py + dy, [255, 60, 60], 1); else if(d < 5.5) put(px + dx, py + dy, [255, 255, 255], 0.75); }
}
writePng(path.join(OUT, "areas_proposal.png"), P);
fs.writeFileSync(path.join(OUT, "areas.json"), JSON.stringify({note: "World tiles as in world_layout.json; each area is one room. size: its bounding box. ways: where you can walk from one area to the next (a road, lane, bridge, rail, square or beach crossing the border) - exactly these, nowhere else. Room edges should follow cliffs, the river, sea or forest, with the way through at a road.",
	areas: info, ways: ways.map(w => ({between: [AREAS[w.a].name, AREAS[w.b].name], at: w.at, wide: w.pts.length})),
	unlocked: [{between: ["Phoenix Bay", "Bunny Island"], by: "the ferry from Starsand Pier"}, {between: ["Phoenix Bay", "The Mountain"], by: "the cable car (a town project)"}, {along: "the Corniche and Damascus Road", by: "the tram (a town project): fast travel between its stops"}]}, null, 1));
console.log(ways.length + " ways through:");
for(const w of ways) console.log("  " + AREAS[w.a].name + " - " + AREAS[w.b].name + " at " + w.at.join(","));
for(const a of info) console.log(a.name.padEnd(18), (a.size[0] + "x" + a.size[1]).padEnd(9), "old: " + a.old.join(", "));
