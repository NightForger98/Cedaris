// Import animations: every folder of frame_NN.png (all the same size) under a source folder becomes one multi-frame
// GameMaker sprite spr_anim_<folder> (top-left origin), registered under Sprites/<folder name>.
//   node tools/art/import_anims.js art/anim_spritecook Animations
// Re-running replaces the frames (the sprite's ids are made anew).
const fs = require("fs");
const path = require("path");
const crypto = require("crypto");
const {readPng, writePng} = require("../rooms/png.js");
const ROOT = path.join(__dirname, "..", "..");
const [src, folder] = process.argv.slice(2);
const TEMPLATE = fs.readFileSync(path.join(ROOT, "sprites", "spr_furn_painting", "spr_furn_painting.yy"), "utf8");
const yypPath = path.join(ROOT, "CedarAndSea.yyp");
let yyp = fs.readFileSync(yypPath, "utf8");
const nl = yyp.includes("\r\n") ? "\r\n" : "\n";
const folderPath = `folders/Sprites/${folder}.yy`;
if(!yyp.includes(`"folderPath":"${folderPath}"`))
	yyp = yyp.replace('"Folders":[' + nl, '"Folders":[' + nl + `    {"$GMFolder":"","%Name":"${folder}","folderPath":"${folderPath}","name":"${folder}","resourceType":"GMFolder","resourceVersion":"2.0",},` + nl);
let n = 0;
for(const d of fs.readdirSync(path.join(ROOT, src)).sort()){
	const dir = path.join(ROOT, src, d);
	if(!fs.statSync(dir).isDirectory()) continue;
	const frames = fs.readdirSync(dir).filter(f => /^frame_\d+\.png$/.test(f)).sort();
	if(frames.length === 0) continue;
	const name = "spr_anim_" + d, out = path.join(ROOT, "sprites", name);
	fs.rmSync(out, {recursive: true, force: true});
	const layer = crypto.randomUUID(), ids = frames.map(() => crypto.randomUUID());
	let w = 0, h = 0;
	frames.forEach((f, i) => {
		const im = readPng(path.join(dir, f));
		w = im.w; h = im.h;
		fs.mkdirSync(path.join(out, "layers", ids[i]), {recursive: true});
		writePng(path.join(out, ids[i] + ".png"), im);
		writePng(path.join(out, "layers", ids[i], layer + ".png"), im);
	});
	const frameList = ids.map(id => `    {"$GMSpriteFrame":"v1","%Name":"${id}","name":"${id}","resourceType":"GMSpriteFrame","resourceVersion":"2.0",},`).join("\n");
	const keys = ids.map((id, i) => `            {"$Keyframe<SpriteFrameKeyframe>":"","Channels":{
                "0":{"$SpriteFrameKeyframe":"","Id":{"name":"${id}","path":"sprites/${name}/${name}.yy",},"resourceType":"SpriteFrameKeyframe","resourceVersion":"2.0",},
              },"Disabled":false,"id":"${crypto.randomUUID()}","IsCreationKey":false,"Key":${i}.0,"Length":1.0,"resourceType":"Keyframe<SpriteFrameKeyframe>","resourceVersion":"2.0","Stretch":false,},`).join("\n");
	let yy = TEMPLATE.split("spr_furn_painting").join(name)
		.replace('"name":"Furniture",\n    "path":"folders/Sprites/Furniture.yy"', `"name":"${folder}",\n    "path":"${folderPath}"`)
		.replace(/"bbox_bottom":\d+/, `"bbox_bottom":${h - 1}`).replace(/"bbox_right":\d+/, `"bbox_right":${w - 1}`)
		.replace(/"height":38/, `"height":${h}`).replace(/"width":48,/, `"width":${w},`)
		.replace(/"frames":\[\n[\s\S]*?\n  \],/, `"frames":[\n${frameList}\n  ],`)
		.replace(/"Keyframes":\[\n            \{"\$Keyframe<SpriteFrameKeyframe>"[\s\S]*?\n          \],"resourceType":"KeyframeStore<SpriteFrameKeyframe>"/, `"Keyframes":[\n${keys}\n          ],"resourceType":"KeyframeStore<SpriteFrameKeyframe>"`)
		.replace(/"layers":\[\n    \{"\$GMImageLayer":"","%Name":"[0-9a-f-]+"/, `"layers":[\n    {"$GMImageLayer":"","%Name":"${layer}"`)
		.replace(/("\$GMImageLayer":"","%Name":"[0-9a-f-]+","blendMode":0,"displayName":"default","isLocked":false,"name":")[0-9a-f-]+"/, `$1${layer}"`)
		.replace(/"length":1\.0,/, `"length":${frames.length}.0,`);
	fs.writeFileSync(path.join(out, name + ".yy"), yy);
	const entry = `    {"id":{"name":"${name}","path":"sprites/${name}/${name}.yy",},},`;
	if(!yyp.includes(`"name":"${name}","path"`)) yyp = yyp.replace('"resources":[' + nl, '"resources":[' + nl + entry + nl);
	console.log(`${name}: ${frames.length} frames ${w}x${h}`);
	n++;
}
fs.writeFileSync(yypPath, yyp);
console.log(`${n} animations in ${folderPath}`);
