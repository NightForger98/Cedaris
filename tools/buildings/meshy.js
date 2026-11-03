// Make the user's Meshy house pictures game-ready: background out, down to the game's pixel scale.
//
//   node tools/buildings/meshy.js        art/meshy_houses/originals/house_<n>.png -> art/meshy_houses/house_<n>.png
//
// The pictures are 1254px squares of pixel art drawn about 4 screen pixels to an art pixel, on a plain background
// (cream, white or black). The background is cleared by a flood from the edges (colours near the corner's), then
// each 4x4 block becomes one pixel: the commonest colour in it (so edges stay crisp instead of blurring), or clear
// when the block is mostly background. The result is trimmed to the house.
const fs = require("fs");
const path = require("path");
const {readPng, writePng, newImage} = require("../rooms/png.js");
const ROOT = path.join(__dirname, "../.."), DIR = path.join(ROOT, "art/meshy_houses");
const SCALE = 4, TOL = 60;

function clearBackground(im){
	const W = im.w, H = im.h, px = im.px, seen = new Uint8Array(W * H), st = [];
	const bg = [px[0], px[1], px[2]];
	const near = i => px[i * 4 + 3] < 128 || Math.abs(px[i * 4] - bg[0]) + Math.abs(px[i * 4 + 1] - bg[1]) + Math.abs(px[i * 4 + 2] - bg[2]) < TOL;
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
	// Background the house encloses (under a lean-to, between posts): big patches almost exactly the corner's
	// colour (the cream walls are further off, so they stay)
	const exact = i => px[i * 4 + 3] >= 128 && Math.abs(px[i * 4] - bg[0]) + Math.abs(px[i * 4 + 1] - bg[1]) + Math.abs(px[i * 4 + 2] - bg[2]) < 18;
	const done = new Uint8Array(W * H);
	for(let s0 = 0; s0 < W * H; s0++){
		if(done[s0] || !exact(s0)) continue;
		const part = [], q = [s0];
		done[s0] = 1;
		while(q.length){
			const i = q.pop(); part.push(i);
			const x = i % W, y = (i - x) / W;
			for(const j of [x > 0 ? i - 1 : -1, x < W - 1 ? i + 1 : -1, y > 0 ? i - W : -1, y < H - 1 ? i + W : -1])
				if(j >= 0 && !done[j] && exact(j)){ done[j] = 1; q.push(j); }
		}
		if(part.length > 1500) for(const i of part) px[i * 4 + 3] = 0;
	}
}

function shrink(im){
	const w = Math.floor(im.w / SCALE), h = Math.floor(im.h / SCALE), o = newImage(w, h);
	for(let by = 0; by < h; by++) for(let bx = 0; bx < w; bx++){
		const buckets = new Map();
		let opaque = 0;
		for(let y = 0; y < SCALE; y++) for(let x = 0; x < SCALE; x++){
			const i = ((by * SCALE + y) * im.w + bx * SCALE + x) * 4;
			if(im.px[i + 3] < 128) continue;
			opaque++;
			const k = (im.px[i] >> 3) << 10 | (im.px[i + 1] >> 3) << 5 | (im.px[i + 2] >> 3);
			const b = buckets.get(k) || {n: 0, r: 0, g: 0, b: 0};
			b.n++; b.r += im.px[i]; b.g += im.px[i + 1]; b.b += im.px[i + 2];
			buckets.set(k, b);
		}
		if(opaque * 2 < SCALE * SCALE) continue;
		let best = null;
		for(const b of buckets.values()) if(!best || b.n > best.n) best = b;
		o.px.set([Math.round(best.r / best.n), Math.round(best.g / best.n), Math.round(best.b / best.n), 255], (by * w + bx) * 4);
	}
	return o;
}

function trim(im){
	let x0 = im.w, y0 = im.h, x1 = -1, y1 = -1;
	for(let y = 0; y < im.h; y++) for(let x = 0; x < im.w; x++) if(im.px[(y * im.w + x) * 4 + 3]){ x0 = Math.min(x0, x); y0 = Math.min(y0, y); x1 = Math.max(x1, x); y1 = Math.max(y1, y); }
	const o = newImage(x1 - x0 + 1, y1 - y0 + 1);
	for(let y = 0; y < o.h; y++) o.px.set(im.px.subarray(((y0 + y) * im.w + x0) * 4, ((y0 + y) * im.w + x1 + 1) * 4), y * o.w * 4);
	return o;
}

for(const f of fs.readdirSync(path.join(DIR, "originals")).filter(f => /^house_\d+\.png$/.test(f))){
	const im = readPng(path.join(DIR, "originals", f));
	clearBackground(im);
	const out = trim(shrink(im));
	writePng(path.join(DIR, f), out);
	console.log(`${f}: ${out.w} x ${out.h}px (${(out.w / 32).toFixed(1)} x ${(out.h / 32).toFixed(1)} tiles)`);
}
