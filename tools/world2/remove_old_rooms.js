// Take the old world's 24 outdoor rooms out of the project (Cedar & Sea's blueprint rooms replace them): their room
// folders, their specs, and their entries in the project file and the resource order. The farm (rm_1) stays.
//   node tools/world2/remove_old_rooms.js
const fs = require("fs");
const path = require("path");
const {GRID} = require("../world/world.js");
const ROOT = path.join(__dirname, "..", "..");
const OLD = GRID.flat().filter(id => id !== "rm_1");
const yypPath = path.join(ROOT, "CedarAndSea.yyp"), roPath = path.join(ROOT, "CedarAndSea.resource_order");
let yyp = fs.readFileSync(yypPath, "utf8"), ro = fs.existsSync(roPath) ? fs.readFileSync(roPath, "utf8") : null;
let n = 0;
for(const id of OLD){
	const line = new RegExp(`^.*"name":"${id}".*\\r?\\n`, "gm");
	yyp = yyp.replace(line, () => { n++; return ""; });
	if(ro) ro = ro.replace(line, "");
	fs.rmSync(path.join(ROOT, "rooms", id), {recursive: true, force: true});
	fs.rmSync(path.join(ROOT, "tools", "rooms", "specs", id + ".js"), {force: true});
}
fs.writeFileSync(yypPath, yyp);
if(ro) fs.writeFileSync(roPath, ro);
console.log(`removed ${OLD.length} old rooms (${n} project lines)`);
