// The new world's blueprint (2026-11-06, draft 2 after Beirut's topographic map): the 25 outdoor rooms merged into big Stardew-style areas, drawn one pixel per
// tile in flat colours (design/map/world_blueprint.png - paint over it to change the world), and a labelled 4x preview
// (design/map/world_blueprint_preview.png).
//   node tools/map/blueprint.js
//
// Areas (old rooms in brackets):
//   Beirut, the town   [Well's Head (sea in its north-west corner, the Riviera hotel), Red Street, Downtown, Grace
//                       Tower, Verdun Street, Uptown, Oven's Window] - districts keep the old names on signposts
//   North Beach        [Manara's Light, Starsand Pier, Hangar 12] - a rocky shore that runs into the cliffs early
//   West Beach         [Olive Bay, Pigeon Rocks, White Sand Beach, South Beach] - one long sandy beach
//   The Mountain       [Plummet's Point, Beacon Hill, Victory Hill] - top right: the mine, a road up to the peak
//   The Outskirts      [Wing Hill, Dahya, Resolve's Rise] - between the farm and the town, the pine wood in the middle
//   Whispering Woods   [Whispering Woods]
//   The Countryside    [Saint Thereza, Frere's Fray, Abda's Ascent]
//   The Farm           [the farm]
//   Bunny Island       new: by ferry from Starsand Pier
//
// Colours (the blueprint's key - keep to these when painting):
const C = {
	deep: [36, 92, 158], sea: [64, 140, 204], shallow: [110, 180, 225], sand: [236, 214, 140], rocky: [176, 162, 136],
	grass: [104, 172, 76], meadow: [128, 186, 88], forest: [40, 112, 52], pine: [30, 92, 58], cliff: [134, 92, 60],
	cliffTop: [120, 150, 84], highland: [96, 124, 70], rock: [150, 138, 124], snow: [240, 244, 248], road: [170, 168, 160], lane: [196, 164, 106],
	plaza: [210, 200, 180], field: [138, 104, 62], river: [82, 158, 214], building: [250, 250, 250], pier: [120, 84, 52],
	cave: [40, 34, 32],
};
const fs = require("fs");
const path = require("path");
const {writePng, newImage} = require("../rooms/png.js");

const M = 30;                       // sea round the world (Bunny Island sits in the north of it)
const W = 250 + 2 * M, H = 200 + 2 * M;
const g = Array.from({length: H}, () => Array(W).fill("deep"));
const set = (x, y, k) => { x = Math.round(x); y = Math.round(y); if(x >= 0 && y >= 0 && x < W && y < H) g[y][x] = k; };
const get = (x, y) => (x >= 0 && y >= 0 && x < W && y < H) ? g[y][x] : "deep";
const rect = (x1, y1, x2, y2, k, only) => { for(let y = y1; y <= y2; y++) for(let x = x1; x <= x2; x++) if(!only || only.includes(get(x + M, y + M))) set(x + M, y + M, k); };
const disc = (cx, cy, rx, ry, k, only) => { for(let y = Math.floor(cy - ry); y <= cy + ry; y++) for(let x = Math.floor(cx - rx); x <= cx + rx; x++) if(((x - cx) / rx) ** 2 + ((y - cy) / ry) ** 2 <= 1 && (!only || only.includes(get(x + M, y + M)))) set(x + M, y + M, k); };

// Smooth noise (deterministic) for coastlines and edges
const hash = (i, s) => { let h = (i * 374761393 + s * 668265263) | 0; h = (h ^ (h >>> 13)) * 1274126177 | 0; return ((h ^ (h >>> 16)) >>> 0) / 4294967296; };
const noise = (t, s, f) => { const x = t * f, i = Math.floor(x), u = x - i, a = hash(i, s), b = hash(i + 1, s), k = u * u * (3 - 2 * u); return a + (b - a) * k; };
const wob = (t, s, amp) => (noise(t, s, 0.07) - 0.5) * 2 * amp + (noise(t, s + 9, 0.22) - 0.5) * amp * 0.6;

// ---- land, the coasts (world tiles 0..249 x 0..199, plus the margin), after Beirut's real shape: a low peninsula
// (the town) with the sea to its north and west and its north-west corner rounded off; past the port the coast turns
// up to the north-east (North Beach, short, meeting the mountain's cliffs); south of the peninsula the west coast runs
// long and straight (West Beach)
const northCoast = x => (x < 128 ? 11 : 11 - (x - 128) * 0.6) + wob(x, 2, 2.5);
const westCoast = y => (y < 84 ? 7 : y < 104 ? 7 + (y - 84) * 0.75 : 22) + wob(y, 1, (y < 84 ? 2 : 4));
for(let y = -M; y < 200 + M; y++) for(let x = -M; x < 250 + M; x++){
	const tip = (x + y) < 34 + wob(x - y, 3, 3);                      // the peninsula's rounded north-west corner
	if(x >= westCoast(y) && y >= Math.max(northCoast(x), -3 + wob(x, 7, 2)) && !tip) set(x + M, y + M, "grass");   // the mountain meets the sea at the top
}
const isSea = (x, y) => ["deep", "sea", "shallow"].includes(get(x + M, y + M));
const nearSea = (x, y, r) => { for(let dy = -r; dy <= r; dy++) for(let dx = -r; dx <= r; dx++) if(isSea(x + dx, y + dy)) return true; return false; };

// ---- the land's height, in steps (0 the lowland and the town; 1, 2 the hills and mountain terraces; 3 the summit):
// rising to the east and south-east as in the topographic map, with the river's valley cut down through it
const river = [[246, 168], [224, 150], [204, 140], [184, 132], [166, 124], [154, 112], [148, 96], [146, 78], [142, 56], [140, 34], [138, 16], [137, 2]];
const riverDist = (x, y) => { let best = 1e9; for(let i = 0; i < river.length - 1; i++){
	const [x1, y1] = river[i], [x2, y2] = river[i + 1], dx = x2 - x1, dy = y2 - y1, t = Math.max(0, Math.min(1, ((x - x1) * dx + (y - y1) * dy) / (dx * dx + dy * dy)));
	best = Math.min(best, Math.hypot(x - x1 - t * dx, y - y1 - t * dy)); } return best; };
const Lr = Array.from({length: 200 + 2 * M}, () => Array(250 + M).fill(0));
const L = new Proxy(Lr, {get: (t, k) => t[Number(k) + M]});      // L[y][x] for y from -M
for(let y = -M; y < 200 + M; y++) for(let x = 0; x < 250 + M; x++){
	let h = (x - 150 - wob(y, 30, 12)) / 34 + Math.max(0, y - 130 - wob(x, 31, 10)) / 42 * Math.min(1, Math.max(0, (x - 70) / 80));
	h += Math.max(0, 1.4 - Math.hypot(x - 232, y - 22) / 34);         // the summit, top right
	const rd = riverDist(x, y);
	if(rd < 9) h = Math.min(h, y < 110 ? 0 : 1);                     // the valley floor
	else if(rd < 16) h = Math.min(h, y < 110 ? 1 : 1.9);
	Lr[y + M][x] = Math.max(0, Math.min(3, Math.floor(h)));
}
const highKind = ["grass", "cliffTop", "highland", "rock"];
for(let y = -M; y < 200 + M; y++) for(let x = 0; x < 250 + M; x++) if(get(x + M, y + M) === "grass" && L[y][x] > 0) set(x + M, y + M, highKind[L[y][x]]);
disc(234, 18, 7, 5, "snow", ["rock"]);
// A cliff face wherever the ground steps down to the west or the south (2 tiles deep: the face you see)
{
	const lv = (x, y) => (x < 0 || y < -M || y >= 200 + M || x >= 250 + M) ? -1 : (isSea(x, y) ? -1 : L[y][x]), face = [];
	for(let y = -M; y < 200 + M; y++) for(let x = 0; x < 250 + M; x++){
		if(lv(x, y) <= 0) continue;
		if(lv(x - 1, y) >= 0 && lv(x - 1, y) < lv(x, y)){ face.push([x, y]); face.push([x + 1, y]); }
		if(lv(x, y + 1) >= 0 && lv(x, y + 1) < lv(x, y)){ face.push([x, y]); face.push([x, y - 1]); }
	}
	for(const [x, y] of face) if(["cliffTop", "highland", "rock"].includes(get(x + M, y + M))) set(x + M, y + M, "cliff");
}

// ---- beaches: the West Beach's wide sand (in and out like a real beach); rocky shore round the peninsula (Raouche,
// the corniche) and along North Beach
for(let y = 0; y < 200; y++) for(let x = 0; x < 250; x++){
	if(get(x + M, y + M) !== "grass") continue;
	const sandy = y > 92;
	const band = sandy ? 6 + Math.round(wob(y, 4, 4)) : 3 + Math.round(wob(x + y, 5, 1.5));
	if(nearSea(x, y, Math.max(2, band))) set(x + M, y + M, sandy ? "sand" : "rocky");
}
for(let y = -M; y < 200 + M; y++) for(let x = -M; x < 250 + M; x++){
	if(!isSea(x, y)) continue;
	let land = false;
	for(let dy = -4; dy <= 4 && !land; dy++) for(let dx = -4; dx <= 4; dx++) if(!isSea(x + dx, y + dy)){ land = true; break; }
	if(land) set(x + M, y + M, "shallow");
}
for(let y = -M; y < 200 + M; y++) for(let x = -M; x < 250 + M; x++){
	if(get(x + M, y + M) !== "deep") continue;
	for(let dy = -9; dy <= 9; dy++) for(let dx = -9; dx <= 9; dx++) if(get(x + dx + M, y + dy + M) === "shallow"){ set(x + M, y + M, "sea"); dy = 99; break; }
}

// ---- forests: Horsh Beirut's pines south of the town (the Outskirts), Whispering Woods on the slopes east of the river,
// pines scattered over the mountain, and a thick wood along the world's south and east edges
const blob = (cx, cy, rx, ry, k, s, on) => { for(let y = cy - ry - 6; y <= cy + ry + 6; y++) for(let x = cx - rx - 6; x <= cx + rx + 6; x++){
	const a = Math.atan2(y - cy, x - cx), r = 1 + wob(a * 20 + 50, s, 0.18);
	if(((x - cx) / rx) ** 2 + ((y - cy) / ry) ** 2 <= r * r && (on || ["grass"]).includes(get(x + M, y + M))) set(x + M, y + M, k);
} };
blob(92, 122, 15, 9, "pine", 13);
blob(192, 104, 26, 18, "forest", 11, ["grass", "cliffTop", "highland"]);
for(let y = 0; y < 200; y++) for(let x = 150; x < 250; x++) if(["cliffTop", "highland"].includes(get(x + M, y + M)) && hash(x * 3, y * 7) < 0.08) set(x + M, y + M, "pine");
for(let y = 0; y < 200 + M; y++) for(let x = 0; x < 250 + M; x++){
	const southEdge = y > 196 + wob(x, 17, 3), eastEdge = x > 246 + wob(y, 18, 3);
	if((southEdge || eastEdge) && ["grass", "sand", "cliffTop", "highland"].includes(get(x + M, y + M))) set(x + M, y + M, "forest");
}

// ---- the river (Nahr Beirut): down from the south-east mountains, along the valley, north past the town's east edge
// into the sea east of the port
for(let i = 0; i < river.length - 1; i++){
	const [x1, y1] = river[i], [x2, y2] = river[i + 1], n = Math.max(Math.abs(x2 - x1), Math.abs(y2 - y1));
	for(let t = 0; t <= n; t++){
		const x = x1 + (x2 - x1) * t / n + wob(y1 + t, 16, 1.5), y = y1 + (y2 - y1) * t / n, w = 1 + (i / river.length) * 1.5;
		for(let dy = -w; dy <= w; dy++) for(let dx = -w; dx <= w; dx++) if(!isSea(Math.round(x + dx), Math.round(y + dy))) set(x + dx + M, y + dy + M, "river");
	}
}
disc(246, 168, 3, 3, "river");

// ---- roads (grey cobbles) and lanes (dirt)
const line = (pts, k, w, under) => { for(let i = 0; i < pts.length - 1; i++){
	const [x1, y1] = pts[i], [x2, y2] = pts[i + 1], n = Math.max(Math.abs(x2 - x1), Math.abs(y2 - y1), 1);
	for(let t = 0; t <= n; t++){ const x = x1 + (x2 - x1) * t / n, y = y1 + (y2 - y1) * t / n;
		for(let dy = -w; dy <= w; dy++) for(let dx = -w; dx <= w; dx++){ const cur = get(Math.round(x + dx) + M, Math.round(y + dy) + M);
			if(cur === "river") set(x + dx + M, y + dy + M, "pier");            // a bridge
			else if(!["deep", "sea", "shallow"].includes(cur) && (!under || under.includes(cur))) set(x + dx + M, y + dy + M, k); } } } };
const lowland = ["grass", "rocky", "sand", "road", "lane", "pine"];
// The town: the corniche round the peninsula, avenues out from the square by the port (Downtown), cross streets
line([[34, 16], [70, 15], [120, 16], [134, 18]], "road", 1);                          // the corniche, north
line([[13, 40], [12, 60], [14, 80], [24, 100]], "road", 1);                          // the corniche, west
line([[22, 26], [34, 16]], "road", 1);
line([[16, 36], [60, 36], [130, 36]], "road", 1); line([[14, 58], [60, 58], [134, 58]], "road", 1); line([[16, 80], [70, 82], [136, 80]], "road", 1);
line([[40, 18], [38, 92]], "road", 1); line([[64, 16], [62, 96]], "road", 1); line([[100, 16], [104, 96]], "road", 1); line([[128, 20], [130, 90]], "road", 1);
line([[88, 36], [112, 70], [126, 96]], "road", 1);                                   // a diagonal avenue, as Beirut has
rect(78, 24, 96, 34, "plaza");                                                      // the square, by the port
// Out of town: south through the Outskirts to the farm; down the West Beach; east over the river and up the mountain
line([[62, 96], [64, 120], [70, 140], [72, 156]], "road", 1);
line([[104, 96], [112, 118], [120, 140], [124, 156]], "lane", 1);
line([[24, 100], [30, 130], [32, 160], [34, 196]], "lane", 1);
line([[72, 156], [100, 158], [124, 156], [150, 160], [178, 164]], "lane", 1);         // the countryside lane
line([[130, 58], [146, 58], [158, 56], [170, 52], [178, 54]], "lane", 1, lowland.concat(["cliffTop", "cliff", "highland"]));   // to the mine
line([[178, 54], [190, 46], [198, 38], [210, 34], [220, 28], [230, 22]], "lane", 1, lowland.concat(["cliffTop", "cliff", "highland", "rock", "pine"]));  // up to the peak
line([[136, 80], [150, 80], [160, 78], [170, 80]], "lane", 1, lowland.concat(["cliffTop", "cliff"]));   // to Victory Hill
line([[150, 80], [164, 96], [180, 104], [190, 112]], "lane", 1, lowland.concat(["cliffTop", "cliff", "forest"]));  // into Whispering Woods
line([[134, 18], [146, 10], [158, 4]], "lane", 1);                                   // over the river mouth to North Beach

// ---- the port (Starsand's piers) and the West Beach's piers; Pigeon Rocks offshore (the sea arch)
const pier = (x, y, len, dx, dy) => { for(let k = 0; k < len; k++) for(let w = 0; w <= 1; w++) set(x + dx * k + (dy ? w : 0) + M, y + dy * k + (dx ? w : 0) + M, "pier"); };
pier(84, 11, 9, 0, -1); pier(96, 11, 9, 0, -1); pier(108, 11, 9, 0, -1); pier(84, 3, 26, 1, 0);
pier(22, 112, 10, -1, 0); pier(26, 170, 12, -1, 0);
disc(2, 64, 3, 2, "rock");

// ---- the farm (south-west lowland, near the beach) and the countryside's fields
rect(56, 166, 94, 192, "grass", ["grass", "forest", "pine", "sand"]);
rect(70, 174, 92, 190, "field");
disc(60, 186, 4, 3, "river");
rect(104, 170, 120, 180, "field"); rect(136, 180, 150, 188, "field");

// ---- the mine, in a cliff face on the mountain
disc(178, 51, 2, 1.5, "cave");

// ---- Bunny Island, out in the northern sea, and the ferry from Starsand's port
for(let y = -28; y < -6; y++) for(let x = 50; x < 90; x++){
	const a = Math.atan2(y + 17, x - 70), r = 1 + wob(a * 20, 21, 0.15);
	if(((x - 70) / 17) ** 2 + ((y + 17) / 9) ** 2 <= r * r) set(x + M, y + M, "grass");
}
for(let y = -28; y < -6; y++) for(let x = 50; x < 90; x++) if(get(x + M, y + M) === "grass" && nearSea(x, y, 2)) set(x + M, y + M, "sand");
disc(66, -16, 6, 3, "forest", ["grass"]);
pier(70, -9, 4, 0, 1);

// ---- buildings: [x, y, w, h] in tiles (footprints, roughly to scale), by area
const B = [];
const b = (x, y, w, h, name) => B.push({x, y, w, h, name});
// Beirut, the town (districts: Well's Head in the north-west corner, Red Street, Downtown round the square by the port,
// Grace Tower, Verdun Street, Uptown, Oven's Window)
b(24, 22, 9, 5, "Riviera hotel"); b(26, 29, 6, 4, "Glassworks"); b(18, 30, 5, 4, "Fairglass");
b(44, 40, 6, 5, "Goldcrest"); b(68, 26, 7, 5, "Tavern"); b(70, 38, 8, 6, "Bank"); b(98, 26, 6, 5, "Tools"); b(98, 38, 6, 5, "Guild hall");
b(108, 40, 7, 5, "Smithy"); b(118, 40, 6, 5, "Whitlow");
b(22, 62, 6, 4, "Bakery"); b(30, 62, 6, 4, "Flowers"); b(44, 62, 7, 4, "Furniture"); b(50, 48, 5, 4, "Cafe");
b(68, 62, 8, 5, "Hospital"); b(78, 62, 8, 5, "Library"); b(72, 72, 8, 5, "Museum");
b(108, 62, 6, 4, "Quill"); b(116, 62, 8, 5, "Meadowlark");
// North Beach (the lighthouse on the peninsula's corner, the port, Hangar 12 past the river mouth)
b(12, 30, 3, 7, "Lighthouse"); b(56, 18, 6, 4, "Fish market"); b(112, 18, 6, 4, "Ferry");
b(150, 0, 8, 5, "Hangar 12"); b(160, -6, 6, 4, "Tinker"); b(144, 8, 5, 4, "Brassbolt");
// West Beach
b(16, 66, 5, 4, "Gullwater"); b(30, 100, 6, 4, "Beach bar"); b(26, 108, 3, 4, "Lifeguard"); b(38, 112, 4, 3, "Shack");
b(32, 128, 6, 4, "Olive press"); b(40, 134, 5, 4, "Saba"); b(30, 164, 7, 4, "Boatyard"); b(40, 174, 6, 4, "Saltwhistle");
// The Mountain (Beacon Hill's mine, Victory Hill's mill above the river, the witch's tower near the top by the sea)
b(170, 44, 5, 4, "Ironvein"); b(160, 72, 4, 6, "Windmill"); b(168, 76, 7, 5, "Oakhart"); b(176, 72, 7, 4, "Mill");
b(204, 4, 5, 7, "Witch tower");
// The Outskirts (Wing Hill, Dahya by the pine wood, Resolve's Rise)
b(46, 104, 6, 4, "Kassar"); b(54, 108, 6, 4, "Merchant"); b(96, 104, 6, 4, "Larkspun"); b(104, 106, 6, 4, "Outfitter");
b(108, 128, 6, 4, "Tawil"); b(124, 112, 6, 5, "Silverbough"); b(128, 124, 6, 4, "Apothecary");
// Whispering Woods
b(194, 108, 5, 4, "Ranger");
// The farm
b(60, 168, 5, 4, "Farmhouse"); b(84, 166, 7, 5, "Barn");
// The Countryside (Saint Thereza, Frere's Fray, Abda's Ascent on the rising ground)
b(102, 162, 6, 4, "Night farm"); b(112, 164, 7, 4, "Seeds"); b(134, 164, 7, 6, "Monastery"); b(144, 168, 6, 4, "Stables");
b(152, 174, 6, 4, "Hayward"); b(142, 176, 5, 4, "Frere"); b(166, 160, 6, 6, "Church"); b(174, 166, 5, 4, "Ward");
// Bunny Island
b(74, -20, 4, 3, "Burrow");
for(const k of B) rect(k.x, k.y, k.x + k.w - 1, k.y + k.h - 1, "building");

// ---- the blueprint: one pixel a tile
const out = path.join(__dirname, "..", "..", "design", "map");
fs.mkdirSync(out, {recursive: true});
const TW = M + 252, TH = M + 202;   // trimmed: the world plus the sea to the west and north
const im = newImage(TW, TH);
for(let y = 0; y < TH; y++) for(let x = 0; x < TW; x++){ const c = C[g[y][x]] || [255, 0, 255]; const i = (y * TW + x) * 4; im.px[i] = c[0]; im.px[i + 1] = c[1]; im.px[i + 2] = c[2]; im.px[i + 3] = 255; }
writePng(path.join(out, "world_blueprint.png"), im);

// ---- the preview: 4x, with tree tufts, cliff shading, roofs, and labels
const S = 4, P = newImage(TW * S, TH * S);
const put = (x, y, c, a = 1) => { if(x < 0 || y < 0 || x >= P.w || y >= P.h) return; const i = (y * P.w + x) * 4; for(let k = 0; k < 3; k++) P.px[i + k] = Math.round(P.px[i + k] * (1 - a) + c[k] * a); P.px[i + 3] = 255; };
const shade = (c, f) => c.map(v => Math.max(0, Math.min(255, Math.round(v * f))));
for(let y = 0; y < H; y++) for(let x = 0; x < W; x++){
	const k = g[y][x]; let c = C[k];
	if(k === "building") c = C.plaza;
	for(let dy = 0; dy < S; dy++) for(let dx = 0; dx < S; dx++){
		let cc = c;
		if(k === "grass" || k === "meadow" || k === "cliffTop" || k === "highland") cc = shade(c, 1 + (hash(x * 7 + dx, y * 13 + dy) - 0.5) * 0.08);
		if(k === "deep" || k === "sea") cc = shade(c, ((x * 3 + y * 5 + dx) % 23 === 0 && dy === 1) ? 1.25 : 1);
		if(k === "sand") cc = shade(c, (hash(x * S + dx, y * S + dy) < 0.06) ? 0.9 : 1);
		put(x * S + dx, y * S + dy, cc);
	}
}
// trees: a round crown on forest tiles (pines darker and pointed), every other tile
for(let y = 0; y < H; y++) for(let x = 0; x < W; x++){
	const k = g[y][x];
	if(k !== "forest" && k !== "pine") continue;
	if((x + y) % 2 && hash(x, y) < 0.7) continue;
	const cx = x * S + 2, cy = y * S + 2, base = C[k];
	for(let dy = -3; dy <= 3; dy++) for(let dx = -3; dx <= 3; dx++){
		const inside = k === "pine" ? (Math.abs(dx) <= (dy + 3) / 2) : (dx * dx + dy * dy <= 9);
		if(inside) put(cx + dx, cy + dy, shade(base, dy < 0 ? 1.25 : (dy > 1 ? 0.75 : 1)));
	}
	put(cx, cy + 4, [80, 56, 36]);
}
// cliff faces: darker stripes; the mountain rock speckled
for(let y = 0; y < H; y++) for(let x = 0; x < W; x++){
	if(g[y][x] === "cliff") for(let dy = 0; dy < S; dy++) for(let dx = 0; dx < S; dx++) if((dy + x) % 3 === 0) put(x * S + dx, y * S + dy, shade(C.cliff, 0.7));
	if(g[y][x] === "rock" && hash(x, y) < 0.3) put(x * S + 1, y * S + 1, shade(C.rock, 0.75));
}
// buildings: a roof (colour by name) over a pale wall, with a dark outline
const roofs = [[178, 72, 56], [70, 96, 150], [96, 120, 72], [150, 110, 60], [110, 70, 110], [190, 150, 70]];
for(const k of B){
	const x1 = (k.x + M) * S, y1 = (k.y + M) * S, x2 = (k.x + k.w + M) * S - 1, y2 = (k.y + k.h + M) * S - 1;
	const roof = roofs[Math.floor(hash(k.name.length * 31, k.x) * roofs.length)], wallTop = y1 + Math.round((y2 - y1) * 0.6);
	for(let y = y1; y <= y2; y++) for(let x = x1; x <= x2; x++){
		const edge = x === x1 || x === x2 || y === y1 || y === y2;
		put(x, y, edge ? [40, 30, 30] : (y < wallTop ? shade(roof, y < y1 + 2 ? 1.2 : 1) : [236, 226, 206]));
	}
	const dx = Math.round((x1 + x2) / 2);
	for(let y = y2 - 5; y < y2; y++) for(let x = dx - 1; x <= dx + 1; x++) put(x, y, [110, 74, 44]);   // a door
}

// ---- a 5x7 pixel font for the labels
const F = {
	A: "01110 10001 10001 11111 10001 10001 10001", B: "11110 10001 10001 11110 10001 10001 11110", C: "01110 10001 10000 10000 10000 10001 01110",
	D: "11110 10001 10001 10001 10001 10001 11110", E: "11111 10000 10000 11110 10000 10000 11111", F: "11111 10000 10000 11110 10000 10000 10000",
	G: "01110 10001 10000 10111 10001 10001 01111", H: "10001 10001 10001 11111 10001 10001 10001", I: "01110 00100 00100 00100 00100 00100 01110",
	J: "00111 00010 00010 00010 00010 10010 01100", K: "10001 10010 10100 11000 10100 10010 10001", L: "10000 10000 10000 10000 10000 10000 11111",
	M: "10001 11011 10101 10101 10001 10001 10001", N: "10001 11001 10101 10011 10001 10001 10001", O: "01110 10001 10001 10001 10001 10001 01110",
	P: "11110 10001 10001 11110 10000 10000 10000", Q: "01110 10001 10001 10001 10101 10010 01101", R: "11110 10001 10001 11110 10100 10010 10001",
	S: "01111 10000 10000 01110 00001 00001 11110", T: "11111 00100 00100 00100 00100 00100 00100", U: "10001 10001 10001 10001 10001 10001 01110",
	V: "10001 10001 10001 10001 10001 01010 00100", W: "10001 10001 10001 10101 10101 10101 01010", X: "10001 10001 01010 00100 01010 10001 10001",
	Y: "10001 10001 01010 00100 00100 00100 00100", Z: "11111 00001 00010 00100 01000 10000 11111", "'": "00100 00100 01000 00000 00000 00000 00000",
	"0": "01110 10011 10101 11001 10001 10001 01110", "1": "00100 01100 00100 00100 00100 00100 01110", "2": "01110 10001 00001 00110 01000 10000 11111",
	" ": "00000 00000 00000 00000 00000 00000 00000", "(": "00010 00100 01000 01000 01000 00100 00010", ")": "01000 00100 00010 00010 00010 00100 01000",
	"-": "00000 00000 00000 11111 00000 00000 00000", ".": "00000 00000 00000 00000 00000 01100 01100", ",": "00000 00000 00000 00000 01100 00100 01000",
};
const text = (str, x, y, sc, col) => {
	str = str.toUpperCase();
	const width = str.length * 6 * sc;
	let px0 = Math.round(x - width / 2);
	for(const ch of str){
		const rows = (F[ch] || F[" "]).split(" ");
		for(let r = 0; r < 7; r++) for(let c = 0; c < 5; c++) if(rows[r][c] === "1"){
			for(let oy = -1; oy <= 1; oy++) for(let ox = -1; ox <= 1; ox++)
				for(let yy = 0; yy < sc; yy++) for(let xx = 0; xx < sc; xx++) put(px0 + c * sc + xx + ox, y + r * sc + yy + oy, [24, 20, 18]);
		}
		for(let r = 0; r < 7; r++) for(let c = 0; c < 5; c++) if(rows[r][c] === "1")
			for(let yy = 0; yy < sc; yy++) for(let xx = 0; xx < sc; xx++) put(px0 + c * sc + xx, y + r * sc + yy, col);
		px0 += 6 * sc;
	}
};
const at = (x, y) => [(x + M) * S, (y + M) * S];
const area = (name, x, y) => { const [px, py] = at(x, y); text(name, px, py, 3, [255, 236, 150]); };
const dist = (name, x, y) => { const [px, py] = at(x, y); text(name, px, py, 2, [255, 255, 255]); };
area("Beirut", 87, 46); area("North Beach", 40, 2); area("West Beach", 14, 146); area("The Mountain", 205, 64);
area("The Outskirts", 84, 145); area("Whispering Woods", 196, 128); area("Countryside", 140, 190); area("The Farm", 76, 196);
area("Bunny Island", 70, -27);
dist("Well's Head", 30, 10); dist("Red Street", 40, 50); dist("Downtown", 87, 20); dist("Grace Tower", 122, 50);
dist("Verdun Street", 40, 70); dist("Uptown", 76, 80); dist("Oven's Window", 116, 70);
dist("Manara's Light", 12, 40); dist("Starsand Pier", 96, -2); dist("Hangar 12", 170, 4);
dist("Pigeon Rocks", 8, 56); dist("White Sand", 34, 118); dist("Olive Bay", 36, 140); dist("South Beach", 36, 180);
dist("Plummet's Point", 210, -10); dist("Beacon Hill", 176, 38); dist("Victory Hill", 170, 84);
dist("Wing Hill", 58, 98); dist("Dahya", 100, 112); dist("Resolve's Rise", 128, 132);
dist("Saint Thereza", 108, 152); dist("Frere's Fray", 144, 184); dist("Abda", 172, 154);
dist("Mine", 178, 56); dist("Peak", 234, 8); dist("Ferry", 60, -6); dist("Riviera", 28, 18); dist("Beirut River", 156, 136);
writePng(path.join(out, "world_blueprint_preview.png"), P);
console.log("world_blueprint.png " + TW + "x" + TH + " (1 px = 1 tile), preview " + P.w + "x" + P.h);
