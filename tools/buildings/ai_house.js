// Make a PixelLab building game-ready: clear its flat background and trim it to the building.
//
//   node tools/buildings/ai_house.js <name> [...]   art/ai_houses/originals/<name>.png -> art/ai_houses/<name>.png
//
// PixelLab draws objects bigger than 200x200 on one flat colour instead of transparency, already at the game's pixel
// scale (one art pixel per pixel). The background is cleared by a flood from the edges over pixels near that
// colour - the buildings' 1px dark outline stops it - and the result is trimmed, so the building's base is the
// bottom edge. FIX (below) clears what a few drew that a building can't have (smoke, ground).
const path = require("path");
const {readPng, writePng, newImage} = require("../rooms/png.js");
const DIR = path.join(__dirname, "../../art/ai_houses");
const TOL = 40;

// tol: how near the background colour a pixel must be to clear (higher for a speckled background); holes: also
// clear background-coloured pixels the flood can't reach (seen through an arch)
function clearBackground(im, tol = TOL, holes = false){
	const W = im.w, H = im.h, px = im.px, seen = new Uint8Array(W * H), st = [];
	const bg = [px[0], px[1], px[2]];
	const near = i => px[i * 4 + 3] < 128 || Math.abs(px[i * 4] - bg[0]) + Math.abs(px[i * 4 + 1] - bg[1]) + Math.abs(px[i * 4 + 2] - bg[2]) < tol;
	// a hole: a patch of background colour over 400 pixels (smaller patches are the art's own highlights)
	if(holes){
		const done = new Uint8Array(W * H);
		for(let s = 0; s < W * H; s++){
			if(done[s] || !near(s)) continue;
			const part = [], q = [s];
			done[s] = 1;
			while(q.length){
				const i = q.pop(), x = i % W;
				part.push(i);
				for(const j of [x > 0 ? i - 1 : -1, x < W - 1 ? i + 1 : -1, i - W, i + W])
					if(j >= 0 && j < W * H && !done[j] && near(j)){ done[j] = 1; q.push(j); }
			}
			if(part.length > 400) for(const i of part) px[i * 4 + 3] = 0;
		}
	}
	for(let x = 0; x < W; x++) for(const y of [0, H - 1]) st.push(y * W + x);
	for(let y = 0; y < H; y++) for(const x of [0, W - 1]) st.push(y * W + x);
	while(st.length){
		const i = st.pop();
		if(seen[i] || !near(i)) continue;
		seen[i] = 1;
		px[i * 4 + 3] = 0;
		const x = i % W, y = (i - x) / W;
		if(x > 0) st.push(i - 1); if(x < W - 1) st.push(i + 1);
		if(y > 0) st.push(i - W); if(y < H - 1) st.push(i + W);
	}
}

function trim(im){
	let x0 = im.w, y0 = im.h, x1 = -1, y1 = -1;
	for(let y = 0; y < im.h; y++) for(let x = 0; x < im.w; x++) if(im.px[(y * im.w + x) * 4 + 3] >= 128){
		x0 = Math.min(x0, x); x1 = Math.max(x1, x); y0 = Math.min(y0, y); y1 = Math.max(y1, y);
	}
	const o = newImage(x1 - x0 + 1, y1 - y0 + 1);
	for(let y = 0; y < o.h; y++) for(let x = 0; x < o.w; x++){
		const s = ((y + y0) * im.w + x + x0) * 4, d = (y * o.w + x) * 4;
		const a = im.px[s + 3] >= 128;
		for(let c = 0; c < 4; c++) o.px[d + c] = a ? (c === 3 ? 255 : im.px[s + c]) : 0;
	}
	return o;
}

// Things PixelLab drew that a building can't have, in rows of the trimmed picture: smoke above the chimney (cutTop
// rows), the ground it stood on (cutBottom rows), grass tufts left at its foot (green pixels in the last grassRows),
// stray pixels of the key colour a hand-stitched original was put together on (key).
const FIX = {
	brewery: {cutTop: 27},
	lighthouse: {cutBottom: 13, grassRows: 8},
	fisherman_hut: {key: [255, 0, 255]},	// stitched by hand on magenta, see the README
	home_hayward: {},	// a speckled background: only the loose specks (dropped below) need clearing
	home_ward: {tol: 90}, cafe_terrace: {tol: 90},	// speckled backgrounds
	prop_sea_arch: {holes: true},
	marina_club: {tol: 20}, tram_stop: {tol: 20}, bunny_burrow: {tol: 20}, cable_car_station: {grassRows: 6},	// on black: a low tolerance keeps the dark outline
	town_hallhouse: {tol: 20}, town_hallhouse2: {tol: 20}, town_hallhouse3: {tol: 20}, town_apartments: {tol: 20}, town_yellowhouse: {tol: 20},
	town_yellowhouse2: {tol: 20}, town_villa: {tol: 20}, town_villa2: {tol: 20},	// on black
	port_silos: {tol: 60}, bourj_market: {tol: 60},	// speckled backgrounds	// the sky seen through the arch
	windmill: {cutBottom: 24, grassRows: 34},	// a patch of grass and a path round its foot
	oakhart_farmhouse: {},	// a faint signature in a corner (dropped as specks)
	home_larkspun: {cutBottom: 25}, rangers_cabin: {cutBottom: 26}, home_frere: {grassRows: 6},	// a path drawn down from the door
};

function clearRows(im, y0, y1){
	for(let y = Math.max(0, y0); y < Math.min(im.h, y1); y++) for(let x = 0; x < im.w; x++) im.px[(y * im.w + x) * 4 + 3] = 0;
}

// Clear pieces smaller than min pixels that aren't joined to anything (8-way): what's left of a cut-away tuft.
function dropSpecks(im, min){
	const W = im.w, H = im.h, seen = new Uint8Array(W * H);
	for(let s0 = 0; s0 < W * H; s0++){
		if(seen[s0] || im.px[s0 * 4 + 3] < 128) continue;
		const part = [], q = [s0];
		seen[s0] = 1;
		while(q.length){
			const i = q.pop(); part.push(i);
			const x = i % W, y = (i - x) / W;
			for(let dy = -1; dy <= 1; dy++) for(let dx = -1; dx <= 1; dx++){
				const xx = x + dx, yy = y + dy, j = yy * W + xx;
				if(xx >= 0 && yy >= 0 && xx < W && yy < H && !seen[j] && im.px[j * 4 + 3] >= 128){ seen[j] = 1; q.push(j); }
			}
		}
		if(part.length < min) for(const i of part) im.px[i * 4 + 3] = 0;
	}
}

for(const name of process.argv.slice(2)){
	const im = readPng(path.join(DIR, "originals", name + ".png"));
	clearBackground(im, (FIX[name] || {}).tol, (FIX[name] || {}).holes);
	let o = trim(im);
	const fix = FIX[name];
	if(fix){
		clearRows(o, 0, fix.cutTop || 0);
		clearRows(o, o.h - (fix.cutBottom || 0), o.h);
		if(fix.key) for(let i = 0; i < o.w * o.h; i++)
			if(Math.abs(o.px[i * 4] - fix.key[0]) + Math.abs(o.px[i * 4 + 1] - fix.key[1]) + Math.abs(o.px[i * 4 + 2] - fix.key[2]) < 60) o.px[i * 4 + 3] = 0;
		const bottom = o.h - (fix.cutBottom || 0);
		for(let y = bottom - (fix.grassRows || 0); y < bottom; y++) for(let x = 0; x < o.w; x++){
			const i = (y * o.w + x) * 4, r = o.px[i], g = o.px[i + 1], b = o.px[i + 2];
			if(g > r + 4 && g >= b) o.px[i + 3] = 0;	// greens, dark outline greens too
		}
		dropSpecks(o, 60);
		o = trim(o);
	}
	writePng(path.join(DIR, name + ".png"), o);
	console.log(name + ": " + o.w + "x" + o.h);
}
