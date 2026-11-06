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
	// Piers and bridges: planks over the water
	for(let r = 0; r < H; r++) for(let c = 0; c < W; c++) if(bk(c, r) === "p"){ things.push({src: [17, 20, 1, 1], at: [c, r]}); taken.add(c + "," + r); }
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
			if(l && l.is && placedNames.has(l.is) && here.some(b => THING[b.name] === l.is)) continue;   // on the blueprint already
			const ru = l && l.ruin ? RUINS[l.ruin] : null;
			const is = it.is || (l && l.is);
			const [w, h] = is ? size(is) : ru ? [ru.w, ru.h] : [l.w || 2, l.h || 3];
			const qx = l ? ({nw: -1, sw: -1, ne: 1, se: 1}[l.q] || 0) : (rr() < 0.5 ? -1 : 1), qy = l ? ({nw: -1, ne: -1, sw: 1, se: 1}[l.q] || 0) : 1;
			const want = [cx + qx * Math.round((x2 - x1) / 4), cy + qy * Math.round((y2 - y1) / 4)];
			let spot = null;
			// (the sea arch stands in the sea; anything else on open ground, as near its old room's spot as there's room)
			const sea = is === "prop_sea_arch", okk = sea ? ["~"] : [".", ",", "_"];
			for(let d = 0; d <= 60 && !spot; d++) for(let dy = -d; dy <= d && !spot; dy++) for(let dx = -d; dx <= d && !spot; dx++){
				if(Math.max(Math.abs(dx), Math.abs(dy)) !== d) continue;
				if(free(want[0] + dx, want[1] + dy, w, h, okk, sea)) spot = [want[0] + dx, want[1] + dy];
			}
			if(!spot){ console.log(`  ${id}: no room for ${o}'s ${is || (l && (l.ruin || l.obj))}`); continue; }
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

	// The town's houses between the landmarks (PixelLab, 2026-11-06): no way in, each by a street, on the
	// blueprint's plain town ground with a cell clear around it
	{ const FILL = ["prop_town_hallhouse", "prop_town_hallhouse2", "prop_town_hallhouse3", "prop_town_apartments",
		"prop_town_yellowhouse", "prop_town_yellowhouse2", "prop_town_villa", "prop_town_villa2",
		"prop_town_shop", "prop_town_shop2", "prop_town_cafe", "prop_town_cafe2", "prop_town_bakery", "prop_town_bakery2"].concat(ALT_HOMES).filter(k => T.things[k]);
	  // and out of town, a home now and then by the roads and lanes (the spare homes: the Outskirts, the Countryside, the
	  // Sunset Coast felt empty)
	  const RURAL = ["rm_outskirts", "rm_countryside", "rm_sunset"].includes(id), POOL = RURAL ? ALT_HOMES.filter(k => T.things[k]) : FILL;
	  if((KIND[id] === "town" || RURAL) && POOL.length){
		const FILL = POOL;
		const fr = rng(seed + 57), want = Math.round(W * H / (RURAL ? 900 : 350)), road = ch => ch === ":" || ch === ",";
		let n = 0;
		// every cell in a shuffled order, each trying the houses in a shuffled order, until the town has enough
		const cells = [];
		for(let r = 2; r < H - 5; r++) for(let c = 2; c < W - 4; c++) cells.push([c, r]);
		for(let i = cells.length - 1; i > 0; i--){ const j = Math.floor(fr() * (i + 1)); [cells[i], cells[j]] = [cells[j], cells[i]]; }
		for(const [c, r] of cells){
			if(n >= want) break;
			const order = FILL.slice().sort(() => fr() - 0.5);
			for(const is of order){
				const [w, h] = size(is), mid = c + Math.floor(w / 2);
				if(c + w >= W - 2 || r + h >= H - 3) continue;
				// facing a street: its door looks onto a side lane (in town; out of town a road or a lane) at most two
				// cells of grass away - houses and workshops along the side lanes, which go somewhere (tools/map/blueprint.js)
				const street = ch => ch === "," || (RURAL && ch === ":");
				let front = null;   // [x, y] of the street cell nearest below the house (under its width)
				for(let k2 = 0; k2 < 3 && !front; k2++) for(let x = c; x < c + w && !front; x++) if(street(at(x, r + h + k2))) front = [x, r + h + k2];
				if(!front || !free(c - 1, r, w + 2, h, ["."])) continue;   // a cell clear each side (its back may meet the next street)
				let pathOk = true;   // the path from the door: down to the street's row, then along to it, all on grass
				for(let y = r + h; y < front[1] && pathOk; y++) if(at(mid, y) !== "." || taken.has(mid + "," + y)) pathOk = false;
				for(let x = Math.min(mid, front[0]); x <= Math.max(mid, front[0]) && pathOk; x++){ const ch = at(x, front[1]); if(!street(ch) && (ch !== "." || taken.has(x + "," + front[1]))) pathOk = false; }
				if(!pathOk) continue;
				for(let y = r + h; y < front[1]; y++) grid[y][mid] = ",";
				for(let x = Math.min(mid, front[0]); x <= Math.max(mid, front[0]); x++) if(at(x, front[1]) === ".") grid[front[1]][x] = ",";
				let plain = true;
				for(let y = r; y < r + h && plain; y++) for(let x = c; x < c + w && plain; x++) if(bk(x, y) !== ".") plain = false;
				if(!plain) continue;
				things.push({is, at: [c, r]});
				take(c - 1, r - 1, w + 2, h + 1);
				n++;
				break;
			}
		}
	  } }

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
	return {
		seed: seed % 1000, map: grid.map(r => r.join("")), things, instances, points, areas, areaKinds, edge,
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
