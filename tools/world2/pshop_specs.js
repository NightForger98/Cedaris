// Write tools/rooms/specs/rm_pshop_<id>.js for every plot the builder lays out (tools/world2/areas_build.js PLOTS),
// and take out the specs of plots that are gone. Run by tools/world/make_specs.js.
const fs = require("fs");
const path = require("path");
const A = require("./areas_build.js");
const SPECS = path.join(__dirname, "..", "rooms", "specs");
A.all();
const want = new Set(A.PLOTS.map(p => "rm_pshop_" + p.id + ".js"));
for(const f of fs.readdirSync(SPECS)) if(/^rm_pshop_.*\.js$/.test(f) && !want.has(f)) fs.unlinkSync(path.join(SPECS, f));
for(const p of A.PLOTS) fs.writeFileSync(path.join(SPECS, "rm_pshop_" + p.id + ".js"),
	`// rm_pshop_${p.id}: the shop on plot ${p.id} (tools/world2/pshop_room.js) - written by tools/world2/pshop_specs.js.\n// Build with: node tools/rooms/build.js rm_pshop_${p.id}\nmodule.exports = require("../../world2/pshop_room.js")("${p.id}");\n`);
console.log(`pshop specs: ${A.PLOTS.length} plots`);
