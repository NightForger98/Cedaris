// Look at part of a tile sheet: crop, enlarge and draw the 32px grid (with every 4th line brighter).
//   node tools/buildings/grid.js <tileset|png> <col> <row> <cols> <rows> [scale] [out.png]
const path = require("path");
const {readPng, writePng, newImage} = require("../rooms/png.js");
const {tilesetImage} = require("../rooms/render.js");
const [src, c, r, w, h, s = "2", out] = process.argv.slice(2);
const img = src.endsWith(".png") ? readPng(src) : tilesetImage(src).img;
const S = +s, T = 32, o = newImage(w * T * S, h * T * S, [40, 40, 48, 255]);
for(let y = 0; y < h * T * S; y++) for(let x = 0; x < w * T * S; x++){
	const sx = c * T + Math.floor(x / S), sy = r * T + Math.floor(y / S);
	const i = (y * o.w + x) * 4;
	if(x % (T * S) === 0 || y % (T * S) === 0){
		const strong = (Math.floor(x / (T * S)) % 4 === 0 && x % (T * S) === 0) || (Math.floor(y / (T * S)) % 4 === 0 && y % (T * S) === 0);
		o.px.set(strong ? [255, 60, 60, 255] : [255, 255, 0, 255], i); continue;
	}
	if(sx >= img.w || sy >= img.h) continue;
	const j = (sy * img.w + sx) * 4, a = img.px[j + 3] / 255;
	for(let k = 0; k < 3; k++) o.px[i + k] = Math.round(img.px[j + k] * a + o.px[i + k] * (1 - a));
}
writePng(out || path.join(__dirname, "../../build/buildings/grid", `${path.basename(src, ".png")}_${c}_${r}.png`), o);
