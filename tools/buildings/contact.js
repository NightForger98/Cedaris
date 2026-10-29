// Draw the pieces listed by parts.js (lines "i x y w h") in a grid of 80px cells, in order, for picking by index.
//   node tools/buildings/contact.js <png> <parts.txt> <first> <count> <out.png>
const fs = require("fs");
const L = require("./lib.js");
const [png, list, first, count, out] = process.argv.slice(2);
const im = L.readPng(png), rows = fs.readFileSync(list, "utf8").trim().split("\n").map(l => l.split(" ").map(Number)).filter(r => r[0] >= +first).slice(0, +count);
const C = 10, S = 100, o = L.newImage(C * S, Math.ceil(rows.length / C) * S, [60, 60, 70, 255]);
rows.forEach(([i, x, y, w, h], k) => {
	const cx = (k % C) * S, cy = Math.floor(k / C) * S;
	for(let d = 0; d < S; d++){ o.px.set([255, 255, 0, 255], ((cy) * o.w + cx + d) * 4); o.px.set([255, 255, 0, 255], ((cy + d) * o.w + cx) * 4); }
	L.draw(o, im, x, y, Math.min(w, S - 4), Math.min(h, S - 4), cx + 2, cy + 2);
});
L.writePng(out, o);
console.log(rows.map((r, k) => k + ":" + r[0]).join(" "));
