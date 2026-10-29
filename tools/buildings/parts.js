// List the separate pieces (connected opaque areas) of a sheet as pixel boxes, and draw them numbered.
//   node tools/buildings/parts.js <tileset|png> [minSize]
const path = require("path");
const L = require("./lib.js");
const [name, min = "12"] = process.argv.slice(2);
const im = L.img(name), W = im.w, H = im.h, seen = new Uint8Array(W * H), boxes = [];
const op = (x, y) => im.px[(y * W + x) * 4 + 3] > 20;
for(let y = 0; y < H; y++) for(let x = 0; x < W; x++){
	if(seen[y * W + x] || !op(x, y)) continue;
	let x0 = x, x1 = x, y0 = y, y1 = y, n = 0;
	const st = [[x, y]]; seen[y * W + x] = 1;
	while(st.length){
		const [cx, cy] = st.pop(); n++;
		x0 = Math.min(x0, cx); x1 = Math.max(x1, cx); y0 = Math.min(y0, cy); y1 = Math.max(y1, cy);
		for(const [dx, dy] of [[1,0],[-1,0],[0,1],[0,-1]]){
			const nx = cx + dx, ny = cy + dy;
			if(nx < 0 || ny < 0 || nx >= W || ny >= H || seen[ny * W + nx] || !op(nx, ny)) continue;
			seen[ny * W + nx] = 1; st.push([nx, ny]);
		}
	}
	if(x1 - x0 >= +min || y1 - y0 >= +min) boxes.push([x0, y0, x1 - x0 + 1, y1 - y0 + 1]);
}
boxes.forEach((b, i) => console.log(i, b.join(" ")));
