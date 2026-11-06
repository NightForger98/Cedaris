// The new world's blueprint (2026-11-06, draft 2 after Beirut's topographic map): the 25 outdoor rooms merged into big Stardew-style areas, drawn one pixel per
// tile in flat colours (design/map/world_blueprint.png - paint over it to change the world), and a labelled 4x preview
// (design/map/world_blueprint_preview.png).
//   node tools/map/blueprint.js
//
// Areas (old rooms in brackets):
//   Beirut, the town   [Well's Head (sea in its north-west corner, the Riviera hotel), Red Street, Downtown, Grace
//                       Tower, Verdun Street, Uptown, Oven's Window] - districts keep the old names on signposts
//   Phoenix Bay        [Manara's Light, Starsand Pier, Hangar 12] - a rocky shore that runs into the cliffs early
//   Sunset Coast         [Olive Bay, Pigeon Rocks, White Sand Beach, South Beach] - one long sandy beach
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
	grass: [104, 172, 76], meadow: [128, 186, 88], forest: [40, 112, 52], pine: [30, 92, 58], cliff: [134, 92, 60],   // meadow: parks, lawns
	cliffTop: [120, 150, 84], highland: [96, 124, 70], rock: [150, 138, 124], snow: [240, 244, 248], road: [170, 168, 160], lane: [196, 164, 106],
	plaza: [210, 200, 180], field: [138, 104, 62], river: [82, 158, 214], building: [250, 250, 250], pier: [120, 84, 52],
	cave: [40, 34, 32], rail: [92, 78, 64], ruin: [190, 178, 150], stairs: [214, 204, 184],
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
// up to the north-east (Phoenix Bay, short, meeting the mountain's cliffs); south of the peninsula the west coast runs
// long and straight (Sunset Coast)
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

// ---- beaches: the Sunset Coast's wide sand (in and out like a real beach); rocky shore round the peninsula (Raouche,
// the corniche) and along Phoenix Bay
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

// ---- roads (grey cobbles) and lanes (dirt), after Beirut's real ones, made simpler and wide enough to walk (main roads 3
// tiles, streets 2). The old rooms' roads and the villagers' routes are kept for reference: design/map/old_rooms.json
// and old_rooms_on_new.png (see tools/map/old_rooms.js).
const line = (pts, k, w, under) => { for(let i = 0; i < pts.length - 1; i++){
	const [x1, y1] = pts[i], [x2, y2] = pts[i + 1], n = Math.max(Math.abs(x2 - x1), Math.abs(y2 - y1), 1);
	for(let t = 0; t <= n; t++){ const x = x1 + (x2 - x1) * t / n, y = y1 + (y2 - y1) * t / n;
		for(let dy = -w; dy <= w; dy++) for(let dx = -w; dx <= w; dx++){ const cur = get(Math.round(x + dx) + M, Math.round(y + dy) + M);
			if(cur === "river") set(x + dx + M, y + dy + M, "pier");            // a bridge
			else if(!["deep", "sea", "shallow"].includes(cur) && (!under || under.includes(cur))) set(x + dx + M, y + dy + M, k); } } } };
const lowland = ["grass", "rocky", "sand", "road", "lane", "pine", "plaza"];
const hills = lowland.concat(["cliffTop", "cliff", "highland", "rock", "forest"]);
const ROADS = {
	// The main roads
	corniche_north: [[24, 18], [40, 15], [70, 14], [100, 15], [134, 17]],                      // Avenue des Francais, the port's Charles Helou
	coast_highway:  [[134, 17], [146, 9], [160, 2], [172, -4]],                                // on north-east along the coast, past the river mouth
	corniche_west:  [[24, 18], [14, 28], [11, 44], [11, 62], [14, 80], [22, 96], [28, 120], [30, 150], [32, 175], [34, 196]],   // the Corniche, then down the Sunset Coast
	hamra:          [[14, 32], [58, 32]],                                                     // Hamra Street (Red Street)
	the_ring:       [[58, 32], [70, 42], [104, 42], [124, 40], [140, 42], [150, 46]],          // Fouad Chehab, east over the river
	mazraa:         [[11, 62], [50, 62], [80, 64], [110, 64]],                                // Corniche el-Mazraa / Salam
	damascus_road:  [[90, 34], [100, 46], [110, 64], [114, 84], [112, 100], [118, 120], [132, 140], [150, 152], [170, 158]],   // south to Baabda (Abda)
	bechara_khoury: [[80, 42], [80, 64], [78, 86], [72, 100]],
	airport_road:   [[72, 100], [66, 122], [62, 146], [66, 162]],                             // on to the farm (where the airport would be)
	south_boulevard:[[22, 96], [50, 98], [72, 100], [100, 104], [112, 100]],                  // Jnah to Tayouneh
	// Streets
	verdun:         [[40, 32], [40, 62], [44, 90]],
	ain_mreisseh:   [[24, 18], [30, 26], [40, 32]],
	basta:          [[64, 42], [62, 64]],
	tariq_jdideh:   [[50, 62], [52, 90], [60, 98]],
	achrafieh:      [[104, 42], [112, 50], [124, 52], [132, 46]],
	sassine:        [[112, 50], [114, 64]],
	furn_chebbak:   [[114, 84], [134, 84]],
	old_saida_road: [[100, 104], [94, 130], [88, 150], [80, 160]],
};
const STREETS = ["verdun", "ain_mreisseh", "basta", "tariq_jdideh", "achrafieh", "sassine", "furn_chebbak", "old_saida_road"];
const LANES = {
	river_road:     [[131, 22], [135, 40], [138, 60], [141, 80], [145, 96]],                  // along the river's west bank
	mountain_road:  [[150, 46], [164, 52], [178, 54], [190, 46], [200, 38], [212, 32], [222, 26], [230, 22]],   // Mansourieh, the mine, the peak
	victory_hill:   [[146, 80], [156, 80], [166, 80]],
	woods:          [[156, 80], [166, 96], [182, 104], [192, 110]],
	countryside:    [[66, 162], [100, 158], [124, 156], [150, 158]],
	farm_to_beach:  [[34, 170], [56, 170]],
	up_from_bourj:  [[146, 18], [158, 24], [172, 34], [182, 44], [190, 46]],                 // Bourj Hammoud up toward Mansourieh, to the mine road
	into_the_woods: [[170, 158], [184, 152], [196, 144], [206, 136]],                        // Abda over the river into Whispering Woods
};
for(const [name, pts] of Object.entries(ROADS)) line(pts, "road", STREETS.includes(name) ? 0.5 : 1, hills);
for(const [name, pts] of Object.entries(LANES)) line(pts, "lane", 0.5, hills);
rect(82, 22, 96, 32, "plaza");                     // Martyrs' Square, downtown by the port
disc(102, 104, 3, 3, "plaza");                     // the Tayouneh roundabout, by the Horsh pines
disc(110, 64, 2, 2, "plaza");                      // the Museum crossing

// ---- the port (Starsand's piers) and the Sunset Coast's piers; Pigeon Rocks offshore (the sea arch)
const pier = (x, y, len, dx, dy) => { for(let k = 0; k < len; k++) for(let w = 0; w <= 1; w++) set(x + dx * k + (dy ? w : 0) + M, y + dy * k + (dx ? w : 0) + M, "pier"); };
// Starsand Pier, east of Biel (where Beirut's port basins are): quays built out into the sea with basins between them,
// and Biel's long stone breakwater angling out to the north-east
for(const qx of [88, 100, 112]) rect(qx, 1, qx + 6, 12, "plaza");
for(let k = 0; k <= 34; k++){ const y = -1 - Math.round(k * 0.45); for(let w = 0; w <= 1; w++) for(let dy = 0; dy <= 1; dy++) set(82 + k + w + M, y + dy + M, "pier"); }
// The port, moved up the coast above Hangar 12: land built out into the sea, three basins, a breakwater, the silos
rect(140, -13, 174, -3, "plaza");
for(const bx of [146, 154, 162]) rect(bx, -13, bx + 4, -7, "shallow");
for(let x = 138; x <= 176; x++) set(x + M, -14 + M, "pier");
// Biel: land built out into the sea north of downtown, a big hall on it, a stone pier along its north edge (Starsand Pier)
rect(64, 1, 82, 12, "plaza");
for(let x = 64; x <= 82; x++){ set(x + M, 0 + M, "pier"); set(x + M, -1 + M, "pier"); }
// Zaitunay Bay: a marina basin cut into the shore, pontoons out into it, a promenade along it
rect(46, 9, 60, 14, "shallow"); rect(46, 15, 60, 16, "plaza");
for(const px of [48, 52, 56]) for(let y = 10; y <= 14; y++) set(px + M, y + M, "pier");
// The Ain el-Mreisseh fishermen's harbour by the Riviera: a little basin and a jetty
rect(32, 12, 37, 15, "shallow"); for(let x = 32; x <= 38; x++) set(x + M, 11 + M, "pier");
// Palms along the Corniche (a tree every few tiles on the landward side)
for(const [x, y] of [[26, 22], [16, 34], [14, 48], [14, 56], [16, 72], [18, 86], [44, 18], [62, 18], [124, 20]]) set(x + M, y + M, "forest");
// Parks and grounds: Sanayeh Garden; the Hippodrome (a racetrack by the Horsh pines); Sports City's stadium at Jnah
rect(46, 46, 54, 52, "meadow"); for(const [x, y] of [[47, 47], [52, 48], [49, 51]]) set(x + M, y + M, "forest");
{ const cx = 72, cy = 120, rx = 9, ry = 6;
  for(let y = cy - ry - 1; y <= cy + ry + 1; y++) for(let x = cx - rx - 1; x <= cx + rx + 1; x++){
	const d = ((x - cx) / rx) ** 2 + ((y - cy) / ry) ** 2;
	if(d <= 1.25 && d >= 0.75) set(x + M, y + M, "lane"); else if(d < 0.75) set(x + M, y + M, "meadow"); } }
pier(22, 112, 10, -1, 0); pier(26, 170, 12, -1, 0);
disc(2, 64, 3, 2, "rock");

// ---- rails: Beirut's old tram (it ran until the 1960s; restoring a line is a town project: fast travel along the
// Corniche and down Damascus Road), and the old coast railway past the old Mar Mikhael station toward the port
const TRAM = [[14, 80], [11, 62], [11, 44], [14, 28], [24, 18], [40, 15], [70, 14], [86, 15], [90, 34], [100, 46], [110, 64],
	[114, 84], [112, 100], [118, 120], [132, 140], [150, 152], [170, 158]];
const RAILWAY = [[96, 19], [126, 18], [134, 20], [148, 12], [162, 6], [176, -2]];
line(TRAM, "rail", 0, hills.concat(["road", "plaza"]));
line(RAILWAY, "rail", 0, hills.concat(["road", "plaza"]));
// The cable car (like Jounieh-Harissa's): from the coast by Hangar 12 up to the peak - overhead, so only its two
// stations are on the ground (buildings below); its line is in world_layout.json and drawn on the preview
const CABLE = [[166, 9], [228, 16]];
// Gemmayzeh's street east of downtown (the evening district), and the Saint Nicholas Stairs (the stairs of art) up into
// Achrafieh
line([[96, 36], [122, 34]], "road", 0.5, hills);
rect(116, 52, 117, 60, "stairs");

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
const b = (x, y, w, h, name, kind) => B.push({x, y, w, h, name, kind: kind || "building"});
// Beirut, the town (districts: Well's Head in the north-west corner, Red Street, Downtown round the square by the port,
// Grace Tower, Verdun Street, Uptown, Oven's Window)
b(24, 22, 9, 5, "Riviera hotel"); b(26, 29, 6, 4, "Glassworks"); b(18, 30, 5, 4, "Fairglass");
b(44, 40, 6, 5, "Goldcrest"); b(68, 26, 7, 5, "Tavern"); b(70, 38, 8, 6, "Bank"); b(98, 26, 6, 5, "Tools"); b(98, 38, 6, 5, "Guild hall");
b(108, 40, 7, 5, "Smithy"); b(118, 40, 6, 5, "Whitlow");
b(22, 62, 6, 4, "Bakery"); b(30, 62, 6, 4, "Flowers"); b(44, 62, 7, 4, "Furniture"); b(50, 48, 5, 4, "Cafe");
b(68, 66, 8, 5, "Hospital"); b(78, 66, 8, 5, "Library"); b(113, 66, 8, 5, "Museum");
b(68, 4, 9, 5, "Biel hall"); b(168, -12, 4, 5, "Silos"); b(58, 18, 5, 3, "Marina club");
b(142, 20, 7, 4, "Bourj Hammoud market"); b(46, 114, 7, 6, "Stadium");
b(108, 62, 6, 4, "Quill"); b(116, 62, 8, 5, "Meadowlark");
// Phoenix Bay (the lighthouse on the peninsula's corner, the port, Hangar 12 past the river mouth)
b(12, 30, 3, 7, "Lighthouse"); b(56, 18, 6, 4, "Fish market"); b(112, 18, 6, 4, "Ferry");
b(150, 0, 8, 5, "Hangar 12"); b(162, 2, 6, 4, "Tinker"); b(144, 8, 5, 4, "Brassbolt");
// Sunset Coast
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
// Beirut's history and art: the Roman Baths and the Cardo's columns downtown (the Wardens' ruins story, and a dig site for
// the Museum), the Sursock gallery, Gemmayzeh's bars, the old Mar Mikhael station; the temple ruins at Beit Mery
b(60, 44, 7, 5, "Roman Baths", "ruin"); b(82, 35, 12, 2, "Cardo", "ruin"); b(120, 44, 7, 5, "Sursock gallery");
b(104, 29, 5, 3, "Bar"); b(112, 29, 5, 3, "Bar"); b(120, 22, 7, 4, "Old station"); b(196, 38, 7, 5, "Temple ruins", "ruin");
// The cable car's stations, and the tram's stops
b(162, 10, 4, 3, "Cable car"); b(226, 14, 4, 3, "Cable car top");
for(const [x, y] of [[16, 58], [58, 18], [92, 40], [114, 70], [106, 98], [160, 150]]) b(x, y, 3, 2, "Tram stop");
// Each building where it's put, or slid to the nearest clear spot (on open ground, a tile clear of roads, rivers and other
// buildings), so the roads can be redrawn without moving every building by hand
const open = ["grass", "rocky", "sand", "cliffTop", "highland", "pine", "forest", "plaza", "meadow"];
const fits = (x, y, w, h) => { for(let yy = y - 1; yy <= y + h; yy++) for(let xx = x - 1; xx <= x + w; xx++){
	const k = get(xx + M, yy + M), inside = xx >= x && yy >= y && xx < x + w && yy < y + h;
	if(k === "building" || k === "ruin" || (inside && !open.includes(k)) || (!inside && ["river", "deep", "sea", "shallow"].includes(k))) return false; }
	return true; };
for(const k of B){
	let best = null;
	for(let d = 0; d <= 10 && !best; d++) for(let dy = -d; dy <= d && !best; dy++) for(let dx = -d; dx <= d; dx++){
		if(Math.max(Math.abs(dx), Math.abs(dy)) !== d) continue;
		if(fits(k.x + dx, k.y + dy, k.w, k.h)){ best = [dx, dy]; break; }
	}
	if(!best){ console.log("no room for " + k.name); best = [0, 0]; }
	k.x += best[0]; k.y += best[1];
	rect(k.x, k.y, k.x + k.w - 1, k.y + k.h - 1, k.kind);
}

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
	if(k === "building" || k === "ruin") c = C.plaza;
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
// rails: dark sleepers across a light bed; stairs: steps
for(let y = 0; y < H; y++) for(let x = 0; x < W; x++){
	if(g[y][x] === "rail") for(let dy = 0; dy < S; dy++) for(let dx = 0; dx < S; dx++) put(x * S + dx, y * S + dy, (dx === 0 || dx === S - 1 || dy === 0 || dy === S - 1) ? [70, 58, 48] : [150, 138, 120]);
	if(g[y][x] === "stairs") for(let dy = 0; dy < S; dy++) for(let dx = 0; dx < S; dx++) put(x * S + dx, y * S + dy, dy === S - 1 ? [150, 140, 125] : C.stairs);
}
// the cable car: a dotted cable between its stations, with two cabins on it
{ const [[ax, ay], [bx, by]] = CABLE, n = Math.hypot(bx - ax, by - ay) * S;
  for(let t = 0; t <= n; t++){ const x = Math.round((ax + M) * S + (bx - ax) * S * t / n), y = Math.round((ay + M) * S + (by - ay) * S * t / n);
	if(t % 6 < 4) put(x, y, [40, 40, 48]); }
  for(const f of [0.3, 0.7]){ const x = Math.round((ax + M + (bx - ax) * f) * S), y = Math.round((ay + M + (by - ay) * f) * S);
	for(let dy = 1; dy <= 6; dy++) for(let dx = -3; dx <= 3; dx++) put(x + dx, y + dy, dy === 1 || dx === -3 || dx === 3 || dy === 6 ? [40, 30, 30] : [200, 60, 50]); } }
// buildings: a roof (colour by name) over a pale wall, with a dark outline; ruins: broken stone with column stumps
const roofs = [[178, 72, 56], [70, 96, 150], [96, 120, 72], [150, 110, 60], [110, 70, 110], [190, 150, 70]];
for(const k of B.filter(k => k.kind === "ruin")){
	const x1 = (k.x + M) * S, y1 = (k.y + M) * S, x2 = (k.x + k.w + M) * S - 1, y2 = (k.y + k.h + M) * S - 1;
	for(let y = y1; y <= y2; y++) for(let x = x1; x <= x2; x++) put(x, y, hash(x, y) < 0.15 ? [150, 140, 120] : C.ruin);
	for(let x = x1 + 2; x < x2 - 1; x += 6) for(let y = y1 + 1; y <= y2 - 1; y++) for(let w = 0; w < 3; w++) put(x + w, y, w === 2 ? [140, 130, 112] : [236, 230, 214]);
}
for(const k of B.filter(k => k.kind !== "ruin")){
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
	"3": "11110 00001 00001 01110 00001 00001 11110", "4": "00010 00110 01010 10010 11111 00010 00010", "5": "11111 10000 11110 00001 00001 10001 01110",
	"6": "00110 01000 10000 11110 10001 10001 01110", "7": "11111 00001 00010 00100 01000 01000 01000", "8": "01110 10001 10001 01110 10001 10001 01110",
	"9": "01110 10001 10001 01111 00001 00010 01100",
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
writePng(path.join(out, "world_blueprint_plain.png"), P);   // the 4x picture before any names go on
const at = (x, y) => [(x + M) * S, (y + M) * S];
const area = (name, x, y) => { const [px, py] = at(x, y); text(name, px, py, 3, [255, 236, 150]); };
const dist = (name, x, y) => { const [px, py] = at(x, y); text(name, px, py, 2, [255, 255, 255]); };
area("Beirut", 100, 88); area("Phoenix Bay", 30, -2); area("Sunset Coast", 14, 146); area("The Mountain", 205, 64);
area("The Outskirts", 84, 145); area("Whispering Woods", 196, 128); area("Countryside", 140, 190); area("The Farm", 76, 196);
area("Bunny Island", 70, -27);
dist("Hippodrome", 72, 128); dist("Stadium", 48, 108); dist("Museum", 104, 78); dist("Sanayeh", 42, 56);
dist("Bourj Hammoud", 144, 13);
const near = (name, dy, label) => { const k = B.find(q => q.name === name); if(k) dist(label || name, k.x + k.w / 2, k.y + k.h + dy); };
dist("Roman Baths", 64, 40); dist("Cardo", 88, 38); dist("Sursock", 128, 42); dist("Old station", 142, 32);
near("Temple ruins", 1); dist("Cable car", 188, 20); dist("Cable car", 212, 10);
dist("St Nicholas Stairs", 117, 62); dist("Gemmayzeh", 112, 27); dist("Tram", 6, 66);
dist("Well's Head", 30, 10); dist("Red Street", 40, 50); dist("Downtown", 87, 20); dist("Grace Tower", 122, 50);
dist("Verdun Street", 40, 70); dist("Uptown", 76, 80); dist("Oven's Window", 116, 70);
dist("Manara's Light", 12, 40); dist("Starsand Pier (Biel)", 104, -6); dist("Port", 157, -20); dist("Zaitunay Bay", 52, 4); dist("Hangar 12", 170, 4);
dist("Pigeon Rocks", 8, 56); dist("White Sand", 34, 118); dist("Olive Bay", 36, 140); dist("South Beach", 36, 180);
dist("Plummet's Point", 210, -10); dist("Beacon Hill", 176, 38); dist("Victory Hill", 170, 84);
dist("Wing Hill", 58, 98); dist("Dahya", 100, 112); dist("Resolve's Rise", 128, 132);
dist("Saint Thereza", 108, 152); dist("Frere's Fray", 144, 184); dist("Abda", 172, 154);
dist("Mine", 178, 56); dist("Peak", 234, 8); dist("Ferry", 46, -12); dist("Riviera", 28, 18); dist("Beirut River", 156, 136);
writePng(path.join(out, "world_blueprint_preview.png"), P);
console.log("world_blueprint.png " + TW + "x" + TH + " (1 px = 1 tile), preview " + P.w + "x" + P.h);

// ---- the layout as data, for building the rooms and moving the villagers' routes over later: the roads and lanes by
// name (points in world tiles) and every building's footprint where it ended up
fs.writeFileSync(path.join(out, "world_layout.json"), JSON.stringify({
	note: "World tiles: x 0-249 east, y 0-199 south (the blueprint image adds a 30-tile margin to the west and north). Roads are 3 tiles wide, streets and lanes 2.",
	roads: ROADS, streets: STREETS, lanes: LANES, tram: TRAM, railway: RAILWAY, cable_car: CABLE,
	buildings: B.map(k => ({name: k.name, kind: k.kind, x: k.x, y: k.y, w: k.w, h: k.h})),
}, null, 1));

// ---- the grid as data, for tools/world2 (the room builder): one character a tile, by kind (KEY), rows from y = -M
const KEY = {deep: "D", sea: "S", shallow: "s", sand: "_", rocky: "r", grass: ".", meadow: "m", forest: "F", pine: "P",
	cliff: "C", cliffTop: "1", highland: "2", rock: "3", snow: "4", road: ":", lane: ",", plaza: "q", field: "=",
	river: "~", building: "B", pier: "p", cave: "c", rail: "t", ruin: "u", stairs: "z"};
fs.writeFileSync(path.join(out, "world_grid.json"), JSON.stringify({M, key: KEY,
	note: "rows[y + M][x + M] is world tile (x, y); x from -M (west sea) to 251, y from -M (north sea) to 201",
	rows: g.slice(0, M + 202).map(r => r.slice(0, M + 252).map(k => KEY[k] || "?").join(""))}));
