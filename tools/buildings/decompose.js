// Rebuild the buildings in a pack's preview picture from the pack's own tiles, without the ground under them.
//
//   node tools/buildings/decompose.js <preview.png> <out.png> <sheet.png>...
//
// A sheet written as +sheet.png is props only (decorations, containers): its fully solid tiles are left out, as they
// would match the ground (a patch of dirt) rather than anything standing on it.
//
// A preview is a flattened map: each 32px grid cell shows a stack of tiles. For each cell, find the tile (from the
// given sheets) whose solid pixels all match the picture where nothing above it covers them, the one covering most
// of what is still unexplained; take it as the next layer down, and repeat. A tile counts when most of its pixels
// match (the rest are something drawn over it that isn't in the sheets, like an older window). The building is then
// the picture's own pixels wherever a found tile is solid, and the tiles' faint edges (shadows) elsewhere; what no
// tile explains is ground (grass, dirt - not in the sheets), which is left transparent. Writes the rebuilt picture (same size) and <out>.json with each
// cell's tiles, top first: [sheet, col, row]; and <out>_tiles.png, the found tiles alone.
const fs = require("fs");
const {readPng, writePng, newImage} = require("../rooms/png.js");
const L = require("./lib.js");
const T = 32;

const [prevPath, outPath, ...sheetPaths] = process.argv.slice(2);
const prev = readPng(prevPath);
const props = sheetPaths.map(p => p.startsWith("+"));
const sheets = sheetPaths.map(p => readPng(p.replace(/^\+/, "")));

// Every non-empty tile: its solid pixels (alpha 255) as [offset, r, g, b], and its faint ones (to draw, not to match)
const tiles = [];
sheets.forEach((im, s) => {
	for(let r = 0; r < Math.floor(im.h / T); r++) for(let c = 0; c < Math.floor(im.w / T); c++){
		const solid = [];
		for(let y = 0; y < T; y++) for(let x = 0; x < T; x++){
			const i = ((r * T + y) * im.w + c * T + x) * 4;
			if(im.px[i + 3] === 255) solid.push([y * T + x, im.px[i], im.px[i + 1], im.px[i + 2]]);
		}

		if(solid.length >= 12 && !(props[s] && solid.length === T * T)) tiles.push({s, c, r, solid});
	}
});

// The grid offset: try each, keep the one where most cells are fully explained by a single tile
function cellPx(ox, oy, gx, gy){
	const px = new Int16Array(T * T * 3).fill(-1);
	for(let y = 0; y < T; y++) for(let x = 0; x < T; x++){
		const X = ox + gx * T + x, Y = oy + gy * T + y;
		if(X < 0 || Y < 0 || X >= prev.w || Y >= prev.h) continue;
		const i = (Y * prev.w + X) * 4, k = (y * T + x) * 3;
		if(prev.px[i + 3] < 255) continue;   // the picture's empty margin matches nothing
		px[k] = prev.px[i]; px[k + 1] = prev.px[i + 1]; px[k + 2] = prev.px[i + 2];
	}
	return px;
}
// Does a tile fit a cell, given the pixels already explained by tiles above? Returns how many new pixels it explains,
// or -1. strict: every pixel must match (finding the grid); otherwise up to 60% may be covered by something unknown
// (a big window over a wall), as long as what does show matches
function fit(t, px, done, strict = true){
	let n = 0, bad = 0;
	const limit = strict ? 0 : Math.floor(t.solid.length * 0.6);
	for(const [o, r, g, b] of t.solid){
		if(done[o]) continue;
		const k = o * 3;
		if(px[k] !== r || px[k + 1] !== g || px[k + 2] !== b){ if(++bad > limit) return -1; continue; }
		n++;
	}
	return (strict || (n >= 80 && n * 10 > bad * 7)) ? n : -1;
}
function solveCell(px){
	const done = new Uint8Array(T * T), stack = [];
	for(let depth = 0; depth < 5; depth++){
		let best = null, bestN = 8;
		for(const t of tiles){ const n = fit(t, px, done, false); if(n > bestN){ bestN = n; best = t; } }
		if(!best) break;
		stack.push(best);
		for(const [o] of best.solid) done[o] = 1;
	}
	return stack;
}

let ox = 0, oy = 0;
{
	let bestScore = -1;
	const gw = Math.floor(prev.w / T) - 1, gh = Math.floor(prev.h / T) - 1;
	for(let oy2 = 0; oy2 < T; oy2 += 1) for(let ox2 = 0; ox2 < T; ox2 += 1){
		let score = 0;
		// sample a spread of cells for speed
		for(let gy = 0; gy < gh; gy += 3) for(let gx = 0; gx < gw; gx += 3){
			const px = cellPx(ox2, oy2, gx, gy), done = new Uint8Array(T * T);
			for(const t of tiles) if(fit(t, px, done) > 200){ score++; break; }
		}
		if(score > bestScore){ bestScore = score; ox = ox2; oy = oy2; }
	}
	console.log(`grid offset ${ox},${oy} (${bestScore} sampled cells matched)`);
}

const out = newImage(prev.w, prev.h), tilesOnly = newImage(prev.w, prev.h), cells = {};
// Pixels taken from the picture rather than matched to a tile: they may be ground showing through, checked at the end
const copied = new Uint8Array(prev.w * prev.h);
let solved = 0;
for(let gy = -1; gy * T + oy < prev.h; gy++) for(let gx = -1; gx * T + ox < prev.w; gx++){
	const stack = solveCell(cellPx(ox, oy, gx, gy));
	if(!stack.length) continue;
	solved++;
	cells[gx + "," + gy] = stack.map(t => [t.s, t.c, t.r]);
	// Faint tile edges first, then the picture's pixels wherever a found tile is solid
	for(let i = stack.length - 1; i >= 0; i--){
		const t = stack[i];
		L.draw(out, sheets[t.s], t.c * T, t.r * T, T, T, ox + gx * T, oy + gy * T);
		L.draw(tilesOnly, sheets[t.s], t.c * T, t.r * T, T, T, ox + gx * T, oy + gy * T);
	}
	const solidMask = new Uint8Array(T * T);
	for(const t of stack) for(const [o] of t.solid) solidMask[o] = 1;
	for(let o = 0; o < T * T; o++){
		if(!solidMask[o]) continue;
		const X = ox + gx * T + (o % T), Y = oy + gy * T + Math.floor(o / T);
		if(X < 0 || Y < 0 || X >= prev.w || Y >= prev.h) continue;
		const i = (Y * prev.w + X) * 4;
		if(prev.px[i + 3] < 255) continue;
		if(out.px[i] !== prev.px[i] || out.px[i + 1] !== prev.px[i + 1] || out.px[i + 2] !== prev.px[i + 2] || out.px[i + 3] !== 255) copied[i / 4] = 1;
		out.px[i] = prev.px[i]; out.px[i + 1] = prev.px[i + 1]; out.px[i + 2] = prev.px[i + 2]; out.px[i + 3] = 255;
	}
}
// Holes inside a building (a window hiding nearly all of the wall tile behind it): empty pixels the outside can't
// reach take the picture's own pixels
{
	const W = prev.w, H = prev.h, outside = new Uint8Array(W * H), q = [];
	const empty = i => out.px[i * 4 + 3] === 0;
	for(let x = 0; x < W; x++) for(const y of [0, H - 1]) if(empty(y * W + x)){ outside[y * W + x] = 1; q.push(y * W + x); }
	for(let y = 0; y < H; y++) for(const x of [0, W - 1]) if(empty(y * W + x) && !outside[y * W + x]){ outside[y * W + x] = 1; q.push(y * W + x); }
	while(q.length){
		const i = q.pop(), x = i % W, y = (i - x) / W;
		for(const [nx, ny] of [[x + 1, y], [x - 1, y], [x, y + 1], [x, y - 1]]){
			if(nx < 0 || ny < 0 || nx >= W || ny >= H) continue;
			const j = ny * W + nx;
			if(!outside[j] && empty(j)){ outside[j] = 1; q.push(j); }
		}
	}
	let filled = 0;
	for(let i = 0; i < W * H; i++) if(empty(i) && !outside[i] && prev.px[i * 4 + 3] === 255){ out.px.set(prev.px.subarray(i * 4, i * 4 + 4), i * 4); copied[i] = 1; filled++; }
	console.log(`${filled} enclosed pixels filled`);
	// The ground's colours: the picture where no building was found. Copied pixels in those colours that are grass
	// green are grass showing through (other ground colours are shared with windows and shadows, so they stay)
	const key = i => (prev.px[i * 4] << 16) | (prev.px[i * 4 + 1] << 8) | prev.px[i * 4 + 2], count = new Map();
	for(let i = 0; i < W * H; i++) if(outside[i] && prev.px[i * 4 + 3] === 255) count.set(key(i), (count.get(key(i)) || 0) + 1);
	let dropped = 0;
	const green = i => { const r = prev.px[i * 4], g = prev.px[i * 4 + 1], b = prev.px[i * 4 + 2]; return g > r + 25 && g > b + 25; };
	for(let i = 0; i < W * H; i++) if(copied[i] && green(i) && (count.get(key(i)) || 0) >= 20){ out.px[i * 4 + 3] = 0; dropped++; }
	console.log(`${dropped} ground pixels dropped`);
	// Whole cells that are nearly all the ground's commonest colours are ground a loose match let in (a patch of
	// dirt); only colours seen hundreds of times count, as the unmatched parts of a picture hold a few roof colours too.
	// GROUND_CELLS=0 turns this off (pictures on plain grass whose roofs share the commonest colours)
	let cleared = 0;
	if(process.env.GROUND_CELLS !== "0") for(let gy = -1; gy * T + oy < H; gy++) for(let gx = -1; gx * T + ox < W; gx++){
		let n = 0, g = 0;
		for(let y = 0; y < T; y++) for(let x = 0; x < T; x++){
			const X = ox + gx * T + x, Y = oy + gy * T + y;
			if(X < 0 || Y < 0 || X >= W || Y >= H) continue;
			const i = Y * W + X;
			if(!out.px[i * 4 + 3]) continue;
			n++;
			if((count.get(key(i)) || 0) >= 400) g++;
		}
		if(n > 200 && g > n * 0.9){
			cleared++;
			for(let y = 0; y < T; y++) for(let x = 0; x < T; x++){
				const X = ox + gx * T + x, Y = oy + gy * T + y;
				if(X >= 0 && Y >= 0 && X < W && Y < H) out.px[(Y * W + X) * 4 + 3] = 0;
			}
		}
	}
	console.log(`${cleared} ground cells cleared`);
}
writePng(outPath, out);
// Only the tiles found, none of the picture's own pixels: for spots where the picture shows something not ours to
// keep (an animal from another pack standing in a doorway)
writePng(outPath.replace(/.png$/, "_tiles.png"), tilesOnly);
fs.writeFileSync(outPath.replace(/\.png$/, ".json"), JSON.stringify({ox, oy, sheets: sheetPaths, cells}));
console.log(`${solved} cells rebuilt -> ${outPath}`);
