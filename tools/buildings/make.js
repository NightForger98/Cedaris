// New building exteriors, composed from the tile sheets (TS_cottage house kit, TS_town) and the downloaded LPC packs
// (blacksmith, woodshop, containers in build/assets_dl). Not used in the game yet: they're sprites to place later.
//
//   node tools/buildings/make.js            write build/buildings/<name>.png and a contact sheet (all.png)
//   node tools/buildings/make.js --import   also import them as sprites in the Buildings folder
//
// The cottage kit holds each wall and roof in several colours, one block under another, so colours are swaps of
// whole blocks (like the room builder's swap): walls stone (rows 8-11) / cream (-4) / beige (-8, its top row -7); thatch brown (rows
// 7-13) / yellow (-7); windows lit (col 16, 19-20) / dark (+1, +2) / white (+2, +4).
const fs = require("fs");
const path = require("path");
const {execFileSync} = require("child_process");
const L = require("./lib.js");
const T = L.T;

const DL = "build/assets_dl/";
const SMITH = DL + "blacksmith/x/lpc-blacksmith/blacksmith-smelter.png";
const WOOD = DL + "woodshop/x/lpc-woodshop/woodshop.png";
const BOX = DL + "containers/x/container-v4_2/container.png";

const WALL_CREAM = {tileset: "TS_cottage", cols: [0, 15], rows: [8, 11], dRow: -4};
const WALL_BEIGE = [{tileset: "TS_cottage", cols: [0, 15], rows: [8, 8], dRow: -7}, {tileset: "TS_cottage", cols: [0, 15], rows: [9, 11], dRow: -8}];
const ROOF_YELLOW = {tileset: "TS_cottage", cols: [16, 31], rows: [7, 13], dRow: -7};
const WIN_DARK = [{tileset: "TS_cottage", cols: [16, 16], rows: [14, 15], dCol: 1}, {tileset: "TS_cottage", cols: [19, 20], rows: [14, 15], dCol: 2}];
const WIN_WHITE = [{tileset: "TS_cottage", cols: [16, 16], rows: [14, 15], dCol: 2}, {tileset: "TS_cottage", cols: [19, 20], rows: [14, 15], dCol: 4}];

// Props: [sheet, x, y, w, h] in pixels
const P = {
	furnace:   [SMITH, 384, 0, 128, 192],   // the round forge with the conical roof, lit
	oven:      [SMITH, 0, 129, 128, 127],   // a brick oven with its chimney
	anvil:     [SMITH, 331, 419, 46, 27],
	anvil_s:   [SMITH, 288, 421, 32, 24],
	trough:    [SMITH, 646, 432, 57, 38],
	coal:      [SMITH, 396, 200, 101, 44],
	toolbench: [SMITH, 322, 480, 61, 92],
	rack:      [SMITH, 384, 483, 63, 61],
	bench:     [WOOD, 97, 7, 95, 46],
	vise:      [WOOD, 15, 10, 77, 52],
	sawhorse:  [WOOD, 226, 64, 28, 32],
	saw_log:   [WOOD, 6, 184, 51, 36],
	toolboard: [WOOD, 128, 225, 96, 30],
	planks_up: [WOOD, 482, 352, 26, 32],
	planks:    [WOOD, 70, 385, 53, 28],
	planks2:   [WOOD, 136, 384, 47, 22],
	barrels3:  [BOX, 197, 5, 55, 50],
	barrel:    [BOX, 72, 1, 48, 61],
	crates:    [BOX, 0, 551, 63, 55],
	crate_row: [BOX, 0, 615, 128, 57],
	crate_pile:[BOX, 320, 677, 64, 55],
	crate:     [BOX, 458, 691, 38, 44],
	hay:       [BOX, 449, 749, 62, 51],
	sack:      [BOX, 225, 803, 29, 28],
	sacks:     [BOX, 97, 801, 61, 63],
	basket:    [BOX, 48, 801, 32, 31],
};
// Draw a prop with its bottom-left at pixel (x, bottom)
function prop(o, key, x, bottom, flip = false){ const [s, sx, sy, w, h] = P[key]; L.pixels(o, s, sx, sy, w, h, x, bottom - h, flip); }

// ---------------------------------------------------------------- the house shapes

// The farmhouse stamp's columns (13 wide, 10 tall), cut and remixed
const cut = cols => L.stampGrids("farmhouse").map(l => ({tileset: l.tileset, tiles: l.tiles.map(r => cols.map(c => r[c]))}));
// The narrow cottage: the farmhouse's middle gable on its own (5 x 10), its walls closed off at the sides
function narrow(){
	const n = cut([4, 5, 6, 7, 8]), w = n[0].tiles;
	for(const r of [5, 6, 8]){ w[r][0] = 288; w[r][4] = 290; }
	w[7][0] = 256; w[7][4] = 258; w[9][0] = 320; w[9][4] = 322;
	return n;
}
// With the small side gables (7 x 10)
const wings = () => cut([3, 4, 5, 6, 7, 8, 9]);
// The whole farmhouse (13 x 10); the stamp has a left gable piece on its right side, which left a notch
function farmhouse(){ const f = L.stampGrids("farmhouse"); f[0].tiles[6][11] = 357; return f; }

// ---------------------------------------------------------------- awnings for the market stalls

// A striped cloth awning w x h px at (x, y): stripes 16 wide, a scalloped hem, shading at the top and a shadow below
function awning(o, x, y, w, h, col, light = [238, 226, 200]){
	const set = (px, py, c, a = 255) => {
		if(px < 0 || py < 0 || px >= o.w || py >= o.h) return;
		const i = (py * o.w + px) * 4, b = a / 255;
		for(let k = 0; k < 3; k++) o.px[i + k] = Math.round(c[k] * b + o.px[i + k] * (1 - b) * (o.px[i + 3] / 255));
		o.px[i + 3] = Math.max(o.px[i + 3], a);
	};
	const shade = (c, f) => c.map(v => Math.max(0, Math.min(255, Math.round(v * f))));
	const outline = shade(col, 0.45);
	for(let j = 0; j < h + 6; j++) for(let i = 0; i < w; i++){
		const inset = Math.round(6 * (1 - j / h));           // narrower at the top: it slopes towards you
		if(j < h && (i < inset || i >= w - inset)) continue;
		const stripe = Math.floor((i - (w % 32) / 2) / 16) & 1, base = stripe ? light : col;
		const sx = (i % 16) - 7.5, hem = h + Math.round(4 * Math.sqrt(Math.max(0, 1 - (sx / 8) ** 2)));
		if(j >= hem) continue;
		let c = base;
		if(j < 3) c = shade(base, 0.7);                       // the fold at the top
		else if(j >= hem - 2) c = shade(base, 0.82);          // the hem
		if(i % 16 === 0 || i % 16 === 15) c = shade(c, 0.9);
		if(j === 0 || i === inset || i === w - inset - 1 || j === hem - 1) c = outline;
		set(x + i, y + j, c);
	}
	for(let i = 4; i < w - 4; i++) for(let j = 0; j < 3; j++) set(x + i, y + h + 5 + j, [20, 16, 12], 70 - j * 20);   // shadow
}
// A market stall: posts, the awning, a counter with wares
function stall(o, x, y, col, wares){
	const post = [92, 60, 36], dark = [58, 36, 22];
	for(const px of [x + 6, x + 118]) for(let j = y + 10; j < y + 112; j++) for(let i = 0; i < 5; i++){
		const c = (i === 0 || i === 4) ? dark : post, k = (j * o.w + px + i) * 4;
		o.px.set([...c, 255], k);
	}
	awning(o, x, y, 128, 30, col);
	prop(o, "bench", x + 16, y + 116);
	wares.forEach(([k, dx, dy]) => prop(o, k, x + dx, y + dy));
}

// ---------------------------------------------------------------- the buildings

const buildings = {
	// Houses from the cottage kit
	cottage_stone: {w: 5, h: 10, draw: o => L.grids(o, narrow(), 0, 0)},
	cottage_cream: {w: 5, h: 10, draw: o => L.grids(o, narrow(), 0, 0, [WALL_CREAM, ROOF_YELLOW, ...WIN_WHITE])},
	cottage_beige: {w: 5, h: 10, draw: o => L.grids(o, narrow(), 0, 0, [...WALL_BEIGE, ...WIN_DARK])},
	house_wings_beige: {w: 7, h: 10, draw: o => L.grids(o, wings(), 0, 0, [...WALL_BEIGE, ROOF_YELLOW])},
	house_wings_cream: {w: 7, h: 10, draw: o => L.grids(o, wings(), 0, 0, [WALL_CREAM, ...WIN_DARK])},
	house_long_beige: {w: 13, h: 10, draw: o => L.grids(o, farmhouse(), 0, 0, [...WALL_BEIGE, ROOF_YELLOW, ...WIN_DARK])},
	house_long_cream: {w: 13, h: 10, draw: o => L.grids(o, farmhouse(), 0, 0, [WALL_CREAM, ...WIN_WHITE])},
	// Three narrow houses in a row, each its own colours
	terrace: {w: 15, h: 10, draw: o => {
		L.grids(o, narrow(), 0, 0, [WALL_CREAM, ROOF_YELLOW, ...WIN_WHITE]);
		L.grids(o, narrow(), 5, 0);
		L.grids(o, narrow(), 10, 0, [...WALL_BEIGE, ...WIN_DARK]);
	}},

	// The smithy: a stone cottage, the round forge beside it, an anvil, the quench trough and the tool bench
	smithy: {w: 12, h: 10, draw: o => {
		prop(o, "furnace", 0, 312);
		L.grids(o, narrow(), 4, 0);
		L.tiles(o, "TS_town", 30, 10, 1, 1, 4.2, 6.6);                 // the sword sign
		prop(o, "toolbench", 318, 312);
		prop(o, "trough", 290, 322);
		prop(o, "anvil", 44, 320);
	}},
	// The carpenter's: a beige house with its workshop yard - bench, sawhorse with a log, lumber
	carpentry: {w: 11, h: 10, draw: o => {
		L.grids(o, wings(), 0, 0, [...WALL_BEIGE]);
		prop(o, "planks_up", 222, 318);
		prop(o, "saw_log", 250, 276);
		prop(o, "bench", 250, 320);
		prop(o, "planks", 296, 272);
		prop(o, "planks2", 300, 300);
	}},
	// The general store: the long cream house with crates, barrels and sacks out front, a coin-bag sign
	general_store: {w: 16, h: 10, draw: o => {
		L.grids(o, farmhouse(), 1.5, 0, [WALL_CREAM, ROOF_YELLOW]);
		L.tiles(o, "TS_town", 31, 10, 1, 1, 6.6, 6.6);
		prop(o, "crate_row", 0, 322);
		prop(o, "barrels3", 452, 320);
		prop(o, "sacks", 390, 322);
		prop(o, "crate", 128, 322);
	}},
	// A bakery: the cream cottage with a brick oven beside it, sacks of flour
	bakery: {w: 9, h: 10, draw: o => {
		prop(o, "oven", 150, 320);
		L.grids(o, narrow(), 0, 0, [WALL_CREAM, ...WIN_DARK]);
		prop(o, "sack", 160, 322); prop(o, "sack", 184, 322);
	}},

	// Market stalls: striped awnings in three colours
	stall_red: {w: 4.5, h: 4, draw: o => stall(o, 8, 8, [176, 48, 44], [["basket", 26, 76], ["sack", 62, 76], ["basket", 88, 76]])},
	stall_green: {w: 4.5, h: 4, draw: o => stall(o, 8, 8, [60, 128, 64], [["crate", 22, 76], ["basket", 66, 76], ["sack", 94, 76]])},
	stall_blue: {w: 4.5, h: 4, draw: o => stall(o, 8, 8, [52, 88, 160], [["sack", 24, 76], ["sack", 46, 76], ["crate", 80, 76]])},
	// A wide stall: two awnings, barrels and crates
	stall_wide: {w: 8.5, h: 4, draw: o => {
		stall(o, 8, 8, [196, 140, 40], [["basket", 26, 76], ["sack", 62, 76], ["basket", 88, 76]]);
		stall(o, 136, 8, [176, 48, 44], [["crate", 22, 76], ["basket", 66, 76], ["sack", 94, 76]]);
		prop(o, "barrel", 222, 128);
	}},

	// The chapel (for the temple): TS_town's castle pieces - a stone front with a ledge along the top, two pairs of
	// arched windows, the arched door with steps, pillars at the corners, and the blue spire at its side
	chapel: {w: 11, h: 11, draw: o => {
		const t = (c, r, w, h, x, y) => L.tiles(o, "TS_town", c, r, w, h, x, y);
		for(let y = 4; y < 11; y++) for(let x = 3; x < 11; x++) t(21, 26, 1, 1, x, y);
		for(let x = 3; x < 11; x++) t(21, 25, 1, 1, x, 3.5);
		t(23, 24, 3, 3, 3.5, 4.5); t(23, 24, 3, 3, 7.5, 4.5);
		t(21, 27, 2, 4, 6, 7);
		t(19, 25, 1, 4, 3, 6.6); t(19, 25, 1, 4, 10, 6.6);
		t(23, 30, 2, 1, 6, 10.6);
		t(16, 21, 3, 11, 0.6, 0);
	}},
};

function main(){
	const only = process.argv.slice(2).filter(a => !a.startsWith("--"));
	const out = path.join(__dirname, "../../build/buildings");
	fs.mkdirSync(out, {recursive: true});
	const made = [];
	for(const [name, b] of Object.entries(buildings)){
		if(only.length && !only.includes(name)) continue;
		const o = L.newImage(Math.ceil(b.w * T), Math.ceil(b.h * T));
		b.draw(o);
		const im = L.trim(o);
		L.writePng(path.join(out, name + ".png"), im);
		made.push([name, im]);
	}
	// The contact sheet: every building on grass, in rows
	const W = 1600, pad = 16;
	let x = pad, y = pad, rowH = 0;
	const spots = made.map(([n, im]) => { if(x + im.w > W){ x = pad; y += rowH + pad; rowH = 0; } const s = [x, y]; x += im.w + pad; rowH = Math.max(rowH, im.h); return s; });
	const sheet = L.newImage(W, y + rowH + pad, [62, 112, 54, 255]);
	made.forEach(([n, im], i) => L.draw(sheet, im, 0, 0, im.w, im.h, spots[i][0], spots[i][1]));
	L.writePng(path.join(out, "all.png"), sheet);
	console.log(made.map(([n, im]) => `${n} ${im.w}x${im.h}`).join("\n"));
	if(process.argv.includes("--import"))
		for(const [n] of made) execFileSync("node", [path.join(__dirname, "../sprite_import.js"), path.join(out, n + ".png"), "spr_bld_" + n, "Buildings"], {stdio: "inherit"});
}
main();
