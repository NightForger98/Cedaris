// Save a rectangle of a room's tile layers as a stamp the room builder can place (tools/rooms/stamps/<name>.json).
//
//   node tools/rooms/capture.js <room> <name> <col> <row> <w> <h> [layer,layer...]
//
// Each captured layer keeps its tileset; layers are listed bottom first. Also writes build/rooms/stamp_<name>.png.
const fs = require("fs");
const path = require("path");
const {root, readYy, decodeTiles, EMPTY} = require("./yy.js");
const {writePng, newImage, blit} = require("./png.js");
const {tilesetImage} = require("./render.js");

const [roomName, name, c, r, w, h, only] = process.argv.slice(2);
if(!h){ console.error("usage: node tools/rooms/capture.js <room> <name> <col> <row> <w> <h> [layers]"); process.exit(2); }
const C = +c, R = +r, W = +w, H = +h, pick = only ? only.split(",") : null;
const room = readYy(`rooms/${roomName}/${roomName}.yy`);
const all = [];
const walk = ls => ls.forEach(l => { all.push(l); walk(l.layers || []); });
walk(room.layers);
const layers = all.filter(l => l.resourceType === "GMRTileLayer" && l.tilesetId && (!pick || pick.includes(l.name))).sort((a, b) => b.depth - a.depth);

const stamp = {from: `${roomName} ${C},${R} ${W}x${H}`, w: W, h: H, layers: []};
for(const l of layers){
	const t = decodeTiles(l.tiles.TileCompressedData), lw = l.tiles.SerialiseWidth;
	const rows = [];
	let any = false;
	for(let y = 0; y < H; y++){
		const row = [];
		for(let x = 0; x < W; x++){
			const v = t[(R + y) * lw + C + x];
			const k = (v === EMPTY || v === undefined) ? 0 : v & 0x7FFFF;
			if(k) any = true;
			row.push(k);
		}
		rows.push(row);
	}
	if(any) stamp.layers.push({name: l.name, tileset: l.tilesetId.name, tiles: rows});
}
const dir = path.join(__dirname, "stamps");
fs.mkdirSync(dir, {recursive: true});
fs.writeFileSync(path.join(dir, name + ".json"), JSON.stringify(stamp, null, "\t").replace(/\[\s+([\d,\s]+?)\s+\]/g, (m, s) => "[" + s.replace(/\s+/g, " ") + "]") + "\n");

const img = newImage(W * 32, H * 32, [40, 40, 40, 255]);
for(const l of stamp.layers){
	const ts = tilesetImage(l.tileset);
	l.tiles.forEach((row, y) => row.forEach((k, x) => { if(k) blit(img, ts.img, (k % ts.cols) * 32, Math.floor(k / ts.cols) * 32, 32, 32, x * 32, y * 32); }));
}
fs.mkdirSync(path.join(root, "build", "rooms"), {recursive: true});
writePng(path.join(root, "build", "rooms", "stamp_" + name + ".png"), img);
console.log(name + ": " + stamp.layers.map(l => l.name).join(", "));
