// Make each tileset's output_tileset.png: the padded tile sheet the compiler (Igor) packs, which the IDE normally
// writes when it opens the project (it's git-ignored). Igor reads tile i at column i % out_columns of that sheet, so
// the sheet must be laid out with the .yy's out_columns - when they disagree, every tile in the game is the wrong
// one (the buildings were scrambled like that until 2026-11-05). The IDE always lays a sheet out
// ceil(sqrt(tile_count)) wide, so the tools write that as out_columns, and this script fixes any .yy that differs.
//
//   node tools/rooms/output_tileset.js           (every tileset whose sheet is missing or has the wrong width)
//   node tools/rooms/output_tileset.js --all     (rewrite every sheet)
// build.sh runs it before each build.
const fs = require("fs");
const path = require("path");
const {readPng, writePng, newImage} = require("./png.js");
const ROOT = path.join(__dirname, "..", "..");
const all = process.argv.includes("--all");

for(const ts of fs.readdirSync(path.join(ROOT, "tilesets"))){
	const dir = path.join(ROOT, "tilesets", ts), yyPath = path.join(dir, ts + ".yy");
	if(!fs.existsSync(yyPath)) continue;
	let yy = fs.readFileSync(yyPath, "utf8");
	const num = k => +yy.match(new RegExp('"' + k + '":([0-9]+)'))[1];
	const b = num("out_tilehborder"), tw = num("tileWidth"), th = num("tileHeight"), count = num("tile_count");
	const cols = Math.ceil(Math.sqrt(count)), cw = tw + 2 * b, ch = th + 2 * b;
	if(num("out_columns") !== cols){
		yy = yy.replace(/"out_columns":[0-9]+/, '"out_columns":' + cols);
		fs.writeFileSync(yyPath, yy);
		console.log(`${ts}: out_columns set to ${cols} (ceil(sqrt(${count})), as the IDE lays it out)`);
	}
	const outPath = path.join(dir, "output_tileset.png");
	if(!all && fs.existsSync(outPath)){
		const buf = fs.readFileSync(outPath);
		if(buf.readUInt32BE(16) === cols * cw) continue;
	}
	const spr = yy.match(/"spriteId":\{\s*"name":"(\w+)"/)[1], sdir = path.join(ROOT, "sprites", spr);
	const src = readPng(path.join(sdir, fs.readdirSync(sdir).find(f => f.endsWith(".png"))));
	const scols = Math.floor(src.w / tw), rows = Math.ceil(count / cols);
	const px = (x, y) => { const o = (y * src.w + x) * 4; return src.px.subarray(o, o + 4); };
	const out = newImage(cols * cw, rows * ch);
	for(let i = 0; i < count; i++){
		const sx = (i % scols) * tw, sy = Math.floor(i / scols) * th, ox = (i % cols) * cw, oy = Math.floor(i / cols) * ch;
		// each tile with its edge pixels repeated into the border
		for(let y = -b; y < th + b; y++) for(let x = -b; x < tw + b; x++)
			out.px.set(px(sx + Math.max(0, Math.min(tw - 1, x)), sy + Math.max(0, Math.min(th - 1, y))), ((oy + y + b) * out.w + ox + x + b) * 4);
	}
	writePng(outPath, out);
	console.log(`${ts}: output_tileset.png ${out.w}x${out.h}, ${cols} columns`);
}
