// The user's main roads, traced from their drawing: black strokes drawn over the in-game world map (spr_world_map, 8
// pixels a tile, world row -32 at the top) - thinned to a centreline (Zhang-Suen), followed into lines, joined where
// they meet, straightened - written as design/map/user_roads.json in world tiles. tools/map/blueprint.js makes these
// the main roads; the other roads become side roads (or go, where they only run alongside these).
//
//   node tools/map/drawn_roads.js <drawing.png> [scale]
//     scale: the drawing's pixels to the map's (the map is 2008 wide; default: 2008 / the drawing's width)
const fs = require("fs");
const path = require("path");
const {readPng, writePng, newImage} = require("../rooms/png.js");
const ROOT = path.join(__dirname, "..", "..");
const [file, scArg] = process.argv.slice(2);
const im = readPng(file);
const SC = scArg ? Number(scArg) : 2008 / im.w;
const W = im.w, H = im.h;

// 1. The strokes: near-black pixels (the map's own darkest is a building outline, a few pixels each - small specks
// are dropped below)
let m = new Uint8Array(W * H);
for(let i = 0; i < W * H; i++){ const r = im.px[i * 4], g = im.px[i * 4 + 1], b = im.px[i * 4 + 2]; if(r + g + b < 110 && Math.max(r, g, b) - Math.min(r, g, b) < 40 && im.px[i * 4 + 3] > 128) m[i] = 1; }   // dark and grey: the pen, not a dark roof
{ const seen = new Uint8Array(W * H);
  for(let s = 0; s < W * H; s++){
	if(!m[s] || seen[s]) continue;
	const part = [s], st = [s]; seen[s] = 1;
	while(st.length){ const i = st.pop(), x = i % W, y = (i - x) / W;
		for(let dy = -1; dy <= 1; dy++) for(let dx = -1; dx <= 1; dx++){ const xx = x + dx, yy = y + dy, j = yy * W + xx;
			if(xx >= 0 && yy >= 0 && xx < W && yy < H && m[j] && !seen[j]){ seen[j] = 1; st.push(j); part.push(j); } } }
	// the drawing spans the map; a dark roof or outline is small: only parts at least 150 pixels across are kept
	let x0 = W, y0 = H, x1 = 0, y1 = 0; for(const i of part){ const x = i % W, y = (i - x) / W; x0 = Math.min(x0, x); x1 = Math.max(x1, x); y0 = Math.min(y0, y); y1 = Math.max(y1, y); }
	const diag = Math.hypot(x1 - x0, y1 - y0);
	if(diag < 150) for(const i of part) m[i] = 0;   // (the drawing is big; a roof, an outline or a speck is not)
  } }
// thickened by 2 pixels, so a stroke drawn thin in places stays whole
for(let pass = 0; pass < 2; pass++){ const n = m.slice(); for(let y = 1; y < H - 1; y++) for(let x = 1; x < W - 1; x++){ const i = y * W + x; if(m[i]) continue;
	if(m[i - 1] || m[i + 1] || m[i - W] || m[i + W]) n[i] = 1; } m = n; }


// 2. Thinned to a one-pixel centreline (Zhang-Suen)
const at = (x, y) => (x >= 0 && y >= 0 && x < W && y < H) ? m[y * W + x] : 0;
for(let changed = true; changed;){
	changed = false;
	for(const step of [0, 1]){
		const del = [];
		for(let y = 1; y < H - 1; y++) for(let x = 1; x < W - 1; x++){
			if(!m[y * W + x]) continue;
			const p = [at(x, y - 1), at(x + 1, y - 1), at(x + 1, y), at(x + 1, y + 1), at(x, y + 1), at(x - 1, y + 1), at(x - 1, y), at(x - 1, y - 1)];
			const B = p.reduce((a, b) => a + b, 0);
			if(B < 2 || B > 6) continue;
			let A = 0; for(let k = 0; k < 8; k++) if(!p[k] && p[(k + 1) % 8]) A++;
			if(A !== 1) continue;
			if(step === 0 ? (p[0] * p[2] * p[4] || p[2] * p[4] * p[6]) : (p[0] * p[2] * p[6] || p[0] * p[4] * p[6])) continue;
			del.push(y * W + x);
		}
		for(const i of del) m[i] = 0;
		if(del.length) changed = true;
	}
}

// 3. Followed into lines: from each end or junction along the skeleton to the next
const nb = i => { const x = i % W, y = (i - x) / W, o = []; for(let dy = -1; dy <= 1; dy++) for(let dx = -1; dx <= 1; dx++){
	if(!dx && !dy) continue; if(at(x + dx, y + dy)) o.push((y + dy) * W + x + dx); } return o; };
const isNode = i => nb(i).length !== 2;
const used = new Set(), lines = [];
const key = (a, b) => a < b ? a + "," + b : b + "," + a;
const walk = (start, next) => { const pts = [start]; let prev = start, cur = next;
	while(true){ pts.push(cur); used.add(key(prev, cur)); if(isNode(cur)) break;
		const n = nb(cur).filter(j => j !== prev); if(!n.length) break; prev = cur; cur = n[0]; if(cur === start) { pts.push(cur); break; } }
	return pts; };
for(let i = 0; i < W * H; i++){ if(!m[i] || !isNode(i)) continue; for(const j of nb(i)) if(!used.has(key(i, j))) lines.push(walk(i, j)); }
for(let i = 0; i < W * H; i++){ if(!m[i]) continue; for(const j of nb(i)) if(!used.has(key(i, j))) lines.push(walk(i, j)); }   // loops

// 4. In world tiles, straightened; scraps (a few pixels between two close junctions) dropped
const toTile = i => { const x = i % W, y = (i - x) / W; return [x * SC / 8, y * SC / 8 - 32]; };
const segDist = (p, a, b) => { const dx = b[0] - a[0], dy = b[1] - a[1], L = dx * dx + dy * dy;
	const t = L ? Math.max(0, Math.min(1, ((p[0] - a[0]) * dx + (p[1] - a[1]) * dy) / L)) : 0; return Math.hypot(p[0] - a[0] - t * dx, p[1] - a[1] - t * dy); };
const simplify = (pts, eps) => { if(pts.length < 3) return pts; let k = -1, d = 0;
	for(let i = 1; i < pts.length - 1; i++){ const e = segDist(pts[i], pts[0], pts[pts.length - 1]); if(e > d){ d = e; k = i; } }
	return d <= eps ? [pts[0], pts[pts.length - 1]] : simplify(pts.slice(0, k + 1), eps).slice(0, -1).concat(simplify(pts.slice(k), eps)); };
const len = pts => { let L = 0; for(let i = 1; i < pts.length; i++) L += Math.hypot(pts[i][0] - pts[i - 1][0], pts[i][1] - pts[i - 1][1]); return L; };
const out = lines.map(l => simplify(l.map(toTile), 0.6)).map(l => l.map(p => p.map(v => Math.round(v * 10) / 10)));
fs.writeFileSync(path.join(ROOT, "design", "map", "user_roads.json"), JSON.stringify({note: "The user's main roads, traced from their drawing on the world map (tools/map/drawn_roads.js), in world tiles", roads: out}));
// a check picture: the traced lines over the drawing
const chk = newImage(W, H); chk.px.set(im.px);
for(const l of out) for(let i = 0; i < l.length - 1; i++){ const n = Math.ceil(Math.hypot(l[i + 1][0] - l[i][0], l[i + 1][1] - l[i][1]) * 8 / SC) + 1;
	for(let t = 0; t <= n; t++){ const x = Math.round((l[i][0] + (l[i + 1][0] - l[i][0]) * t / n) * 8 / SC), y = Math.round((l[i][1] + 32 + (l[i + 1][1] - l[i][1]) * t / n) * 8 / SC);
		for(let d = -1; d <= 1; d++) for(let e = -1; e <= 1; e++){ const j = ((y + d) * W + x + e) * 4; if(j >= 0 && j < chk.px.length){ chk.px[j] = 255; chk.px[j + 1] = 40; chk.px[j + 2] = 200; } } } }
writePng(path.join(ROOT, "build", "user_roads_check.png"), chk);
console.log(`user_roads.json: ${out.length} lines, ${Math.round(out.reduce((a, l) => a + len(l), 0))} tiles of road`);
