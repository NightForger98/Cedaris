// Render a room's tile layers (and outlines of its instances) to a PNG, to check a layout without running the game.
//
//   node tools/rooms/render.js <room> [out.png] [--no-instances] [--scale 0.5]
//
// Instances show as outlines: blue for collision boxes, cyan for water, yellow for exits, red for the rest.
const fs = require("fs");
const path = require("path");
const {readPng, writePng, newImage, blit} = require("./png.js");
const {root, readYy, decodeTiles, EMPTY} = require("./yy.js");

const sheets = {};
function tilesetImage(name){
	if(sheets[name]) return sheets[name];
	const ts = readYy(`tilesets/${name}/${name}.yy`);
	const spr = readYy(`sprites/${ts.spriteId.name}/${ts.spriteId.name}.yy`);
	const img = readPng(path.join(root, "sprites", ts.spriteId.name, spr.frames[0].name + ".png"));
	return sheets[name] = {img, cols: Math.floor(img.w / ts.tileWidth), tw: ts.tileWidth, th: ts.tileHeight};
}

// A sprite's first frame
const spriteImages = {};
function spriteImage(name){
	if(spriteImages[name]) return spriteImages[name];
	const spr = readYy(`sprites/${name}/${name}.yy`);
	return spriteImages[name] = readPng(path.join(root, "sprites", name, spr.frames[0].name + ".png"));
}

// Tile data bits: 0-18 the index, 28 mirror, 29 flip, 30 rotate (only the index is used by these rooms)
function renderRoom(roomName, opts = {}){
	const room = typeof roomName === "string" ? readYy(`rooms/${roomName}/${roomName}.yy`) : roomName;
	const W = room.roomSettings.Width, H = room.roomSettings.Height;
	const out = newImage(W, H, [0, 0, 0, 255]);
	const layers = [];
	const walk = (ls) => ls.forEach(l => { layers.push(l); walk(l.layers || []); });
	walk(room.layers);
	layers.filter(l => l.visible !== false).sort((a, b) => b.depth - a.depth).forEach(l => {
		if(l.resourceType !== "GMRTileLayer" || !l.tilesetId || l.name === "Collision") return;
		const ts = tilesetImage(l.tilesetId.name), t = decodeTiles(l.tiles.TileCompressedData), w = l.tiles.SerialiseWidth;
		t.forEach((v, i) => {
			if(v === EMPTY || v === 0) return;
			const k = v & 0x7FFFF;
			blit(out, ts.img, (k % ts.cols) * ts.tw, Math.floor(k / ts.cols) * ts.th, ts.tw, ts.th, (i % w) * ts.tw + (l.x || 0), Math.floor(i / w) * ts.th + (l.y || 0));
		});
	});
	// Sprite buildings and drawn doors (obj_building, obj_door_art), over the tiles, the nearer (lower) ones last
	if(typeof roomName === "string"){
		const drawn = [];
		layers.filter(l => l.resourceType === "GMRInstanceLayer").forEach(l => l.instances.forEach(inst => {
			const o = inst.objectId.name;
			if(o === "obj_door_art") drawn.push({spr: "spr_door_brick", x: inst.x, y: inst.y, sort: inst.y + 48});
			if(o === "obj_placeholder") drawn.push({box: true, x: inst.x, y: inst.y, sort: inst.y, name: inst.name});
			if(o !== "obj_building") return;
			const f = path.join(root, "rooms", roomName, "InstanceCreationCode_" + inst.name + ".gml");
			const m = fs.existsSync(f) && fs.readFileSync(f, "utf8").match(/sprite_index = (spr_\w+)/);
			if(m){ const img = spriteImage(m[1]); drawn.push({spr: m[1], x: inst.x, y: inst.y - img.h, sort: inst.y}); }
		}));
		drawn.sort((a, b) => a.sort - b.sort).forEach(d => {
			if(d.box){
				const f = path.join(root, "rooms", roomName, "InstanceCreationCode_" + d.name + ".gml"), s = fs.existsSync(f) ? fs.readFileSync(f, "utf8") : "";
				const bw = +(s.match(/boxW = (\d+)/) || [0, 64])[1], bh = +(s.match(/boxH = (\d+)/) || [0, 64])[1];
				for(let y = 0; y < bh; y++) for(let x = 0; x < bw; x++){
					const edge = x < 2 || y < 2 || x >= bw - 2 || y >= bh - 2, o = ((d.y - bh + y) * out.w + d.x + x) * 4;
					if(d.x + x < 0 || d.y - bh + y < 0 || d.x + x >= out.w || d.y - bh + y >= out.h) continue;
					const c = edge ? [250, 220, 90] : [150, 110, 190];
					for(let k = 0; k < 3; k++) out.px[o + k] = edge ? c[k] : Math.round(out.px[o + k] * 0.5 + c[k] * 0.5);
				}
				return;
			}
			const img = spriteImage(d.spr); blit(out, img, 0, 0, img.w, img.h, Math.round(d.x), Math.round(d.y)); });
	}
	if(opts.instances !== false){
		layers.filter(l => l.resourceType === "GMRInstanceLayer").forEach(l => l.instances.forEach(inst => {
			const o = inst.objectId.name;
			const col = o === "obj_col_box" ? [60, 120, 255] : o === "obj_water_zone" ? [0, 255, 255] : o === "obj_transition" ? [255, 230, 0] : [255, 40, 40];
			// Collision-check-sized objects are 16x16 centred; others get a small marker
			const sized = ["obj_col_box", "obj_water_zone", "obj_transition"].includes(o);
			const w = sized ? 16 * inst.scaleX : 12, h = sized ? 16 * inst.scaleY : 12;
			const x0 = Math.round(inst.x - w / 2), y0 = Math.round(inst.y - h / 2);
			rect(out, x0, y0, w, h, col);
		}));
	}
	return out;
}

function rect(img, x, y, w, h, c){
	const put = (px, py) => { if(px >= 0 && py >= 0 && px < img.w && py < img.h) img.px.set([...c, 255], (py * img.w + px) * 4); };
	for(let i = 0; i < w; i++){ put(x + i, y); put(x + i, y + h - 1); }
	for(let j = 0; j < h; j++){ put(x, y + j); put(x + w - 1, y + j); }
}

function scaleImage(img, s){
	const w = Math.max(1, Math.round(img.w * s)), h = Math.max(1, Math.round(img.h * s)), out = newImage(w, h);
	for(let y = 0; y < h; y++) for(let x = 0; x < w; x++){
		const o = (Math.min(img.h - 1, Math.floor(y / s)) * img.w + Math.min(img.w - 1, Math.floor(x / s))) * 4;
		img.px.copy(out.px, (y * w + x) * 4, o, o + 4);
	}
	return out;
}

if(require.main === module){
	const args = process.argv.slice(2);
	const name = args[0];
	if(!name){ console.error("usage: node tools/rooms/render.js <room> [out.png] [--no-instances] [--scale s]"); process.exit(2); }
	const out = args[1] && !args[1].startsWith("--") ? args[1] : path.join(root, "build", "rooms", name + ".png");
	const si = args.indexOf("--scale");
	let img = renderRoom(name, {instances: !args.includes("--no-instances")});
	if(si >= 0) img = scaleImage(img, +args[si + 1]);
	fs.mkdirSync(path.dirname(out), {recursive: true});
	writePng(out, img);
	console.log(out);
}

module.exports = {renderRoom, scaleImage, tilesetImage};
