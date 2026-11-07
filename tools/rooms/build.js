// Build a room from a spec in tools/rooms/specs/<room>.js: a text map of the ground, things placed on it (buildings,
// trees, props), instances, and named spots. Writes rooms/<room>/<room>.yy (tile layers, collision boxes, water
// zones, instances), regenerates scripts/room_layout and scripts/room_walk (where villagers can walk, see walk.js),
// and renders build/rooms/<room>.png to check the result.
//
//   node tools/rooms/build.js rm_1 [rm_2 ...]      (or "all")
//
// See "Room builder" in CLAUDE.md for the spec format.
const fs = require("fs");
const path = require("path");
const crypto = require("crypto");
const {root, readYy, writeYy, encodeTiles, EMPTY} = require("./yy.js");
const {writePng} = require("./png.js");
const {renderRoom, tilesetImage} = require("./render.js");
const T = require("./tiles.js");

const CELL = 32;

// Small seeded RNG so a spec always builds the same room
function rng(seed){
	let s = seed >>> 0 || 1;
	return () => { s ^= s << 13; s >>>= 0; s ^= s >> 17; s ^= s << 5; s >>>= 0; return s / 4294967296; };
}

function tileIndex(tileset, c, r){ return r * tilesetImage(tileset).cols + c; }

// ---------------------------------------------------------------- tile layers

// Layers are made on demand: a role (where it sits against the player) and a tileset. A placement that would
// overwrite a tile goes onto the next layer of the same role, so overlapping things stack.
const ROLE_DEPTH = {above: 600, buildings: 1200, decor: 1300, scatter: 1350, soil: 1400, terrain: 1500, ground: 1600};   // scatter: leaves and sprouts (hidden in winter, scripts/ground)

class Layers {
	constructor(W, H){ this.W = W; this.H = H; this.list = []; }
	get(role, tileset, k = 0, name){
		let l = this.list.find(l => l.role === role && l.tileset === tileset && l.k === k && (!name || l.name === name));
		if(!l){
			l = {role, tileset, k, name: name || `${role}_${tileset.replace("TS_", "")}_${k}`, tiles: new Array(this.W * this.H).fill(0), order: this.list.length};
			this.list.push(l);
		}
		return l;
	}
	// Put a block of tile indices (0 = none) at a cell, on the first layer of the role where it fits
	put(role, tileset, grid, c0, r0){
		for(let k = 0; ; k++){
			const l = this.get(role, tileset, k);
			let fits = true;
			grid.forEach((row, y) => row.forEach((t, x) => {
				const cx = c0 + x, cy = r0 + y;
				if(t && cx >= 0 && cy >= 0 && cx < this.W && cy < this.H && l.tiles[cy * this.W + cx]) fits = false;
			}));
			if(!fits) continue;
			grid.forEach((row, y) => row.forEach((t, x) => {
				const cx = c0 + x, cy = r0 + y;
				if(t && cx >= 0 && cy >= 0 && cx < this.W && cy < this.H) l.tiles[cy * this.W + cx] = t;
			}));
			return;
		}
	}
}

// LPC terrain blocks (3 wide, 6 tall): rows 0-1 an inner-corner piece (cols 1-2), rows 2-4 the outer 3x3, row 5 fills.
// A terrain cell picks its tile from which of its 8 neighbours are the same terrain (the room's edge counts as same).
function autotile(def, has, W, H, rand){
	const [bc, br] = def.block, out = new Array(W * H).fill(0);
	const fills = def.fill || [[bc + 1, br + 3]];
	for(let y = 0; y < H; y++) for(let x = 0; x < W; x++){
		if(!has(x, y)) continue;
		const at = (dx, dy) => { const nx = x + dx, ny = y + dy; return nx < 0 || ny < 0 || nx >= W || ny >= H || has(nx, ny); };
		const n = at(0, -1), s = at(0, 1), w = at(-1, 0), e = at(1, 0);
		let c, r;
		if(!n && !w){ c = bc; r = br + 2; }
		else if(!n && !e){ c = bc + 2; r = br + 2; }
		else if(!s && !w){ c = bc; r = br + 4; }
		else if(!s && !e){ c = bc + 2; r = br + 4; }
		else if(!n){ c = bc + 1; r = br + 2; }
		else if(!s){ c = bc + 1; r = br + 4; }
		else if(!w){ c = bc; r = br + 3; }
		else if(!e){ c = bc + 2; r = br + 3; }
		else if(!at(1, 1)){ c = bc + 1; r = br; }
		else if(!at(-1, 1)){ c = bc + 2; r = br; }
		else if(!at(1, -1)){ c = bc + 1; r = br + 1; }
		else if(!at(-1, -1)){ c = bc + 2; r = br + 1; }
		else [c, r] = fills[Math.floor(rand() * fills.length)];
		out[y * W + x] = tileIndex(def.tileset, c, r);
	}
	return out;
}

// ---------------------------------------------------------------- the outdoor ground (dual grid)

// spec.ground: a map of terrain letters (one a cell). The tiles sit on the corners where four cells meet - a layer one
// cell wider and taller, half a cell up and left - and each shows those four cells' terrains. (A PixelLab version
// of this, 2026-11-06, was dropped for the LPC Revised art: its tiles looked like blocks; art/terrain_pl.)
// The LPC Revised ground (art/lpc_revised, TS_lpcr_<season>): its corner table (tools/map/lpcr_wang.js) gives, for
// any four corner terrains, the tiles that draw them (a random one of the variants). Letters: g grass, d dirt (lanes and
// under the roads - the old dark road autotiles over it), s sand, w shallow water, D deep water; rock, snow, trail and
// concrete fall back to dirt.
const LPCR_OF = {g: "grass", d: "dirt", r: "dirt", t: "dirt", c: "dirt", k: "dirt", n: "dirt", s: "sand", w: "shallow_water", D: "deep_water"};
const LPCR_GIVE = {deep_water: "shallow_water", shallow_water: "sand", sand: "grass", dirt: "grass"};
let LPCR = null;
function lpcrGround(spec, W, H, rand){
	if(!LPCR){
		const t = JSON.parse(fs.readFileSync(path.join(root, "art", "lpc_revised", "wang.json"), "utf8")), by = {};
		for(const x of t.tiles) if(x.c.every(c => c)) (by[x.c.join(",")] = by[x.c.join(",")] || []).push(x.id);
		LPCR = by;
	}
	const rows = spec.ground.rows;
	const terr = (x, y) => LPCR_OF[(rows[Math.max(0, Math.min(H - 1, y))] || "")[Math.max(0, Math.min(W - 1, x))]] || "grass";
	const tiles = new Array((W + 1) * (H + 1)).fill(0);
	let gave = 0;
	for(let y = 0; y <= H; y++) for(let x = 0; x <= W; x++){
		let c = [terr(x - 1, y - 1), terr(x, y - 1), terr(x - 1, y), terr(x, y)];
		// grass, dirt and water at one corner: the grass gives way (a muddy bank all along, not a notch)
		if(!LPCR[c.join(",")] && c.includes("dirt") && c.includes("grass") && (c.includes("shallow_water") || c.includes("deep_water"))) c = c.map(t => t === "grass" ? "dirt" : t);
		for(let g = 0; g < 10 && !LPCR[c.join(",")]; g++){
			const u = [...new Set(c)], victim = u.sort((a, b) => c.filter(t => t === a).length - c.filter(t => t === b).length)[0];
			c = c.map(t => t === victim ? (LPCR_GIVE[victim] || "grass") : t); gave++;
		}
		const opts = LPCR[c.join(",")] || LPCR["grass,grass,grass,grass"];
		// mostly the first (plainest) variant, now and then another
		tiles[y * (W + 1) + x] = (rand() < 0.75 ? opts[0] : opts[Math.floor(rand() * opts.length)]) || EMPTY;
	}
	return {role: "ground", tileset: spec.ground.tileset, k: 0, name: "Ground", tiles, order: -1, w: W + 1, h: H + 1, x: -16, y: -16, gave};
}

function groundLayer(spec, W, H, rand){ return lpcrGround(spec, W, H, rand); }

// ---------------------------------------------------------------- things

// A thing is a stamp (tools/rooms/stamps/<name>.json) or a rectangle of a tileset, with how many of its top rows
// draw over the player ("above") and which cells block movement ("solid": [dx, dy, w, h] rects inside it).
function thingGrids(def){
	// A sprite building (tools/rooms/sprite_buildings.js) has no tiles: build() places an obj_building for it
	if(def.sprite || def.placeholder) return {w: def.src[2], h: def.src[3], layers: []};
	if(def.stamp){
		const st = JSON.parse(fs.readFileSync(path.join(__dirname, "stamps", def.stamp + ".json"), "utf8"));
		// crop: [x, y, w, h], a part of the stamp
		const [cx, cy, cw, ch] = def.crop || [0, 0, st.w, st.h];
		const layers = st.layers.map(l => ({tileset: l.tileset,
			tiles: l.tiles.slice(cy, cy + ch).map(row => row.slice(cx, cx + cw).map(k => k ? swapTile(def, l.tileset, k) : 0))}))
			.filter(l => l.tiles.some(row => row.some(k => k)));
		return {w: cw, h: ch, layers};
	}
	const [c, r, w, h] = def.src, ts = def.tileset || "TS_terrain";
	const tiles = [];
	for(let y = 0; y < h; y++){
		const row = [];
		for(let x = 0; x < w; x++) row.push((def.skip || []).some(([sx, sy]) => sx === x && sy === y) ? 0 : tileIndex(ts, c + x, r + y));
		tiles.push(row);
	}
	// repeat: [nx, ny] tiles the rectangle (a pier of planks, a long fence)
	const [nx, ny] = def.repeat || [1, 1];
	const big = [];
	for(let j = 0; j < h * ny; j++) big.push(Array.from({length: w * nx}, (_, i) => tiles[j % h][i % w]));
	return {w: w * nx, h: h * ny, layers: [{tileset: ts, tiles: big}]};
}

// Recolour a stamp by moving tiles in a block of the tileset by some rows (the cottage kit repeats its walls and
// roofs in several colours, one under another): swap: [{cols: [c1, c2], rows: [r1, r2], dRow}]
function swapTile(def, tileset, k){
	const cols = tilesetImage(tileset).cols, c = k % cols, r = Math.floor(k / cols);
	for(const s of def.swap || []){
		if(s.tileset && s.tileset !== tileset) continue;
		if(c >= s.cols[0] && c <= s.cols[1] && r >= s.rows[0] && r <= s.rows[1]) return (r + s.dRow) * cols + c;
	}
	return k;
}

// ---------------------------------------------------------------- collision

// Merge solid cells into as few rectangles as possible: runs along a row, grown down while the next row matches
function mergeRects(grid, W, H){
	const used = new Uint8Array(W * H), out = [];
	for(let y = 0; y < H; y++) for(let x = 0; x < W; x++){
		if(!grid[y * W + x] || used[y * W + x]) continue;
		let w = 1;
		while(x + w < W && grid[y * W + x + w] && !used[y * W + x + w]) w++;
		let h = 1;
		for(;;){
			if(y + h >= H) break;
			let ok = true;
			for(let i = 0; i < w; i++) if(!grid[(y + h) * W + x + i] || used[(y + h) * W + x + i]){ ok = false; break; }
			if(!ok) break;
			h++;
		}
		for(let j = 0; j < h; j++) for(let i = 0; i < w; i++) used[(y + j) * W + x + i] = 1;
		out.push([x, y, w, h]);
	}
	return out;
}

// ---------------------------------------------------------------- the room file

let instCount = 0;
function instName(room, i){
	return "inst_" + crypto.createHash("md5").update(room + ":" + i).digest("hex").slice(0, 8).toUpperCase();
}

function instance(room, obj, x, y, sx = 1, sy = 1, code = ""){
	const name = instName(room, instCount++);
	return {"$GMRInstance": "v4", "%Name": name, colour: 4294967295, frozen: false, hasCreationCode: !!code, ignore: false, imageIndex: 0,
		imageSpeed: 1, inheritCode: false, inheritedItemId: null, inheritItemSettings: false, isDnd: false, name,
		objectId: {name: obj, path: `objects/${obj}/${obj}.yy`}, properties: [], resourceType: "GMRInstance", resourceVersion: "2.0",
		rotation: 0, scaleX: sx, scaleY: sy, x, y, _code: code};
}

function layerBase(type, name, depth, visible = true){
	return {[`$${type}`]: "", "%Name": name, depth, effectEnabled: true, effectType: null, gridX: 32, gridY: 32, hierarchyFrozen: false,
		inheritLayerDepth: false, inheritLayerSettings: false, inheritSubLayers: true, inheritVisibility: true, layers: [], name,
		properties: [], resourceType: type, resourceVersion: "2.0", userdefinedDepth: true, visible};
}

function build(roomName, opts = {}){
	const spec = opts.spec || require(path.join(__dirname, "specs", roomName + ".js"));
	const map = spec.map.map(s => s.replace(/\s+$/, ""));
	const H = map.length, W = Math.max(...map.map(s => s.length));
	const rand = rng(spec.seed || 1);
	const legend = Object.assign({}, T.legend, spec.legend || {});
	const charAt = (x, y) => (map[y] && map[y][x]) || spec.pad || ".";
	const cellDef = (x, y) => {
		const d = legend[charAt(x, y)];
		if(!d) throw new Error(`${roomName}: no legend for "${charAt(x, y)}" at ${x},${y}`);
		return d;
	};

	const layers = new Layers(W, H);
	const solid = new Uint8Array(W * H), water = new Uint8Array(W * H), busy = new Uint8Array(W * H);

	// Ground: the base terrain everywhere, then each terrain over it, in the order of T.terrains
	// (base: "none" for interiors, whose floors come with their stamps)
	if(spec.ground){
		// the PixelLab ground in place of the LPC terrain (the legend still gives walls and water)
		const gl = groundLayer(spec, W, H, rand);
		layers.list.push(gl);
	} else if(spec.base !== "none"){
		const base = T.terrains[spec.base || "grass"];
		const g = layers.get("ground", base.tileset, 0, "Ground");
		const bf = base.fill || [[base.block[0] + 1, base.block[1] + 3]];
		for(let i = 0; i < W * H; i++){ const [c, r] = bf[Math.floor(rand() * bf.length)]; g.tiles[i] = tileIndex(base.tileset, c, r); }
	}
	Object.entries(T.terrains).forEach(([tname, def], ti) => {
		if((spec.ground && !(spec.ground.overlay || []).includes(tname)) || tname === (spec.base || "grass")) return;
		const has = (x, y) => (cellDef(x, y).terrain || "") === tname || (cellDef(x, y).under || []).includes(tname);
		let any = false;
		for(let y = 0; y < H && !any; y++) for(let x = 0; x < W; x++) if(has(x, y)){ any = true; break; }
		if(!any) return;
		const lname = def.layer || ("Ground_" + tname);
		const l = layers.get(def.role || "terrain", def.tileset, ti, lname);
		l.tiles = autotile(def, has, W, H, rand);
	});
	for(let y = 0; y < H; y++) for(let x = 0; x < W; x++){
		const d = cellDef(x, y);
		if(d.solid) solid[y * W + x] = 1;
		if(d.water) water[y * W + x] = 1;
		if(d.terrain === "water" || d.terrain === "soil" || d.busy) busy[y * W + x] = 1;
	}

	// Things: buildings, trees, props
	const things = [];
	for(const t of spec.things || []){
		const def = Object.assign({}, typeof t.is === "string" ? T.things[t.is] : {}, t);
		if(typeof t.is === "string" && !T.things[t.is]) throw new Error(`${roomName}: unknown thing "${t.is}"`);
		things.push(def);
	}
	const spriteThings = [];
	for(const def of things){
		const [c0, r0] = def.at, gr = thingGrids(def), above = def.above || 0;
		// Its sprite's bottom on the box's bottom edge (obj_building draws up from its y, and depth-sorts by it)
		// A placeholder (a landmark without art yet): obj_placeholder draws a labelled box over its cells
		if(def.placeholder) spriteThings.push({obj: "obj_placeholder", x: c0 * CELL, y: (r0 + gr.h) * CELL,
			code: `label = "${def.placeholder}";
boxW = ${gr.w * CELL};
boxH = ${gr.h * CELL};`});
		if(def.sprite) spriteThings.push({obj: "obj_building", x: c0 * CELL + def.ox, y: (r0 + gr.h) * CELL, code: `sprite_index = ${def.sprite};`});
		gr.layers.forEach(l => {
			const below = l.tiles.map((row, y) => y < above ? row.map(() => 0) : row);
			const over = l.tiles.map((row, y) => y < above ? row : row.map(() => 0));
			layers.put(def.role || "buildings", l.tileset, below, c0, r0);
			if(above) layers.put("above", l.tileset, over, c0, r0);
		});
		for(const [dx, dy, w, h] of (def.solid || [])) for(let y = 0; y < h; y++) for(let x = 0; x < w; x++){
			const cx = c0 + dx + x, cy = r0 + dy + y;
			if(cx >= 0 && cy >= 0 && cx < W && cy < H) solid[cy * W + cx] = 1;
		}
		for(let y = 0; y < gr.h; y++) for(let x = 0; x < gr.w; x++){
			const cx = c0 + x, cy = r0 + y;
			if(cx >= 0 && cy >= 0 && cx < W && cy < H) busy[cy * W + cx] = 1;
		}
	}

	// Scatter: small decorations on free cells of some ground chars
	for(const sc of spec.scatter || []){
		const r2 = rng(sc.seed || 7);
		const total = sc.pieces.reduce((a, p) => a + (p.weight || 1), 0);
		for(let y = 0; y < H; y++) for(let x = 0; x < W; x++){
			if(!sc.on.includes(charAt(x, y)) || busy[y * W + x] || solid[y * W + x] || r2() > sc.density) continue;
			let pick = r2() * total, p = sc.pieces[0];
			for(const q of sc.pieces){ pick -= (q.weight || 1); if(pick <= 0){ p = q; break; } }
			const def = Object.assign({}, typeof p.is === "string" ? T.things[p.is] : {}, p);
			const gr = thingGrids(def);
			let free = true;
			for(let j = 0; j < gr.h; j++) for(let i = 0; i < gr.w; i++){
				const cx = x + i, cy = y + j;
				if(cx >= W || cy >= H || busy[cy * W + cx] || solid[cy * W + cx] || !sc.on.includes(charAt(cx, cy))) free = false;
			}
			if(!free) continue;
			gr.layers.forEach(l => layers.put(spec.ground ? "scatter" : (def.role || "decor"), l.tileset, l.tiles, x, y));
			for(let j = 0; j < gr.h; j++) for(let i = 0; i < gr.w; i++) busy[(y + j) * W + x + i] = 1;
		}
	}

	// Instances: collision boxes (merged), water zones, a wall around the room, then the spec's own
	instCount = 0;
	const cols = [], insts = [];
	for(const [x, y, w, h] of mergeRects(solid, W, H))
		cols.push(instance(roomName, "obj_col_box", (x + w / 2) * CELL, (y + h / 2) * CELL, w * 2, h * 2));
	const border = [[-1, -1, W + 2, 1], [-1, H, W + 2, 1], [-1, 0, 1, H], [W, 0, 1, H]];
	for(const [x, y, w, h] of border) cols.push(instance(roomName, "obj_col_box", (x + w / 2) * CELL, (y + h / 2) * CELL, w * 2, h * 2));
	for(const [x, y, w, h] of mergeRects(water, W, H))
		insts.push(instance(roomName, "obj_water_zone", (x + w / 2) * CELL, (y + h / 2) * CELL, w * 2, h * 2));
	const px = v => Array.isArray(v) ? v : [v.x, v.y];
	// Exits go on the hidden layer with the collision boxes (their sprite is only a marker)
	const hidden = ["obj_transition", "obj_col_box"];
	for(const i of [...spriteThings, ...(spec.instances || [])]){
		const [x, y] = i.cell ? [i.cell[0] * CELL + (i.dx ?? 16), i.cell[1] * CELL + (i.dy ?? 16)] : px(i);
		(hidden.includes(i.obj) ? cols : insts).push(instance(roomName, i.obj, x, y, i.sx || 1, i.sy || 1, i.code || ""));
	}

	// Write the room: views and settings kept from the existing room, layers replaced
	const file = `rooms/${roomName}/${roomName}.yy`;
	// A new room starts from the village's settings (views, physics) and is registered in the project
	const isNew = !fs.existsSync(path.join(root, file));
	const room = readYy(isNew ? "rooms/rm_town_inn/rm_town_inn.yy" : file);   // (rm_2, the old template, is gone)
	if(isNew){
		room["%Name"] = room.name = roomName;
		room.creationCodeFile = "";
		if(!opts.preview) registerRoom(roomName);
	}
	room.roomSettings.Width = W * CELL;
	room.roomSettings.Height = H * CELL;
	// view: [w, h] of the camera's view (interiors use the farmhouse's closer 375 x 210, so a small room fills the screen)
	if(spec.view){ room.views[0].wview = spec.view[0]; room.views[0].hview = spec.view[1]; room.views[0].hborder = Math.round(spec.view[0] / 2); room.views[0].vborder = Math.round(spec.view[1] / 2); }
	const instLayer = Object.assign(layerBase("GMRInstanceLayer", "Instances", 1000), {instances: insts});
	// The buildings' pictures on an asset layer, so the room editor shows them (obj_building has no sprite of its own:
	// its creation code sets it). Only a preview: the game hides this layer (game Room Start); edit the specs, not it.
	const previews = spriteThings.filter(t => t.obj === "obj_building").map((t, i) => {
		const m = /sprite_index = ([A-Za-z0-9_]+);/.exec(t.code), spr = m && m[1];
		if(!spr || !fs.existsSync(path.join(root, "sprites", spr))) return null;
		const h = require("./png.js").readPng(path.join(root, "sprites", spr, fs.readdirSync(path.join(root, "sprites", spr)).find(f => f.endsWith(".png")))).h;
		const name = "graphic_" + crypto.createHash("md5").update(roomName + spr + i).digest("hex").slice(0, 8).toUpperCase();
		return {"$GMRSpriteGraphic": "", "%Name": name, animationSpeed: 1.0, colour: 4294967295, frozen: false, headPosition: 0.0,
			ignore: false, inheritedItemId: null, inheritItemSettings: false, name, resourceType: "GMRSpriteGraphic", resourceVersion: "2.0",
			rotation: 0.0, scaleX: 1.0, scaleY: 1.0, spriteId: {name: spr, path: `sprites/${spr}/${spr}.yy`}, x: t.x, y: t.y - h};
	}).filter(Boolean);
	const previewLayer = previews.length ? Object.assign(layerBase("GMRAssetLayer", "Buildings_preview", 990), {assets: previews}) : null;
	const colLayer = Object.assign(layerBase("GMRInstanceLayer", "Collisions", 1050, false), {instances: cols});
	// Within a role, layers made later draw on top (a sign put on a house goes over its wall)
	const tileLayer = l => {
		const depth = ROLE_DEPTH[l.role] - layers.list.filter(o => o.role === l.role && o.order < l.order).length;
		const o = layerBase("GMRTileLayer", l.name, depth);
		o.tiles = {SerialiseHeight: l.h || H, SerialiseWidth: l.w || W, TileCompressedData: encodeTiles(l.tiles.map(t => t || EMPTY)), TileDataFormat: 1};
		o.tilesetId = {name: l.tileset, path: `tilesets/${l.tileset}/${l.tileset}.yy`};
		o.x = l.x || 0; o.y = l.y || 0;
		return o;
	};
	const tl = layers.list.map(tileLayer);
	const all = [...tl.filter(l => l.depth < 1000), ...(previewLayer ? [previewLayer] : []), instLayer, colLayer, ...tl.filter(l => l.depth > 1000)].sort((a, b) => a.depth - b.depth);
	// Tile layer fields in GameMaker's order
	room.layers = all.map(l => {
		if(!l.tiles) return l;
		const {x, y, tiles, tilesetId, ...rest} = l;
		return Object.assign(rest, {tiles, tilesetId, userdefinedDepth: true, visible: true, x, y});
	});
	const everyInst = [...insts, ...cols];
	room.instanceCreationOrder = everyInst.map(i => ({name: i.name, path: file}));
	if(opts.preview){
		fs.mkdirSync(path.dirname(opts.preview), {recursive: true});
		writePng(opts.preview, renderRoom(room));
		return;
	}
	const dir = path.join(root, "rooms", roomName);
	for(const f of fs.readdirSync(dir)) if(f.startsWith("InstanceCreationCode_")) fs.unlinkSync(path.join(dir, f));
	for(const i of everyInst){
		if(i._code) fs.writeFileSync(path.join(dir, `InstanceCreationCode_${i.name}.gml`), i._code.trim() + "\n");
		delete i._code;
	}
	writeYy(file, room);

	const img = renderRoom(roomName);
	fs.mkdirSync(path.join(root, "build", "rooms"), {recursive: true});
	writePng(path.join(root, "build", "rooms", roomName + ".png"), img);
	console.log(`${roomName}: ${W}x${H} cells, ${layers.list.length} tile layers, ${cols.length} collision boxes, ${insts.length} instances`);
}

// Add a new room to CedarAndSea.yyp: its resource entry and its place in the room order (after the others)
function registerRoom(name){
	const yypPath = path.join(root, "CedarAndSea.yyp");
	let yyp = fs.readFileSync(yypPath, "utf8");
	const nl = yyp.includes("\r\n") ? "\r\n" : "\n";
	const ref = `{"name":"${name}","path":"rooms/${name}/${name}.yy",}`;
	if(!yyp.includes(`{"id":${ref},}`)) yyp = yyp.replace('"resources":[' + nl, '"resources":[' + nl + `    {"id":${ref},},` + nl);
	if(!yyp.includes(`{"roomId":${ref},}`)) yyp = yyp.replace(/("RoomOrderNodes":\[[\s\S]*?)(\s*\],)/, (m, a, b) => a + nl + `    {"roomId":${ref},},` + b);
	fs.writeFileSync(yypPath, yyp);
	fs.mkdirSync(path.join(root, "rooms", name), {recursive: true});
}

// scripts/room_layout: every spec's named points and areas, for scripts that need to know where things are
function writeLayout(){
	const specs = fs.readdirSync(path.join(__dirname, "specs")).filter(f => f.endsWith(".js")).sort();
	let body = "";
	for(const f of specs){
		const name = f.replace(/\.js$/, "");
		delete require.cache[require.resolve(path.join(__dirname, "specs", f))];
		const s = require(path.join(__dirname, "specs", f));
		const moved = require("./walk.js").MOVED[name] || {};
		const pts = Object.entries(Object.assign({}, s.points || {}, moved)).map(([k, v]) => `${k}: [${v.join(", ")}]`).join(", ");
		const ars = Object.entries(s.areas || {}).map(([k, v]) => `${k}: [${v.join(", ")}]`).join(", ");
		body += `\t\t${name}: {points: {${pts}}, areas: {${ars}}},\n`;
	}
	const gml = `// Generated by tools/rooms/build.js from tools/rooms/specs - don't edit by hand.
// Named spots in the built rooms: points are room pixels [x, y]; areas are cells [c1, r1, c2, r2] (32px, inclusive).

function room_layout(){
	static t = {
${body}	};
	return t;
}

/// @description A named spot in a room ("rm_1", "cave"): [x, y] in room pixels.
function layout_point(_room, _key){
	var r = room_layout()[$ _room];
	if(r == undefined){
		// an old room's name (before the merge): its spot is "<old room>__<spot>" in the room it's part of now
		var nr = room_layout()[$ world_alias(_room)];
		if(nr == undefined) return undefined;
		return nr.points[$ _room + "__" + _key] ?? nr.points[$ _key];
	}
	return r.points[$ _key];
}

/// @description A named area in a room, in cells [c1, r1, c2, r2].
function layout_cells(_room, _key){
	var r = room_layout()[$ _room];
	if(r == undefined){
		var nr = room_layout()[$ world_alias(_room)];
		if(nr == undefined) return undefined;
		return nr.areas[$ _room + "__" + _key] ?? nr.areas[$ _key];
	}
	return r.areas[$ _key];
}

/// @description A named area in a room, in room pixels [x1, y1, x2, y2].
function layout_area(_room, _key){
	var a = layout_cells(_room, _key);
	return [a[0] * 32, a[1] * 32, a[2] * 32 + 31, a[3] * 32 + 31];
}
`;
	const dir = path.join(root, "scripts", "room_layout");
	fs.mkdirSync(dir, {recursive: true});
	fs.writeFileSync(path.join(dir, "room_layout.gml"), gml);
	const yy = path.join(dir, "room_layout.yy");
	if(!fs.existsSync(yy)){
		fs.writeFileSync(yy, `{\n  "$GMScript":"v1",\n  "%Name":"room_layout",\n  "isCompatibility":false,\n  "isDnD":false,\n  "name":"room_layout",\n  "parent":{\n    "name":"Scripts",\n    "path":"folders/Scripts.yy",\n  },\n  "resourceType":"GMScript",\n  "resourceVersion":"2.0",\n}`);
		const yypPath = path.join(root, "CedarAndSea.yyp");
		let yyp = fs.readFileSync(yypPath, "utf8");
		const nl = yyp.includes("\r\n") ? "\r\n" : "\n";
		const entry = '    {"id":{"name":"room_layout","path":"scripts/room_layout/room_layout.yy",},},';
		if(!yyp.includes(entry)){ yyp = yyp.replace('"resources":[' + nl, '"resources":[' + nl + entry + nl); fs.writeFileSync(yypPath, yyp); }
	}
}

module.exports = {build};

if(require.main === module){
	let names = process.argv.slice(2);
	if(names.length === 0 || names[0] === "all") names = fs.readdirSync(path.join(__dirname, "specs")).filter(f => f.endsWith(".js")).map(f => f.replace(/\.js$/, ""));
	for(const n of names) build(n);
	require("./walk.js").writeWalk();   // (first: it moves points nobody could reach)
	writeLayout();
}
