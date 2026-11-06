// Beirut's real roads (OpenStreetMap, (c) OpenStreetMap contributors, ODbL) warped onto the blueprint: the user's
// map is Beirut redrawn for the game - the port moved, districts stretched - so a plain scale won't do. Anchors (real
// places at their blueprint spots) give an affine fit, and each anchor's leftover pulls the land near it (inverse
// distance weighting), so every anchor lands exactly where the blueprint has it and the roads bend smoothly between.
//
//   node tools/map/osm_roads.js [--fetch]
//     --fetch: get the roads, coastline and river from the Overpass API first (cached in build/osm_beirut_raw.json)
//   writes design/map/osm_beirut.json: {roads: [{k, pts}], ...} in blueprint tiles - k: "road" (motorways, trunk,
//   primary and secondary roads) or "lane" (tertiary streets) - and design/map/osm_on_blueprint.png (the check)
// tools/map/blueprint.js draws them in the town (TOWN_BOX) in place of its own roads there.
const fs = require("fs");
const path = require("path");
const ROOT = path.join(__dirname, "..", "..");
const RAW = path.join(ROOT, "build", "osm_beirut_raw.json");

// [blueprint x, y, lat, lon, place]
const ANCHORS = [
	[13.5, 33.5, 33.8985, 35.4805, "Manara lighthouse"], [8, 56, 33.8899, 35.4697, "Pigeon Rocks (Raouche)"],
	[72.5, 6.5, 33.9020, 35.5050, "Biel"], [170, -10, 33.9010, 35.5180, "the port silos"],
	[123.5, 24, 33.8960, 35.5260, "Mar Mikhael station"], [123.5, 46.5, 33.8930, 35.5185, "Sursock"],
	[117, 68, 33.8784, 35.5153, "the National Museum"], [145, 22, 33.8930, 35.5410, "Bourj Hammoud"],
];

function solve3(rows, vals){
	const M = [[0, 0, 0], [0, 0, 0], [0, 0, 0]], b = [0, 0, 0];
	rows.forEach((r, k) => { for(let i = 0; i < 3; i++){ b[i] += r[i] * vals[k]; for(let j = 0; j < 3; j++) M[i][j] += r[i] * r[j]; } });
	for(let i = 0; i < 3; i++){
		let p = i; for(let r = i + 1; r < 3; r++) if(Math.abs(M[r][i]) > Math.abs(M[p][i])) p = r;
		[M[i], M[p]] = [M[p], M[i]]; [b[i], b[p]] = [b[p], b[i]];
		for(let r = 0; r < 3; r++) if(r !== i){ const f = M[r][i] / M[i][i]; for(let j = i; j < 3; j++) M[r][j] -= f * M[i][j]; b[r] -= f * b[i]; }
	}
	return b.map((v, i) => v / M[i][i]);
}
const rows = ANCHORS.map(a => [a[3], a[2], 1]);
const cx = solve3(rows, ANCHORS.map(a => a[0])), cy = solve3(rows, ANCHORS.map(a => a[1]));
const affine = (lat, lon) => [cx[0] * lon + cx[1] * lat + cx[2], cy[0] * lon + cy[1] * lat + cy[2]];
const LEFT = ANCHORS.map(a => { const [x, y] = affine(a[2], a[3]); return {x, y, dx: a[0] - x, dy: a[1] - y}; });
function warp(lat, lon){
	const [x, y] = affine(lat, lon);
	let sw = 0, sx = 0, sy = 0;
	for(const r of LEFT){
		const d2 = (x - r.x) ** 2 + (y - r.y) ** 2;
		if(d2 < 1e-6) return [x + r.dx, y + r.dy];
		const w = 1 / (d2 * d2); sw += w; sx += w * r.dx; sy += w * r.dy;
	}
	return [x + sx / sw, y + sy / sw];
}

async function fetchRaw(){
	const q = `[out:json][timeout:90];(way["highway"~"^(motorway|trunk|primary|secondary|tertiary|motorway_link|trunk_link|primary_link)$"](33.855,35.465,33.915,35.56);way["natural"="coastline"](33.855,35.465,33.915,35.56);way["waterway"="river"](33.855,35.465,33.915,35.60););out geom;`;
	const r = await fetch("https://overpass-api.de/api/interpreter", {method: "POST",
		headers: {"User-Agent": "CedarAndSea-mapper/1.0", "Content-Type": "application/x-www-form-urlencoded"}, body: "data=" + encodeURIComponent(q)});
	fs.mkdirSync(path.dirname(RAW), {recursive: true});
	fs.writeFileSync(RAW, await r.text());
}

(async () => {
	if(process.argv.includes("--fetch") || !fs.existsSync(RAW)) await fetchRaw();
	const raw = JSON.parse(fs.readFileSync(RAW, "utf8"));
	const KIND = {motorway: "road", trunk: "road", primary: "road", secondary: "road", tertiary: "lane"};
	// slim: every main road 2 tiles wide (the user: "narrower and more slim"), the streets 1 (blueprint.js widens them)
	const WIDE_K = {road: 0.5, lane: 0};   // every main road 2 tiles wide, every street 1 (the user: slim, and streets smaller)
	const out = {note: "Beirut's roads from OpenStreetMap ((c) OpenStreetMap contributors, ODbL), warped onto the blueprint by tools/map/osm_roads.js", roads: []};
	const segDist = (p, a, b) => { const dx = b[0] - a[0], dy = b[1] - a[1], L = dx * dx + dy * dy;
		const t = L ? Math.max(0, Math.min(1, ((p[0] - a[0]) * dx + (p[1] - a[1]) * dy) / L)) : 0;
		return Math.hypot(p[0] - a[0] - t * dx, p[1] - a[1] - t * dy); };
	const lineDist = (p, pts) => { let d = 1e9; for(let i = 0; i < pts.length - 1; i++) d = Math.min(d, segDist(p, pts[i], pts[i + 1])); return d; };
	const len = pts => { let L = 0; for(let i = 1; i < pts.length; i++) L += Math.hypot(pts[i][0] - pts[i - 1][0], pts[i][1] - pts[i - 1][1]); return L; };
	const simplify = (pts, eps) => { if(pts.length < 3) return pts; let k = -1, dmax = 0;
		for(let i = 1; i < pts.length - 1; i++){ const d = segDist(pts[i], pts[0], pts[pts.length - 1]); if(d > dmax){ dmax = d; k = i; } }
		return dmax <= eps ? [pts[0], pts[pts.length - 1]] : simplify(pts.slice(0, k + 1), eps).slice(0, -1).concat(simplify(pts.slice(k), eps)); };
	const sample = pts => { const o = []; for(let i = 0; i < pts.length - 1; i++){ const n = Math.max(1, Math.ceil(len([pts[i], pts[i + 1]])));
		for(let t = 0; t < n; t++) o.push([pts[i][0] + (pts[i + 1][0] - pts[i][0]) * t / n, pts[i][1] + (pts[i + 1][1] - pts[i][1]) * t / n]); } o.push(pts[pts.length - 1]); return o; };
	const along = (a, b, d) => { const sm = sample(a); return sm.filter(p => lineDist(p, b) < d).length / sm.length; };
	const D = (p, q) => Math.hypot(p[0] - q[0], p[1] - q[1]);

	// 1. The pieces, warped, by street: OpenStreetMap splits every street at every junction, and gives a road with a
	// carriageway each way as two one-way lines; pieces with the same name and kind make one street
	const groups = {};
	for(const e of raw.elements){
		const h = e.tags.highway || "";
		if(!KIND[h] || !e.geometry) continue;   // (ramps, the *_link roads, left out: at a game's scale they pave whole blocks)
		const pts = e.geometry.map(p => warp(p.lat, p.lon));
		const name = e.tags["name:en"] || e.tags.name || "#" + e.id;
		(groups[KIND[h] + "|" + name] = groups[KIND[h] + "|" + name] || []).push(pts);
	}
	// 2. Each street's pieces chained end to end into whole lines (the nearest loose ends joined, up to 2 tiles apart)
	const chains = [];
	for(const [key, pieces] of Object.entries(groups)){
		const k = key.split("|")[0], left = pieces.map(p => p.slice());
		while(left.length){
			let line = left.shift(), grew = true;
			while(grew){ grew = false;
				for(let i = 0; i < left.length; i++){ const p = left[i], h0 = line[0], t0 = line[line.length - 1];
					if(D(t0, p[0]) < 2){ line = line.concat(p.slice(1)); }
					else if(D(t0, p[p.length - 1]) < 2){ line = line.concat(p.slice(0, -1).reverse()); }
					else if(D(h0, p[p.length - 1]) < 2){ line = p.slice(0, -1).concat(line); }
					else if(D(h0, p[0]) < 2){ line = p.slice(1).reverse().concat(line); }
					else continue;
					left.splice(i, 1); grew = true; break; } }
			chains.push({k, name: key.split("|")[1], pts: simplify(line, 1.2)});
		}
	}
	// 3. Keep the streets that matter: the longest first; a line running alongside one already kept (the other
	// carriageway, or a street beside a road) goes; short unnamed bits go
	chains.sort((a, b) => (a.k === b.k ? 0 : a.k === "road" ? -1 : 1) || len(b.pts) - len(a.pts));
	const kept = [];
	for(const c of chains){
		const L = len(c.pts), named = !c.name.startsWith("#");
		if(L < (c.k === "road" ? (named ? 6 : 14) : (named ? 8 : 16))) continue;
		if(kept.some(b => along(c.pts, b.pts, c.k === "road" && b.k === "road" ? 3 : 3.5) >= 0.5)) continue;
		kept.push(c);
	}
	// 4. Loose ends: one that stops just short of another line is joined to it; a short line still left hanging goes
	const BOX = [6, -4, 140, 104], atEdge = p => p[0] <= BOX[0] + 2 || p[1] <= BOX[1] + 2 || p[0] >= BOX[2] - 2 || p[1] >= BOX[3] - 2;
	const nearestOn = (p, pts) => { let best = null, bd = 1e9; for(let i = 0; i < pts.length - 1; i++){ const a2 = pts[i], b2 = pts[i + 1], dx = b2[0] - a2[0], dy = b2[1] - a2[1], L = dx * dx + dy * dy;
		const t = L ? Math.max(0, Math.min(1, ((p[0] - a2[0]) * dx + (p[1] - a2[1]) * dy) / L)) : 0, q = [a2[0] + t * dx, a2[1] + t * dy], d = D(p, q); if(d < bd){ bd = d; best = q; } } return [best, bd]; };
	for(const c of kept) for(const end of [0, 1]){
		const e = end ? c.pts[c.pts.length - 1] : c.pts[0];
		if(atEdge(e)) continue;
		let best = null, bd = 1e9;
		for(const o of kept){ if(o === c) continue; const [q, d] = nearestOn(e, o.pts); if(d < bd){ bd = d; best = q; } }
		if(bd > 0.8 && bd < 5){ if(end) c.pts.push(best); else c.pts.unshift(best); }
		c.loose = c.loose || bd >= 5;
	}
	const final = kept.filter(c => !(c.loose && len(c.pts) < 16));
	out.roads = final.map(c => ({k: c.k, w: WIDE_K[c.k], name: c.name.startsWith("#") ? undefined : c.name, pts: c.pts.map(p => p.map(v => Math.round(v * 10) / 10))}));
	console.log(`  ${chains.length} whole streets from the pieces; kept ${kept.length}, ${kept.length - final.length} left hanging dropped`);
	fs.writeFileSync(path.join(ROOT, "design", "map", "osm_beirut.json"), JSON.stringify(out));
	console.log(`osm_beirut.json: ${out.roads.length} roads (${out.roads.filter(r => r.k === "road").length} main, ${out.roads.filter(r => r.k === "lane").length} streets)`);
	for(const a of ANCHORS){ const [x, y] = warp(a[2], a[3]); if(Math.hypot(x - a[0], y - a[1]) > 0.5) console.log("  anchor off: " + a[4]); }
})();
