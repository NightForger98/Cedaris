// The LPC Revised tiles' animations (water, waterfalls, flowers: their Tiled <animation>s) into the GameMaker tilesets
// TS_lpcr_<season>. GameMaker plays every animation in a tileset with one frame count, so all are made 4 frames: a
// 2-frame loop twice (a b a b), a 3-frame one there and back (a b c b); the odd 1- and 5-frame ones are left still.
// Tiled's 200 ms a frame is 5 frames a second.
//   node tools/map/lpcr_anim.js   (after tools/rooms/tileset_import.js has made the tilesets)
const fs = require("fs"), path = require("path");
const ROOT = path.join(__dirname, "..", "..");
const x = fs.readFileSync(path.join(ROOT, "art", "lpc_revised", "lpc-tileset-terrain-summer.tsx"), "utf8");
const anims = [];
for(const m of x.matchAll(/<tile id="(\d+)"[^>]*>([\s\S]*?)<\/tile>/g)){
	const a = /<animation>([\s\S]*?)<\/animation>/.exec(m[2]);
	if(!a) continue;
	let f = [...a[1].matchAll(/tileid="(\d+)"/g)].map(q => +q[1]);
	if(f.length === 2) f = [f[0], f[1], f[0], f[1]];
	else if(f.length === 3) f = [f[0], f[1], f[2], f[1]];
	else if(f.length !== 4) continue;
	if(f.includes(0)) continue;   // (tile 0 is "no tile")
	anims.push(f);
}
for(const season of ["spring", "summer", "autumn", "winter"]){
	const file = path.join(ROOT, "tilesets", `TS_lpcr_${season}`, `TS_lpcr_${season}.yy`);
	let s = fs.readFileSync(file, "utf8");
	const frames = anims.map((f, i) => `    {"$GMTileAnimation":"","%Name":"animation_${i}","frames":[${f.join(",")},],"name":"animation_${i}","resourceType":"GMTileAnimation","resourceVersion":"2.0",},`).join("\n");
	s = s.replace(/"tileAnimationFrames":\[[\s\S]*?\],\n  "tileAnimationSpeed":[0-9.]+,/, `"tileAnimationFrames":[\n${frames}\n  ],\n  "tileAnimationSpeed":5.0,`);
	fs.writeFileSync(file, s);
}
console.log(`${anims.length} animations of 4 frames in TS_lpcr_<season>`);
