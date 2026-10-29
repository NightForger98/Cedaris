// The building library: buildings cut from the packs' preview pictures, rebuilt without their ground by
// decompose.js (build/buildings/dec/<preview>.png; run tools/buildings/previews.sh first), packed into the tileset
// TS_buildings for the room builder.
//
//   node tools/buildings/library.js            cut them and write build/buildings/library.png (a look at them all)
//   node tools/buildings/library.js --tileset  also write spr_tile_buildings / TS_buildings and tools/rooms/buildings.json
//
// Each entry: from (the preview), box [x1, y1, x2, y2] in the preview's pixels (widened to its tile grid),
// door [x, y]: the pixel just inside the doorway at its foot (none: no way in), foot: how many rows at the bottom
// are solid (the rest draws over the player walking behind), and fixes:
//   tiles: [x1, y1, x2, y2] - take this part from the found tiles alone (an animal from another pack stood there)
//   erase: [x1, y1, x2, y2] - clear it (ground the rebuild kept)
//   add: [sheet, sx, sy, w, h, x, y] - draw a piece over it (a door where the preview shows none)
const fs = require("fs");
const path = require("path");
const L = require("./lib.js");
const T = 32;
const DEC = "build/buildings/dec/";
const COL = "art/lpc_colonial/colonial.png", TOWN = "TS_town";

const B = {
	// ---- Cottages, dressed with the medieval village decorations (preview-cottage)
	cottage_L:      {from: "preview-cottage", box: [85, 45, 440, 282], door: [174, 230], foot: 3},
	cottage_shop:   {from: "preview-cottage", box: [437, 4, 640, 282], door: [525, 272], foot: 3},
	cottage_twin:   {from: "preview-cottage", box: [757, 34, 1258, 252], door: [845, 240], foot: 3},
	cottage_small:  {from: "preview-cottage", box: [310, 304, 470, 502], door: [365, 490], foot: 3},
	cottage_long:   {from: "preview-cottage", box: [733, 304, 1070, 540], door: [830, 528], foot: 3},
	// ---- Cottages as the pack shows them, undressed (preview_280)
	plain_L:        {from: "preview_280", box: [200, 134, 512, 362], door: [290, 315], foot: 3},
	plain_tall:     {from: "preview_280", box: [553, 86, 740, 362], door: [643, 352], foot: 3},
	plain_small:    {from: "preview_280", box: [425, 386, 575, 586], door: [482, 575], foot: 3},
	plain_long:     {from: "preview_280", box: [873, 388, 1185, 618], door: [948, 605], foot: 3},
	// ---- Colonial (Brindlemoor)
	brick_hip:      {from: "preview-1_5", box: [68, 176, 232, 404], door: [150, 385], foot: 3},
	brick_gable:    {from: "preview-1_5", box: [262, 2, 422, 276], door: [342, 258], foot: 3, erase: [[350, 255, 400, 300]]},
	brick_small:    {from: "preview-1_5", box: [452, 80, 615, 276], door: [518, 258], foot: 3},
	brick_wide:     {from: "preview-1_5", box: [580, 300, 742, 466], door: [662, 450], foot: 3},
	brick_market:   {from: "preview-1_5", box: [210, 414, 455, 628], door: [357, 610], foot: 3},
	clapboard:      {from: "preview-3_2", box: [390, 134, 650, 364], door: [520, 355], foot: 3},
	brick_bay:      {from: "preview-4", box: [65, 68, 320, 290], door: [192, 285], foot: 3,
	                 add: [[COL, 0, 704, 32, 64, 176, 232]]},
	brick_hall:     {from: "preview-4", box: [352, 22, 642, 300], door: [497, 290], foot: 3,
	                 add: [[COL, 0, 704, 32, 64, 465, 232], [COL, 0, 704, 32, 64, 497, 232]]},
	clock_tower:    {from: "preview-4", box: [65, 278, 130, 586], door: [97, 565], foot: 2, erase: [[100, 260, 140, 300]]},
	brick_arch:     {from: "preview-4", box: [352, 374, 578, 746], door: [465, 712], foot: 4},
	church:         {from: "preview-2_3", box: [15, 8, 435, 748], door: [225, 690], foot: 5},
	// ---- Farm
	barn:           {from: "farm-preview", box: [128, 94, 515, 460], door: [315, 448], foot: 4,
	                 tiles: [[290, 390, 345, 458], [462, 352, 548, 425]], erase: [[100, 380, 162, 520], [100, 200, 130, 400], [120, 90, 150, 190], [440, 90, 550, 250]]},
	silo:           {from: "farm-preview", box: [62, 204, 127, 384], foot: 3, erase: [[0, 350, 62, 420], [127, 100, 200, 420]]},
	shed:           {from: "farm-preview", box: [30, 384, 162, 516], foot: 2, erase: [[0, 350, 30, 420], [150, 380, 200, 450], [150, 500, 200, 540]]},
	bee_shed:       {from: "farm-preview", box: [543, 158, 673, 290], foot: 2},
	coop:           {from: "farm-preview", box: [555, 318, 792, 514], door: [712, 455], foot: 4,
	                 tiles: [[635, 375, 720, 405], [660, 445, 708, 490]]},
	granary:        {from: "farm-preview", box: [863, 270, 993, 514], foot: 3, erase: [[830, 250, 870, 380]]},
	windmill:       {from: "farm-preview", box: [122, 510, 262, 866], foot: 4, erase: [[90, 470, 170, 512]]},
	watermill:      {from: "farm-preview", box: [565, 560, 745, 800], foot: 4},
	outhouse:       {from: "farm-preview", box: [103, 98, 152, 190], foot: 1},
	// ---- Market and village pieces (preview-market, preview-cottage)
	stall_stripe:   {from: "preview-market", box: [415, 136, 545, 270], foot: 2},
	stall_white:    {from: "preview-market", box: [255, 134, 322, 270], foot: 2},
	stall_green:    {from: "preview-market", box: [543, 232, 642, 364], foot: 2},
	stall_blue:     {from: "preview-market", box: [125, 232, 225, 376], foot: 2},
	stall_cart:     {from: "preview-market", box: [135, 104, 250, 212], foot: 2},
	fruit_table:    {from: "preview-market", box: [258, 362, 318, 410], foot: 1},
	obelisk:        {from: "preview-market", box: [333, 204, 410, 342], foot: 2},
	well:           {from: "preview-cottage", box: [573, 338, 640, 440], foot: 2},
	wagon:          {from: "preview-cottage", box: [1125, 274, 1240, 382], foot: 2},
	doghouse:       {from: "preview-cottage", box: [1083, 416, 1150, 532], foot: 2},
	hay_roll:       {from: "preview-cottage", box: [1155, 444, 1212, 528], foot: 1},
};

// Cut one building: its box widened to the preview's grid, with its fixes
function cut(name){
	const b = B[name], json = JSON.parse(fs.readFileSync(DEC + b.from + ".json", "utf8"));
	const full = L.readPng(DEC + b.from + ".png"), tilesOnly = L.readPng(DEC + b.from + "_tiles.png");
	const g = v => ({x: Math.floor((v[0] - json.ox) / T) * T + json.ox, y: Math.floor((v[1] - json.oy) / T) * T + json.oy});
	const a = g([b.box[0], b.box[1]]), z = g([b.box[2] + T - 1, b.box[3] + T - 1]);
	const w = z.x - a.x, h = z.y - a.y, o = L.newImage(w, h);
	L.draw(o, full, a.x, a.y, w, h, 0, 0);
	const clear = ([x1, y1, x2, y2]) => { for(let y = y1; y < y2; y++) for(let x = x1; x < x2; x++){ const X = x - a.x, Y = y - a.y; if(X >= 0 && Y >= 0 && X < w && Y < h) o.px.fill(0, (Y * w + X) * 4, (Y * w + X) * 4 + 4); } };
	for(const r of b.tiles || []){ clear(r); L.draw(o, tilesOnly, r[0], r[1], r[2] - r[0], r[3] - r[1], r[0] - a.x, r[1] - a.y); }
	for(const r of b.erase || []) clear(r);
	for(const [s, sx, sy, sw, sh, x, y] of b.add || []) L.pixels(o, s, sx, sy, sw, sh, x - a.x, y - a.y);
	// Drop empty rows and columns of whole tiles at the edges
	const emptyCol = c => { for(let y = 0; y < h; y++) for(let x = c * T; x < c * T + T; x++) if(o.px[(y * w + x) * 4 + 3]) return false; return true; };
	const emptyRow = r => { for(let y = r * T; y < r * T + T; y++) for(let x = 0; x < w; x++) if(o.px[(y * w + x) * 4 + 3]) return false; return true; };
	let c0 = 0, c1 = w / T - 1, r0 = 0, r1 = h / T - 1;
	while(c0 < c1 && emptyCol(c0)) c0++;
	while(c1 > c0 && emptyCol(c1)) c1--;
	while(r0 < r1 && emptyRow(r0)) r0++;
	while(r1 > r0 && emptyRow(r1)) r1--;
	const img = L.newImage((c1 - c0 + 1) * T, (r1 - r0 + 1) * T);
	L.draw(img, o, c0 * T, r0 * T, img.w, img.h, 0, 0);
	const left = a.x + c0 * T, top = a.y + r0 * T;
	const door = b.door ? [Math.floor((b.door[0] - left) / T), Math.floor((b.door[1] - top) / T)] : null;
	return {name, img, w: img.w / T, h: img.h / T, door, foot: b.foot};
}

function main(){
	const all = Object.keys(B).map(cut);
	// A look at them all, with each door cell marked
	const W = 2000, pad = 12;
	let x = pad, y = pad, rowH = 0;
	const spots = all.map(b => { if(x + b.img.w > W){ x = pad; y += rowH + pad; rowH = 0; } const s = [x, y]; x += b.img.w + pad; rowH = Math.max(rowH, b.img.h); return s; });
	const sheet = L.newImage(W, y + rowH + pad, [62, 112, 54, 255]);
	all.forEach((b, i) => {
		L.draw(sheet, b.img, 0, 0, b.img.w, b.img.h, spots[i][0], spots[i][1]);
		if(b.door) for(let k = 0; k < T; k++){
			const px = spots[i][0] + b.door[0] * T, py = spots[i][1] + b.door[1] * T;
			for(const [dx, dy] of [[k, 0], [k, T - 1], [0, k], [T - 1, k]]) sheet.px.set([255, 40, 200, 255], ((py + dy) * W + px + dx) * 4);
		}
	});
	L.writePng("build/buildings/library.png", sheet);
	console.log(all.map(b => `${b.name} ${b.w}x${b.h}${b.door ? " door " + b.door : ""}`).join("\n"));
	if(process.argv.includes("--tileset")) require("./tileset.js")(all);
}
module.exports = {B, cut};
if(require.main === module) main();
