// Catch calls to functions that don't exist - GameMaker's compiler doesn't, and the game only fails when the line
// runs. Checks every name(...) in the project's GML against the runtime's built-ins (GmlSpec.xml) and the
// project's own functions, and every "call <function>" in the test cases against the project's functions.
//
//   node tools/check_calls.js [runtime folder]     (build.sh runs it before compiling)
//
// Names that might hold a function at runtime (variables, parameters, struct fields) are let through, so this
// catches typos and removed functions, not every possible mistake.
const fs = require("fs");
const path = require("path");

const root = path.join(__dirname, "..");
const runtime = process.argv[2] || (() => {
	const base = "C:/ProgramData/GameMakerStudio2-LTS2026/Cache/runtimes";
	const all = fs.existsSync(base) ? fs.readdirSync(base).filter(d => d.startsWith("runtime-")).sort() : [];
	return all.length ? path.join(base, all[all.length - 1]) : "";
})();

function files(dir, ext, out = []){
	if(!fs.existsSync(dir)) return out;
	for(const e of fs.readdirSync(dir, {withFileTypes: true})){
		const p = path.join(dir, e.name);
		if(e.isDirectory()) files(p, ext, out);
		else if(p.endsWith(ext)) out.push(p);
	}
	return out;
}

// Built-ins: every GmlSpec.xml in the runtime (the base one and the platform modules)
const known = new Set(["if", "while", "for", "switch", "with", "return", "repeat", "until", "catch", "function", "new",
	"do", "case", "throw", "mod", "div", "delete", "not", "and", "or", "xor", "exit", "else", "try", "finally", "static", "var", "constructor"]);
if(runtime) for(const spec of files(runtime, "GmlSpec.xml"))
	for(const m of fs.readFileSync(spec, "utf8").matchAll(/<Function Name="([^"]+)"/g)) known.add(m[1]);
if(known.size < 1000){ console.log("check_calls: GmlSpec.xml not found under " + (runtime || "(no runtime)") + " - skipped"); process.exit(0); }

// GML without its comments and strings (so a word in a string or a comment isn't read as a call)
function strip(src){
	return src.replace(/\/\*[\s\S]*?\*\//g, " ")
		.replace(/@?"(?:\\.|[^"\\\n])*"|'(?:\\.|[^'\\\n])*'/g, '""')
		.replace(/\/\/[^\n]*/g, " ");
}

const gml = ["scripts", "objects", "rooms"].flatMap(d => files(path.join(root, d), ".gml"));
const src = gml.map(f => [f, strip(fs.readFileSync(f, "utf8"))]);

// The project's own functions, and names that may hold a function (assigned, declared or a parameter)
const own = new Set(), maybe = new Set();
for(const [, s] of src){
	for(const m of s.matchAll(/\bfunction\s+([A-Za-z_]\w*)/g)) own.add(m[1]);
	for(const m of s.matchAll(/\b([A-Za-z_]\w*)\s*=(?!=)/g)) maybe.add(m[1]);
	for(const m of s.matchAll(/\bvar\s+([A-Za-z_]\w*)/g)) maybe.add(m[1]);
	for(const m of s.matchAll(/\b([A-Za-z_]\w*)\s*:/g)) maybe.add(m[1]);                      // struct fields
	for(const m of s.matchAll(/\bfunction\s*\w*\s*\(([^)]*)\)/g))
		for(const p of m[1].split(",")) { const n = p.trim().split(/\s|=/)[0]; if(n) maybe.add(n); }
	for(const m of s.matchAll(/#macro\s+([A-Za-z_]\w*)/g)) maybe.add(m[1]);
}
// Assets (a sprite or object name followed by ( is never right, but scripts are callable by their asset name)
for(const d of fs.readdirSync(path.join(root, "scripts"))) own.add(d);

const problems = [];
for(const [f, s] of src){
	const lines = s.split("\n");
	lines.forEach((line, i) => {
		for(const m of line.matchAll(/(^|[^.\w$])([A-Za-z_]\w*)\s*\(/g)){
			const n = m[2];
			if(known.has(n) || own.has(n) || maybe.has(n)) continue;
			problems.push(`${path.relative(root, f).replace(/\\/g, "/")}:${i + 1}: ${n}() is not a built-in or a project function`);
		}
	});
}

// Test cases: "call <function>" runs a project function by name
for(const f of files(path.join(root, "tools/test/cases"), ".txt")){
	fs.readFileSync(f, "utf8").split("\n").forEach((line, i) => {
		const m = line.trim().match(/^call\s+(\S+)/);
		if(m && !own.has(m[1])) problems.push(`${path.relative(root, f).replace(/\\/g, "/")}:${i + 1}: call ${m[1]} - no such project function`);
	});
}

if(problems.length){
	console.log("check_calls: " + problems.length + " unknown function(s):\n" + problems.join("\n"));
	process.exit(1);
}
console.log(`check_calls: OK (${gml.length} GML files, ${own.size} project functions)`);
