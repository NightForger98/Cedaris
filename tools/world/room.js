// Generate an outdoor room spec (for tools/rooms/build.js) from the world data in tools/world/world.js.
//
//   specs/<room>.js:  module.exports = require("../../world/room.js").spec("<room>");
//
// The layout: a street across the room (rows ry-1..ry+1) and one down it (cols cx-1..cx+1), meeting in the middle;
// each side with a link runs its street out to that edge (cobbles for a road, dirt or sand for a lane). Buildings
// stand on the street's north side with their doors on it (left of the crossing, then right, alternately); decor
// sits south of it. The coast (sea and sand) fills the top and/or left; the river the west side. Woods fill the rest.
const path = require("path");
const {ROOMS, FARM, CELL, GRID} = require("./world.js");
const T = require("../rooms/tiles.js");
const woods = require("../rooms/woods.js");
const INTERIORS = require("./interior_data.js");

const SEA = 10;        // sea rows/cols (7 water + 3 sand)
const RIVER = [1, 4];  // river cols (west side), then a cell of bank
const SIDES = {l: [0, -1], r: [0, 1], t: [-1, 0], b: [1, 0]};
const OPP = {l: "r", r: "l", t: "b", b: "t"};

const size = is => { const s = T.things[is].src; return [s[2], s[3]]; };
const doorOf = is => { const b = T.things[is]; return b.door || [Math.floor(b.src[2] / 2), b.src[3] - 1]; };

// The room's frame: size, land box, the crossing (cx, ry)
function geom(id){
	const R = ROOMS[id];
	if(R.farm) return {farm: true, W: FARM.w, H: FARM.h};
	const W = R.w, H = R.h, sea = R.sea || "";
	const x0 = (sea.includes("l") ? SEA : 0) + (R.river ? RIVER[1] + 2 : 0), y0 = sea.includes("t") ? SEA : 0;
	const tallest = Math.max(0, ...(R.buildings || []).map(b => size(b.is)[1]));
	let ry = Math.floor((y0 + H - 1) / 2);
	ry = Math.max(ry, y0 + tallest + 3);
	if(ry > H - 6) throw new Error(`${id}: too short for its buildings`);
	const cx = Math.floor((x0 + W - 1) / 2);
	return {W, H, x0, y0, cx, ry};
}

// Where you arrive in a room coming through its side s
function arrive(id, s){
	const g = geom(id);
	if(g.farm) return FARM.arrive[s];
	if(s === "l") return [64, g.ry * 32 + 16];
	if(s === "r") return [g.W * 32 - 64, g.ry * 32 + 16];
	if(s === "t") return [g.cx * 32 + 16, 72];
	return [g.cx * 32 + 16, g.H * 32 - 72];
}

function neighbour(id, s){
	const [r, c] = CELL[id], [dr, dc] = SIDES[s];
	return (GRID[r + dr] || [])[c + dc];
}

const FACE = {l: "left", r: "right", t: "up", b: "down"};
function transition(id, s){
	const g = geom(id), to = neighbour(id, s), [tx, ty] = arrive(to, OPP[s]);
	const at = {l: [8, g.ry * 32 + 16, 1, 6], r: [g.W * 32 - 8, g.ry * 32 + 16, 1, 6],
	            t: [g.cx * 32 + 16, 8, 6, 1], b: [g.cx * 32 + 16, g.H * 32 - 8, 6, 1]}[s];
	return {obj: "obj_transition", x: at[0], y: at[1], sx: at[2], sy: at[3],
		code: `targetRoom = ${to};\ntargetX = ${tx};\ntargetY = ${ty};\nPlayerFacingBefore = dir.${FACE[s]};\nPlayerFacingAfter = dir.${FACE[s]};`};
}

function rng(seed){ let s = seed * 9301 + 49297; return () => (s = (s * 16807) % 2147483647) / 2147483647; }

function spec(id){
	const R = ROOMS[id], g = geom(id), {W, H, x0, y0, cx, ry} = g, links = R.links || {};
	const seed = [...id].reduce((a, ch) => a * 31 + ch.charCodeAt(0), 7) % 100000;
	const grid = Array.from({length: H}, () => Array(W).fill("."));
	const put = (c1, c2, r1, r2, ch) => { for(let r = Math.max(0, r1); r <= Math.min(H - 1, r2); r++) for(let c = Math.max(0, c1); c <= Math.min(W - 1, c2); c++) grid[r][c] = ch; };
	const at = (c, r) => (grid[r] || [])[c];
	const sea = R.sea || "";
	const things = [], instances = [], points = {}, areas = {}, exits = {}, taken = new Set();
	const take = (c1, r1, w, h, m = 1) => { for(let r = r1 - m; r < r1 + h + m; r++) for(let c = c1 - m; c < c1 + w + m; c++) taken.add(c + "," + r); };
	const free = (c1, r1, w, h) => { for(let r = r1 - 1; r < r1 + h + 1; r++) for(let c = c1 - 1; c < c1 + w + 1; c++){ if(r < 0 || c < 0 || r >= H || c >= W || taken.has(c + "," + r) || at(c, r) !== ".") return false; } return true; };

	// The coast
	if(sea.includes("t")){ put(0, W - 1, 0, SEA - 4, "~"); put(0, W - 1, SEA - 3, SEA - 1, "_"); }
	if(sea.includes("l")){ put(0, SEA - 4, 0, H - 1, "~"); put(SEA - 3, SEA - 1, sea.includes("t") ? SEA - 3 : 0, H - 1, "_"); }
	// The river down the west side (from a spring partway down at Abda's Ascent)
	const riverX = (sea.includes("l") ? SEA : 0) + RIVER[0];
	if(R.river === "spring") put(riverX, riverX + 3, 0, ry - 8, "~"), put(riverX - 1, riverX + 6, ry - 11, ry - 7, "~");
	else if(R.river) put(riverX, riverX + 3, sea.includes("t") ? SEA - 3 : 0, H - 1, "~");

	// Streets: the kind of each way out; inside, cobbles if any way out is a road
	const kinds = Object.values(links);
	const sandy = sea.includes("l") || sea.includes("t");
	const lane = sandy && !kinds.includes("road") ? "," : ",";
	const inner = kinds.includes("road") || (R.buildings || []).length > 1 ? ":" : lane;
	const ch = s => links[s] === "road" ? ":" : lane;
	// Across: from the west edge (or the land's edge) to the east
	const xa = links.l ? 0 : x0 + 2, xb = links.r ? W - 1 : W - 3;
	put(xa, cx, ry - 1, ry + 1, links.l ? ch("l") : inner);
	put(cx, xb, ry - 1, ry + 1, links.r ? ch("r") : inner);
	put(cx - 1, cx + 1, ry - 1, ry + 1, inner);
	if(links.t) put(cx - 1, cx + 1, 0, ry - 2, ch("t"));
	if(links.b) put(cx - 1, cx + 1, ry + 2, H - 1, ch("b"));
	// Bridges where a street crosses the river: planks over walkable water
	if(R.river && R.river !== "spring" && links.l){
		put(riverX, riverX + 3, ry - 1, ry + 1, "b");
		things.push({src: [17, 20, 1, 1], repeat: [4, 3], at: [riverX, ry - 1]});
	}

	// Blocked ways: rocks (a cliff across the lane's end) or a wall of trees
	const blocked = Object.entries(links).filter(([, k]) => k === "rocks" || k === "trees");
	for(const [s, k] of blocked){
		if(s === "r" || s === "l"){
			const c1 = s === "r" ? W - 12 : 0;
			if(k === "rocks"){ put(c1, c1 + 11, ry - 3, ry + 1, "X"); things.push({is: "cliff", at: [c1, ry - 3]}); }
			else { put(c1, c1 + 11, ry - 1, ry + 1, "x"); }
		} else {
			const r1 = s === "t" ? 0 : H - 6;
			put(cx - 1, cx + 1, s === "t" ? 0 : ry + 2, s === "t" ? ry - 2 : H - 1, lane);
			put(cx - 6, cx + 6, r1, r1 + 5, "x");
			if(k === "rocks") things.push({is: "cliff", at: [cx - 6, r1]});
			else for(let c = cx - 6; c <= cx + 5; c += 2) things.push({is: "pine", at: [c, r1 + (c % 4 === 0 ? 0 : 1)]});
		}
	}

	// The mine's cave in a cliff along the top (east of the trail up)
	if(R.mine){
		const cave = W - 14;
		put(cx + 3, W - 1, 0, 3, "X"); put(cx + 3, W - 1, 4, 6, ",");
		things.push({is: "cliff_cave", at: [cave, 0]}, {is: "cliff", at: [W - 12, 0]});
		for(let c = W - 26; c >= cx + 3; c -= 12) things.push({is: "cliff", at: [c, 0]});
		put(cave, cave + 1, 7, ry - 2, ",");
		instances.push({obj: "obj_mine_door", x: (cave + 1) * 32, y: 140});
		points.cave = [(cave + 1) * 32, 168];
		points.miner = [(cave - 3) * 32 + 16, 200];   // where the miner works, beside the cave (not in front of the lift)
		areas.cliff_west = [cx + 4, 4, cave - 2, 6];
		areas.cliff_east = [cave + 3, 4, W - 2, 6];
		take(cx + 3, 0, W - cx - 3, 7, 0);
	}

	// A pier out to sea
	if(R.pier === "t"){
		const pc = Math.min(W - 6, cx + 10);
		put(pc, pc + 2, 2, SEA - 1, "b"); put(pc, pc + 2, SEA, ry - 2, ",");
		things.push({src: [17, 20, 1, 1], repeat: [3, SEA - 3], at: [pc, 2]});
		points.pier_end = [(pc + 1) * 32 + 16, 3 * 32 + 16];
		points.pier_b = [(pc + 1) * 32 + 16, 5 * 32 + 16];
	} else if(R.pier === "l"){
		const pr = Math.min(H - 4, ry + 6);
		put(2, SEA - 1, pr, pr + 1, "b"); put(SEA, x0 + 1, pr, pr + 1, ",");
		things.push({src: [17, 20, 1, 1], repeat: [SEA - 2, 2], at: [2, pr]});
		points.pier_end = [3 * 32 + 16, pr * 32 + 16];
		points.pier_b = [5 * 32 + 16, pr * 32 + 16];
	}

	// The town square
	if(R.plaza){
		put(cx - 9, cx + 9, ry + 2, ry + 9, ":");
		things.push({is: "statue", at: [cx + 4, ry + 5]}, {is: "board_notes", at: [cx - 6, ry + 2]});
		instances.push({obj: "obj_quest_board", x: (cx - 6) * 32 + 16, y: (ry + 2) * 32 + 26});
		points.board = [(cx - 6) * 32 + 16, (ry + 4) * 32];
		points.crowd = [(cx - 7) * 32, (ry + 6) * 32];
		points.river = [(cx + 1) * 32, 0];   // Lantern Night's lanterns drift down from here
		areas.square = [cx - 9, ry + 2, cx + 9, ry + 9];
		take(cx - 9, ry + 2, 19, 8, 0);
	}

	// Streets are taken (no trees on them), and the coast and river too
	for(let r = 0; r < H; r++) for(let c = 0; c < W; c++) if(grid[r][c] !== ".") taken.add(c + "," + r);

	// Buildings on the north side of the street, doors on it: left of the crossing, then right
	let left = cx - 3, right = cx + 3;
	const yard = (R.buildings || []).map(b => Object.assign({}, b, {size: size(b.is), door: doorOf(b.is)}));
	let side = 0;
	for(const b of yard){
		const [w, h] = b.size, top = ry - 1 - h;
		let c = null;
		for(let tries = 0; tries < 2 && c === null; tries++, side ^= 1){
			if(side === 0 && left - w + 1 >= x0 + 1){ c = left - w + 1; left = c - 3; }
			else if(side === 1 && right + w - 1 <= W - 2){ c = right; right = c + w + 2; }
		}
		if(c === null) throw new Error(`${id}: no room on the street for ${b.key}`);
		const bx = c, d = b.door;
		const dx = (bx + d[0]) * 32 + 16, dy = (top + d[1]) * 32 + 16;
		things.push({is: b.is, at: [bx, top]});
		take(bx, top, w, h, 1);
		const inside = INTERIORS.doorPoint(b.room);
		instances.push({obj: "obj_transition", x: dx, y: dy, sx: 2, sy: 1,
			code: `targetRoom = ${b.room};\ntargetX = ${inside[0]};\ntargetY = ${inside[1]};\nPlayerFacingBefore = dir.up;\nPlayerFacingAfter = dir.up;`});
		exits[b.key] = [dx, dy + 36];
		points[b.key + "_front"] = [dx, dy + 52];
		// A bit of path from the door down to the street, if the door sits above the building's bottom row
		for(let r = top + d[1] + 1; r < ry - 1; r++) put(bx + d[0], bx + d[0] + 1, r, r, inner);
	}

	// Decor south of the street, outward from the crossing
	let dl = cx - 3, dr = cx + 3; side = 0;
	for(const dcr of R.decor || []){
		const [w, h] = size(dcr.is);
		let placed = false;
		for(let tries = 0; tries < 6 && !placed; tries++, side ^= 1){
			const r1 = ry + 3 + (tries >> 1) * 0;
			if(side === 0){
				const c = dl - w + 1;
				if(c >= x0 + 1 && free(c, r1, w, h)){ things.push({is: dcr.is, at: [c, r1]}); take(c, r1, w, h, 1); dl = c - 2; placed = true; }
				else dl -= 2;
			} else {
				const c = dr;
				if(c + w <= W - 1 && free(c, r1, w, h)){ things.push({is: dcr.is, at: [c, r1]}); take(c, r1, w, h, 1); dr = c + w + 1; placed = true; }
				else dr += 2;
			}
		}
		if(placed && (dcr.is === "stall_cart" || dcr.is.startsWith("stall"))){
			const t = things[things.length - 1];
			if(!points.stall) points.stall = [(t.at[0] + 1) * 32 + 16, (t.at[1] + h) * 32 + 24];
		}
	}

	// Whisperwood: a way east out of Yarzeh Woods (obj_path; scripts/forest builds the wood when you step on it)
	if(R.whisperwood){
		put(cx, W - 3, ry - 1, ry + 1, lane);
		for(let c = cx; c <= W - 1; c++) for(let r = ry - 1; r <= ry + 1; r++) taken.add(c + "," + r);
		instances.push({obj: "obj_path", x: (W - 2) * 32 + 8, y: ry * 32 + 16});
		points.bridge = [(W - 5) * 32, ry * 32 + 16];
	}

	// Woods over the free grass: thick in the wild, light in town
	const density = {town: 0.004, rural: 0.012, wild: 0.045}[R.kind || "rural"];
	const quads = [[x0, y0, cx - 3, ry - 3], [cx + 3, y0, W - 1, ry - 3], [x0, ry + 3, cx - 3, H - 1], [cx + 3, ry + 3, W - 1, H - 1]];
	const kinds2 = R.pines ? [["pine", 8], ["sapling", 1]] : undefined;
	quads.forEach((q, i) => {
		const area = Math.max(0, (q[2] - q[0]) * (q[3] - q[1]));
		things.push(...woods(grid.map(r => r.join("")), q, Math.round(area * density * (R.pines && i < 2 ? 4 : 1)), seed + i, kinds2, taken));
	});
	// Spawn areas: the four corners of land, clear of the streets (resource_areas in scripts/gathering)
	const names = ["nw", "ne", "sw", "se"];
	quads.forEach((q, i) => { if(q[2] - q[0] >= 4 && q[3] - q[1] >= 4) areas[names[i]] = [q[0] + 1, q[1] + 1, q[2] - 1, q[3] - 1]; });
	if(sea.includes("l")) areas.shore = [SEA - 3, Math.max(sea.includes("t") ? SEA : 1, 1), SEA - 1, H - 2];
	if(sea.includes("t")) areas.shore_top = [Math.max(x0, 1), SEA - 3, W - 2, SEA - 1];

	// Ways out, and where you arrive by each
	for(const [s, k] of Object.entries(links)){
		if(k !== "road" && k !== "lane") continue;
		instances.push(transition(id, s));
		points["road_" + s] = arrive(id, s);
	}
	const first = Object.keys(points).find(k => k.startsWith("road_"));
	const start = points[first] || [cx * 32 + 16, ry * 32 + 16];
	instances.unshift({obj: "obj_plyr", x: start[0], y: start[1]}, {obj: "camera", x: start[0], y: start[1]});

	// Spots for villagers along the street, either side of the crossing (s0 at the crossing)
	points.mid = [cx * 32 + 16, ry * 32 + 16];
	[-9, -6, -3, 3, 6, 9].forEach((k, i) => {
		const c = cx + k;
		if(c > xa + 1 && c < xb - 1) points["s" + (i + 1)] = [c * 32 + 16, (ry + (i % 2 ? 1 : -1)) * 32 + 16];
	});

	return {
		seed: seed % 1000,
		map: grid.map(r => r.join("")),
		things,
		scatter: [
			{on: ".", density: R.kind === "town" ? 0.03 : 0.05, seed: seed % 97, pieces: [{is: "leaves", weight: 4}, {is: "leaves2", weight: 4}, {is: "mushrooms"}, {is: "sprout", weight: 2}]},
			{on: "~", density: 0.03, seed: seed % 89, pieces: [{is: "lilypads"}, {is: "lilypads2"}]},
		],
		instances,
		points,
		areas,
		exits,
	};
}

module.exports = {spec, geom, arrive, neighbour, transition};
