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

const WATER = 5, SAND = 10;   // the coast: a band of sea, then a wide beach (sand takes most of it)
const SEA = WATER + SAND;      // coast rows/cols in all
const RIVER = [1, 4];  // river cols (west side), then a cell of bank
const SIDES = {l: [0, -1], r: [0, 1], t: [-1, 0], b: [1, 0]};
const OPP = {l: "r", r: "l", t: "b", b: "t"};

const size = is => { const s = T.things[is].src; return [s[2], s[3]]; };
const doorOf = is => { const b = T.things[is]; return b.door || [Math.floor(b.src[2] / 2), b.src[3] - 1]; };

// The room's frame: size, land box, the crossing (cx, ry)
// Each room is sized to what's in it (not one size for all): wide enough for its buildings either side of the
// crossing (they alternate left, right), its decor south of the street, its corner landmarks, the square, the mine,
// the pier and the cliffs; tall enough for its tallest building or northern landmark above the street and its decor
// or southern landmarks below. Wild rooms (woods) keep a bigger minimum, so they still feel like woods.
function geom(id){
	const R = ROOMS[id];
	if(R.farm) return {farm: true, W: FARM.w, H: FARM.h};
	const sea = R.sea || "";
	const x0 = (sea.includes("l") ? SEA : 0) + (R.river ? RIVER[1] + 2 : 0), y0 = sea.includes("t") ? SEA : 0;
	// A split room is a set size: a wide beach and lowland, and room for the high ground and the tower
	if(R.split){ const W = x0 + 54, H = y0 + 34; return {W, H, x0, y0, cx: Math.floor((x0 + W) / 2), ry: Math.floor((y0 + H) / 2)}; }
	const bsize = b => b.ph ? [b.w, b.h] : size(b.is);
	const lmSize = lm => lm.is ? size(lm.is) : lm.ruin ? (lm.ruin === "house" ? [8, 4] : [8, 5]) : [lm.w, lm.h];
	const side = [0, 0];
	(R.buildings || []).filter(b => !b.plateau).forEach((b, i) => { side[i % 2] += bsize(b)[0] + 3; });
	const decorW = [0, 0];
	(R.decor || []).forEach((d, i) => { decorW[i % 2] += size(d.is)[0] + 2; });
	const lms = R.landmarks || [];
	const lmW = q => Math.max(0, ...lms.filter(l => l.q === q).map(l => lmSize(l)[0] + 4));
	const lmH = q => Math.max(0, ...lms.filter(l => l.q === q).map(l => lmSize(l)[1] + 3));
	const min = R.dense ? 22 : R.kind === "wild" ? 16 : 9;   // a dense wood is a big place
	let left = Math.max(min, side[0], decorW[0], lmW("nw"), lmW("sw"), R.plaza ? 10 : 0);
	let right = Math.max(min, side[1], decorW[1], lmW("ne"), lmW("se"), R.plaza ? 10 : 0, R.mine ? 20 : 0,
		R.pier === "t" || (sea.includes("t") && R.pier !== null) ? 13 : 0);
	right += R.cliffEast ? 7 : 0;
	right += R.plateau ? 8 + Math.max(0, ...(R.buildings || []).filter(b => b.plateau).map(b => bsize(b)[0] + 2)) : 0;
	const W = x0 + 2 + left + 7 + right + 2;
	const tallest = Math.max(0, ...(R.buildings || []).map(b => bsize(b)[1]));
	// A northern landmark stands above the buildings, a southern one below the decor (each corner can share its
	// side with them), so their heights add up
	const lmN = Math.max(lmH("nw"), lmH("ne")), lmS = Math.max(lmH("sw"), lmH("se"));
	const decorH = Math.max(0, ...(R.decor || []).map(d => size(d.is)[1] + 2));
	const north = Math.max(R.dense ? 16 : R.kind === "wild" ? 12 : 6, tallest + 2 + lmN, R.mine ? 9 + lmN : 0, R.plateau ? tallest + 5 : 0);
	const south = Math.max(R.dense ? 18 : R.pineForest ? 18 : R.kind === "wild" ? 14 : 9, 3 + decorH + lmS + 2, R.plaza ? 12 + lmS : 0, sea.includes("l") ? 10 : 0);
	const ry = y0 + north + 1, H = ry + 2 + south;
	const cx = x0 + 2 + left + 3;
	return {W, H, x0, y0, cx, ry};
}

// Where you arrive in a room coming through its side s
// The row of a beach link (a way along the sand between two rooms on the north coast): the middle of the sand
const BEACH_ROW = WATER + Math.floor(SAND / 2);

// A cliff link's column: Beacon Hill's ladder up its mine cliff, or the east of a split room's cliff top
function cliffCol(id){
	const R = ROOMS[id], g = geom(id);
	return R.mine ? g.cx + 8 : g.W - 10;
}

function arrive(id, s){
	const g = geom(id);
	if(g.farm) return FARM.arrive[s];
	if((ROOMS[id].links || {})[s] === "cliff") return [cliffCol(id) * 32 + 16, s === "t" ? 72 : g.H * 32 - 72];
	if((ROOMS[id].links || {})[s] === "beach") return s === "l" ? [64, BEACH_ROW * 32 + 16] : [g.W * 32 - 64, BEACH_ROW * 32 + 16];
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
	const y = ((ROOMS[id].links || {})[s] === "beach" ? BEACH_ROW : g.ry) * 32 + 16;
	const x = ((ROOMS[id].links || {})[s] === "cliff" ? cliffCol(id) : g.cx) * 32 + 16;
	const at = {l: [8, y, 1, 6], r: [g.W * 32 - 8, y, 1, 6],
	            t: [x, 8, 6, 1], b: [x, g.H * 32 - 8, 6, 1]}[s];
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
	// The north shore is rocky (dirt, with stones and boulders scattered on it later); the west coast is sand, its sea
	// and beach widening and narrowing like a real shore (straight near the street's row and the room's ends, so the
	// pier and the ways along it line up)
	if(sea.includes("t")){ put(0, W - 1, 0, WATER - 1, "~"); put(0, W - 1, WATER, SEA - 1, ","); }
	if(sea.includes("l")){
		const ph = (seed % 97) / 15, ph2 = (seed % 89) / 11;
		for(let rr = sea.includes("t") ? WATER : 0; rr < H; rr++){
			const env = Math.min(1, Math.abs(rr - ry) / 6, rr / 4, (H - 1 - rr) / 4);
			const wl = WATER + Math.round(env * 2 * Math.sin(rr * 0.21 + ph));
			const end = SEA - Math.round(env * (2.5 + 2.5 * Math.sin(rr * 0.16 + ph2)));
			put(0, wl - 1, rr, rr, "~"); put(wl, end - 1, rr, rr, "_");
		}
		if(sea.includes("t")) put(0, WATER - 1, 0, WATER - 1, "~");
	}
	// The river down the west side (from a spring partway down at Abda's Ascent)
	const riverX = (sea.includes("l") ? SEA : 0) + RIVER[0];
	if(R.river === "spring") put(riverX, riverX + 3, 0, ry - 8, "~"), put(riverX - 1, riverX + 6, ry - 11, ry - 7, "~");
	else if(R.river) put(riverX, riverX + 3, sea.includes("t") ? WATER : 0, H - 1, "~");

	// Streets: the kind of each way out; inside, cobbles if any way out is a road
	const kinds = Object.values(links);
	const sandy = sea.includes("l") || sea.includes("t");
	const lane = sandy && !kinds.includes("road") ? "," : ",";
	const inner = kinds.includes("road") || (R.buildings || []).length > 1 ? ":" : lane;
	const ch = s => links[s] === "road" ? ":" : lane;
	// Across: from the west edge (or the land's edge) to the east
	// (a beach link has no street: you walk along the sand)
	const sl = links.l && links.l !== "beach", sr = links.r && links.r !== "beach";
	const xa = sl ? 0 : x0 + 2, xb = sr ? W - 1 : W - 3;
	if(!R.split){
		put(xa, cx, ry - 1, ry + 1, sl ? ch("l") : inner);
		put(cx, xb, ry - 1, ry + 1, sr ? ch("r") : inner);
		put(cx - 1, cx + 1, ry - 1, ry + 1, inner);
	}
	if(links.t && links.t !== "cliff") put(cx - 1, cx + 1, 0, ry - 2, ch("t"));
	if(links.b && links.b !== "cliff") put(cx - 1, cx + 1, ry + 2, H - 1, ch("b"));
	// Bridges where a street crosses the river: planks over walkable water
	if(R.river && R.river !== "spring" && sl){
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
		// The ladder up the cliff: from the ledge to the top, where the way north runs on to Plummet's cliff top
		if(links.t === "cliff"){
			const lc = cx + 5;
			things.push({is: "cliff_ladder", at: [lc, 0]});
			put(lc + 3, lc + 3, 0, 3, ",");
			points.ladder = [(lc + 3) * 32 + 16, 6 * 32 + 16];
		}
		instances.push({obj: "obj_mine_door", x: (cave + 1) * 32, y: 140});
		points.cave = [(cave + 1) * 32, 168];
		points.miner = [(cave - 3) * 32 + 16, 200];   // where the miner works, beside the cave (not in front of the lift)
		areas.cliff_west = [cx + 4, 4, cave - 2, 6];
		areas.cliff_east = [cave + 3, 4, W - 2, 6];
		take(cx + 3, 0, W - cx - 3, 7, 0);
	}

	// A pier out to sea
	// Every stretch of coast has a pier out over the water from the beach, for fishing (Starsand's is stone)
	const pierSide = R.pier ?? (sea.includes("t") ? "t" : sea.includes("l") ? "l" : null);
	if(pierSide === "t"){
		const pc = Math.min(W - 6, cx + 10);
		put(pc, pc + 2, 1, WATER - 1, "b"); if(!R.split) put(pc, pc + 2, SEA, ry - 2, ",");
		if(R.pierStone) things.push({is: "stone_pier", repeat: [1, 2], at: [pc, 1]});
		else things.push({src: [17, 20, 1, 1], repeat: [3, WATER + 1], at: [pc, 1]});
		points.pier_end = [(pc + 1) * 32 + 16, 2 * 32 + 16];
		points.pier_b = [(pc + 1) * 32 + 16, 4 * 32 + 16];
	} else if(pierSide === "l"){
		// On the street's row: the street runs on across the sand to it
		const pr = ry;
		put(1, WATER - 1, pr, pr + 1, "b"); put(WATER + 1, xa, ry - 1, ry + 1, ",");
		things.push({src: [17, 20, 1, 1], repeat: [WATER + 1, 2], at: [1, pr]});
		points.pier_end = [2 * 32 + 16, pr * 32 + 16];
		points.pier_b = [4 * 32 + 16, pr * 32 + 16];
	}

	// A plateau drawn in cliff tiles (TS_terrain cols 5-7, rows 0-4, a 9-slice): its north edge, its sides, its top,
	// and three rows of cliff face along the bottom. open: sides that run on past the room's edge (no edge drawn).
	const plateau = (c1, r1, c2, r2, open = {}) => {
		for(let rr = r1; rr <= r2; rr++) for(let c = c1; c <= c2; c++){
			const face = !open.b && rr > r2 - 3;
			const fr = face ? 2 + rr - (r2 - 2) : (rr === r1 && !open.t ? 0 : 1);
			const fc = (c === c1 && !open.l) ? 5 : (c === c2 && !open.r) ? 7 : 6;
			things.push({src: [fc, fr, 1, 1], at: [c, rr]});
		}
	};
	const cliffy = n => n && ROOMS[n] && (ROOMS[n].cliffEast || ROOMS[n].split);
	// High ground drawn from a test inP(c, r): a 3-row cliff face where it drops away to the south, its rim along the
	// north, its sides, and its top. Edges at the room's border are left open (the high ground runs on).
	const highGround = (inP, c1, r1, c2, r2) => {
		const P = (c, rr) => (c < 0 || c >= W) ? inP(Math.max(0, Math.min(W - 1, c)), rr) : (rr < 0 || rr >= H) ? inP(c, Math.max(0, Math.min(H - 1, rr))) : inP(c, rr);
		for(let rr = r1; rr <= r2; rr++) for(let c = c1; c <= c2; c++){
			if(!inP(c, rr)) continue;
			let fb = 0;
			for(let k = 1; k <= 3; k++) if(!P(c, rr + k)){ fb = k; break; }
			const fr = fb ? 2 + (3 - fb) : (!P(c, rr - 1) ? 0 : 1);
			const fc = !P(c - 1, rr) ? 5 : !P(c + 1, rr) ? 7 : 6;
			things.push({src: [fc, fr, 1, 1], at: [c, rr]});
			grid[rr][c] = "X";
			taken.add(c + "," + rr);
		}
	};

	// Cliffs down the world's east edge, from Plummet's Point to Whispering Woods: high ground you can't climb, its
	// edge running on from room to room (open where the room above or below has it too), ending in a cliff face
	if(R.cliffEast){
		const r1 = R.mine ? 7 : (sea.includes("t") ? SEA : 0);
		const openT = !R.mine && cliffy(neighbour(id, "t")), openB = !!cliffy(neighbour(id, "b"));
		const ph = (seed % 61) / 9, ph2 = (seed % 53) / 7, span = Math.max(1, H - 1 - r1);
		const bandW = rr => 7 + Math.round(Math.sin(Math.PI * (rr - r1) / span) * (3 * Math.sin(rr * 0.31 + ph) + 2 * Math.sin(rr * 0.12 + ph2) + 2));
		const inBand = (c, rr) => rr >= r1 && (rr < H || openB) && c >= W - bandW(Math.min(rr, H - 1)) && (rr > r1 || openT || true);
		// rows past the room's ends count as band where the band runs on (no rim or face drawn there)
		const inB = (c, rr) => rr < r1 ? (openT && c >= W - 7) : rr >= H ? (openB && c >= W - 7) : inBand(c, rr);
		highGround(inB, W - 14, r1, W - 1, H - 1);
		// Pines on the high ground, so it reads as wild hilltop
		for(let rr = r1 + 1, k = 0; rr <= H - (openB ? 5 : 8); rr += 4, k++){
			const c = W - bandW(rr + 4) + 2 + (k * 3) % Math.max(1, bandW(rr + 4) - 3);
			if(inB(c, rr + 4) && inB(c + 1, rr + 4)) things.push({is: "pine", at: [c, rr]});
		}
	}

	// A split room (Plummet's Point): a diagonal cliff divides it. The high ground fills the south-east, reached only
	// over the cliff tops from the room below (a cliff link); the beach and lowland fill the north-west, reached only
	// along the beach from the left. The witch's tower (buildings with plateau: true) stands on the high ground.
	if(R.split){
		const xL = x0 + 8, rT = y0 + 3;
		const top = c => c < xL ? H : rT + Math.round((W - 1 - c) / (W - 1 - xL) * (H - 1 - rT));
		const inP = (c, rr) => c >= xL && c < W && rr >= top(c) && rr < H;
		for(let rr = 0; rr < H; rr++) for(let c = 0; c < W; c++){
			if(!inP(c, rr)) continue;
			const north = !inP(c, rr - 1), west = !inP(c - 1, rr);
			things.push({src: [west ? 5 : 6, north ? 0 : 1, 1, 1], at: [c, rr]});
			grid[rr][c] = (north || west) ? "X" : ",";
			taken.add(c + "," + rr);
		}
		// The tower, standing on the high ground near its east edge
		let bx = W - 15;
		for(const b of (R.buildings || []).filter(b => b.plateau)){
			const [w, h] = size(b.is), d = doorOf(b.is), foot = H - 6, tp = foot - h + 1;
			things.push({is: b.is, at: [bx, tp]});
			const dx = (bx + d[0]) * 32 + 16, dy = (tp + d[1]) * 32 + 16, inside = INTERIORS.doorPoint(b.room);
			instances.push({obj: "obj_transition", x: dx, y: dy, sx: 2, sy: 1,
				code: `targetRoom = ${b.room};\ntargetX = ${inside[0]};\ntargetY = ${inside[1]};\nPlayerFacingBefore = dir.up;\nPlayerFacingAfter = dir.up;`});
			exits[b.key] = [dx, dy + 36];
			points[b.key + "_front"] = [dx, dy + 52];
			bx -= w + 3;
		}
		// Spots up there for the witch and her son, and pines on the high ground
		points.cliff_a = [(W - 20) * 32 + 16, (H - 4) * 32 + 16];
		points.cliff_b = [(W - 6) * 32 + 16, (H - 12) * 32 + 16];
		const pr = rng(seed + 23);
		for(let k = 0; k < 40; k++){
			const c = xL + 2 + Math.floor(pr() * (W - xL - 4)), rr = top(c) + 2 + Math.floor(pr() * 6);
			if(rr + 5 >= H - 1 || c + 1 >= W) continue;
			if(Math.abs(c - (W - 10)) < 3 || (c >= W - 17 && c <= W - 8 && rr + 5 >= H - 18)) continue;   // the way in, the tower
			let ok = true;
			for(let y = rr + 3; y <= rr + 4; y++) for(let x = c; x <= c + 1; x++) if(!inP(x, y) || grid[y][x] !== ",") ok = false;
			if(!ok) continue;
			things.push({is: "pine", at: [c, rr]});
			for(let y = rr + 3; y <= rr + 4; y++) for(let x = c; x <= c + 1; x++) grid[y][x] = "X";
		}
	}

	// A beach link crosses a river on the sand by a footbridge: broken until the Beach Bridge project is done (a
	// labelled placeholder and a collision box over its east half, both gone once it's mended)
	if(R.river && R.river !== "spring" && links.l === "beach"){
		const by = BEACH_ROW;
		put(riverX, riverX + 3, by - 1, by + 1, "b");
		things.push({src: [17, 20, 1, 1], repeat: [4, 3], at: [riverX, by - 1]});
		instances.push({obj: "obj_col_box", x: (riverX + 3) * 32, y: by * 32 + 16, sx: 4, sy: 6, code: `if(project_done("bridge")) instance_destroy();`});
		instances.push({obj: "obj_placeholder", x: riverX * 32, y: (by + 2) * 32,
			code: `label = "Broken bridge";\nboxW = 128;\nboxH = 96;\nif(project_done("bridge")) instance_destroy();`});
		points.beach_bridge = [(riverX + 5) * 32, by * 32 + 16];
	}

	// The town square
	if(R.plaza){
		put(cx - 9, cx + 9, ry + 2, ry + 9, ":");
		things.push({is: "statue", at: [cx + 4, ry + 5]}, {is: "board_notes", at: [cx - 6, ry + 2]});
		// A fountain in the middle of the square, benches either side of it
		if(T.things.prop_fountain) things.push({is: "prop_fountain", at: [cx - 2, ry + 4]});
		if(T.things.prop_bench) things.push({is: "prop_bench", at: [cx - 6, ry + 6]}, {is: "prop_bench", at: [cx + 6, ry + 7]});
		instances.push({obj: "obj_quest_board", x: (cx - 6) * 32 + 16, y: (ry + 2) * 32 + 26});
		points.board = [(cx - 6) * 32 + 16, (ry + 4) * 32];
		points.crowd = [(cx - 7) * 32, (ry + 6) * 32];
		points.river = [(cx + 1) * 32, 0];   // Lantern Night's lanterns drift down from here
		areas.square = [cx - 9, ry + 2, cx + 9, ry + 9];
		take(cx - 9, ry + 2, 19, 8, 0);
	}

	if(sea.includes("t")){
		const sr = rng(seed + 31), kinds = ["rock_grey_big", "rock_grey", "pebbles_grey", "pebbles_grey2", "rock_grey_tall", "rock_grey_big2", "pebbles_brown", "rock_brown_big", "pebbles_grey"];
		for(let k = 0; k < Math.round(W * 0.6); k++){
			const is = kinds[Math.floor(sr() * kinds.length)], [w, h] = size(is);
			const c = 1 + Math.floor(sr() * (W - 2 - w)), rr = WATER + 1 + Math.floor(sr() * (SAND - 2 - h));
			if((links.l === "beach" || links.r === "beach") && rr + h - 1 >= BEACH_ROW - 1 && rr <= BEACH_ROW + 1) continue;
			let ok = true;
			for(let y = rr - 1; y <= rr + h; y++) for(let x = c - 1; x <= c + w; x++) if(at(x, y) !== "," || taken.has(x + "," + y)) ok = false;
			if(!ok) continue;
			things.push({is, at: [c, rr]});
			for(let y = rr; y < rr + h; y++) for(let x = c; x < c + w; x++) taken.add(x + "," + y);
		}
	}
	if(R.corniche){
		const cy = y0;   // the promenade: the first two rows of land below the shore
		put(Math.max(0, x0), W - 1, cy, cy + 1, ":");
		for(let c = x0 + 3; c < W - 2; c += 6) if(at(c, cy + 2) === ".") things.push({is: "prop_lamp", at: [c, cy - 1]});
		points.corniche = [(cx + 4) * 32 + 16, cy * 32 + 16];
	}

	// Streets are taken (no trees on them), and the coast and river too
	for(let r = 0; r < H; r++) for(let c = 0; c < W; c++) if(grid[r][c] !== ".") taken.add(c + "," + r);

	// Buildings on the north side of the street, doors on it: left of the crossing, then right
	let left = cx - 3, right = cx + 3;
	// A building can be a placeholder until its art is made: {key, ph: "Label", w, h, room} - a labelled box with its
	// door in the middle of its bottom row (obj_placeholder), the way in as for any building
	for(const b of R.buildings || []){
		if(!b.ph) continue;
		const name = "ph_" + id + "_" + b.key, dc = Math.floor(b.w / 2);
		T.things[name] = {placeholder: b.ph, src: [0, 0, b.w, b.h], door: [dc, b.h - 1],
			solid: [[0, b.h - 2, b.w, 1], [0, b.h - 1, dc, 1], [dc + 1, b.h - 1, b.w - dc - 1, 1]]};
		b.is = name;
	}
	const boxes = [];   // what stands on the street's north side: buildings and the props beside them [c, r, w, h]
	const yard = (R.buildings || []).filter(b => !b.plateau).map(b => Object.assign({}, b, {size: size(b.is), door: doorOf(b.is)}));
	let side = 0;
	for(const b of yard){
		const [w, h] = b.size, top = ry - 1 - h;
		let c = null;
		// Clear grass for the whole building (a pier's lane or the like may cross the street's edge): slide outward
		const clear = cc => { for(let y = top; y < top + h; y++) for(let x = cc; x < cc + w; x++) if(at(x, y) !== ".") return false; return true; };
		for(let tries = 0; tries < 2 && c === null; tries++, side ^= 1){
			if(side === 0){ let cc = left - w + 1; while(cc >= x0 + 1 && !clear(cc)) cc--; if(cc >= x0 + 1){ c = cc; left = c - 3; } }
			else { let cc = right; while(cc + w - 1 <= W - 2 && !clear(cc)) cc++; if(cc + w - 1 <= W - 2){ c = cc; right = c + w + 2; } }
		}
		if(c === null) throw new Error(`${id}: no room on the street for ${b.key}`);
		const bx = c, d = b.door;
		const dx = (bx + d[0]) * 32 + 16, dy = (top + d[1]) * 32 + 16;
		things.push({is: b.is, at: [bx, top]});
		take(bx, top, w, h, 1);
		// A door drawn on art that has none (tools/rooms/tiles.js: doorArt)
		const art = T.things[b.is].doorArt;
		if(art) instances.push({obj: art.obj, x: bx * 32 + art.at[0], y: top * 32 + art.at[1]});
		const inside = INTERIORS.doorPoint(b.room);
		instances.push({obj: "obj_transition", x: dx, y: dy, sx: 2, sy: 1,
			code: `targetRoom = ${b.room};\ntargetX = ${inside[0]};\ntargetY = ${inside[1]};\nPlayerFacingBefore = dir.up;\nPlayerFacingAfter = dir.up;`});
		exits[b.key] = [dx, dy + 36];
		points[b.key + "_front"] = [dx, dy + 52];
		// A bit of path from the door down to the street, if the door sits above the building's bottom row
		for(let r = top + d[1] + 1; r < ry - 1; r++) put(bx + d[0], bx + d[0] + 1, r, r, inner);
		boxes.push([bx, top, w, h]);
	}

	// More houses along the street that you can't go into (neighbours' homes), outward from the real ones, so a town
	// street is lined with houses and a country road has a farmhouse or two. No way in: their door cell stays solid.
	const fillers = {town: ["house_townhouse", "house_family_house", "house_small_house", "house_tavern_inn", "house_cottage"],
	                 rural: ["house_cottage", "house_small_house"]}[R.kind] || [];
	const fillMax = R.fill ?? 0;   // none by default: the user wants every house to be someone's you can go into
	const fillRand = rng(seed + 11);
	let fk = Math.floor(fillRand() * 5);
	for(let k = 0, placedN = 0; k < fillMax * 2 && placedN < fillMax; k++){
		const is = fillers[fk++ % fillers.length], [w, h] = size(is), top = ry - 1 - h;
		if(top < y0 + 1) continue;
		let c = null;
		for(let tries = 0; tries < 2 && c === null; tries++, side ^= 1){
			if(side === 0 && left - w + 1 >= x0 + 1){ const cc = left - w + 1; if(free(cc, top, w, h - 1)){ c = cc; left = c - 3; } else left -= 2; }
			else if(side === 1 && right + w - 1 <= W - 2){ const cc = right; if(free(cc, top, w, h - 1)){ c = cc; right = c + w + 2; } else right += 2; }
		}
		if(c === null) continue;
		const def = T.things[is];
		things.push({is, at: [c, top], solid: def.solid.concat([[def.door[0], def.door[1], 1, 1]])});
		take(c, top, w, h, 1);
		boxes.push([c, top, w, h]);
		placedN++;
	}

	// Street props: something by each building's side wall, on the street's edge (barrels by a town house, a bucket
	// or hay by a farm), so a street isn't bare between the doors
	const inBox = (c, r) => boxes.some(([bx, by, bw, bh]) => c >= bx && c < bx + bw && r >= by && r < by + bh);
	const propRand = rng(seed + 5);
	const propKinds = R.kind === "town" ? ["barrels", "prop_planter", "crate_open", "barrel", "prop_planter"] : ["barrel", "bucket", "crate_open", "wheelbarrow", "barrels"];
	for(const [bx, by, bw, bh] of boxes.slice()){
		for(const c of [bx - 2, bx + bw + 1]){
			if(propRand() < 0.25) continue;
			const is = propKinds[Math.floor(propRand() * propKinds.length)], [pw, ph] = size(is), r1 = ry - 1 - ph;
			let ok = c >= 1 && c + pw < W - 1;
			for(let y = r1; y < r1 + ph && ok; y++) for(let x = c; x < c + pw && ok; x++) if(at(x, y) !== "." || inBox(x, y)) ok = false;
			if(!ok) continue;
			things.push({is, at: [c, r1]});
			boxes.push([c, r1, pw, ph]);
			for(let y = r1; y < r1 + ph; y++) for(let x = c; x < c + pw; x++) taken.add(x + "," + y);
		}
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

	// In town, a row of neighbours' houses south of the street too (after the decor and the square, in what's left),
	// their fronts facing south like every building in the game
	if(R.kind === "town" && (R.fillSouth ?? 0) > 0){
		let sl = cx - 4, sr = cx + 4, sside = 0, placedS = 0;
		for(let k = 0; k < 16 && placedS < R.fillSouth; k++, sside ^= 1){
			const is = fillers[fk++ % fillers.length], [w, h] = size(is), top = ry + 4;
			if(top + h > H - 2) continue;
			let c = sside === 0 ? sl - w + 1 : sr;
			if(c < x0 + 1 || c + w > W - 1) continue;
			if(!free(c, top, w, h)){ if(sside === 0) sl -= 2; else sr += 2; k--; if(sl < x0 && sr > W) break; continue; }
			const def = T.things[is];
			things.push({is, at: [c, top], solid: def.solid.concat([[def.door[0], def.door[1], 1, 1]])});
			take(c, top, w, h, 1);
			if(sside === 0) sl = c - 3; else sr = c + w + 2;
			placedS++;
		}
	}

	// Landmarks: one in each corner of land that has one (q: "nw" | "ne" | "sw" | "se"), as near its middle as there's
	// room, with a lane to the street when the way is clear. A landmark is a thing (is) or, where there's no art yet,
	// a labelled placeholder box (ph: "Sea arch", w, h in cells; obj_placeholder draws it).
	const quadsL = {nw: [x0 + 1, y0 + 1, cx - 4, ry - 4], ne: [cx + 4, y0 + 1, W - 2, ry - 4],
	                sw: [x0 + 1, ry + 4, cx - 4, H - 2], se: [cx + 4, ry + 4, W - 2, H - 2]};
	for(const lm of R.landmarks || []){
		const q = quadsL[lm.q];
		if(!q) throw new Error(`${id}: landmark ${lm.is || lm.ph || lm.ruin} has no corner "${lm.q}"`);
		const RUINS = {   // ruins built from pieces: [thing, dx, dy]
			house: {w: 8, h: 4, parts: [["ruin_wall_brick", 0, 0], ["ruin_wall_stone", 4, 0], ["ruin_rubble", 1, 3], ["ruin_rubble", 5, 3], ["ruin_stump", 3, 2]]},
			temple: {w: 8, h: 5, parts: [["ruin_pillar", 0, 0], ["ruin_ivy", 2, 1], ["ruin_head", 3, 1], ["ruin_columns", 6, 1], ["ruin_rubble", 1, 4], ["ruin_stump", 5, 3]]},
		};
		const ruin = lm.ruin ? RUINS[lm.ruin] : null;
		if(lm.obj && !lm.w) throw new Error(`${id}: landmark ${lm.obj} needs w, h`);
		const [w, h] = lm.is ? size(lm.is) : ruin ? [ruin.w, ruin.h] : [lm.w, lm.h];   // (an obj landmark gives w, h)
		const mc = Math.round((q[0] + q[2] - w) / 2), mr = Math.round((q[1] + q[3] - h) / 2);
		let spot = null;
		for(let d = 0; d < 14 && !spot; d++) for(let dr = -d; dr <= d && !spot; dr++) for(let dc = -d; dc <= d && !spot; dc++){
			if(Math.max(Math.abs(dr), Math.abs(dc)) !== d) continue;
			const c = mc + dc * 2, rr = mr + dr;
			if(c >= q[0] && rr >= q[1] && c + w - 1 <= q[2] && rr + h - 1 <= q[3] && free(c, rr, w, h)) spot = [c, rr];
		}
		if(!spot){ console.log(`  ${id}: no room for landmark ${lm.is || lm.ph} (${lm.q})`); continue; }
		const [c, rr] = spot;
		if(lm.is) things.push({is: lm.is, at: [c, rr]});
		else if(ruin) for(const [p, dx, dy] of ruin.parts) things.push({is: p, at: [c + dx, rr + dy]});
		else if(lm.obj) instances.push({obj: lm.obj, x: (c + w / 2) * 32, y: (rr + h) * 32 - 8});
		else things.push({placeholder: lm.ph, src: [0, 0, w, h], solid: [[0, Math.max(0, h - 2), w, Math.min(h, 2)]], at: [c, rr]});
		take(c, rr, w, h, 1);
		points["lm_" + lm.q] = [(c + Math.floor(w / 2)) * 32 + 16, (rr + h) * 32 + 24];
		// A lane from its front to the street, if every cell on the way is clear grass
		const lc = c + Math.floor(w / 2), north = rr < ry;
		const r1 = north ? rr + h : ry + 2, r2 = north ? ry - 2 : rr - 1;
		let clear = r1 <= r2;
		for(let y = r1; y <= r2 && clear; y++) for(const x of [lc, lc + 1]) if(at(x, y) !== "." || inBox(x, y) || (taken.has(x + "," + y) && !(y >= rr - 1 && y <= rr + h))) clear = false;
		if(R.split) clear = false;   // no street to lead to
		if(north && clear){ put(lc, lc + 1, r1, r2, ","); for(let y = r1; y <= r2; y++) taken.add(lc + "," + y), taken.add((lc + 1) + "," + y); }
		if(!north && clear){ put(lc, lc + 1, r1, r2, ","); for(let y = r1; y <= r2; y++) taken.add(lc + "," + y), taken.add((lc + 1) + "," + y); }
	}

	// Street lamps along the south edge of a town's street, every few cells; a bench by every other one
	if(R.kind === "town" && T.things.prop_lamp){
		const lampRand = rng(seed + 17);
		let n = 0;
		for(let c = xa + 3; c <= xb - 3; c += 7){
			if(Math.abs(c - cx) < 4) continue;
			const r1 = ry + 2 - 3;   // the lamp's 4 cells: its foot on the grass edge just south of the street
			if(at(c, ry + 2) !== "." || taken.has(c + "," + (ry + 2))) continue;
			things.push({is: "prop_lamp", at: [c, r1]});
			taken.add(c + "," + (ry + 2));
			if(T.things.prop_bench && n++ % 2 === 0 && lampRand() < 0.8){
				const bc = c + 1;
				let ok = true;
				for(let y = ry + 2; y <= ry + 3; y++) for(let x = bc; x <= bc + 1; x++) if(at(x, y) !== "." || taken.has(x + "," + y)) ok = false;
				if(ok){ things.push({is: "prop_bench", at: [bc, ry + 2]}); take(bc, ry + 2, 2, 2, 0); }
			}
		}
	}

	// Woods over the free grass: thick in the wild, light in town
	const density = R.dense ? 0.22 : {town: 0.004, rural: 0.012, wild: 0.045}[R.kind || "rural"];
	const quads = [[x0, y0, cx - 3, ry - 3], [cx + 3, y0, W - 1, ry - 3], [x0, ry + 3, cx - 3, H - 1], [cx + 3, ry + 3, W - 1, H - 1]];
	const kinds2 = R.pines ? [["pine", 8], ["sapling", 1]] : undefined;
	quads.forEach((q, i) => {
		const area = Math.max(0, (q[2] - q[0]) * (q[3] - q[1]));
		const forest = R.pineForest && i >= 2;
		things.push(...woods(grid.map(r => r.join("")), q, Math.round(area * (forest ? 0.2 : density) * (R.pines && i < 2 ? 4 : 1)), seed + i,
			forest ? [["pine", 10], ["sapling", 1]] : kinds2, taken, !!R.dense || forest));
	});
	// Spawn areas: the four corners of land, clear of the streets (resource_areas in scripts/gathering)
	const names = ["nw", "ne", "sw", "se"];
	quads.forEach((q, i) => { if(q[2] - q[0] >= 4 && q[3] - q[1] >= 4) areas[names[i]] = [q[0] + 1, q[1] + 1, q[2] - 1, q[3] - 1]; });
	if(sea.includes("l")) areas.shore = [WATER + 1, Math.max(sea.includes("t") ? SEA : 1, 1), SEA - 1, H - 2];
	if(sea.includes("t")) areas.shore_top = [Math.max(x0, 1), WATER + 1, W - 2, SEA - 1];

	// Ways out, and where you arrive by each
	for(const [s, k] of Object.entries(links)){
		if(k !== "road" && k !== "lane" && k !== "beach" && k !== "cliff") continue;
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
