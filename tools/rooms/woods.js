// Scatter trees and bushes over part of a room spec's map, clear of roads, water and each other.
//
//   const woods = require("../woods.js");
//   things: [...woods(map, [c1, r1, c2, r2], 12, 5), ...]
//
// Each pick is a thing from tools/rooms/tiles.js placed where its whole footprint (and a cell round it) is plain
// grass (".") and touches nothing placed before. The same seed gives the same wood.
const T = require("./tiles.js");

const KINDS = [["oak", 5], ["pine", 5], ["sapling", 2], ["bush_big", 1], ["bush_big2", 1]];

// tight: a dense wood - only the trunk rows (a tree's bottom two) need room, so canopies overlap
module.exports = function woods(map, [c1, r1, c2, r2], count, seed = 1, kinds = KINDS, taken = new Set(), tight = false){
	let s = seed * 9301 + 49297;
	const rand = () => (s = (s * 16807) % 2147483647) / 2147483647;
	const total = kinds.reduce((a, k) => a + k[1], 0), out = [];
	const pick = () => { let p = rand() * total; for(const [k, w] of kinds){ p -= w; if(p <= 0) return k; } return kinds[0][0]; };
	for(let tries = 0; tries < count * 40 && out.length < count; tries++){
		const is = pick(), [, , w, h] = T.things[is].src;
		const c = c1 + Math.floor(rand() * Math.max(1, c2 - c1 - w + 2)), r = r1 + Math.floor(rand() * Math.max(1, r2 - r1 - h + 2));
		let ok = true;
		const ya = tight ? r + h - 2 : r - 1, yb = tight ? r + h - 1 : r + h, xa = tight ? c : c - 1, xb = tight ? c + w - 1 : c + w;
		for(let y = ya; y <= yb && ok; y++) for(let x = xa; x <= xb && ok; x++){
			if((map[y] || "")[x] !== "." || taken.has(x + "," + y)) ok = false;
		}
		if(tight) for(let y = r; y < r + h && ok; y++) for(let x = c; x < c + w && ok; x++) if((map[y] || "")[x] !== ".") ok = false;
		if(!ok) continue;
		for(let y = tight ? r + h - 2 : r; y < r + h; y++) for(let x = c; x < c + w; x++) taken.add(x + "," + y);
		out.push({is, at: [c, r]});
	}
	return out;
};
