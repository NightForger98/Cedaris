// Make a PixelLab building game-ready: clear its flat background and trim it to the building.
//
//   node tools/buildings/ai_house.js <name> [...]   art/ai_houses/originals/<name>.png -> art/ai_houses/<name>.png
//
// PixelLab draws objects bigger than 200x200 on one flat colour instead of transparency, already at the game's pixel
// scale (one art pixel per pixel). The background is cleared by a flood from the edges over pixels of (almost) that
// colour - the buildings' 1px dark outline stops it - and the result is trimmed, so the building's base is the
// bottom edge.
const path = require("path");
const {readPng, writePng, newImage} = require("../rooms/png.js");
const DIR = path.join(__dirname, "../../art/ai_houses");
const TOL = 12;

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

for(const name of process.argv.slice(2)){
	const im = readPng(path.join(DIR, "originals", name + ".png"));
	clearBackground(im);
	const o = trim(im);
	writePng(path.join(DIR, name + ".png"), o);
	console.log(name + ": " + o.w + "x" + o.h);
}
