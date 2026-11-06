// Check a built room's walkable ground for parts cut off from the rest (by the villagers' walk grid, tools/rooms/walk.js):
// lists each separate part with its size and a cell in it, and which doors and named points are in it.
//   node tools/world2/islands.js rm_phoenix [--png out.png]   (each part coloured, on a cell-per-pixel picture)
const path = require("path");
const {roomWalk} = require("../rooms/walk.js");
const {writePng, newImage} = require("../rooms/png.js");
const name = process.argv[2], pngArg = process.argv.indexOf("--png");
const spec = require(path.join(__dirname, "..", "rooms", "specs", name + ".js"));
const w = roomWalk(name, spec), {W, H, cost} = w;
const part = new Int32Array(W * H).fill(-1), parts = [];
for(let s = 0; s < W * H; s++){
	if(cost[s] <= 0 || part[s] >= 0) continue;
	const id = parts.length, st = [s]; let n = 0; part[s] = id;
	while(st.length){ const i = st.pop(); n++; const x = i % W, y = (i - x) / W;
		for(const [dx, dy] of [[1, 0], [-1, 0], [0, 1], [0, -1]]){ const xx = x + dx, yy = y + dy, j = yy * W + xx;
			if(xx >= 0 && yy >= 0 && xx < W && yy < H && cost[j] > 0 && part[j] < 0){ part[j] = id; st.push(j); } } }
	parts.push({id, n, at: [s % W, Math.floor(s / W)], doors: [], points: []});
}
const partAt = (px, py) => { const c = Math.floor(px / 32), r = Math.floor(py / 32);
	for(let d = 0; d < 3; d++) for(let y = r - d; y <= r + d; y++) for(let x = c - d; x <= c + d; x++) if(x >= 0 && y >= 0 && x < W && y < H && part[y * W + x] >= 0) return part[y * W + x];
	return -1; };
for(const d of w.doors){ const p = partAt(d[0], d[1]); if(p >= 0) parts[p].doors.push(d[2]); }
for(const [k, p] of Object.entries(spec.points || {})){ const q = partAt(p[0], p[1]); if(q >= 0) parts[q].points.push(k); }
const big = parts.filter(p => p.n >= 20 || p.doors.length || p.points.length).sort((a, b) => b.n - a.n);
console.log(name + ": " + parts.length + " parts, " + big.length + " that matter");
for(const p of big) console.log(`  part ${p.id}: ${p.n} cells at ${p.at}  doors: ${[...new Set(p.doors)].join(" ") || "-"}  points: ${p.points.slice(0, 8).join(" ")}${p.points.length > 8 ? " +" + (p.points.length - 8) : ""}`);
if(pngArg > 0){
	const im = newImage(W, H), cols = [[230, 80, 80], [80, 200, 90], [80, 130, 230], [230, 200, 60], [200, 90, 220], [70, 210, 220], [240, 140, 60]];
	for(let i = 0; i < W * H; i++){ const p = part[i], c = p < 0 ? [20, 20, 30] : cols[big.findIndex(b => b.id === p) >= 0 ? big.findIndex(b => b.id === p) % cols.length : 0].map(v => p < 0 ? v : (big.some(b => b.id === p) ? v : 90));
		im.px[i * 4] = c[0]; im.px[i * 4 + 1] = c[1]; im.px[i * 4 + 2] = c[2]; im.px[i * 4 + 3] = 255; }
	writePng(process.argv[pngArg + 1], im);
}
