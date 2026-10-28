// Read and write GameMaker .yy files (JSON with trailing commas) and tile layer data.
const fs = require("fs");
const path = require("path");

const root = path.join(__dirname, "..", "..");

function readYy(file){
	const s = fs.readFileSync(path.isAbsolute(file) ? file : path.join(root, file), "utf8");
	return JSON.parse(s.replace(/,(\s*[}\]])/g, "$1"));
}

// Fields GameMaker writes as reals ("x":288.0)
const REALS = new Set(["x", "y", "scaleX", "scaleY", "rotation", "imageSpeed", "PhysicsWorldGravityX", "PhysicsWorldGravityY",
	"PhysicsWorldPixToMetres", "volume", "animationFPS"]);

// GameMaker's own layout: two-space indent, trailing commas, and small objects (no nested objects/arrays) on one line.
// Its reader wants keys in order: case-insensitive alphabetical ("$GMRoom" and "%Name" sort first).
function toYy(v, ind = "", key = "", intXY = false){
	if(Array.isArray(v)){
		if(v.length === 0) return "[]";
		if(v.every(x => typeof x === "number")) return "[" + v.join(",") + ",]";
		return "[\n" + v.map(x => ind + "  " + toYy(x, ind + "  ") + ",\n").join("") + ind + "]";
	}
	if(v && typeof v === "object"){
		const keys = Object.keys(v).sort((a, b) => a.toLowerCase() < b.toLowerCase() ? -1 : a.toLowerCase() > b.toLowerCase() ? 1 : 0);
		const ints = v["$GMRTileLayer"] !== undefined;   // a tile layer's x and y are integers
		const flat = keys.every(k => v[k] === null || typeof v[k] !== "object" || (!Array.isArray(v[k]) && Object.values(v[k]).every(x => x === null || typeof x !== "object")));
		if(flat && ind !== "") return "{" + keys.map(k => JSON.stringify(k) + ":" + toYy(v[k], ind, k, ints)).join(",") + ",}";
		return "{\n" + keys.map(k => ind + "  " + JSON.stringify(k) + ":" + toYy(v[k], ind + "  ", k, ints) + ",\n").join("") + ind + "}";
	}
	if(typeof v === "number" && REALS.has(key) && Number.isInteger(v) && !(intXY && (key === "x" || key === "y"))) return v.toFixed(1);
	if(typeof v === "number") return String(v);
	return JSON.stringify(v);
}

function writeYy(file, obj){
	fs.writeFileSync(path.isAbsolute(file) ? file : path.join(root, file), toYy(obj) + "\n");
}

// TileCompressedData: a negative count repeats the next value, a positive count is followed by that many literal values
function decodeTiles(c){
	const out = [];
	for(let i = 0; i < c.length;){
		const n = c[i++];
		if(n < 0){ for(let k = 0; k < -n; k++) out.push(c[i]); i++; }
		else { for(let k = 0; k < n; k++) out.push(c[i + k]); i += n; }
	}
	return out;
}

function encodeTiles(t){
	const out = [];
	let lit = [];
	const flush = () => { if(lit.length){ out.push(lit.length, ...lit); lit = []; } };
	for(let i = 0; i < t.length;){
		let j = i;
		while(j < t.length && t[j] === t[i]) j++;
		if(j - i >= 3){ flush(); out.push(-(j - i), t[i]); }
		else for(let k = i; k < j; k++) lit.push(t[k]);
		i = j;
	}
	flush();
	return out;
}

const EMPTY = -2147483648;   // "no tile" in GameMaker's tile data

module.exports = {root, readYy, writeYy, toYy, decodeTiles, encodeTiles, EMPTY};
