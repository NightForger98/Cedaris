// Import PNGs as single-frame GameMaker sprites (top-left origin; the game positions them), trimmed to their
// visible pixels, registered in the .yyp under a sprite folder.
//   node tools/art/import_sprites.js <png folder> <prefix> <folder name> [--no-trim]
//   e.g. node tools/art/import_sprites.js art/resources_pl spr_res_ Resources   -> spr_res_<file name>
// Re-running replaces a sprite's picture (its ids are kept).
const fs = require("fs");
const path = require("path");
const crypto = require("crypto");
const {readPng, writePng, newImage} = require("../rooms/png.js");
const ROOT = path.join(__dirname, "..", "..");
const [src, prefix, folder] = process.argv.slice(2);
const trim = !process.argv.includes("--no-trim");
if(!src || !prefix || !folder){ console.log("usage: import_sprites.js <png folder> <prefix> <folder name>"); process.exit(1); }
const TEMPLATE = fs.readFileSync(path.join(ROOT, "sprites", "spr_furn_painting", "spr_furn_painting.yy"), "utf8");
const yypPath = path.join(ROOT, "CedarAndSea.yyp");
let yyp = fs.readFileSync(yypPath, "utf8");
const nl = yyp.includes("\r\n") ? "\r\n" : "\n";
// the sprite folder
const folderPath = `folders/Sprites/${folder}.yy`;
if(!yyp.includes(`"folderPath":"${folderPath}"`)){
	yyp = yyp.replace('"Folders":[' + nl, '"Folders":[' + nl + `    {"$GMFolder":"","%Name":"${folder}","folderPath":"${folderPath}","name":"${folder}","resourceType":"GMFolder","resourceVersion":"2.0",},` + nl);
}
let n = 0;
for(const f of fs.readdirSync(path.join(ROOT, src)).filter(f => f.endsWith(".png")).sort()){
	const name = prefix + f.replace(/\.png$/, "");
	let im = readPng(path.join(ROOT, src, f));
	if(trim){
		let x0 = im.w, y0 = im.h, x1 = -1, y1 = -1;
		for(let y = 0; y < im.h; y++) for(let x = 0; x < im.w; x++) if(im.px[(y * im.w + x) * 4 + 3] > 0){ x0 = Math.min(x0, x); x1 = Math.max(x1, x); y0 = Math.min(y0, y); y1 = Math.max(y1, y); }
		if(x1 >= 0){
			const t = newImage(x1 - x0 + 1, y1 - y0 + 1);
			for(let y = 0; y < t.h; y++) for(let x = 0; x < t.w; x++) for(let c = 0; c < 4; c++) t.px[(y * t.w + x) * 4 + c] = im.px[((y + y0) * im.w + x + x0) * 4 + c];
			im = t;
		}
	}
	const dir = path.join(ROOT, "sprites", name);
	let frame, layer;
	const yyFile = path.join(dir, name + ".yy");
	if(fs.existsSync(yyFile)){
		const old = fs.readFileSync(yyFile, "utf8");
		frame = old.match(/"\$GMSpriteFrame":"v1","%Name":"([0-9a-f-]+)"/)[1];
		layer = old.match(/"\$GMImageLayer":"","%Name":"([0-9a-f-]+)"/)[1];
	} else { frame = crypto.randomUUID(); layer = crypto.randomUUID(); }
	fs.mkdirSync(path.join(dir, "layers", frame), {recursive: true});
	writePng(path.join(dir, frame + ".png"), im);
	writePng(path.join(dir, "layers", frame, layer + ".png"), im);
	const yy = TEMPLATE.split("spr_furn_painting").join(name)
		.split("fa66cc91-e43e-412f-83d5-f4001c28d4b2").join(frame).split("998255b1-8714-466f-a1ee-c15fea6faf46").join(layer)
		.replace('"name":"Furniture",\n    "path":"folders/Sprites/Furniture.yy"', `"name":"${folder}",\n    "path":"${folderPath}"`)
		.replace(/"bbox_bottom":\d+/, `"bbox_bottom":${im.h - 1}`).replace(/"bbox_right":\d+/, `"bbox_right":${im.w - 1}`)
		.replace(/"height":38/, `"height":${im.h}`).replace(/"width":48,/, `"width":${im.w},`)
		.replace(/"id":"d922a6e0-5bca-4d08-ae57-973c25ccafba"/, `"id":"${crypto.randomUUID()}"`);
	fs.writeFileSync(yyFile, yy);
	const entry = `    {"id":{"name":"${name}","path":"sprites/${name}/${name}.yy",},},`;
	if(!yyp.includes(`"name":"${name}","path"`)) yyp = yyp.replace('"resources":[' + nl, '"resources":[' + nl + entry + nl);
	n++;
}
fs.writeFileSync(yypPath, yyp);
console.log(`${n} sprites ${prefix}* in ${folderPath}`);
