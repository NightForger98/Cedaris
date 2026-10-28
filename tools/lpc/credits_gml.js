// Write scripts/lpc_credits/lpc_credits.gml (artist names for the credits screen) from LPC_CREDITS.csv.
// Same output as credits_gml.py, for machines without Python.
// usage: node tools/lpc/credits_gml.js <project dir>
const fs = require("fs");
const path = require("path");
const proj = process.argv[2] || path.join(__dirname, "..", "..");

// CSV with quoted fields (which may contain commas and "" escapes)
function parseCsv(text){
	const rows = [];
	let row = [], field = "", q = false;
	for(let i = 0; i < text.length; i++){
		const c = text[i];
		if(q){
			if(c === '"' && text[i + 1] === '"'){ field += '"'; i++; }
			else if(c === '"') q = false;
			else field += c;
		} else if(c === '"') q = true;
		else if(c === ","){ row.push(field); field = ""; }
		else if(c === "\n" || c === "\r"){
			if(c === "\r" && text[i + 1] === "\n") i++;
			row.push(field); field = "";
			if(row.length > 1 || row[0] !== "") rows.push(row);
			row = [];
		} else field += c;
	}
	if(field !== "" || row.length) { row.push(field); rows.push(row); }
	return rows;
}

const rows = parseCsv(fs.readFileSync(path.join(proj, "LPC_CREDITS.csv"), "utf8").replace(/^﻿/, ""));
const head = rows.shift();
const ai = head.indexOf("authors"), li = head.indexOf("licenses");
const authors = new Set(), licences = new Set();
for(const r of rows){
	for(const a of (r[ai] || "").split(";")) if(a.trim()) authors.add(a.trim());
	for(const l of (r[li] || "").split(";")) if(l.trim()) licences.add(l.trim());
}
const q = s => '"' + s.replaceAll('"', "'") + '"';
// Python's sorted(): plain code-point order for licences, case-insensitive for names
const cmp = (a, b) => (a < b ? -1 : a > b ? 1 : 0);
const names = [...authors].sort((a, b) => cmp(a.toLowerCase(), b.toLowerCase()));
const gml = "/// Generated from LPC_CREDITS.csv by tools/lpc/credits_gml.py (do not edit by hand).\n"
	+ "/// Artists of the LPC character art, for the credits screen. Full per-piece list: LPC_CREDITS.csv.\n"
	+ "function lpc_credits(){\n\treturn {\n\t\tlicences: [" + [...licences].sort(cmp).map(q).join(", ") + "],\n\t\tauthors: [\n"
	+ names.map(n => "\t\t\t" + q(n)).join(",\n") + "\n\t\t],\n\t};\n}\n";
const d = path.join(proj, "scripts", "lpc_credits");
fs.mkdirSync(d, {recursive: true});
fs.writeFileSync(path.join(d, "lpc_credits.gml"), gml);
console.log(names.length + " authors", [...licences].sort(cmp));
