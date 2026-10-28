// Turn a 32px-grid spritesheet into a GameMaker tileset: imports the PNG as spr_tile_<name> (tools/sprite_import.js)
// and writes tilesets/TS_<name> for it. Remember to credit the art in LPC_CREDITS.csv.
//
//   node tools/rooms/tileset_import.js <png> <name>
const fs = require("fs");
const path = require("path");
const {execFileSync} = require("child_process");

const [png, name] = process.argv.slice(2);
if(!png || !name){ console.error("usage: node tools/rooms/tileset_import.js <png> <name>"); process.exit(2); }
const root = path.join(__dirname, "..", "..");
const spr = "spr_tile_" + name, ts = "TS_" + name;
execFileSync(process.execPath, [path.join(root, "tools", "sprite_import.js"), png, spr, "setTiles"], {stdio: "inherit"});

const buf = fs.readFileSync(png);
const w = buf.readUInt32BE(16), h = buf.readUInt32BE(20);
const cols = Math.floor(w / 32), count = cols * Math.floor(h / 32);
const yy = `{
  "$GMTileSet":"v1",
  "%Name":"${ts}",
  "autoTileSets":[],
  "macroPageTiles":{
    "SerialiseHeight":0,
    "SerialiseWidth":0,
    "TileSerialiseData":[],
  },
  "name":"${ts}",
  "out_columns":${cols},
  "out_tilehborder":2,
  "out_tilevborder":2,
  "parent":{
    "name":"Tile Sets",
    "path":"folders/Tile Sets.yy",
  },
  "resourceType":"GMTileSet",
  "resourceVersion":"2.0",
  "spriteId":{
    "name":"${spr}",
    "path":"sprites/${spr}/${spr}.yy",
  },
  "spriteNoExport":false,
  "textureGroupId":{
    "name":"Default",
    "path":"texturegroups/Default",
  },
  "tileAnimationFrames":[],
  "tileAnimationSpeed":15.0,
  "tileHeight":32,
  "tilehsep":0,
  "tilevsep":0,
  "tileWidth":32,
  "tilexoff":0,
  "tileyoff":0,
  "tile_count":${count},
}`;
fs.mkdirSync(path.join(root, "tilesets", ts), {recursive: true});
fs.writeFileSync(path.join(root, "tilesets", ts, ts + ".yy"), yy);

const yypPath = path.join(root, "NewHarvest.yyp");
let yyp = fs.readFileSync(yypPath, "utf8");
const nl = yyp.includes("\r\n") ? "\r\n" : "\n";
const entry = `    {"id":{"name":"${ts}","path":"tilesets/${ts}/${ts}.yy",},},`;
if(!yyp.includes(entry)){ yyp = yyp.replace('"resources":[' + nl, '"resources":[' + nl + entry + nl); fs.writeFileSync(yypPath, yyp); }
console.log(`${ts}: ${cols} columns, ${count} tiles`);
