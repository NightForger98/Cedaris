// Helpers for composing building sprites from the tile sheets and the downloaded LPC art (see make.js).
const fs = require("fs");
const path = require("path");
const {readPng, writePng, newImage} = require("../rooms/png.js");
const {tilesetImage} = require("../rooms/render.js");
const T = 32;

// Draw src (x, y, w, h) of an image onto dst at (dx, dy), alpha-blended; flip mirrors it left-right
function draw(dst, src, sx, sy, sw, sh, dx, dy, flip = false){
	for(let y = 0; y < sh; y++) for(let x = 0; x < sw; x++){
		const tx = dx + x, ty = dy + y;
		if(tx < 0 || ty < 0 || tx >= dst.w || ty >= dst.h) continue;
		const fx = flip ? sx + sw - 1 - x : sx + x;
		const j = ((sy + y) * src.w + fx) * 4, a = src.px[j + 3] / 255;
		if(a === 0) continue;
		const i = (ty * dst.w + tx) * 4, b = dst.px[i + 3] / 255, oa = a + b * (1 - a);
		for(let k = 0; k < 3; k++) dst.px[i + k] = Math.round((src.px[j + k] * a + dst.px[i + k] * b * (1 - a)) / oa);
		dst.px[i + 3] = Math.round(oa * 255);
	}
}
const sheet = name => name.endsWith(".png") ? readPng(path.join(__dirname, "../..", name)) : tilesetImage(name).img;
const sheets = {};
const img = name => sheets[name] || (sheets[name] = sheet(name));

// Tiles: [c, r, w, h] of a sheet onto dst at cell (x, y) (cells may be fractional)
function tiles(dst, name, c, r, w, h, x, y, flip = false){ draw(dst, img(name), c * T, r * T, w * T, h * T, Math.round(x * T), Math.round(y * T), flip); }
// Pixels: [sx, sy, sw, sh] of a sheet onto dst at pixel (dx, dy)
function pixels(dst, name, sx, sy, sw, sh, dx, dy, flip = false){ draw(dst, img(name), sx, sy, sw, sh, dx, dy, flip); }

// A stamp from tools/rooms/stamps, recoloured like the room builder's swap (whole blocks of the sheet moved by rows)
function stamp(dst, file, x, y, swap = []){
	const st = JSON.parse(fs.readFileSync(path.join(__dirname, "../rooms/stamps", file + ".json"), "utf8"));
	for(const l of st.layers){
		const ts = tilesetImage(l.tileset);
		l.tiles.forEach((row, j) => row.forEach((k, i) => {
			if(!k) return;
			let c = k % ts.cols, r = Math.floor(k / ts.cols);
			for(const s of swap) if(c >= s.cols[0] && c <= s.cols[1] && r >= s.rows[0] && r <= s.rows[1]){ r += s.dRow; c += s.dCol || 0; break; }
			draw(dst, ts.img, c * T, r * T, T, T, (x + i) * T, (y + j) * T);
		}));
	}
	return st;
}

// Cut the empty margin off an image (keeps whole 1px rows/cols with any alpha)
function trim(im){
	let x0 = im.w, y0 = im.h, x1 = -1, y1 = -1;
	for(let y = 0; y < im.h; y++) for(let x = 0; x < im.w; x++) if(im.px[(y * im.w + x) * 4 + 3]){ x0 = Math.min(x0, x); y0 = Math.min(y0, y); x1 = Math.max(x1, x); y1 = Math.max(y1, y); }
	const o = newImage(x1 - x0 + 1, y1 - y0 + 1);
	draw(o, im, x0, y0, o.w, o.h, 0, 0);
	return o;
}

module.exports = {T, draw, img, tiles, pixels, stamp, trim, newImage, writePng, readPng};

// A stamp's tile grids (one per layer) as [{tileset, tiles}], to cut and remix before drawing with grids()
function stampGrids(file){
	return JSON.parse(fs.readFileSync(path.join(__dirname, "../rooms/stamps", file + ".json"), "utf8")).layers.map(l => ({tileset: l.tileset, tiles: l.tiles.map(r => r.slice())}));
}
// Draw tile grids at cell (x, y); swap moves blocks of the sheet like the room builder's swap ({cols, rows, dRow, dCol})
function grids(dst, layers, x, y, swap = []){
	for(const l of layers){
		const ts = tilesetImage(l.tileset);
		l.tiles.forEach((row, j) => row.forEach((k, i) => {
			if(!k) return;
			let c = k % ts.cols, r = Math.floor(k / ts.cols);
			for(const s of swap) if((!s.tileset || s.tileset === l.tileset) && c >= s.cols[0] && c <= s.cols[1] && r >= s.rows[0] && r <= s.rows[1]){ r += s.dRow || 0; c += s.dCol || 0; break; }
			draw(dst, ts.img, c * T, r * T, T, T, Math.round((x + i) * T), Math.round((y + j) * T));
		}));
	}
}
module.exports.stampGrids = stampGrids;
module.exports.grids = grids;
