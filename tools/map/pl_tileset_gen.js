// node tools/map/pl_tileset_gen.js <jobs.json> <outdir>   (the API key: pl_key.txt beside it, never committed)
//   jobs: [{name, lower, upper, transition?, size?: 0..1, mode?: "pro"}]
// Generates PixelLab top-down Wang tilesets (16 corner tiles each, 32 px), 3 at a time. Saves <outdir>/<name>.json (the
// API's answer without the images, plus each tile's corners) and <outdir>/<name>.png (a 4 x 4 sheet in the answer's order).
const fs = require("fs"), path = require("path");
const {writePng, newImage} = require("../rooms/png.js");
const zlib = require("zlib");
const KEY = process.env.PIXELLAB_KEY || fs.readFileSync(path.join(__dirname, "pl_key.txt"), "utf8").trim();   // (the key: PIXELLAB_KEY, or pl_key.txt here - git-ignored)
const API = "https://api.pixellab.ai/v2";
const [jobsFile, out] = process.argv.slice(2);
const jobs = JSON.parse(fs.readFileSync(jobsFile, "utf8"));
fs.mkdirSync(out, {recursive: true});
const sleep = ms => new Promise(r => setTimeout(r, ms));
const H = {Authorization: "Bearer " + KEY, "Content-Type": "application/json"};
const {readPngBuf} = (() => { const P = require("../rooms/png.js"); return {readPngBuf: b => { const f = path.join(out, "_tmp_" + Math.random() + ".png"); fs.writeFileSync(f, b); const im = P.readPng(f); fs.unlinkSync(f); return im; }}; })();

function save(name, ts){
	const tiles = ts.tiles || [];
	const T = (ts.tile_size || {}).width || 32;
	const sheet = newImage(4 * T, Math.ceil(tiles.length / 4) * T);
	const meta = [];
	tiles.forEach((t, k) => {
		const im = readPngBuf(Buffer.from(t.image.base64, "base64"));
		const X = (k % 4) * T, Y = Math.floor(k / 4) * T;
		for(let y = 0; y < Math.min(T, im.h); y++) for(let x = 0; x < Math.min(T, im.w); x++){
			const s = (y * im.w + x) * 4, d = ((Y + y) * sheet.w + X + x) * 4;
			for(let c = 0; c < 4; c++) sheet.px[d + c] = im.px[s + c];
		}
		meta.push({k, name: t.name, corners: t.corners, w: im.w, h: im.h});
	});
	writePng(path.join(out, name + ".png"), sheet);
	fs.writeFileSync(path.join(out, name + ".json"), JSON.stringify({name, tile: T, terrain_types: ts.terrain_types, tiles: meta}, null, 1));
}

async function one(j){
	const body = {lower_description: j.lower, upper_description: j.upper, tile_size: {width: 32, height: 32}, mode: j.mode || "pro",
		view: "low top-down", transition_size: j.size || 0};
	if(j.transition) body.transition_description = j.transition;
	if(j.mode === "standard") delete body.view;
	let r = await fetch(API + "/create-tileset", {method: "POST", headers: H, body: JSON.stringify(body)});
	let t = await r.text();
	if(!r.ok) throw new Error(j.name + " create " + r.status + " " + t.slice(0, 400));
	let m = JSON.parse(t);
	if(m.tileset && m.tileset.tiles){ save(j.name, m.tileset); return j.name + " ok (direct)"; }
	const id = m.tileset_id || m.id || (m.data || {}).tileset_id || (m.tileset || {}).id;
	if(!id) throw new Error(j.name + " no id: " + t.slice(0, 300));
	for(let k = 0; k < 180; k++){
		await sleep(5000);
		r = await fetch(API + "/tilesets/" + id, {headers: H});
		if(r.status === 423 || r.status === 202) continue;
		t = await r.text();
		if(!r.ok) throw new Error(j.name + " poll " + r.status + " " + t.slice(0, 300));
		m = JSON.parse(t);
		const ts = m.tileset || m.data || m;
		if(!ts.tiles || !ts.tiles.length) continue;
		save(j.name, ts);
		return j.name + " ok";
	}
	throw new Error(j.name + " timed out");
}

(async () => {
	const q = [...jobs];
	await Promise.all([0, 1, 2].map(async () => {
		while(q.length){ const j = q.shift(); try{ console.log(await one(j)); } catch(e){ console.log("FAIL", e.message); } }
	}));
	const b = await (await fetch(API + "/balance", {headers: H})).json();
	console.log("left:", JSON.stringify(b.subscription));
})();
