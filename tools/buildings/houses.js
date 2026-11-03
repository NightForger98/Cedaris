// Custom houses for the villagers, rebuilt from the cottage pack's own tiles (the preview picture decomposed by
// decompose.js into tile stacks per cell) and dressed with props from the LPC packs.
//
//   node tools/buildings/houses.js        write build/buildings/houses/<name>.png and a contact sheet (all.png)
//
// A house starts from a part of a decomposed preview (cells), re-rendered tile by tile so its colours can change:
//   roof: "yellow" | "brown"           the thatch (thatched-roof.png: yellow rows 0-6, brown rows 7-13)
//   walls: "cream" | "beige" | "stone" the infill (cottage.png: beige rows 0-3, cream 4-7, stone 8-11)
// The pixels the tiles don't explain (windows, flower boxes, doors from an older pack version) are laid back on top.
const fs = require("fs");
const path = require("path");
const L = require("./lib.js");
const T = 32;
const ROOT = path.join(__dirname, "../..");
const DEC = path.join(ROOT, "build/buildings/dec/");

const previews = {};
function preview(name){
	if(previews[name]) return previews[name];
	const json = JSON.parse(fs.readFileSync(DEC + name + ".json", "utf8"));
	return previews[name] = {json, full: L.readPng(DEC + name + ".png"), tiles: L.readPng(DEC + name + "_tiles.png"),
		sheets: json.sheets.map(s => L.readPng(path.join(ROOT, s.replace(/^\+/, ""))))};
}

const ROOF = {yellow: r => r < 7 ? r : r - 7, brown: r => r < 7 ? r + 7 : r};
const WALL = {beige: r => r < 12 ? r % 4 : r, cream: r => r < 12 ? 4 + r % 4 : r, stone: r => r < 12 ? 8 + r % 4 : r};

// Rebuild cells [gx, gy, w, h] of a decomposed preview with new colours; returns an image (w*32 x h*32)
function rebuild(name, [gx0, gy0, w, h], {roof, walls} = {}){
	const p = preview(name), {ox, oy, cells} = p.json, o = L.newImage(w * T, h * T);
	const sheetName = s => path.basename(p.json.sheets[s]);
	for(let gy = gy0; gy < gy0 + h; gy++) for(let gx = gx0; gx < gx0 + w; gx++){
		const stack = cells[gx + "," + gy] || [], dx = (gx - gx0) * T, dy = (gy - gy0) * T;
		for(let i = stack.length - 1; i >= 0; i--){
			let [s, c, r] = stack[i];
			if(roof && sheetName(s) === "thatched-roof.png") r = ROOF[roof](r);
			if(walls && sheetName(s) === "cottage.png") r = WALL[walls](r);
			L.draw(o, p.sheets[s], c * T, r * T, T, T, dx, dy);
		}
		// What the tiles don't explain (windows, boxes) comes back from the picture
		for(let y = 0; y < T; y++) for(let x = 0; x < T; x++){
			const X = ox + gx * T + x, Y = oy + gy * T + y;
			if(X < 0 || Y < 0 || X >= p.full.w || Y >= p.full.h) continue;
			const i = (Y * p.full.w + X) * 4, a = p.full.px, b = p.tiles.px;
			if(a[i + 3] && (a[i] !== b[i] || a[i + 1] !== b[i + 1] || a[i + 2] !== b[i + 2] || a[i + 3] !== b[i + 3]))
				o.px.set(a.subarray(i, i + 4), ((dy + y) * o.w + dx + x) * 4);
		}
	}
	return o;
}

// Base shapes in the cottage pack's preview (preview_280): [gx, gy, w, h] in its grid
const SHAPES = {
	l_house: ["preview_280", [5, 3, 11, 8]],
	tall: ["preview_280", [16, 2, 7, 9]],
	small: ["preview_280", [12, 11, 6, 7]],
	long: ["preview_280", [26, 11, 11, 8]],
};
// The standalone hip-roofed cottage: the free halves of the twin cottages either side of the gateway
function hipCottage(opts){
	const left = rebuild("preview_280", [26, 3, 4, 8], opts), right = rebuild("preview_280", [40, 3, 3, 8], opts);
	const o = L.newImage(7 * T, 8 * T);
	L.draw(o, left, 0, 0, left.w, left.h, 0, 0);
	L.draw(o, right, 0, 0, right.w, right.h, 4 * T, 0);
	return o;
}

// Props: [sheet, x, y, w, h]
const DECO = "art/lpc_medieval_decorations/decorations-medieval.png", BOX = "art/lpc_containers/container.png";
const SMITH = "art/lpc_blacksmith/blacksmith-smelter.png", WOOD = "art/lpc_woodshop/woodshop.png";
const P = {
	sign_potion: [DECO, 320, 0, 32, 32], sign_smith: [DECO, 320, 32, 32, 32], sign_goods: [DECO, 256, 0, 32, 32],
	sign_bread: [DECO, 288, 0, 32, 32], sign_sword: [DECO, 224, 0, 32, 32], sign_book: [DECO, 192, 32, 32, 32],
	bracket: [DECO, 237, 288, 19, 32], lantern: [DECO, 423, 66, 19, 30], torch: [DECO, 427, 160, 13, 31],
	laundry: [DECO, 288, 198, 64, 26], bottles: [DECO, 0, 0, 0, 0], fence: [DECO, 369, 457, 64, 48],
	wheelbarrow: [DECO, 196, 514, 82, 62], hay_box: [DECO, 426, 536, 74, 40], trough_w: [DECO, 426, 577, 74, 31],
	planter: [DECO, 426, 609, 74, 31], rake_hay: [DECO, 192, 640, 32, 62], logs: [DECO, 402, 641, 30, 32],
	hay: [DECO, 70, 646, 51, 45], firewood: [DECO, 455, 646, 52, 55], cart: [DECO, 224, 647, 64, 45], hay_roll: [DECO, 5, 649, 51, 78],
	produce: [DECO, 256, 153, 64, 39], well: [DECO, 0, 432, 64, 48],
	forge: [SMITH, 0, 129, 128, 127], anvil: [SMITH, 331, 419, 46, 27], trough: [SMITH, 646, 432, 57, 38],
	coal: [SMITH, 396, 200, 101, 44], toolbench: [SMITH, 322, 480, 61, 92],
	saw_log: [WOOD, 6, 184, 51, 36], sawhorse: [WOOD, 226, 64, 28, 32], planks: [WOOD, 70, 385, 53, 28],
	barrels: [BOX, 197, 5, 55, 50], barrel: [BOX, 72, 1, 48, 61], crates: [BOX, 0, 551, 63, 55], crate: [BOX, 458, 691, 38, 44],
	sack: [BOX, 225, 803, 29, 28], sacks: [BOX, 97, 801, 61, 63], basket: [BOX, 48, 801, 32, 31],
};
// Draw a prop with its bottom-left corner at (x, bottom)
function prop(o, key, x, bottom, flip = false){ const [sh, sx, sy, w, h] = P[key]; L.pixels(o, sh, sx, sy, w, h, x, bottom - h, flip); }
// A shop sign hanging from a bracket on a wall: the bracket's top-left at (x, y)
function sign(o, key, x, y){ prop(o, "bracket", x, y + 32); prop(o, key, x + 6, y + 40); }

// The villagers' houses. Each returns {img, door: [col, row]} - the door cell in the image's 32px grid. The house
// is drawn a row down from the top; props stand on the ground line of the house's front (its bottom edge).
const TERRAIN = "TS_terrain";
function picketRow(o, x, y, n){ for(let i = 0; i < n; i++) L.tiles(o, TERRAIN, 19, 20, 3, 1, x / T + i * 3, y / T); }
const DESIGNS = {
	// Elda the herbalist: the little cottage with its stone chimney wall, a potion sign by the door, herbs drying on a
	// line, a basket of cuttings
	elda(){
		const h = rebuild(...SHAPES.small), o = L.newImage(9 * T, 9 * T), gx = 3, gy = 1, ground = (gy + 7) * T;
		L.draw(o, h, 0, 0, h.w, h.h, gx * T, gy * T);
		sign(o, "sign_potion", (gx + 1) * T - 16, (gy + 4) * T);
		prop(o, "laundry", T - 8, ground - 4); prop(o, "basket", (gx + 4) * T + 8, ground + 4);
		prop(o, "lantern", (gx + 3) * T + 2, (gy + 5) * T + 8);
		return {img: o, door: [gx + 2, gy + 6]};
	},
	// Brom the smith: the long dormer cottage in stone, the brick forge with its chimneys built on at the side, the
	// anvil and the quench trough out front, firewood by the forge, the smith's sign
	brom(){
		const h = rebuild(...SHAPES.long, {walls: "stone"}), o = L.newImage(16 * T, 10 * T), gy = 1, ground = (gy + 8) * T;
		L.draw(o, h, 0, 0, h.w, h.h, 0, gy * T);
		prop(o, "forge", 10 * T - 6, ground);
		prop(o, "anvil", 5 * T, ground + 26); prop(o, "trough", 7 * T + 4, ground + 30);
		prop(o, "firewood", 14 * T - 6, ground);
		sign(o, "sign_smith", 4, (gy + 5) * T);
		return {img: o, door: [2, gy + 7]};
	},
	// Mara's general store: the L-shaped cottage in brown thatch, its open lean-to stacked with the stock
	mara(){
		const h = rebuild(...SHAPES.l_house, {roof: "brown"}), o = L.newImage(12 * T, 10 * T), gy = 1, ground = (gy + 8) * T;
		L.draw(o, h, 0, 0, h.w, h.h, 0, gy * T);
		prop(o, "crates", 7 * T - 4, ground - 2); prop(o, "sacks", 8 * T + 26, ground - 2);
		prop(o, "barrels", 10 * T - 10, ground - 6); prop(o, "basket", 6 * T + 4, ground + 6);
		sign(o, "sign_goods", 4, (gy + 4) * T + 10);
		return {img: o, door: [3, gy + 6]};
	},
	// Aunt Hesta and Tobin: the tall two-storey cottage in brown thatch, a picket-fenced corn patch beside it
	hesta(){
		const h = rebuild(...SHAPES.tall, {roof: "brown"}), o = L.newImage(13 * T, 11 * T), gy = 1, ground = (gy + 9) * T;
		L.draw(o, h, 0, 0, h.w, h.h, 0, gy * T);
		L.tiles(o, TERRAIN, 8, 17, 3, 3, 7.5, ground / T - 3.4);    // the corn patch
		picketRow(o, 7 * T, ground - T + 4, 2);
		prop(o, "basket", 6 * T + 8, ground + 2);
		return {img: o, door: [3, gy + 8]};
	},
	// Rowan, who works the lumber yard: the hip-roofed cottage in yellow thatch with its chimney, a woodpile, a log on
	// the sawhorse and the wheelbarrow
	rowan(){
		const h = hipCottage({roof: "yellow"}), o = L.newImage(11 * T, 10 * T), gx = 2, gy = 1, ground = (gy + 7) * T + 28;
		L.draw(o, h, 0, 0, h.w, h.h, gx * T, gy * T);
		L.pixels(o, "art/lpc_colonial/colonial.png", 551, 331, 18, 45, gx * T + 152, gy * T + 14);
		prop(o, "firewood", 9 * T - 4, ground); prop(o, "saw_log", 9 * T + 8, ground + 12);
		prop(o, "wheelbarrow", 0, ground - 6);
		return {img: o, door: [gx + 3, gy + 6]};
	},
};

module.exports = {rebuild, hipCottage, SHAPES, preview, DESIGNS, prop, sign};

if(require.main === module) main();
function main(){
	const out = path.join(ROOT, "build/buildings/houses");
	fs.mkdirSync(out, {recursive: true});
	// Each villager's house, and a sheet of them all
	const made = Object.entries(DESIGNS).map(([n, f]) => { const r = f(); L.writePng(path.join(out, n + ".png"), r.img); return r.img; });
	{
		const W = made.reduce((a, i) => a + i.w + 16, 16), H = Math.max(...made.map(i => i.h)) + 32;
		const sheet = L.newImage(W, H, [62, 112, 54, 255]);
		let x = 16;
		for(const im of made){ L.draw(sheet, im, 0, 0, im.w, im.h, x, H - 16 - im.h); x += im.w + 16; }
		L.writePng(path.join(out, "all.png"), sheet);
		console.log("all.png", W, H);
	}
	if(!process.argv.includes("--swaps")) return;
	const looks = [{}, {roof: "brown"}, {roof: "yellow"}, {walls: "beige"}, {walls: "stone"}, {walls: "cream"}];
	const rows = [...Object.entries(SHAPES).map(([n, [pv, box]]) => looks.map(l => rebuild(pv, box, l))), looks.map(l => hipCottage(l))];
	const W = rows.reduce((m, r) => Math.max(m, r.reduce((a, i) => a + i.w + 8, 0)), 0), H = rows.reduce((a, r) => a + Math.max(...r.map(i => i.h)) + 8, 0);
	const sheet = L.newImage(W, H, [62, 112, 54, 255]);
	let y = 0;
	for(const r of rows){ let x = 0; for(const im of r){ L.draw(sheet, im, 0, 0, im.w, im.h, x, y); x += im.w + 8; } y += Math.max(...r.map(i => i.h)) + 8; }
	L.writePng(path.join(out, "swaps.png"), sheet);
	console.log("swaps.png", W, H);
}
