// Import a PNG into the project as a single-frame sprite (drawn with draw_sprite_part, like the tilesets).
//
//   node tools/sprite_import.js <png> <spr_name> [folder]
//
// Copies the image into sprites/<spr_name>/, writes the .yy (from spr_tile_terrain's as a template, with fresh ids)
// and adds it to CedarAndSea.yyp, in folders/Sprites/<folder>.yy (default "Monsters"; created if missing).
// Running it again for the same name replaces the image.
const fs = require("fs");
const path = require("path");
const crypto = require("crypto");

const [png, name, folder = "Monsters"] = process.argv.slice(2);
if(!png || !name){ console.error("usage: node tools/sprite_import.js <png> <spr_name> [folder]"); process.exit(2); }
const root = path.join(__dirname, "..");

// PNG size from the IHDR chunk
const buf = fs.readFileSync(png);
if(buf.readUInt32BE(12) !== 0x49484452){ console.error("not a PNG: " + png); process.exit(2); }
const w = buf.readUInt32BE(16), h = buf.readUInt32BE(20);

const dir = path.join(root, "sprites", name);
fs.rmSync(dir, {recursive: true, force: true});
const frame = crypto.randomUUID(), layer = crypto.randomUUID(), key = crypto.randomUUID();
fs.mkdirSync(path.join(dir, "layers", frame), {recursive: true});
fs.writeFileSync(path.join(dir, frame + ".png"), buf);
fs.writeFileSync(path.join(dir, "layers", frame, layer + ".png"), buf);

const tpl = fs.readFileSync(path.join(root, "sprites/spr_tile_terrain/spr_tile_terrain.yy"), "utf8");
const yy = tpl
	.replaceAll("spr_tile_terrain", name)
	.replaceAll("8a308e22-b5d8-418c-ae47-ab3d60738574", frame)
	.replaceAll("02e3c592-b4a7-41a4-a881-09cb87bb4a62", layer)
	.replaceAll("fb3523a4-8aca-4fee-b0b5-8106c75727bd", key)
	.replace('"bbox_bottom":1023', '"bbox_bottom":' + (h - 1))
	.replace('"bbox_right":1023', '"bbox_right":' + (w - 1))
	.replace('"height":1024', '"height":' + h)
	.replace('"width":1024', '"width":' + w)
	.replace('"name":"setTiles",\r\n    "path":"folders/Sprites/setTiles.yy"', '"name":"' + folder + '",\r\n    "path":"folders/Sprites/' + folder + '.yy"')
	.replace('"name":"setTiles",\n    "path":"folders/Sprites/setTiles.yy"', '"name":"' + folder + '",\n    "path":"folders/Sprites/' + folder + '.yy"');
fs.writeFileSync(path.join(dir, name + ".yy"), yy);

// Register the sprite (and its folder) in the project
const yypPath = path.join(root, "CedarAndSea.yyp");
let yyp = fs.readFileSync(yypPath, "utf8");
const nl = yyp.includes("\r\n") ? "\r\n" : "\n";
if(!yyp.includes('"folderPath":"folders/Sprites/' + folder + '.yy"')){
	yyp = yyp.replace('"Folders":[' + nl, '"Folders":[' + nl + '    {"$GMFolder":"","%Name":"' + folder + '","folderPath":"folders/Sprites/' + folder
		+ '.yy","name":"' + folder + '","resourceType":"GMFolder","resourceVersion":"2.0",},' + nl);
}
const entry = '    {"id":{"name":"' + name + '","path":"sprites/' + name + '/' + name + '.yy",},},';
if(!yyp.includes(entry)) yyp = yyp.replace('"resources":[' + nl, '"resources":[' + nl + entry + nl);
fs.writeFileSync(yypPath, yyp);
console.log(name + ": " + w + "x" + h + " in folders/Sprites/" + folder);
