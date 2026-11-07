// The farmhouse with its built-in furniture cleared (the user, 2026-11-07: room for your own furniture, the
// Stardew way): writes stamps/<name>_clear.json from a captured stamp - its first layer (floor, walls, trim) and its
// TS_cottage windows kept whole, every other TS_interior tile from the furniture part of the sheet (column 19 and
// up) dropped, except in the kept cells (the stairs, the hearth, the kitchen, the bed); holes are filled from another
// cell. Cells are room cells (the stamp's crop offset taken off). Writes build/stamp_layers/<name>_clear.png to check.
//
//   node tools/rooms/clear_stamp.js
const fs = require("fs");
const path = require("path");
const {root} = require("./yy.js");
const {writePng, newImage, blit} = require("./png.js");
const {tilesetImage} = require("./render.js");

const JOBS = {
	// downstairs: the stairs (without the cupboards under them), the hearth, the kitchen along the top right
	house_ground: {crop: [1, 1], keep: [[0, 0, 5, 1], [4, 2, 5, 3], [9, 5, 9, 7], [12, 0, 18, 3]],
	               fill: {"10,4": "10,7", "10,5": "10,7", "10,6": "10,7"}},
	// upstairs: the bed (obj_bed stands on it), the curtains and wall pieces round the windows
	// (the rug stays: a starter rug, your pieces go on it; the two armchairs go, though their tiles are in the
	// structure part of the sheet)
	house_upstairs: {crop: [1, 1], keep: [[15, 1, 18, 4], [8, -1, 14, 1]], drop: [[6, 6, 6, 7], [9, 6, 9, 7]], fill: {}},
};

for(const [name, job] of Object.entries(JOBS)){
	const s = JSON.parse(fs.readFileSync(path.join(__dirname, "stamps", name + ".json"), "utf8"));
	const [cx, cy] = job.crop;
	const kept = (x, y) => job.keep.some(([x1, y1, x2, y2]) => x >= x1 && x <= x2 && y >= y1 && y <= y2);
	s.layers.forEach((l, k) => {
		if(k === 0 || l.tileset !== "TS_interior") return;
		const cols = tilesetImage(l.tileset).cols;
		l.tiles = l.tiles.map((row, y) => row.map((t, x) => ((t & 0x7FFFF) && (t & 0x7FFFF) % cols >= 19 && !kept(x - cx, y - cy)) ? 0 : t));
	});
	for(const [x1, y1, x2, y2] of job.drop || []) s.layers.forEach((l, k) => { if(k > 0) for(let y = y1; y <= y2; y++) for(let x = x1; x <= x2; x++) l.tiles[y + cy][x + cx] = 0; });
	for(const [to, from] of Object.entries(job.fill)){
		const [tx, ty] = to.split(",").map(Number), [fx, fy] = from.split(",").map(Number);
		for(const l of s.layers){ l.tiles[ty + cy][tx + cx] = l.tiles[fy + cy][fx + cx]; }
	}
	s.from = (s.from || name) + " (furniture cleared: tools/rooms/clear_stamp.js)";
	fs.writeFileSync(path.join(__dirname, "stamps", name + "_clear.json"), JSON.stringify(s));
	// the check picture
	const out = newImage(s.w * 32, s.h * 32);
	for(const l of s.layers){ const ts = tilesetImage(l.tileset);
		l.tiles.forEach((row, y) => row.forEach((t, x) => { const i = t & 0x7FFFF; if(i) blit(out, ts.img, (i % ts.cols) * 32, Math.floor(i / ts.cols) * 32, 32, 32, x * 32, y * 32); })); }
	fs.mkdirSync(path.join(root, "build", "stamp_layers"), {recursive: true});
	writePng(path.join(root, "build", "stamp_layers", name + "_clear.png"), out);
	console.log(`stamps/${name}_clear.json`);
}
