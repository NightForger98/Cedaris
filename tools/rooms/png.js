// Minimal PNG read/write (8-bit RGBA or RGB, non-interlaced) with only Node's zlib, so the room tools need no packages.
const fs = require("fs");
const zlib = require("zlib");

function readPng(file){
	const buf = fs.readFileSync(file);
	let pos = 8, w = 0, h = 0, ct = 0, depth = 0, palette = null, trns = null;
	const idat = [];
	while(pos < buf.length){
		const len = buf.readUInt32BE(pos), type = buf.toString("ascii", pos + 4, pos + 8);
		const data = buf.subarray(pos + 8, pos + 8 + len);
		if(type === "IHDR"){ w = data.readUInt32BE(0); h = data.readUInt32BE(4); depth = data[8]; ct = data[9]; if(data[12]) throw new Error("interlaced PNG: " + file); }
		else if(type === "PLTE") palette = data;
		else if(type === "tRNS") trns = data;
		else if(type === "IDAT") idat.push(data);
		else if(type === "IEND") break;
		pos += 12 + len;
	}
	if(depth !== 8) throw new Error("only 8-bit PNGs: " + file);
	const bpp = {6: 4, 2: 3, 3: 1, 0: 1, 4: 2}[ct];
	const raw = zlib.inflateSync(Buffer.concat(idat));
	const stride = w * bpp, px = Buffer.alloc(w * h * 4);
	let prev = Buffer.alloc(stride);
	for(let y = 0; y < h; y++){
		const f = raw[y * (stride + 1)], line = Buffer.from(raw.subarray(y * (stride + 1) + 1, (y + 1) * (stride + 1)));
		for(let i = 0; i < stride; i++){
			const a = i >= bpp ? line[i - bpp] : 0, b = prev[i], c = i >= bpp ? prev[i - bpp] : 0;
			let v = line[i];
			if(f === 1) v += a;
			else if(f === 2) v += b;
			else if(f === 3) v += (a + b) >> 1;
			else if(f === 4){ const p = a + b - c, pa = Math.abs(p - a), pb = Math.abs(p - b), pc = Math.abs(p - c); v += (pa <= pb && pa <= pc) ? a : (pb <= pc ? b : c); }
			line[i] = v & 255;
		}
		for(let x = 0; x < w; x++){
			const o = (y * w + x) * 4, s = x * bpp;
			if(ct === 6){ line.copy(px, o, s, s + 4); }
			else if(ct === 2){ px[o] = line[s]; px[o + 1] = line[s + 1]; px[o + 2] = line[s + 2]; px[o + 3] = 255; }
			else if(ct === 3){ const k = line[s]; px[o] = palette[k * 3]; px[o + 1] = palette[k * 3 + 1]; px[o + 2] = palette[k * 3 + 2]; px[o + 3] = trns && k < trns.length ? trns[k] : 255; }
			else if(ct === 0){ px[o] = px[o + 1] = px[o + 2] = line[s]; px[o + 3] = 255; }
			else { px[o] = px[o + 1] = px[o + 2] = line[s]; px[o + 3] = line[s + 1]; }
		}
		prev = line;
	}
	return {w, h, px};
}

const crcTable = Array.from({length: 256}, (_, n) => { let c = n; for(let k = 0; k < 8; k++) c = c & 1 ? 0xedb88320 ^ (c >>> 1) : c >>> 1; return c >>> 0; });
function crc(b){ let c = 0xffffffff; for(const x of b) c = crcTable[(c ^ x) & 255] ^ (c >>> 8); return (c ^ 0xffffffff) >>> 0; }
function chunk(type, data){
	const out = Buffer.alloc(12 + data.length);
	out.writeUInt32BE(data.length, 0); out.write(type, 4, "ascii"); data.copy(out, 8);
	out.writeUInt32BE(crc(out.subarray(4, 8 + data.length)), 8 + data.length);
	return out;
}

function writePng(file, img){
	const {w, h, px} = img, raw = Buffer.alloc(h * (w * 4 + 1));
	for(let y = 0; y < h; y++) px.copy(raw, y * (w * 4 + 1) + 1, y * w * 4, (y + 1) * w * 4);
	const ihdr = Buffer.alloc(13);
	ihdr.writeUInt32BE(w, 0); ihdr.writeUInt32BE(h, 4); ihdr[8] = 8; ihdr[9] = 6;
	fs.writeFileSync(file, Buffer.concat([Buffer.from([137, 80, 78, 71, 13, 10, 26, 10]), chunk("IHDR", ihdr),
		chunk("IDAT", zlib.deflateSync(raw)), chunk("IEND", Buffer.alloc(0))]));
}

function newImage(w, h, rgba = [0, 0, 0, 0]){
	const px = Buffer.alloc(w * h * 4);
	for(let i = 0; i < w * h; i++) px.set(rgba, i * 4);
	return {w, h, px};
}

// Alpha-blend a part of src onto dst
function blit(dst, src, sx, sy, sw, sh, dx, dy){
	for(let y = 0; y < sh; y++){
		const ty = dy + y, fy = sy + y;
		if(ty < 0 || ty >= dst.h || fy < 0 || fy >= src.h) continue;
		for(let x = 0; x < sw; x++){
			const tx = dx + x, fx = sx + x;
			if(tx < 0 || tx >= dst.w || fx < 0 || fx >= src.w) continue;
			const s = (fy * src.w + fx) * 4, d = (ty * dst.w + tx) * 4, a = src.px[s + 3] / 255;
			if(a === 0) continue;
			for(let c = 0; c < 3; c++) dst.px[d + c] = Math.round(src.px[s + c] * a + dst.px[d + c] * (1 - a));
			dst.px[d + 3] = Math.max(dst.px[d + 3], src.px[s + 3]);
		}
	}
}

module.exports = {readPng, writePng, newImage, blit};
