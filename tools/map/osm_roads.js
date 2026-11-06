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
	const WIDE = {motorway: 1, trunk: 1, primary: 0.5, secondary: 0.5, tertiary: 0};
	const out = {note: "Beirut's roads from OpenStreetMap ((c) OpenStreetMap contributors, ODbL), warped onto the blueprint by tools/map/osm_roads.js", roads: []};
	for(const e of raw.elements){
		const h = e.tags.highway || "";
		if(!KIND[h] || !e.geometry) continue;   // (ramps, the *_link roads, left out: at a game's scale they pave whole blocks)
		const pts = e.geometry.map(p => warp(p.lat, p.lon).map(v => Math.round(v * 10) / 10));
		out.roads.push({k: KIND[h], w: WIDE[h], pts});
	}
	fs.writeFileSync(path.join(ROOT, "design", "map", "osm_beirut.json"), JSON.stringify(out));
	console.log(`osm_beirut.json: ${out.roads.length} roads (${out.roads.filter(r => r.k === "road").length} main, ${out.roads.filter(r => r.k === "lane").length} streets)`);
	for(const a of ANCHORS){ const [x, y] = warp(a[2], a[3]); if(Math.hypot(x - a[0], y - a[1]) > 0.5) console.log("  anchor off: " + a[4]); }
})();
