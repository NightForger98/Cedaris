// The old world (25 rooms on a 5x5 grid, each with its own roads and the villagers' routes in it) on the new map: where
// each old room's ground now lies, so its named spots and routes can be moved over when the rooms are rebuilt.
//   node tools/map/old_rooms.js   (after node tools/map/blueprint.js)
// Writes design/map/old_rooms.json (each old room: its new area and a rectangle in world tiles) and
// design/map/old_rooms_on_new.png (those rectangles drawn over the new map's preview), and keeps the old game's world
// map as design/map/old_world_map.png.
const fs = require("fs");
const path = require("path");
const {readPng, writePng} = require("../rooms/png.js");
const ROOT = path.join(__dirname, "..", ".."), OUT = path.join(ROOT, "design", "map");
const M = 30, S = 4;
// [x1, y1, x2, y2] in world tiles, roughly where the old room's places went
const OLD = {
	rm_wellshead:   {area: "Beirut", rect: [12, 12, 40, 30]},
	rm_redstreet:   {area: "Beirut", rect: [18, 28, 60, 56]},
	rm_downtown:    {area: "Beirut", rect: [60, 16, 104, 44]},
	rm_gracetower:  {area: "Beirut", rect: [104, 16, 136, 48]},
	rm_verdun:      {area: "Beirut", rect: [14, 56, 56, 90]},
	rm_uptown:      {area: "Beirut", rect: [56, 56, 100, 96]},
	rm_ovenswindow: {area: "Beirut", rect: [100, 48, 138, 96]},
	rm_manara:      {area: "North Beach", rect: [4, 28, 18, 52]},
	rm_starsand:    {area: "North Beach", rect: [60, 0, 124, 16]},
	rm_hangar:      {area: "North Beach", rect: [130, -8, 172, 18]},
	rm_plummet:     {area: "The Mountain", rect: [172, -24, 250, 22]},
	rm_beaconhill:  {area: "The Mountain", rect: [150, 22, 250, 62]},
	rm_victoryhill: {area: "The Mountain", rect: [146, 62, 250, 94]},
	rm_pigeonrocks: {area: "West Beach", rect: [0, 56, 22, 90]},
	rm_whitesand:   {area: "West Beach", rect: [18, 92, 50, 122]},
	rm_olivebay:    {area: "West Beach", rect: [16, 122, 52, 150]},
	rm_southbeach:  {area: "West Beach", rect: [16, 150, 52, 198]},
	rm_winghill:    {area: "The Outskirts", rect: [40, 94, 76, 140]},
	rm_dahya:       {area: "The Outskirts", rect: [76, 94, 118, 140]},
	rm_resolve:     {area: "The Outskirts", rect: [118, 94, 152, 146]},
	rm_yarzeh:      {area: "Whispering Woods", rect: [160, 86, 240, 148]},
	rm_1:           {area: "The Farm", rect: [52, 158, 98, 198]},
	rm_sthereza:    {area: "The Countryside", rect: [98, 148, 130, 198]},
	rm_frere:       {area: "The Countryside", rect: [130, 150, 160, 198]},
	rm_abda:        {area: "The Countryside", rect: [160, 146, 200, 198]},
};
fs.writeFileSync(path.join(OUT, "old_rooms.json"), JSON.stringify({
	note: "Where each old room's ground lies in the new world (world tiles, as in world_layout.json). The old rooms' own roads and named spots are in tools/rooms/specs and scripts/room_layout at commit f012fa7 and before.",
	rooms: OLD}, null, 1));
// The rectangles over the preview
const P = readPng(path.join(OUT, "world_blueprint_preview.png"));
const put = (x, y, c) => { if(x < 0 || y < 0 || x >= P.w || y >= P.h) return; const i = (y * P.w + x) * 4; P.px[i] = c[0]; P.px[i + 1] = c[1]; P.px[i + 2] = c[2]; };
const cols = [[255, 80, 80], [255, 200, 40], [80, 220, 255], [200, 120, 255], [120, 255, 120]];
Object.values(OLD).forEach((o, i) => {
	const [x1, y1, x2, y2] = o.rect.map((v, k) => (v + M) * S), c = cols[i % cols.length];
	for(let x = x1; x <= x2; x++) for(let t = 0; t < 2; t++){ if((x >> 3) % 2) continue; put(x, y1 + t, c); put(x, y2 - t, c); }
	for(let y = y1; y <= y2; y++) for(let t = 0; t < 2; t++){ if((y >> 3) % 2) continue; put(x1 + t, y, c); put(x2 - t, y, c); }
});
writePng(path.join(OUT, "old_rooms_on_new.png"), P);
const old = path.join(ROOT, "build", "world_map.png");
if(fs.existsSync(old)) fs.copyFileSync(old, path.join(OUT, "old_world_map.png"));
console.log("old_rooms.json, old_rooms_on_new.png" + (fs.existsSync(old) ? ", old_world_map.png" : ""));
