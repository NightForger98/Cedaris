// Paint rectangles of one character into a spec's map, in place (for quick layout edits from the command line).
//
//   node tools/rooms/paint.js <room> <char> <col> <row> <w> <h> [<char> <col> <row> <w> <h> ...]
const fs = require("fs");
const path = require("path");
const [room, ...rest] = process.argv.slice(2);
const file = path.join(__dirname, "specs", room + ".js");
let src = fs.readFileSync(file, "utf8");
const m = src.match(/map: \[\n([\s\S]*?)\n\t\],/);
if(!m){ console.error("no map in " + file); process.exit(2); }
const rows = m[1].split("\n").map(l => l.trim().replace(/^"|",?$/g, "").split(""));
for(let i = 0; i + 4 < rest.length; i += 5){
	const [ch, c, r, w, h] = [rest[i], +rest[i + 1], +rest[i + 2], +rest[i + 3], +rest[i + 4]];
	for(let y = r; y < r + h; y++) for(let x = c; x < c + w; x++) if(rows[y] && x < rows[y].length) rows[y][x] = ch;
}
src = src.replace(m[0], "map: [\n" + rows.map(r => '\t\t"' + r.join("") + '",').join("\n") + "\n\t],");
fs.writeFileSync(file, src);
