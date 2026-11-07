// Cedar & Sea's world: the outdoor rooms built from the blueprint (design/map: world_grid.json, areas.json,
// world_layout.json, old_rooms.json), as room specs for tools/rooms/build.js.
//
//   specs/<room>.js:  module.exports = require("../../world2/areas_build.js").spec("<room>");
//
// Each new room is one area of the blueprint (its tiles; the rest of its bounding box is drawn but walled off), cut
// from the same world, so a way through is a strip on the border with a transition each side, arriving the same world
// tile on the other side. Buildings stand on their blueprint footprints (slid to clear ground), doors leading to their
// interiors as before. The old 25 rooms' named spots are carried over as "<old room>__<spot>" (and building fronts
// under their own names), and ALIAS maps each old room to the new one, so the villagers' schedules ("rm_downtown.mid")
// keep working (scripts/world_alias). The farm (rm_1) keeps its own spec; its ways out lead here (farmArrive).
const fs = require("fs");
const path = require("path");
const T = require("../rooms/tiles.js");
const woods = require("../rooms/woods.js");
const INTERIORS = require("../world/interior_data.js");
const {ROOMS} = require("../world/world.js");

const MAP = path.join(__dirname, "..", "..", "design", "map");
const read = f => JSON.parse(fs.readFileSync(path.join(MAP, f), "utf8"));
const G = read("world_grid.json"), AREAS = read("areas.json"), LAYOUT = read("world_layout.json"), OLDR = read("old_rooms.json").rooms;
const M = G.M;
const kindAt = (x, y) => (G.rows[y + M] || "")[x + M] || "D";

const ROOM_OF = {"Bunny Island": "rm_bunny", "Phoenix Bay": "rm_phoenix", "Beirut": "rm_beirut", "The Mountain": "rm_mountain",
	"Sunset Coast": "rm_sunset", "The Outskirts": "rm_outskirts", "Whispering Woods": "rm_woods", "The Farm": "rm_1",
	"The Countryside": "rm_countryside"};
const KIND = {rm_bunny: "rural", rm_phoenix: "town", rm_beirut: "town", rm_mountain: "wild", rm_sunset: "rural",
	rm_outskirts: "rural", rm_woods: "deep", rm_countryside: "rural"};
const WATER = {rm_bunny: "sea", rm_phoenix: "sea", rm_beirut: "sea", rm_sunset: "sea", rm_mountain: "river", rm_outskirts: "river",
	rm_woods: "river", rm_countryside: "river"};

// Which area owns each world tile (the areas' rectangles, earlier ones first), as in tools/map/areas.js
const OWN = new Map();
AREAS.areas.forEach((a, i) => { for(const [x1, y1, x2, y2] of a.rects) for(let y = y1; y <= y2; y++) for(let x = x1; x <= x2; x++){
	const k = x + "," + y; if(!OWN.has(k)) OWN.set(k, ROOM_OF[a.name]); } });
const owner = (x, y) => OWN.get(x + "," + y);

// The old rooms: each old room's new room (by the area its ground went to), for the alias table
const ALIAS = {};
// (by which new room owns most of the old room's ground)
for(const [old, o] of Object.entries(OLDR)){
	const [x1, y1, x2, y2] = o.rect, n = {};
	for(let y = y1; y <= y2; y++) for(let x = x1; x <= x2; x++){ const w = owner(x, y); if(w) n[w] = (n[w] || 0) + 1; }
	ALIAS[old] = Object.entries(n).sort((p, q) => q[1] - p[1])[0][0];
}
ALIAS.rm_1 = "rm_1";

// Blueprint building names -> what stands there: a building of world.js (by key: sprite, interior), a thing, a
// placeholder until its art is made, or ruins
const BUILDING = {"Riviera hotel": "hotel", "Glassworks": "glassworks", "Fairglass": "fairglass", "Goldcrest": "goldcrest",
	"Tavern": "tavern", "Bank": "bank", "Tools": "tools", "Guild hall": "guild", "Smithy": "smithy", "Whitlow": "whitlow",
	"Bakery": "bakery", "Flowers": "flowers", "Furniture": "furniture", "Hospital": "hospital", "Library": "library",
	"Quill": "quill", "Meadowlark": "meadowlark", "Lighthouse": "lighthouse", "Tinker": "tinker", "Brassbolt": "brassbolt",
	"Gullwater": "gullwater", "Shack": "shack", "Olive press": "olivepress", "Saba": "saba", "Boatyard": "boatyard",
	"Saltwhistle": "saltwhistle", "Ironvein": "ironvein", "Oakhart": "oakhart", "Mill": "mill", "Witch tower": "tower",
	"Kassar": "kassar", "Larkspun": "larkspun", "Outfitter": "clothes", "Tawil": "tawil", "Silverbough": "silverbough",
	"Apothecary": "potions", "Night farm": "nighthome", "Seeds": "seeds", "Stables": "stables", "Hayward": "hayward",
	"Frere": "frere", "Church": "church", "Ward": "ward"};
const THING = {"Museum": "prop_museum", "Cafe": "prop_cafe_terrace", "Fish market": "prop_fish_market", "Ferry": "prop_ferry_dock",
	"Hangar 12": "prop_old_hangar", "Beach bar": "prop_beach_bar", "Lifeguard": "prop_lifeguard_hut", "Windmill": "house_windmill",
	"Merchant": "prop_merchant_cart", "Ranger": "prop_rangers_cabin", "Monastery": "prop_monastery"};
const PLACEHOLDER = {"Biel hall": "Biel hall", "Silos": "Silos", "Marina club": "Marina club", "Bourj Hammoud market": "Bourj Hammoud market",
	"Stadium": "Stadium", "Sursock gallery": "Sursock gallery", "Bar": "Bar", "Old station": "Old station", "Cable car": "Cable car",
	"Cable car top": "Cable car", "Tram stop": "Tram stop", "Burrow": "Bunny burrow"};
// The placeholders' PixelLab art (spr_prop_*, 2026-11-06); a box with a label only where the art finds no room
const PLACEHOLDER_ART = {"Biel hall": "prop_exhibition_hall", "Silos": "prop_port_silos", "Marina club": "prop_marina_club",
	"Bourj Hammoud market": "prop_bourj_market", "Stadium": "prop_stadium", "Sursock gallery": "prop_sursock_gallery",
	"Bar": "prop_gemmayzeh_bar", "Old station": "prop_old_station", "Cable car": "prop_cable_car_station",
	"Cable car top": "prop_cable_car_station", "Tram stop": "prop_tram_stop", "Burrow": "prop_bunny_burrow"};
// The cable car and the tram: a station (obj_transit) in front of each one's art; you ride once its project is done
// (scripts/transit). Each takes the name of the old district it stands in, or its area's.
const BRICK = ["Red Street", "Verdun Street", "Well's Head", "Oven's Window", "Pigeon Rocks", "Manara's Light"];
const STATION_OF = {"Cable car": "cable", "Cable car top": "cable", "Tram stop": "tram"};
const STATIONS = [];
// Named places on the blueprint (its labels, tools/map/blueprint.js), for a stop whose district already has one
const PLACES = {"Zaitunay Bay": [52, 4], "Martyrs' Square": [89, 27], "Gemmayzeh": [112, 27], "Sanayeh": [42, 56], "Cardo": [88, 38],
	"Museum": [104, 78], "Hippodrome": [72, 128], "Stadium": [48, 108], "Sursock": [128, 42], "Corniche": [14, 70]};   // {kind, name, room, x, y}, filled as the rooms are built
const districtAt = (wx, wy, area) => { for(const [o, d] of Object.entries(OLDR)){ const [x1, y1, x2, y2] = d.rect;
	if(wx >= x1 && wx <= x2 && wy >= y1 && wy <= y2 && ROOMS[o] && ROOMS[o].name) return ROOMS[o].name; }
	// in none (the new shore): the nearest one in this area
	let best = area, bd = 1e9;
	for(const [o, d] of Object.entries(OLDR)){ if(!ROOMS[o] || !ROOMS[o].name || ROOM_OF[area] !== ALIAS[o]) continue; const [x1, y1, x2, y2] = d.rect;
		const dd = Math.hypot(Math.max(x1 - wx, 0, wx - x2), Math.max(y1 - wy, 0, wy - y2)); if(dd < bd){ bd = dd; best = ROOMS[o].name; } }
	return best; };
const BROKEN_BRIDGE = {room: "rm_mountain", at: [146, 80], size: [2, 2]};   // world tiles: a river footbridge
// The spare homes (no way in): the flat versions kept when the remakes with depth replaced them, and the remakes of
// Larkspun and Quill (the families kept their old ones) - art/ai_houses/alt_*
const ALT_HOMES = ["saba", "saltwhistle", "hayward", "ward", "tawil", "kassar", "night", "cottage", "family_house", "larkspun", "quill"].map(n => "prop_alt_" + n);
// The plots for sale (scripts/pshops): how many in each room, their size (cells: room for the biggest design), the
// buildings you can choose for them (the town's spare designs), and where you arrive inside a shop (tools/world2/pshop_room.js)
const PLOTS_IN = {rm_beirut: 8, rm_outskirts: 2};
const PLOT_DESIGNS = ["prop_town_hallhouse", "prop_town_hallhouse3", "prop_town_apartments", "prop_town_yellowhouse", "prop_town_yellowhouse2",
	"prop_town_villa", "prop_town_villa2", "prop_town_shop", "prop_town_shop2", "prop_town_cafe", "prop_town_cafe2", "prop_town_bakery",
	"prop_town_bakery2"].concat(ALT_HOMES);
const PLOT_W = 7, PLOT_H = 6, PSHOP_IN = [224, 280];
const PLOTS = [];
// The Mayor's house (the town hall, by the square) and where you arrive inside it (tools/rooms/specs/rm_mayor.js)
const MAYOR_HOUSE = "prop_town_hallhouse2", MAYOR_IN = [224, 280];
const RUINS = {
	house: {w: 8, h: 4, parts: [["ruin_wall_brick", 0, 0], ["ruin_wall_stone", 4, 0], ["ruin_rubble", 1, 3], ["ruin_rubble", 5, 3], ["ruin_stump", 3, 2]]},
	temple: {w: 8, h: 5, parts: [["ruin_pillar", 0, 0], ["ruin_ivy", 2, 1], ["ruin_head", 3, 1], ["ruin_columns", 6, 1], ["ruin_rubble", 1, 4], ["ruin_stump", 5, 3]]},
};
const RUIN_OF = {"Roman Baths": "house", "Temple ruins": "temple"};
const keyInfo = {};   // building key -> {is, room} from world.js
for(const R of Object.values(ROOMS)) for(const b of R.buildings || []) keyInfo[b.key] = b;
const placedNames = new Set([...Object.keys(THING).map(n => THING[n])]);

const size = is => { const s = T.things[is].src; return [s[2], s[3]]; };
const doorOf = is => { const b = T.things[is]; return b.door || [Math.floor(b.src[2] / 2), b.src[3] - 1]; };
function rng(seed){ let s = seed * 9301 + 49297; return () => (s = (s * 16807) % 2147483647) / 2147483647; }

// Blueprint tile -> map character (the builder's legend: tools/rooms/tiles.js)
const CH = {".": ".", m: ".", F: ".", P: ".", "1": ".", "2": ".", "4": ".", B: ".", u: ".", "3": ".", ":": ":", q: ":", z: ":", t: ":",
	",": ",", r: ",", _: "_", D: "~", S: "~", s: "~", "~": "~", p: "b", "=": ",", C: "X", c: "X"};
const OPEN = [".", ",", ":", "_", "b"];   // walkable map characters

let BUILT = null;   // every room, built once: {rooms: {id: spec}, exits: {key: [room, x, y]}, frame: {id: {ox, oy, W, H}}}

function frameOf(id){
	let x1 = 1e9, y1 = 1e9, x2 = -1e9, y2 = -1e9;
	for(const [k, r] of OWN) if(r === id){ const [x, y] = k.split(",").map(Number); x1 = Math.min(x1, x); y1 = Math.min(y1, y); x2 = Math.max(x2, x); y2 = Math.max(y2, y); }
	return {ox: x1, oy: y1, W: x2 - x1 + 1, H: y2 - y1 + 1};
}

function buildAll(){
	const ids = Object.values(ROOM_OF).filter(id => id !== "rm_1");
	const frames = {};
	for(const id of ids) frames[id] = frameOf(id);
	const rooms = {}, exits = {};
	STATIONS.length = 0;
	PLOTS.length = 0;
	for(const id of ids) rooms[id] = buildRoom(id, frames[id], exits);
	// Ways through, now that every room exists: a strip each side of each crossing, arriving on the other side
	SOLID = {rooms, frames, cells: {}};
	for(const id of ids) addWays(id, rooms, frames);
	return {rooms, exits, frames, stations: STATIONS};
}

function buildRoom(id, fr, exits){
	const {ox, oy, W, H} = fr;
	const seed = [...id].reduce((a, ch) => a * 31 + ch.charCodeAt(0), 7) % 100000;
	const own = (c, r) => owner(ox + c, oy + r) === id;
	const bk = (c, r) => kindAt(ox + c, oy + r);
	const grid = Array.from({length: H}, (_, r) => Array.from({length: W}, (_, c) => CH[bk(c, r)] || "."));
	const at = (c, r) => (grid[r] || [])[c];
	const things = [], instances = [], points = {}, areas = {}, areaKinds = {}, taken = new Set();
	const take = (c, r, w, h) => { for(let y = r; y < r + h; y++) for(let x = c; x < c + w; x++) taken.add(x + "," + y); };
	const free = (c, r, w, h, ok = ["."], overTaken = false) => { for(let y = r; y < r + h; y++) for(let x = c; x < c + w; x++){
		if(x < 1 || y < 1 || x >= W - 1 || y >= H - 1 || !own(x, y) || !ok.includes(at(x, y)) || (!overTaken && taken.has(x + "," + y))) return false; } return true; };

	// Cliff faces: the cliff 9-slice (TS_terrain cols 5-7, rows 2-4 the face), by which neighbours are cliff too
	for(let r = 0; r < H; r++) for(let c = 0; c < W; c++){
		if(bk(c, r) !== "C") continue;
		const isC = (cc, rr) => bk(cc, rr) === "C" || bk(cc, rr) === "c";
		const col = !isC(c - 1, r) ? 5 : !isC(c + 1, r) ? 7 : 6, row = !isC(c, r - 1) ? 2 : !isC(c, r + 1) ? 4 : 3;
		things.push({src: [col, row, 1, 1], at: [c, r]});
		taken.add(c + "," + r);
	}
	// Piers: planks over the sea. Bridges (the planks over a river) are the LPC Revised ones (art/lpc_revised,
	// TS_lpcr_<season>, the same layout every season): a railed plank bridge where the way crosses north-south, a plank
	// deck where it crosses east-west, each reaching a tile onto both banks
	const LPCR = "TS_lpcr_summer";
	const nearRiver = (c, r) => { for(let dy = -2; dy <= 2; dy++) for(let dx = -2; dx <= 2; dx++) if(bk(c + dx, r + dy) === "~") return true; return false; };
	const bridgeCell = new Set();
	for(let r = 0; r < H; r++) for(let c = 0; c < W; c++) if(bk(c, r) === "p"){
		taken.add(c + "," + r);
		if(nearRiver(c, r)) bridgeCell.add(c + "," + r); else things.push({src: [17, 20, 1, 1], at: [c, r]});
	}
	{ const seen = new Set();
	  for(const k of bridgeCell){ if(seen.has(k)) continue;
		const part = [], st = [k]; seen.add(k);
		while(st.length){ const q = st.pop(); part.push(q); const [c, r] = q.split(",").map(Number);
			for(let dy = -1; dy <= 1; dy++) for(let dx = -1; dx <= 1; dx++){ const n = (c + dx) + "," + (r + dy); if(bridgeCell.has(n) && !seen.has(n)){ seen.add(n); st.push(n); } } }
		const xs = part.map(q => +q.split(",")[0]), ys = part.map(q => +q.split(",")[1]);
		const x1 = Math.min(...xs), x2 = Math.max(...xs), y1 = Math.min(...ys), y2 = Math.max(...ys);
		if(x2 - x1 >= y2 - y1){
			// east-west: the plank deck (cols 47-50, rows 3-5: left end, middle again and again, the last two)
			const L = Math.max(4, x2 - x1 + 3), top = Math.round((y1 + y2) / 2) - 1;
			for(let i = 0; i < L; i++){ const col = i === 0 ? 47 : (i === L - 1 ? 50 : (i === L - 2 ? 49 : 48));
				things.push({src: [col, 3, 1, 3], tileset: LPCR, at: [x1 - 1 + i, top], role: "decor"}); }
		} else {
			// north-south: the railed bridge (cols 44-46: row 15 its top, 16 again and again, 17 its foot)
			const L = Math.max(3, y2 - y1 + 3), left = Math.round((x1 + x2) / 2) - 1;
			for(let j = 0; j < L; j++) things.push({src: [44, j === 0 ? 15 : (j === L - 1 ? 17 : 16), 3, 1], tileset: LPCR, at: [left, y1 - 1 + j], role: "decor"});
		}
	  } }
	// Roads, water, cliffs are taken (nothing scattered or grown on them)
	for(let r = 0; r < H; r++) for(let c = 0; c < W; c++) if(at(c, r) !== "." && at(c, r) !== ",") taken.add(c + "," + r);

	// The mine's cave mouth (Beacon Hill's), in the mountain's cliff
	for(let r = 0; r < H; r++) for(let c = 0; c < W; c++) if(bk(c, r) === "c" && !points.cave){
		const px = (c + 1) * 32, py = (r + 2) * 32 + 12;
		instances.push({obj: "obj_mine_door", x: px, y: py});
		for(let y = r + 1; y <= r + 4; y++) for(let x = c - 1; x <= c + 2; x++) if(own(x, y) && at(x, y) === ".") grid[y][x] = ",";
		points.cave = [px, py + 28];
		points.miner = [px - 96, py + 28];
	}

	// Buildings, landmarks, ruins and placeholders on their blueprint footprints
	const here = LAYOUT.buildings.filter(b => owner(b.x + Math.floor(b.w / 2), b.y + b.h - 1) === id);
	// the biggest buildings choose their ground first (a tall lighthouse needs more room than a cottage beside it)
	const bigness = b => BUILDING[b.name] && keyInfo[BUILDING[b.name]] ? size(keyInfo[BUILDING[b.name]].is).reduce((p, q) => p * q, 1) : 0;
	here.sort((a, b) => bigness(b) - bigness(a));
	const placeAt = (w, h, fx, fy, fw, fh, ok, needFront, footRows) => {
		// The thing's foot centred on the footprint's foot, slid to the nearest clear spot
		const want = [Math.round(fx + fw / 2 - w / 2), fy + fh - h];
		for(let d = 0; d <= 24; d++) for(let dy = -d; dy <= d; dy++) for(let dx = -d; dx <= d; dx++){
			if(Math.max(Math.abs(dx), Math.abs(dy)) !== d) continue;
			const c = want[0] + dx, r = want[1] + dy;
			// footRows: only the foot on clear ground, the rest (a tall tower) may stand over a road behind it
			if(footRows){
				if(!free(c, r + h - footRows, w, footRows, ok)) continue;
				let up = true;   // (the tower may rise over the next area's ground: only not over water, cliffs or other things)
				for(let y = r; y < r + h - footRows && up; y++) for(let x = c; x < c + w && up; x++)
					if(x < 1 || y < 0 || x >= W - 1 || ![".", ",", ":", "_"].includes(at(x, y)) || taken.has(x + "," + y)) up = false;
				if(!up) continue;
			}
			else if(!free(c, r, w, h, ok)) continue;
			if(needFront && !OPEN.includes(at(c + needFront[0], r + h)) ) continue;
			return [c, r];
		}
		return null;
	};
	for(const b of here){
		const fx = b.x - ox, fy = b.y - oy;
		if(BUILDING[b.name]){
			const key = BUILDING[b.name], info = keyInfo[key];
			if(!info){ console.log(`  ${id}: no building ${key}`); continue; }
			const is = info.is, [w, h] = size(is), d = doorOf(is);
			const spot = placeAt(w, h, fx, fy, b.w, b.h, [".", ","], d) || placeAt(w, h, fx, fy, b.w, b.h, [".", ",", ":"], d)
				|| (h > 6 ? placeAt(w, h, fx, fy, b.w, b.h, [".", ","], d, 4) : null);
			if(!spot){ console.log(`  ${id}: no room for ${b.name}`); continue; }
			const [c, r] = spot;
			things.push({is, at: [c, r]});
			take(c - 1, r, w + 2, h + 1);
			const art = T.things[is].doorArt;
			if(art) instances.push({obj: art.obj, x: c * 32 + art.at[0], y: r * 32 + art.at[1]});
			const dx = (c + d[0]) * 32 + 16, dy = (r + d[1]) * 32 + 16, inside = INTERIORS.doorPoint(info.room);
			instances.push({obj: "obj_transition", x: dx, y: dy, sx: 2, sy: 1,
				code: `targetRoom = ${info.room};\ntargetX = ${inside[0]};\ntargetY = ${inside[1]};\nPlayerFacingBefore = dir.up;\nPlayerFacingAfter = dir.up;`});
			exits[key] = [id, dx, dy + 36];
			points[key + "_front"] = [dx, dy + 52];
			// a bit of dirt path from the door to the nearest road below it, if it's close
			{ const cc = c + d[0]; let reach = -1;
			  for(let rr = r + h; rr < Math.min(H, r + h + 7); rr++){ if(at(cc, rr) === ":" || at(cc, rr) === ",") { reach = rr; break; } if(at(cc, rr) !== ".") break; }
			  if(reach > 0) for(let rr = r + h; rr < reach; rr++) grid[rr][cc] = ","; }
		} else if(THING[b.name]){
			const is = THING[b.name], [w, h] = size(is);
			const spot = placeAt(w, h, fx, fy, b.w, b.h, [".", ",", "_"]) || placeAt(w, h, fx, fy, b.w, b.h, [".", ",", "_"], null, Math.min(2, h));
			if(!spot){ console.log(`  ${id}: no room for ${b.name}`); continue; }
			things.push({is, at: spot});
			take(spot[0], spot[1], w, h);
			points["lm_" + is.replace(/^(prop|house)_/, "")] = [(spot[0] + Math.floor(w / 2)) * 32 + 16, (spot[1] + h) * 32 + 24];
		} else if(RUIN_OF[b.name] || b.name === "Cardo"){
			if(b.name === "Cardo"){ for(let k = 0; k + 2 <= b.w; k += 3) if(free(fx + k, fy - 1, 2, 3, [".", ",", ":"])){ things.push({is: "ruin_columns", at: [fx + k, fy - 1]}); take(fx + k, fy - 1, 2, 3); } continue; }
			const ru = RUINS[RUIN_OF[b.name]], spot = placeAt(ru.w, ru.h, fx, fy, b.w, b.h, [".", ","]);
			if(!spot) continue;
			for(const [p, ddx, ddy] of ru.parts) things.push({is: p, at: [spot[0] + ddx, spot[1] + ddy]});
			take(spot[0], spot[1], ru.w, ru.h);
			points["lm_" + b.name.toLowerCase().replace(/[^a-z]+/g, "_")] = [(spot[0] + 4) * 32, (spot[1] + ru.h) * 32 + 24];
		} else if(PLACEHOLDER[b.name]){
			const art = PLACEHOLDER_ART[b.name];
			if(art && T.things[art]){
				const [w, h] = size(art), at2 = placeAt(w, h, fx, fy, b.w, b.h, [".", ",", "_"]) || placeAt(w, h, fx, fy, b.w, b.h, [".", ",", "_"], null, Math.min(2, h));
				if(at2){
					things.push({is: art, at: at2});
					// a cell clear around it, and for a station three rows clear in front (where you stand to ride)
					take(at2[0] - 1, at2[1] - 1, w + 2, h + (STATION_OF[b.name] ? 4 : 2));
					points["lm_" + b.name.toLowerCase().replace(/[^a-z]+/g, "_")] = [(at2[0] + Math.floor(w / 2)) * 32 + 16, (at2[1] + h) * 32 + 24];
					if(STATION_OF[b.name]){
						const kind = STATION_OF[b.name], sx = (at2[0] + Math.floor(w / 2)) * 32 + 16, sy = (at2[1] + h) * 32 + 20;
						const area = Object.keys(ROOM_OF).find(n => ROOM_OF[n] === id);
						let name = districtAt(ox + at2[0] + Math.floor(w / 2), oy + at2[1] + h, area);
						if(kind === "cable") name = (b.name === "Cable car top") ? "the Mountain top" : name;
						if(STATIONS.some(t => t.kind === kind && t.name === name)){   // taken: the nearest of Beirut's named places instead
							let bd = 1e9;
							for(const [pn, [px, py]] of Object.entries(PLACES)) if(!STATIONS.some(t => t.name === pn)){
								const dd = Math.hypot(px - b.x, py - b.y); if(dd < bd){ bd = dd; name = pn; } }
						}
						STATIONS.push({kind, name, room: id, x: sx, y: sy + 24});
						instances.push({obj: "obj_transit", x: sx, y: sy, code: `kind = "${kind}";
stop = "${name.replace(/"/g, "")}";`});
						points["station_" + kind + "_" + STATIONS.filter(t => t.kind === kind).length] = [sx, sy + 24];
					}
					continue;
				}
				console.log(`  ${id}: no room for ${b.name}'s art, a placeholder instead`);
			}
			const spot = placeAt(b.w, b.h, fx, fy, b.w, b.h, [".", ",", ":", "_"]);
			if(!spot) continue;
			things.push({placeholder: PLACEHOLDER[b.name], src: [0, 0, b.w, b.h], solid: [[0, Math.max(0, b.h - 2), b.w, Math.min(b.h, 2)]], at: spot});
			take(spot[0], spot[1], b.w, b.h);
		}
	}

	// The old rooms' landmarks and decor that aren't on the blueprint: near where their old room's ground now lies
	const oldsHere = Object.entries(OLDR).filter(([o]) => ALIAS[o] === id).map(([o]) => o);
	for(const o of oldsHere){
		const R = ROOMS[o] || {}, [x1, y1, x2, y2] = OLDR[o].rect;
		const cx = Math.round((x1 + x2) / 2) - ox, cy = Math.round((y1 + y2) / 2) - oy, rr = rng(seed + o.length * 13);
		const items = [...(R.landmarks || []).map(l => ({lm: l})), ...(R.decor || []).map(d => ({is: d.is}))];
		for(const it of items){
			const l = it.lm;
			if(l && l.is && placedNames.has(l.is) && LAYOUT.buildings.some(b => THING[b.name] === l.is)) continue;   // on the blueprint already (in any room)
			const ru = l && l.ruin ? RUINS[l.ruin] : null;
			const is = it.is || (l && l.is);
			const [w, h] = is ? size(is) : ru ? [ru.w, ru.h] : [l.w || 2, l.h || 3];
			const qx = l ? ({nw: -1, sw: -1, ne: 1, se: 1}[l.q] || 0) : (rr() < 0.5 ? -1 : 1), qy = l ? ({nw: -1, ne: -1, sw: 1, se: 1}[l.q] || 0) : 1;
			const want = [cx + qx * Math.round((x2 - x1) / 4), cy + qy * Math.round((y2 - y1) / 4)];
			let spot = null;
			// (the sea arch stands in the sea; anything else on open ground, as near its old room's spot as there's room)
			const sea = is === "prop_sea_arch", okk = sea ? ["~"] : [".", ",", "_", ";"];   // (";": the city's paved squares)
			for(let d = 0; d <= 60 && !spot; d++) for(let dy = -d; dy <= d && !spot; dy++) for(let dx = -d; dx <= d && !spot; dx++){
				if(Math.max(Math.abs(dx), Math.abs(dy)) !== d) continue;
				if(free(want[0] + dx, want[1] + dy, w, h, okk, sea)) spot = [want[0] + dx, want[1] + dy];
			}
			if(!spot){ if(l) console.log(`  ${id}: no room for ${o}'s ${is || l.ruin || l.obj}`); continue; }   // (decor that doesn't fit is left out)
			if(is) things.push({is, at: spot});
			else if(ru) for(const [p, ddx, ddy] of ru.parts) things.push({is: p, at: [spot[0] + ddx, spot[1] + ddy]});
			else if(l.obj) instances.push({obj: l.obj, x: (spot[0] + w / 2) * 32, y: (spot[1] + h) * 32 - 8});
			take(spot[0] - 1, spot[1] - 1, w + 2, h + 2);
			if(l) points[o + "__lm_" + l.q] = [(spot[0] + Math.floor(w / 2)) * 32 + 16, (spot[1] + h) * 32 + 24];
			if(it.is && (it.is === "stall_cart" || it.is.startsWith("stall")) && !points[o + "__stall"]) points[o + "__stall"] = [(spot[0] + 1) * 32 + 16, (spot[1] + h) * 32 + 24];
		}
	}

	// A board with each old district's name where its old room's ground now lies, by the nearest road
	for(const o of oldsHere){
		const name = (ROOMS[o] || {}).name;
		if(!name) continue;
		const [x1, y1, x2, y2] = OLDR[o].rect, cx = Math.round((x1 + x2) / 2) - ox, cy = Math.round((y1 + y2) / 2) - oy;
		const road = (c, r) => [":", ","].includes(at(c, r));
		let spot = null;
		for(let d = 0; d <= 30 && !spot; d++) for(let dy = -d; dy <= d && !spot; dy++) for(let dx = -d; dx <= d && !spot; dx++){
			if(Math.max(Math.abs(dx), Math.abs(dy)) !== d) continue;
			const c = cx + dx, rw = cy + dy;
			if(c < 1 || rw < 1 || c >= W - 1 || rw >= H - 1 || !own(c, rw) || at(c, rw) !== "." || taken.has(c + "," + rw)) continue;
			if(road(c, rw + 1) || road(c, rw - 1) || road(c + 1, rw) || road(c - 1, rw)) spot = [c, rw];
		}
		if(!spot) continue;
		taken.add(spot[0] + "," + spot[1]);
		instances.push({obj: "obj_signpost", x: spot[0] * 32 + 16, y: spot[1] * 32 + 28, code: `text = "${name.replace(/"/g, "")}";
side = "here";`});
		points[o + "__sign"] = [spot[0] * 32 + 16, spot[1] * 32 + 56];
	}

	// Plots for sale (the user, 2026-11-07): where the town's houses with no way in stood, empty lots facing a street -
	// the Mayor sells them, you choose a building and a shop for each (scripts/pshops). Each is PLOT_W x PLOT_H cells,
	// its door in the middle of its bottom row: a door (obj_transition) to its shop's inside (rm_pshop_<id>) that
	// obj_plot shuts until a shop stands there.
	if(PLOTS_IN[id]){
		const fr = rng(seed + 57), want = PLOTS_IN[id], prefix = id === "rm_beirut" ? "b" : "o";
		let n = 0;
		const cells = [];
		for(let r = 2; r < H - PLOT_H - 3; r++) for(let c = 2; c < W - PLOT_W - 2; c++) cells.push([c, r]);
		for(let i = cells.length - 1; i > 0; i--){ const j = Math.floor(fr() * (i + 1)); [cells[i], cells[j]] = [cells[j], cells[i]]; }
		const street = ch => ch === "," || ch === ":";
		for(const [c, r] of cells){
			if(n >= want) break;
			const w = PLOT_W, h = PLOT_H, mid = c + Math.floor(w / 2);
			// keep the plots apart, so the town's spread round them
			if(PLOTS.some(p => p.room === id && Math.abs(p.c - c) < w + 6 && Math.abs(p.r - r) < h + 4)) continue;
			let front = null;
			for(let k2 = 0; k2 < 3 && !front; k2++) for(let x = c; x < c + w && !front; x++) if(street(at(x, r + h + k2))) front = [x, r + h + k2];
			if(!front || !free(c - 1, r, w + 2, h, ["."])) continue;
			let pathOk = true;
			for(let y = r + h; y < front[1] && pathOk; y++) if(at(mid, y) !== "." || taken.has(mid + "," + y)) pathOk = false;
			for(let x = Math.min(mid, front[0]); x <= Math.max(mid, front[0]) && pathOk; x++){ const ch = at(x, front[1]); if(!street(ch) && (ch !== "." || taken.has(x + "," + front[1]))) pathOk = false; }
			if(!pathOk) continue;
			let plain = true;
			for(let y = r; y < r + h && plain; y++) for(let x = c; x < c + w && plain; x++) if(bk(x, y) !== ".") plain = false;
			if(!plain) continue;
			for(let y = r + h; y < front[1]; y++) grid[y][mid] = ",";
			for(let x = Math.min(mid, front[0]); x <= Math.max(mid, front[0]); x++) if(at(x, front[1]) === ".") grid[front[1]][x] = ",";
			take(c - 1, r - 1, w + 2, h + 1);
			n++;
			const pid = prefix + n, dx = mid * 32 + 16, dy = (r + h - 1) * 32 + 16;
			PLOTS.push({id: pid, room: id, c, r});
			instances.push({obj: "obj_plot", x: c * 32, y: r * 32, code: `plot = "${pid}";
pw = ${w};
ph = ${h};`});
			instances.push({obj: "obj_transition", x: dx, y: dy, sx: 2, sy: 1,
				code: `targetRoom = rm_pshop_${pid};
targetX = ${PSHOP_IN[0]};
targetY = ${PSHOP_IN[1]};
PlayerFacingBefore = dir.up;
PlayerFacingAfter = dir.up;`});
			exits["pshop_" + pid] = [id, dx, dy + 36];
			points["plot_" + pid] = [dx, dy + 52];
		}
	}

	// The wild places' life (2026-11-06; the user found the Outskirts and the cliffs empty): clusters set down on open
	// ground away from the roads - a cedar grove and terraced slopes on the Mountain, orchards, olive groves, vineyards,
	// a shepherd's camp and wildflower meadows with hives (PixelLab props, art/props_wild)
	{ const CL = {
		rm_mountain:    [["cedars", 3], ["terraces", 2], ["shepherd", 1], ["meadow", 1]],
		rm_outskirts:   [["orchard", 2], ["olives", 1], ["meadow", 2]],
		rm_countryside: [["orchard", 1], ["vines", 2], ["shepherd", 1], ["meadow", 1]],
		rm_sunset:      [["olives", 1]],
		rm_woods:       [["meadow", 1]],
	  }[id] || [];
	  const cr = rng(seed + 71), road = ch => ch === ":" || ch === ",";
	  const put = (is, c, r) => { if(!T.things[is]) return false; const [w, h] = size(is);
		if(!free(c, r, w, h, ["."])) return false;
		for(let y = r; y < r + h; y++) for(let x = c; x < c + w; x++) if(!["." , "m", "1", "2", "F", "P", "3"].includes(bk(x, y))) return false;
		things.push({is, at: [c, r]}); take(c, r, w, h); return true; };
	  // an open spot: R cells round it nearly all open grass of this area, no road
	  const spot = R => { for(let k = 0; k < 400; k++){
		const c = R + 2 + Math.floor(cr() * (W - 2 * R - 4)), r = R + 2 + Math.floor(cr() * (H - 2 * R - 4));
		let open = 0, all = 0, bad = false;
		for(let y = r - R; y <= r + R && !bad; y++) for(let x = c - R; x <= c + R; x++){ all++; const ch = at(x, y);
			if(road(ch) || ch === "~" || ch === "X") { bad = true; break; } if(ch === "." && own(x, y) && !taken.has(x + "," + y)) open++; }
		if(!bad && open / all > 0.92) return [c, r]; } return null; };
	  const RECIPE = {
		cedars:   ([c, r]) => { let n = 0; for(let k = 0; k < 40 && n < 10; k++){ const a2 = cr() * 6.283, d = Math.sqrt(cr()) * 6;
			if(put(cr() < 0.6 ? "prop_cedar_tree" : "prop_cedar_young", Math.round(c + Math.cos(a2) * d) - 1, Math.round(r + Math.sin(a2) * d) - 2)) n++; } },
		terraces: ([c, r]) => { for(let k = -2; k <= 2; k++) put("prop_stone_terrace", c - 2 + (k & 1), r + k * 2); },
		shepherd: ([c, r]) => { put("prop_shepherd_hut", c - 1, r - 2); for(const [dx, dy] of [[4, 0], [5, 2], [-4, 1]]) put("prop_haystack", c + dx, r + dy); put("prop_beehives", c - 4, r + 3); },
		orchard:  ([c, r]) => { for(let y = -1; y <= 1; y++) for(let x = -1; x <= 1; x++) put("prop_apple_tree", c + x * 4 - 1, r + y * 4 - 2); },
		olives:   ([c, r]) => { for(let y = -1; y <= 1; y++) for(let x = -1; x <= 1; x++) put("prop_olive_tree", c + x * 4 - 1, r + y * 4 - 2); },
		vines:    ([c, r]) => { for(let y = -2; y <= 2; y++) for(let x = -1; x <= 1; x++) put("prop_grapevine", c + x * 3, r + y * 2); },
		meadow:   ([c, r]) => { put("prop_beehives", c - 1, r); for(let k = 0; k < 9; k++) put("prop_wildflowers", c + Math.round((cr() - 0.5) * 10), r + Math.round((cr() - 0.5) * 8)); },
	  };
	  const RAD = {cedars: 7, terraces: 6, shepherd: 6, orchard: 6, olives: 6, vines: 6, meadow: 5};
	  for(const [kind, count] of CL) for(let n = 0; n < count; n++){ const p = spot(RAD[kind]); if(p) RECIPE[kind](p); }
	}

	// A wooden fence along the top-left corner of the land, where it meets the sea (the user, 2026-11-06): the peninsula's
	// north-west edge, on open ground by the water - rails along the north shore, a post-and-rail run down the west
	if(ox < 45 && oy < 60){
		// straight runs on the shore's first tile (the path behind stays open): along the north coast a row per column, down the west coast a column per
		// row, each smoothed to the most common value of its neighbours (so the runs are long), steps joined by posts
		const land = (c, r) => own(c, r) && [".", ",", ":", "_"].includes(at(c, r));
		const placed = {};
		const fence = (c, r, tile) => { if(!own(c, r) || ![".", "_", ","].includes(at(c, r)) || taken.has(c + "," + r)) return;
			const t = {src: [tile[0], tile[1], 1, 1], tileset: LPCR, at: [c, r], role: "decor", solid: [[0, 0, 1, 1]]};
			things.push(t); placed[c + "," + r] = t; taken.add(c + "," + r); };
		const mode = (arr, i) => { const w = arr.slice(Math.max(0, i - 3), i + 4).filter(v => v != null), cnt = {};
			for(const v of w) cnt[v] = (cnt[v] || 0) + 1; return w.length ? +Object.keys(cnt).sort((p, q) => cnt[q] - cnt[p] || p - q)[0] : null; };
		// north coast: world x 16-44
		const nRow = [];
		for(let c = 0; c < W; c++){ const wx = ox + c; if(wx < 16 || wx > 44){ nRow.push(null); continue; }
			let r = 0; while(r < Math.min(H, 30 - oy) && !land(c, r)) r++; nRow.push(r < 30 - oy ? r : null); }
		const nS = nRow.map((_, i) => nRow[i] == null ? null : mode(nRow, i));
		for(let c = 0; c < W; c++){ if(nS[c] == null) continue; fence(c, nS[c], [32, 24]);
			if(c > 0 && nS[c - 1] != null && nS[c - 1] !== nS[c]) for(let r = Math.min(nS[c - 1], nS[c]) + 1; r < Math.max(nS[c - 1], nS[c]); r++) fence(nS[c - 1] < nS[c] ? c : c - 1, r, [31, 25]); }
		// west coast: world y 26-56
		const wCol = [];
		for(let r = 0; r < H; r++){ const wy = oy + r; if(wy < 26 || wy > 56){ wCol.push(null); continue; }
			let c = 0; while(c < Math.min(W, 30 - ox) && !land(c, r)) c++; wCol.push(c < 30 - ox ? c : null); }
		const wS = wCol.map((_, i) => wCol[i] == null ? null : mode(wCol, i));
		for(let r = 0; r < H; r++){ if(wS[r] == null) continue; fence(wS[r], r, [31, 25]);
			if(r > 0 && wS[r - 1] != null && wS[r - 1] !== wS[r]) for(let c = Math.min(wS[r - 1], wS[r]) + 1; c < Math.max(wS[r - 1], wS[r]); c++) fence(c, r, [32, 24]); }
		// where a road (or anything else) breaks a rail run, the run ends in a post, not a rail cut off in mid-air
		for(const [k, t] of Object.entries(placed)){
			if(t.src[0] !== 32) continue;
			const [c, r] = k.split(",").map(Number);
			if(!placed[(c - 1) + "," + r] || !placed[(c + 1) + "," + r]){ t.src[0] = 31; t.src[1] = 25; }
		}
	}

	// Waterfalls where the mountain stream spills over a cliff (the blueprint's falls): the picture's falling column on the
	// lower ground west of the cliff, its lip on the cliff, its splash at the stream's level
	for(const fl of LAYOUT.falls || []){
		if(owner(fl.x, fl.y) !== id) continue;
		const c = fl.x - ox, r = fl.y - oy;
		instances.push({obj: "obj_waterfall", x: (c - 1) * 32, y: (r - 1) * 32, code: `dir = "${fl.dir}";`});
		points["waterfall_" + (Object.keys(points).filter(k => k.startsWith("waterfall_")).length + 1)] = [(c + 2) * 32, (r + 4) * 32];
	}

	// Rocks on the rocky shore and the mountain's bare top
	{ const sr = rng(seed + 31), kinds = ["rock_grey_big", "rock_grey", "pebbles_grey", "pebbles_grey2", "rock_grey_tall", "pebbles_brown"];
	  const rocky = (x, y) => ["r", "3", "4"].includes(bk(x, y));
	  for(let k = 0; k < W * H / 30; k++){
		const is = kinds[Math.floor(sr() * kinds.length)];
		if(!T.things[is]) continue;
		const [w, h] = size(is), c = 1 + Math.floor(sr() * (W - 2 - w)), r = 1 + Math.floor(sr() * (H - 2 - h));
		let ok = true;
		for(let y = r - 1; y <= r + h && ok; y++) for(let x = c - 1; x <= c + w && ok; x++) if(!rocky(x, y) || taken.has(x + "," + y) || !own(x, y)) ok = false;
		if(ok){ things.push({is, at: [c, r]}); take(c, r, w, h); }
	} }

	// Trees: thick in the blueprint's forest and pine wood, a few on open grass and the hills
	const maskOf = test => grid.map((row, r) => row.map((ch, c) => (ch === "." && own(c, r) && test(bk(c, r))) ? "." : "x").join(""));
	const count = test => { let n = 0; for(let r = 0; r < H; r++) for(let c = 0; c < W; c++) if(own(c, r) && test(bk(c, r)) && at(c, r) === ".") n++; return n; };
	const nP = count(k => k === "P"), nF = count(k => k === "F"), nOpen = count(k => k === "." || k === "1" || k === "2");
	if(nP) things.push(...woods(maskOf(k => k === "P"), [0, 0, W - 1, H - 1], Math.round(nP / 5), seed + 1, [["pine", 10], ["sapling", 1]], taken, true));
	if(nF) things.push(...woods(maskOf(k => k === "F"), [0, 0, W - 1, H - 1], Math.round(nF / 5), seed + 2, undefined, taken, true));
	if(nOpen) things.push(...woods(maskOf(k => k === "." || k === "1" || k === "2"), [0, 0, W - 1, H - 1],
		Math.round(nOpen * ({town: 0.002, rural: 0.008, wild: 0.02, deep: 0.03}[KIND[id]] || 0.006)), seed + 3, undefined, taken, false));

	// Lamps along the town's roads, now and then
	if(KIND[id] === "town" && T.things.prop_lamp){
		const lr = rng(seed + 17);
		for(let r = 2; r < H - 2; r++) for(let c = 2; c < W - 2; c++){
			if(at(c, r) !== "." || !own(c, r) || taken.has(c + "," + r) || at(c, r - 1) !== ":" || lr() > 0.06) continue;
			if(!free(c, r - 3 >= 0 ? r : r, 1, 1, ["."])) continue;
			things.push({is: "prop_lamp", at: [c, r - 3]});
			taken.add(c + "," + r);
		}
	}

	// The Beach Bridge project (the board in Downtown) mends a footbridge over the river on the Mountain: until then a
	// labelled box and a collision box over it, both gone once it's done (it isn't the only way across)
	if(id === BROKEN_BRIDGE.room){
		const [bx, by] = [BROKEN_BRIDGE.at[0] - ox, BROKEN_BRIDGE.at[1] - oy], [bw, bh] = BROKEN_BRIDGE.size;
		instances.push({obj: "obj_col_box", x: (bx + bw / 2) * 32, y: (by + bh / 2) * 32, sx: bw * 2, sy: bh * 2, code: `if(project_done("bridge")) instance_destroy();`});
		instances.push({obj: "obj_placeholder", x: (bx - 1) * 32, y: (by + bh + 1) * 32,
			code: `label = "Broken bridge";
boxW = ${(bw + 2) * 32};
boxH = ${(bh + 2) * 32};
if(project_done("bridge")) instance_destroy();`});
		points.broken_bridge = [(bx + bw / 2) * 32, (by + bh + 2) * 32 + 16];
	}

	// Walls where the room's own ground ends (the rest of the box is the neighbouring areas, drawn but not walkable):
	// one row of collision boxes just outside the edge, in runs; the ways through cut gaps in them later (addWays)
	const edge = [];
	for(let r = 0; r < H; r++) for(let c = 0; c < W; c++){
		if(own(c, r)) continue;
		if([[1, 0], [-1, 0], [0, 1], [0, -1]].some(([dx, dy]) => own(c + dx, r + dy))) edge.push([c, r]);
	}

	// The old rooms' named spots, at the same place in the world (the nearest open cell)
	const Old = require("../world/room.js");
	const openAt = (c, r) => own(c, r) && OPEN.includes(at(c, r)) && !(taken.has(c + "," + r) && at(c, r) === ".");
	const snap = (c, r) => { for(let d = 0; d < 20; d++) for(let dy = -d; dy <= d; dy++) for(let dx = -d; dx <= d; dx++){
		if(Math.max(Math.abs(dx), Math.abs(dy)) !== d) continue;
		if(openAt(c + dx, r + dy)) return [c + dx, r + dy]; } return [c, r]; };
	for(const o of oldsHere){
		let sp;
		try{ sp = Old.spec(o); } catch(e){ continue; }
		const g = Old.geom(o), [x1, y1, x2, y2] = OLDR[o].rect;
		for(const [k, a] of Object.entries(sp.areas || {})){
			const cell = (cc, rr) => [Math.round(x1 + cc / g.W * (x2 - x1)) - ox, Math.round(y1 + rr / g.H * (y2 - y1)) - oy];
			const [c1, r1] = cell(a[0], a[1]), [c2, r2] = cell(a[2], a[3]);
			areas[o + "__" + k] = [Math.max(1, Math.min(c1, c2)), Math.max(1, Math.min(r1, r2)), Math.min(W - 2, Math.max(c1, c2)), Math.min(H - 2, Math.max(r1, r2))];
		}
		for(const [k, p] of Object.entries(sp.points)){
			if(points[o + "__" + k]) continue;
			if(k.endsWith("_front") && points[k]){ points[o + "__" + k] = points[k]; continue; }
			if(k === "cave" && points.cave){ points[o + "__cave"] = points.cave; points[o + "__miner"] = points.miner; continue; }
			const wx = x1 + (p[0] / 32) / g.W * (x2 - x1), wy = y1 + (p[1] / 32) / g.H * (y2 - y1);
			const [c, r] = snap(Math.round(wx) - ox, Math.round(wy) - oy);
			points[o + "__" + k] = [c * 32 + 16, r * 32 + 16];
		}
	}
	// A middle for the room itself
	{ const [c, r] = snap(Math.floor(W / 2), Math.floor(H / 2)); points.mid = [c * 32 + 16, r * 32 + 16]; }

	// Spawn areas (scripts/gathering): blocks of 16x16 cells that are mostly the room's own open ground, by what's
	// there (forest -> wild or deep, hills -> cliff, beach -> shore, the rest the room's kind)
	for(let br = 0; br * 16 < H; br++) for(let bc = 0; bc * 16 < W; bc++){
		const c1 = bc * 16 + 1, r1 = br * 16 + 1, c2 = Math.min(W - 2, c1 + 13), r2 = Math.min(H - 2, r1 + 13);
		let n = 0, tot = 0; const tally = {};
		for(let r = r1; r <= r2; r++) for(let c = c1; c <= c2; c++){ tot++; if(own(c, r) && (at(c, r) === "." || at(c, r) === ",") && !taken.has(c + "," + r)){ n++; const k = bk(c, r); tally[k] = (tally[k] || 0) + 1; } }
		if(tot === 0 || n / tot < 0.45) continue;
		const top = Object.entries(tally).sort((a, b) => b[1] - a[1])[0][0];
		const kind = ["F", "P"].includes(top) ? (KIND[id] === "deep" ? "deep" : "wild") : ["2", "3"].includes(top) ? "cliff" : ["r", "_"].includes(top) ? "shore" : KIND[id] === "deep" ? "deep" : KIND[id];
		const name = "a" + br + "_" + bc;
		areas[name] = [c1, r1, c2, r2];
		areaKinds[name] = kind;
	}

	const start = points.mid;
	instances.unshift({obj: "obj_plyr", x: start[0], y: start[1]}, {obj: "camera", x: start[0], y: start[1]});
	// The ground in PixelLab terrain (tools/rooms/build.js groundLayer): a letter a cell, from the map and the blueprint
	const groundOf = (c, r) => { const ch = at(c, r), k = bk(c, r);
		if(k === "q") return "c";                                   // plazas and quays: concrete
		if(ch === ":") return "r";                                  // main roads: stone brick
		if(ch === ",") return ["u", "z", "t"].includes(k) ? "t" : "d";   // lanes dirt; by ruins, stairs and rails a flagstone trail
		if(ch === "_") return "s";
		if(ch === "~") return ["D", "S"].includes(k) ? "D" : "w";
		if(ch === "b") return "w";                                  // under the piers' planks
		if(ch === "X" || ["3", "r", "C", "c"].includes(k)) return "k";
		if(k === "4") return "n";
		return "g"; };
	// LPC Revised (art/lpc_revised), with the old dark road (TS_terrain "path") over it on the roads
	const ground = {tileset: "TS_lpcr_summer", overlay: ["path"], rows: grid.map((row, r) => row.map((_, c) => groundOf(c, r)).join(""))};
	// The city's roads are paved (grey stone slabs from TS_terrain over the dirt; ";" in the map) - the dark brown path
	// is for the roads outside town. The city: the blueprint's TOWN_BOX in Beirut and Phoenix Bay
	if(id === "rm_beirut" || id === "rm_phoenix"){
		for(let r = 0; r < H; r++) for(let c2 = 0; c2 < W; c2++){
			const wx = ox + c2, wy = oy + r;
			if(grid[r][c2] !== ":" || wx < 6 || wx > 140 || wy < -4 || wy > 104) continue;
			grid[r][c2] = ";";
			// each district its paving (the user, 2026-11-07: "a look for each district"): the square a checkerboard,
			// the old west and south of town red brick, downtown and the east grey stone slabs
			const m3 = n => ((n % 3) + 3) % 3, dname = districtAt(wx, wy, "");
			let src;
			if(bk(c2, r) === "q" || (wx >= 82 && wx <= 96 && wy >= 22 && wy <= 32)) src = [19 + ((wx + wy) % 2 + 2) % 2, 22];   // (the square, over its tram rails too)
			else if(BRICK.includes(dname)) src = [22 + m3(wx), 22];
			else src = [16 + m3(wx), 26 + m3(wy)];
			things.push({src: [src[0], src[1], 1, 1], at: [c2, r], role: "terrain"});
		}
	}
	cityPlaces(id, {ox, oy, W, H, grid, things, instances, points, taken, free, take, own, at, bk, exits});
	return {
		// the camera, in a 1500 x 840 window (the farm and interiors keep their own)
		// (Beirut 1.5x: 1000 x 560, about 31 x 17 tiles; the areas round it 2x; the far ones 3x)
		view: id === "rm_beirut" ? [1000, 560] : (["rm_phoenix", "rm_outskirts", "rm_sunset", "rm_mountain"].includes(id) ? [750, 420] : [500, 280]),
		seed: seed % 1000, map: grid.map(r => r.join("")), ground, things, instances, points, areas, areaKinds, edge,
		scatter: [
			{on: ".", density: KIND[id] === "town" ? 0.02 : 0.04, seed: seed % 97, pieces: [{is: "leaves", weight: 4}, {is: "leaves2", weight: 4}, {is: "mushrooms"}, {is: "sprout", weight: 2}]},
			{on: "~", density: 0.01, seed: seed % 89, pieces: [{is: "lilypads"}, {is: "lilypads2"}]},
		],
	};
}

// The farm's ways out (rm_1 keeps its own layout): its north road leads to the Outskirts, its west lane to the Sunset
// Coast, each arriving at that area's crossing with the farm. side: "t" or "l". Returns [room, x, y].
const FARM_SIDE = {t: "The Outskirts", l: "Sunset Coast"};
const FARM_ARRIVE = {t: [1296, 72], l: [64, 576]};   // where you arrive on the farm (its own road_t, road_l)

function addWays(id, rooms, frames){
	const S = rooms[id], fr = frames[id];
	const myName = Object.keys(ROOM_OF).find(n => ROOM_OF[n] === id);
	const gaps = new Set();
	for(const w of AREAS.ways){
		if(!w.between.includes(myName)) continue;
		const otherName = w.between[0] === myName ? w.between[1] : w.between[0], other = ROOM_OF[otherName];
		if(other === "rm_1" && !Object.values(FARM_SIDE).includes(myName)) continue;   // the farm only has two ways out
		if(other === "rm_bunny" || id === "rm_bunny") continue;   // the island is by ferry (addFerry)
		// The crossing cells on my side near this way: my walkable cells next to the other area's walkable cells
		const cells = [];
		for(let y = w.at[1] - 6; y <= w.at[1] + 6; y++) for(let x = w.at[0] - 6; x <= w.at[0] + 6; x++){
			if(owner(x, y) !== id) continue;
			const ch = CH[kindAt(x, y)];
			if(!OPEN.includes(ch)) continue;
			for(const [dx, dy] of [[1, 0], [-1, 0], [0, 1], [0, -1]]){
				if(owner(x + dx, y + dy) !== other || !OPEN.includes(CH[kindAt(x + dx, y + dy)])) continue;
				cells.push({x, y, dx, dy});
			}
		}
		if(!cells.length) continue;
		const dx = cells[0].dx, dy = cells[0].dy, along = cells.filter(c => c.dx === dx && c.dy === dy);
		const xs = along.map(c => c.x), ys = along.map(c => c.y);
		const cx1 = Math.min(...xs) - fr.ox, cx2 = Math.max(...xs) - fr.ox, cy1 = Math.min(...ys) - fr.oy, cy2 = Math.max(...ys) - fr.oy;
		// the strip: the crossing cells themselves; arrive two cells into the other area, at the middle of the crossing
		const mx = Math.round((Math.min(...xs) + Math.max(...xs)) / 2), my = Math.round((Math.min(...ys) + Math.max(...ys)) / 2);
		let target, tx, ty;
		if(other === "rm_1"){
			const side = myName === FARM_SIDE.t ? "t" : "l";
			[tx, ty] = FARM_ARRIVE[side]; target = "rm_1";
		} else {
			const ofr = frames[other];
			const [ax, ay] = arriveAt(other, mx + dx * 3, my + dy * 3);
			tx = (ax - ofr.ox) * 32 + 16; ty = (ay - ofr.oy) * 32 + 16; target = other;
		}
		const face = dx === 1 ? "right" : dx === -1 ? "left" : dy === 1 ? "down" : "up";
		const pw = (cx2 - cx1 + 1), ph = (cy2 - cy1 + 1);
		S.instances.push({obj: "obj_transition", x: (cx1 + pw / 2) * 32, y: (cy1 + ph / 2) * 32, sx: pw * 2, sy: ph * 2,
			code: `targetRoom = ${target};\ntargetX = ${tx};\ntargetY = ${ty};\nPlayerFacingBefore = dir.${face};\nPlayerFacingAfter = dir.${face};`});
		S.points["way_" + other.replace(/^rm_/, "") + "_" + (S.points["way_" + other.replace(/^rm_/, "")] ? mx : "")] = [(mx - fr.ox - dx * 2) * 32 + 16, (my - fr.oy - dy * 2) * 32 + 16];
		if(!S.points["way_" + other.replace(/^rm_/, "")]) S.points["way_" + other.replace(/^rm_/, "")] = [(mx - fr.ox - dx * 2) * 32 + 16, (my - fr.oy - dy * 2) * 32 + 16];
		// a signpost beside the way, a little back from it, naming where it leads
		{ const side = dx === 1 ? "e" : dx === -1 ? "w" : dy === 1 ? "s" : "n";
		  const sc = mx - fr.ox - dx * 2 + (dy !== 0 ? Math.ceil(pw / 2) + 1 : 0), sr = my - fr.oy - dy * 2 + (dx !== 0 ? -Math.ceil(ph / 2) - 1 : 0);
		  S.instances.push({obj: "obj_signpost", x: sc * 32 + 16, y: sr * 32 + 28, code: `text = "${otherName}";
side = "${side}";`}); }
		// no wall where you cross
		for(const c of along) gaps.add((c.x + c.dx - fr.ox) + "," + (c.y + c.dy - fr.oy));
	}
	// The walls: the edge cells (outside the room's ground) not at a way through, in horizontal runs
	const wall = S.edge.filter(([c, r]) => !gaps.has(c + "," + r)).sort((a, b) => a[1] - b[1] || a[0] - b[0]);
	for(let i = 0; i < wall.length;){
		let j = i;
		while(j + 1 < wall.length && wall[j + 1][1] === wall[i][1] && wall[j + 1][0] === wall[j][0] + 1) j++;
		const c1 = wall[i][0], r = wall[i][1], n = j - i + 1;
		S.instances.push({obj: "obj_col_box", x: (c1 + n / 2) * 32, y: r * 32 + 16, sx: n * 2, sy: 2});
		i = j + 1;
	}
	delete S.edge;
}

// The ferry to Bunny Island: stepping onto the end of Starsand's breakwater (Phoenix Bay) takes you to the island's
// jetty, and the jetty's end back (for now; a boat ride later)
// Where to arrive in a room: the nearest cell (world tiles) of its own open ground to the one wanted, at least one cell
// clear of anything blocking around it
// The city's way-finding (the user, 2026-11-07, "the player shouldn't feel lost"): a fountain and benches on the
// central square, landmarks closing the streets' ends, a signpost at each crossroads naming the nearest shops, lamps and
// a "Beirut" board at each way into town, and small parks in the big empty blocks
const SHOPS = {"Tavern": "Tavern", "Bank": "Bank", "Tools": "Tools", "Guild hall": "Guild", "Smithy": "Smithy", "Bakery": "Bakery",
	"Flowers": "Flowers", "Furniture": "Furniture", "Hospital": "Clinic", "Library": "Library", "Apothecary": "Apothecary",
	"Outfitter": "Tailor", "Museum": "Museum", "Glassworks": "Glassworks", "Riviera hotel": "Hotel", "Fish market": "Fish market"};
function cityPlaces(id, R){
	const {ox, oy, W, H, things, instances, points, taken, free, take, own, at} = R;
	// a spot for the townsfolk to visit (sched points "rm_beirut.<name>"): the nearest open ground to (c, r)
	const spot = (name, c, r) => { for(let d = 0; d <= 4; d++) for(let dy = -d; dy <= d; dy++) for(let dx = -d; dx <= d; dx++){
		if(Math.max(Math.abs(dx), Math.abs(dy)) !== d) continue; const cc = c + dx, rr = r + dy;
		if(cc < 1 || rr < 1 || cc >= W - 1 || rr >= H - 1 || !own(cc, rr) || ![".", ",", ";", ":"].includes(at(cc, rr)) || taken.has(cc + "," + rr)) continue;
		taken.add(cc + "," + rr); points[name] = [cc * 32 + 16, rr * 32 + 16]; return true; } return false; };
	const cg = LAYOUT.city_grid || {}, lines = Object.values(cg);
	const L = (wx, wy) => [wx - ox, wy - oy];
	const put = (is, c, r, ok = [".", ","], over = false) => { if(!T.things[is]) return false; const [w, h] = size(is); if(!free(c, r, w, h, ok, over)) return false; things.push({is, at: [c, r]}); take(c - 1, r - 1, w + 2, h + 2); return true; };
	const near = (c, r, is, ok, over) => { for(let d = 0; d <= 3; d++) for(let dy = -d; dy <= d; dy++) for(let dx = -d; dx <= d; dx++) if(Math.max(Math.abs(dx), Math.abs(dy)) === d && put(is, c + dx, r + dy, ok, over)) return true; return false; };
	const sign = (c, r, text) => { for(let d = 0; d <= 3; d++) for(let dy = -d; dy <= d; dy++) for(let dx = -d; dx <= d; dx++){
		if(Math.max(Math.abs(dx), Math.abs(dy)) !== d) continue; const cc = c + dx, rr = r + dy;
		if(cc < 1 || rr < 1 || cc >= W - 1 || rr >= H - 1 || !own(cc, rr) || at(cc, rr) !== "." || taken.has(cc + "," + rr)) continue;
		taken.add(cc + "," + rr); instances.push({obj: "obj_signpost", x: cc * 32 + 16, y: rr * 32 + 28, code: `text = "${text}";
side = "here";`}); return true; } return false; };
	if(id === "rm_beirut"){
		// the central square (Martyrs' Square): its fountain in the middle, benches and lamps round it
		const [sc, sr] = L(89, 27);
		near(sc - 2, sr - 2, "prop_fountain", [";", ":", ".", ","], true);   // (on the paving, which counts as taken)
		for(const [dx, dy] of [[-6, -4], [4, -4], [-6, 3], [4, 3]]) near(sc + dx, sr + dy, "prop_bench", [";", ".", ","]);
		[[-5, -2], [5, -2], [-5, 5], [5, 5]].forEach(([dx, dy], i) => spot("square_" + "abcd"[i], sc + dx, sr + dy));
		// the town hall: the Mayor's house by the square (scripts/pshops: he sells the plots), its door into rm_mayor
		{ const [mw, mh] = size(MAYOR_HOUSE), md = doorOf(MAYOR_HOUSE);
		  let hall = null;
		  for(let d = 4; d <= 24 && !hall; d++) for(let dy = -d; dy <= d && !hall; dy++) for(let dx = -d; dx <= d && !hall; dx++){
			if(Math.max(Math.abs(dx), Math.abs(dy)) !== d) continue;
			const c = sc + dx, r = sr + dy;
			if(!free(c - 1, r, mw + 2, mh, ["."])) continue;
			const below = at(c + md[0], r + mh);
			if(![".", ",", ";", ":"].includes(below)) continue;
			hall = [c, r];
		  }
		  if(hall){
			const [c, r] = hall;
			things.push({is: MAYOR_HOUSE, at: [c, r]});
			take(c - 1, r, mw + 2, mh + 1);
			const dx = (c + md[0]) * 32 + 16, dy = (r + md[1]) * 32 + 16;
			instances.push({obj: "obj_transition", x: dx, y: dy, sx: 2, sy: 1,
				code: `targetRoom = rm_mayor;
targetX = ${MAYOR_IN[0]};
targetY = ${MAYOR_IN[1]};
PlayerFacingBefore = dir.up;
PlayerFacingAfter = dir.up;`});
			R.exits.mayor = [id, dx, dy + 36];
			points.mayor_front = [dx, dy + 52];
			sign(c + md[0] + 2, r + mh + 1, "City Hall");
		  } else console.log("  rm_beirut: no room for the town hall");
		}
		// landmarks closing each street's ends (where a street stops inside town)
		const ends = [];
		for(const [[x1, y1], [x2, y2]] of lines) for(const e of [[x1, y1, Math.sign(x1 - x2), Math.sign(y1 - y2)], [x2, y2, Math.sign(x2 - x1), Math.sign(y2 - y1)]]) ends.push(e);
		const LM = ["statue", "prop_roadside_shrine", "obelisk", "prop_planter", "prop_fountain"];
		let li = 0;
		for(const [ex, ey, dx, dy] of ends){
			if(ex < 8 || ex > 138 || ey < -2 || ey > 102) continue;
			const onOther = lines.some(([[a1, b1], [a2, b2]]) => !(a1 === ex && b1 === ey) && !(a2 === ex && b2 === ey) && ex >= Math.min(a1, a2) - 1 && ex <= Math.max(a1, a2) + 1 && ey >= Math.min(b1, b2) - 1 && ey <= Math.max(b1, b2) + 1);
			if(onOther) continue;   // (it ends at another street: a T, not a dead end)
			const [c, r] = L(ex + dx * 2, ey + dy * 2);
			if(near(c - 1, r - 1, LM[li % LM.length])) li++;
		}
		// a signpost at each crossroads naming the two nearest shops
		const shops = LAYOUT.buildings.filter(b => SHOPS[b.name]);
		for(const [[ax1, ay1], [ax2, ay2]] of lines) for(const [[bx1, by1], [bx2, by2]] of lines){
			if(!(ay1 === ay2 && bx1 === bx2)) continue;   // a horizontal and a vertical
			const cx = bx1, cy = ay1;
			if(cx < Math.min(ax1, ax2) || cx > Math.max(ax1, ax2) || cy < Math.min(by1, by2) || cy > Math.max(by1, by2)) continue;
			const two = shops.map(b => [b, Math.hypot(b.x + b.w / 2 - cx, b.y + b.h / 2 - cy)]).sort((p, q) => p[1] - q[1]).slice(0, 2).map(p => SHOPS[p[0].name]);
			const [c, r] = L(cx + 2, cy + 2);
			sign(c, r, two.join(", "));
		}
		// small parks in the biggest empty blocks: trees, flower beds, a bench; one with a swing, one with a market stall
		let parks = 0;
		for(let k = 0; k < 3000 && parks < 6; k++){
			const c = 6 + Math.floor((k * 7919) % (W - 12)), r = 6 + Math.floor((k * 104729) % (H - 12));
			let open = 0; for(let y = r - 4; y <= r + 4; y++) for(let x = c - 5; x <= c + 5; x++) if(own(x, y) && at(x, y) === "." && !taken.has(x + "," + y)) open++;
			if(open < 95) continue;
			near(c - 2, r - 1, parks % 3 === 1 ? "prop_swing" : parks % 3 === 2 ? "stall_stripe" : "prop_fountain");
			near(c - 5, r - 3, "prop_flower_bed"); near(c + 2, r + 2, "prop_flower_bed"); near(c + 3, r - 3, "prop_bench");
			near(c - 4, r + 2, "oak"); near(c + 4, r - 1, "oak");
			parks++;
			spot("park_" + parks, c + 1, r + 1);
		}
	}
	// a scene a district (the user, 2026-11-07): a market row along Red Street, a café below the square, the port's
	// cargo by the quays
	if(id === "rm_beirut"){
		const stalls = ["stall_stripe", "stall_white", "fruit_table", "stall_green", "stall_blue", "stall_cart"];
		stalls.forEach((is, i) => { const [c, r] = L(22 + i * 8, 24); near(c, r, is); });
		const [cc, cr] = L(86, 35);
		near(cc, cr, "prop_town_cafe"); near(cc - 4, cr + 2, "prop_beach_umbrella"); near(cc + 5, cr + 2, "prop_beach_umbrella");
		spot("cafe_a", cc - 3, cr + 4); spot("cafe_b", cc + 6, cr + 4);
		[0, 2, 4].forEach((i, k) => spot("market_" + "abc"[k], 22 + i * 8 - ox + 2, 24 - oy + 2));
	}
	if(id === "rm_phoenix"){
		for(let i = 0; i < 6; i++){ const [c, r] = L(92 + i * 5, 12); near(c, r, ["barrels", "crate_open", "stall_cart", "barrel", "crate_open", "barrels"][i], [".", ",", ";", ":"]); }
	}
	// at each way into town: a lamp each side and a board with the town's name
	for(const [gx, gy] of LAYOUT.gates || []){
		if(owner(gx, gy) !== id) continue;
		const [c, r] = L(gx, gy), vert = gy >= 100;
		near(vert ? c - 3 : c, vert ? r : r - 3, "prop_lamp"); near(vert ? c + 2 : c, vert ? r : r + 2, "prop_lamp");
		sign(vert ? c + 3 : c + 1, vert ? r + 1 : r + 3, "Beirut");
	}
}

// The cells (world tiles) where something solid stands in a built room: its things' solid parts
let SOLID = null;
function solidCells(id){
	if(!SOLID || !SOLID.rooms[id]) return new Set();
	if(SOLID.cells[id]) return SOLID.cells[id];
	const set = new Set(), fr = SOLID.frames[id];
	for(const t of SOLID.rooms[id].things || []){
		if(!t.at) continue;
		const def = t.is ? T.things[t.is] : null, parts = t.solid || (def && def.solid) || [];
		for(const [sx, sy, sw, sh] of parts) for(let y = 0; y < sh; y++) for(let x = 0; x < sw; x++) set.add((fr.ox + t.at[0] + sx + x) + "," + (fr.oy + t.at[1] + sy + y));
	}
	return (SOLID.cells[id] = set);
}
function arriveAt(id, x, y){
	const solid = solidCells(id);
	const ok = (cx, cy) => { for(let dy = -1; dy <= 1; dy++) for(let dx = -1; dx <= 1; dx++)
		if(owner(cx + dx, cy + dy) !== id || !OPEN.includes(CH[kindAt(cx + dx, cy + dy)]) || solid.has((cx + dx) + "," + (cy + dy))) return false; return true; };
	for(let d = 0; d < 12; d++) for(let dy = -d; dy <= d; dy++) for(let dx = -d; dx <= d; dx++)
		if(Math.max(Math.abs(dx), Math.abs(dy)) === d && ok(x + dx, y + dy)) return [x + dx, y + dy];
	return [x, y];
}

function addFerry(B){
	const P = B.rooms.rm_phoenix, I = B.rooms.rm_bunny, fp = B.frames.rm_phoenix, fi = B.frames.rm_bunny;
	if(!P || !I) return;
	// the breakwater's far end: its pier tile furthest north-east; the jetty's end: Bunny's pier tile furthest south
	let be = null, je = null;
	for(const [k] of OWN) {}
	for(let y = -30; y < 20; y++) for(let x = 60; x < 140; x++){
		if(kindAt(x, y) !== "p") continue;
		if(owner(x, y) === "rm_phoenix" && (!be || x - y > be[0] - be[1])) be = [x, y];
		if(owner(x, y) === "rm_bunny" && (!je || y > je[1])) je = [x, y];
	}
	if(!be || !je) return;
	const px = (c, f) => (c - f) * 32 + 16;
	const pa = arriveAt("rm_phoenix", be[0] - 2, be[1] + 2), ia = arriveAt("rm_bunny", je[0], je[1] - 2);
	P.instances.push({obj: "obj_transition", x: px(be[0], fp.ox), y: px(be[1], fp.oy), sx: 2, sy: 2,
		code: `targetRoom = rm_bunny;\ntargetX = ${px(ia[0], fi.ox)};\ntargetY = ${px(ia[1], fi.oy)};\nPlayerFacingBefore = dir.up;\nPlayerFacingAfter = dir.up;`});
	I.instances.push({obj: "obj_transition", x: px(je[0], fi.ox), y: px(je[1], fi.oy), sx: 2, sy: 2,
		code: `targetRoom = rm_phoenix;\ntargetX = ${px(pa[0], fp.ox)};\ntargetY = ${px(pa[1], fp.oy)};\nPlayerFacingBefore = dir.down;\nPlayerFacingAfter = dir.down;`});
	P.points.ferry = [px(pa[0], fp.ox), px(pa[1], fp.oy)];
	I.points.ferry = [px(ia[0], fi.ox), px(ia[1], fi.oy)];
}

function all(){ if(!BUILT){ BUILT = buildAll(); addFerry(BUILT); } return BUILT; }
module.exports = {
	spec: id => { const s = all().rooms[id]; if(!s) throw new Error("no new room " + id); return s; },
	all, ROOM_OF, ALIAS, KIND, WATER, owner,
	PLOTS, PLOT_DESIGNS, PLOT_W, PLOT_H, PSHOP_IN, MAYOR_IN, doorOf,
	exits: () => all().exits,
	farmArrive: side => {
		// where the farm's side leads: the crossing in that area nearest the farm, arriving two cells in
		const B = all(), name = FARM_SIDE[side], id = ROOM_OF[name], fr = B.frames[id];
		const w = AREAS.ways.find(x => x.between.includes("The Farm") && x.between.includes(name) && (side === "l" || x.at[0] > 80)) ||
		          AREAS.ways.find(x => x.between.includes("The Farm") && x.between.includes(name));
		const [x, y] = w.at, ddy = side === "t" ? -3 : 0, ddx = side === "l" ? -3 : 0;
		return [id, (x + ddx - fr.ox) * 32 + 16, (y + ddy - fr.oy) * 32 + 16];
	},
};
