// The new world's blueprint (2026-11-06): the 25 outdoor rooms merged into big Stardew-style areas, drawn one pixel per
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
	cliffTop: [120, 150, 84], rock: [150, 138, 124], snow: [240, 244, 248], road: [170, 168, 160], lane: [196, 164, 106],
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

// ---- land, the coasts (world tiles 0..249 x 0..199, plus the margin)
// West coast: the sea's edge at x = 12 +- (wider and narrower like a real beach); north coast at y = 12 +-; the town's
// north-west corner (old Well's Head) is a bay
for(let y = -M; y < 200 + M; y++) for(let x = -M; x < 250 + M; x++){
	const west = 14 + wob(y, 1, 6), north = 13 + wob(x, 2, 4);
	const bay = (x < 70 && y < 64) && ((x - 0) ** 2 / 64 ** 2 + (y - 0) ** 2 / 58 ** 2 < 1.0 + wob(x + y, 3, 0.1));
	const landHere = x >= west && y >= north && !bay;
	if(landHere) set(x + M, y + M, "grass");
}
// Shallows and beaches: sand (west, and the bay's shore) and rocky shore (north) a band in from the sea
const isSea = (x, y) => ["deep", "sea", "shallow"].includes(get(x + M, y + M));
const nearSea = (x, y, r) => { for(let dy = -r; dy <= r; dy++) for(let dx = -r; dx <= r; dx++) if(isSea(x + dx, y + dy)) return true; return false; };
for(let y = 0; y < 200; y++) for(let x = 0; x < 250; x++){
	if(get(x + M, y + M) !== "grass") continue;
	const band = (x < 60) ? 7 + Math.round(wob(y, 4, 4)) : 4 + Math.round(wob(x, 5, 2));
	if(nearSea(x, y, Math.max(2, band))) set(x + M, y + M, (y < 40 && x > 46) ? "rocky" : "sand");
}
for(let y = -M; y < 200 + M; y++) for(let x = -M; x < 250 + M; x++){
	if(!isSea(x, y)) continue;
	let land = false;
	for(let dy = -4; dy <= 4 && !land; dy++) for(let dx = -4; dx <= 4; dx++) if(!isSea(x + dx, y + dy) && get(x + dx + M, y + dy + M) !== undefined){ land = true; break; }
	set(x + M, y + M, land ? "shallow" : (get(x + M, y + M) === "deep" && nearSea(x, y, 0) ? "sea" : "deep"));
}
for(let y = -M; y < 200 + M; y++) for(let x = -M; x < 250 + M; x++){
	if(get(x + M, y + M) !== "deep") continue;
	for(let dy = -9; dy <= 9; dy++) for(let dx = -9; dx <= 9; dx++) if(["shallow"].includes(get(x + dx + M, y + dy + M))){ set(x + M, y + M, "sea"); dy = 99; break; }
}

// ---- the mountain (top right): high ground from the north coast's east end down to the woods, a peak, the mine
const ridge = y => 200 + wob(y, 6, 10) - (y < 40 ? (40 - y) * 0.9 : 0);   // its west edge, swinging out over the north
for(let y = 0; y < 150; y++) for(let x = 0; x < 250 + M; x++){
	if(x >= ridge(y) && !isSea(x, y)) set(x + M, y + M, "cliffTop");
}
for(let y = 150; y < 200 + M; y++) for(let x = 236; x < 250 + M; x++) if(!isSea(x, y)) set(x + M, y + M, "cliffTop");
disc(232, 22, 16, 14, "rock", ["cliffTop"]);
for(let y = 0; y < 200; y++) for(let x = 190; x < 250; x++) if(get(x + M, y + M) === "cliffTop" && hash(x * 3, y * 7) < 0.09) set(x + M, y + M, "pine");
disc(234, 18, 7, 6, "snow", ["rock"]);
// The cliff face along the high ground's west and south edges
{
	const high = (x, y) => ["cliffTop", "rock", "snow", "pine"].includes(get(x + M, y + M)), edge = [];
	for(let y = 0; y < 200 + M; y++) for(let x = 0; x < 250 + M; x++){
		if(get(x + M, y + M) !== "cliffTop") continue;
		if(!high(x - 1, y)) for(let k = 0; k < 3; k++) edge.push([x + k, y]);          // the west face, 3 wide
		for(let k = 1; k <= 3; k++) if(get(x + M, y + k + M) === "grass"){ edge.push([x, y]); break; }   // the south face
	}
	for(const [x, y] of edge) if(get(x + M, y + M) === "cliffTop") set(x + M, y + M, "cliff");
}

// ---- forests: Whispering Woods (bottom right), the pine wood in the Outskirts (Dahya), woods along the south
const blob = (cx, cy, rx, ry, k, s) => { for(let y = cy - ry - 6; y <= cy + ry + 6; y++) for(let x = cx - rx - 6; x <= cx + rx + 6; x++){
	const a = Math.atan2(y - cy, x - cx), r = 1 + wob(a * 20 + 50, s, 0.18);
	if(((x - cx) / rx) ** 2 + ((y - cy) / ry) ** 2 <= r * r && ["grass"].includes(get(x + M, y + M))) set(x + M, y + M, k);
} };
blob(222, 172, 26, 26, "forest", 11);
blob(225, 130, 20, 16, "forest", 12);
blob(128, 141, 20, 12, "pine", 13);        // Horsh Beirut, the pine wood
blob(70, 196, 22, 5, "forest", 14);
blob(150, 197, 30, 4, "forest", 15);

for(let y = 0; y < 200 + M; y++) for(let x = 0; x < 250 + M; x++){
	const southEdge = y > 197 + wob(x, 17, 3), eastEdge = x > 247 + wob(y, 18, 3);
	if((southEdge || eastEdge) && ["grass", "sand"].includes(get(x + M, y + M))) set(x + M, y + M, "forest");
}

// ---- the river: from the mountain's spring, down the woods' edge, west between the Outskirts and the farm, to the sea
const river = [[214, 70], [207, 92], [202, 118], [196, 150], [178, 158], [150, 157], [120, 160], [96, 158], [70, 161], [44, 163], [20, 166], [0, 167]];
for(let i = 0; i < river.length - 1; i++){
	const [x1, y1] = river[i], [x2, y2] = river[i + 1], n = Math.max(Math.abs(x2 - x1), Math.abs(y2 - y1));
	for(let t = 0; t <= n; t++){
		const x = x1 + (x2 - x1) * t / n, y = y1 + (y2 - y1) * t / n + wob(x * 2 + t, 16, 1.5), w = 1.5 + i * 0.12;
		for(let dy = -w; dy <= w; dy++) for(let dx = -w; dx <= w; dx++) if(!isSea(Math.round(x + dx), Math.round(y + dy))) set(x + dx + M, y + dy + M, "river");
	}
}
disc(214, 68, 4, 3, "river");                                     // the spring's pool

// ---- roads (grey, the town's cobbles and the main roads) and lanes (dirt)
const line = (pts, k, w, under) => { for(let i = 0; i < pts.length - 1; i++){
	const [x1, y1] = pts[i], [x2, y2] = pts[i + 1], n = Math.max(Math.abs(x2 - x1), Math.abs(y2 - y1), 1);
	for(let t = 0; t <= n; t++){ const x = x1 + (x2 - x1) * t / n, y = y1 + (y2 - y1) * t / n;
		for(let dy = -w; dy <= w; dy++) for(let dx = -w; dx <= w; dx++){ const cur = get(Math.round(x + dx) + M, Math.round(y + dy) + M);
			if(cur === "river") set(x + dx + M, y + dy + M, "pier");            // a bridge
			else if(!["deep", "sea", "shallow"].includes(cur) && (!under || under.includes(cur))) set(x + dx + M, y + dy + M, k); } } } };
// The town: a grid of streets with a square in the middle (old Downtown), the corniche along the north
line([[56, 52], [196, 52]], "road", 1); line([[50, 78], [196, 78]], "road", 1); line([[50, 104], [190, 104]], "road", 1);
line([[78, 30], [78, 118]], "road", 1); line([[112, 44], [112, 120]], "road", 1); line([[148, 44], [148, 120]], "road", 1); line([[184, 52], [184, 118]], "road", 1);
line([[54, 46], [56, 52]], "road", 1);                             // up to the Riviera on the bay
rect(100, 68, 124, 88, "plaza");                                  // the town square
// North Beach's corniche, along the top of the land, running into the cliffs
line([[52, 26], [100, 25], [150, 27], [178, 30]], "road", 1);
line([[112, 44], [112, 26]], "road", 1); line([[148, 44], [148, 27]], "road", 1);
// The West Beach's coast road, and the lanes down to the sand
line([[40, 52], [34, 80], [32, 110], [34, 140], [36, 175], [34, 196]], "lane", 1);
line([[50, 78], [34, 80]], "lane", 1); line([[50, 104], [32, 106]], "lane", 1);
// Out of town to the east: the mine road up the mountain to the mine, and on up to the peak
line([[196, 52], [206, 56], [214, 50], [222, 44], [226, 34], [232, 26]], "lane", 1, ["grass", "cliffTop", "cliff", "rock", "lane", "road"]);
line([[184, 104], [204, 100]], "lane", 1, ["grass", "cliffTop", "cliff", "lane", "road"]);   // up to Victory Hill
// The Outskirts: the road south from the town to the farm, a ring round the pine wood, the lane east to the countryside
line([[112, 120], [112, 140], [100, 150], [78, 160], [74, 172]], "road", 1);
line([[78, 118], [70, 132], [74, 150]], "lane", 1);
line([[148, 120], [152, 140], [160, 150]], "lane", 1);
line([[74, 172], [110, 176], [150, 178], [190, 180]], "lane", 1);
line([[160, 150], [176, 170], [190, 180], [204, 184]], "lane", 1);   // into Whispering Woods
line([[48, 182], [74, 176]], "lane", 1);                            // the farm to the West Beach

// ---- the farm (old rm_1's place): a field and a pond
rect(58, 176, 96, 196, "grass", ["grass", "forest"]);
rect(76, 184, 92, 194, "field");
disc(64, 190, 4, 3, "river");

// ---- the countryside's fields and vineyard
rect(116, 182, 134, 192, "field"); rect(156, 182, 170, 190, "field");

// ---- piers
const pier = (x, y, len, dx, dy) => { for(let k = 0; k < len; k++) for(let w = 0; w <= 1; w++) set(x + dx * k + (dy ? w : 0) + M, y + dy * k + (dx ? w : 0) + M, "pier"); };
pier(112, 22, 14, 0, -1);             // Starsand's stone pier (north)
pier(18, 112, 12, -1, 0);             // Pigeon Rocks
pier(20, 170, 14, -1, 0);             // South Beach's fishing pier

// ---- the mine, in the mountain's cliff face
disc(212, 50, 2, 1.5, "cave");

// ---- Bunny Island, out in the northern sea, and the ferry's route from Starsand
for(let y = -28; y < -6; y++) for(let x = 96; x < 136; x++){
	const a = Math.atan2(y + 17, x - 116), r = 1 + wob(a * 20, 21, 0.15);
	if(((x - 116) / 17) ** 2 + ((y + 17) / 9) ** 2 <= r * r) set(x + M, y + M, "grass");
}
for(let y = -28; y < -6; y++) for(let x = 96; x < 136; x++) if(get(x + M, y + M) === "grass" && nearSea(x, y, 2)) set(x + M, y + M, "sand");
disc(112, -16, 6, 3, "forest", ["grass"]);
pier(116, -9, 4, 0, 1);

// ---- buildings: [x, y, w, h] in tiles (footprints, roughly to scale), by area
const B = [];
const b = (x, y, w, h, name) => B.push({x, y, w, h, name});
// Beirut, the town
b(50, 40, 9, 5, "Riviera hotel"); b(62, 36, 6, 4, "Glassworks"); b(56, 30, 5, 4, "Fairglass");
b(60, 44, 6, 5, "Goldcrest"); b(84, 44, 7, 5, "Tavern"); b(96, 44, 8, 6, "Bank"); b(118, 44, 6, 5, "Tools");
b(154, 44, 7, 5, "Smithy"); b(164, 44, 6, 5, "Whitlow"); b(124, 58, 6, 5, "Guild hall");
b(60, 82, 6, 4, "Bakery"); b(68, 82, 6, 4, "Flowers"); b(84, 82, 7, 4, "Furniture");
b(126, 82, 8, 5, "Hospital"); b(136, 82, 8, 5, "Library"); b(128, 94, 8, 5, "Museum");
b(154, 82, 6, 4, "Quill"); b(162, 82, 8, 5, "Meadowlark"); b(88, 96, 6, 4, "Cafe");
// North Beach
b(60, 16, 3, 7, "Lighthouse"); b(96, 18, 6, 4, "Fish market"); b(124, 18, 6, 4, "Ferry"); b(156, 18, 8, 5, "Hangar 12");
b(166, 30, 6, 4, "Tinker"); b(158, 32, 5, 4, "Brassbolt");
// West Beach
b(26, 58, 6, 4, "Olive press"); b(36, 60, 5, 4, "Saba"); b(24, 96, 5, 4, "Gullwater"); b(22, 130, 6, 4, "Beach bar");
b(18, 140, 3, 4, "Lifeguard"); b(40, 128, 4, 3, "Shack"); b(26, 176, 7, 4, "Boatyard"); b(38, 184, 6, 4, "Saltwhistle");
// The Mountain
b(222, 64, 5, 7, "Witch tower"); b(206, 40, 5, 4, "Ironvein"); b(212, 96, 4, 6, "Windmill"); b(218, 104, 7, 5, "Oakhart"); b(226, 98, 7, 4, "Mill");
// The Outskirts
b(84, 124, 6, 4, "Kassar"); b(94, 128, 6, 4, "Merchant"); b(132, 124, 6, 4, "Larkspun"); b(140, 126, 6, 4, "Outfitter");
b(148, 132, 6, 4, "Tawil"); b(166, 124, 6, 5, "Silverbough"); b(174, 132, 6, 4, "Apothecary");
// Whispering Woods
b(214, 160, 5, 4, "Ranger");
// The farm
b(66, 177, 5, 4, "Farmhouse"); b(84, 177, 7, 5, "Barn");
// The Countryside
b(110, 174, 6, 4, "Night farm"); b(120, 176, 7, 4, "Seeds"); b(146, 172, 7, 6, "Monastery"); b(156, 174, 6, 4, "Stables");
b(164, 176, 6, 4, "Hayward"); b(172, 172, 5, 4, "Frere"); b(184, 168, 6, 6, "Church"); b(192, 172, 5, 4, "Ward");
// Bunny Island
b(120, -20, 4, 3, "Burrow");
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
		if(k === "grass" || k === "meadow" || k === "cliffTop") cc = shade(c, 1 + (hash(x * 7 + dx, y * 13 + dy) - 0.5) * 0.08);
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
area("Beirut", 112, 75); area("North Beach", 60, -6); area("West Beach", 18, 150); area("The Mountain", 222, 82);
area("The Outskirts", 112, 146); area("Whispering Woods", 210, 186); area("Countryside", 150, 194); area("The Farm", 77, 170);
area("Bunny Island", 116, -27);
dist("Well's Head", 30, 30); dist("Red Street", 64, 60); dist("Downtown", 112, 64); dist("Grace Tower", 166, 60);
dist("Verdun Street", 70, 92); dist("Uptown", 130, 110); dist("Oven's Window", 166, 92);
dist("Manara's Light", 64, 8); dist("Starsand Pier", 118, 8); dist("Hangar 12", 162, 10);
dist("Olive Bay", 22, 66); dist("Pigeon Rocks", 22, 104); dist("White Sand", 22, 120); dist("South Beach", 22, 188);
dist("Plummet's Point", 228, 4); dist("Beacon Hill", 222, 54); dist("Victory Hill", 222, 114);
dist("Wing Hill", 86, 134); dist("Dahya", 128, 136); dist("Resolve's Rise", 172, 142);
dist("Saint Thereza", 122, 168); dist("Frere's Fray", 160, 166); dist("Abda", 192, 162);
dist("Mine", 212, 46); dist("Peak", 234, 12); dist("Ferry", 128, -4); dist("Riviera", 54, 26);
writePng(path.join(out, "world_blueprint_preview.png"), P);
console.log("world_blueprint.png " + TW + "x" + TH + " (1 px = 1 tile), preview " + P.w + "x" + P.h);
