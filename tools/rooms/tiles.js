// The tile library the room builder uses: terrains (autotiled), map characters, and named things (buildings, trees,
// props) with where they come from in the tilesets. Coordinates are 32px cells of the tileset image: [col, row].
// To find a piece, look at build/rooms/tiles_<tileset>.png (node tools/rooms/sheet.js) - it has a numbered grid.

// LPC terrain blocks: 3 cells wide, 6 tall, top-left at "block" (see autotile in build.js). Drawn in this order,
// later ones over earlier ones. "fill" lists the cells used for the middle (picked at random for variety).
const terrains = {
	// The coast: the open sea (a fill, used as the coast's base) and sand meeting it (an LPC block of sand on water)
	sea:   {tileset: "TS_terrain", block: [3, 9],  fill: [[5, 14]]},
	shore: {tileset: "TS_terrain", block: [3, 9],  fill: [[4, 12]]},
	grass: {tileset: "TS_terrain", block: [21, 0], fill: [[21, 5], [22, 5], [23, 5], [22, 3], [22, 3], [22, 3]]},
	dirt:  {tileset: "TS_terrain", block: [15, 0], fill: [[16, 3]]},
	path:  {tileset: "TS_terrain", block: [18, 0], fill: [[19, 3]]},
	sand:  {tileset: "TS_terrain", block: [0, 9],  fill: [[0, 14], [1, 14], [2, 14], [1, 12]]},
	water: {tileset: "TS_terrain", block: [6, 9],  fill: [[7, 12]]},
	// The farm's field: farming looks for a layer called T_Soil to know where you can till
	soil:  {tileset: "TS_terrain", block: [5, 15], fill: [[6, 18]], role: "soil", layer: "T_Soil"},
};

// Map characters. terrain: what's drawn; solid: blocks walking; water: refills the watering can and stops spawns;
// busy: nothing scattered or spawned there.
const legend = {
	".": {terrain: "grass"},
	",": {terrain: "dirt"},
	":": {terrain: "path"},
	"_": {terrain: "sand"},
	"~": {terrain: "water", solid: true, water: true},
	"=": {terrain: "soil"},
	"x": {terrain: "grass", solid: true},          // grass you can't walk on (behind hedges, room edges)
	"X": {terrain: "dirt", solid: true},
	"b": {terrain: "water", water: true, busy: true}, // water under a bridge: walkable
};

// Things. src: [col, row, w, h] in the tileset (default TS_terrain), or stamp: a captured multi-layer piece in
// tools/rooms/stamps. above: how many top rows draw over the player. solid: [dx, dy, w, h] blocks, inside the thing.
const things = {
	// Buildings (cottage kit, captured from the first test rooms). door: the cell in front of the door, inside the thing.
	farmhouse:   {stamp: "farmhouse", above: 4, solid: [[0, 3, 13, 6], [0, 9, 6, 1], [7, 9, 6, 1]], door: [6, 9]},
	village_hall:{stamp: "village_hall", above: 4, solid: [[1, 3, 14, 6], [1, 9, 6, 1], [9, 9, 6, 1]], door: [7, 9]},
	// The farmhouse in other colours: the kit has cream walls 4 rows above the stone ones, yellow thatch 7 rows above brown
	house_cream:  {stamp: "farmhouse", above: 4, solid: [[0, 3, 13, 6], [0, 9, 6, 1], [7, 9, 6, 1]], door: [6, 9],
	               swap: [{cols: [0, 15], rows: [8, 11], dRow: -4}]},
	house_thatch: {stamp: "farmhouse", above: 4, solid: [[0, 3, 13, 6], [0, 9, 6, 1], [7, 9, 6, 1]], door: [6, 9],
	               swap: [{cols: [16, 31], rows: [7, 13], dRow: -7}]},
	house_cream_thatch: {stamp: "farmhouse", above: 4, solid: [[0, 3, 13, 6], [0, 9, 6, 1], [7, 9, 6, 1]], door: [6, 9],
	               swap: [{cols: [0, 15], rows: [8, 11], dRow: -4}, {cols: [16, 31], rows: [7, 13], dRow: -7}]},
	// The cliff under the farm's north edge (12 wide, repeats) and the mine's cave mouth (2 wide), from the first farm
	cliff:       {stamp: "cliff_strip", crop: [18, 0, 12, 5]},
	cliff_cave:  {stamp: "cliff_strip", crop: [16, 0, 2, 5]},
	cliff_ladder:{stamp: "cliff_strip", crop: [10, 0, 6, 5]},
	// Shop signs for walls (TS_town, the LPC base atlas)
	sign_inn:    {src: [29, 10, 1, 1], tileset: "TS_town"},
	sign_sword:  {src: [30, 10, 1, 1], tileset: "TS_town"},
	sign_potion: {src: [31, 10, 1, 1], tileset: "TS_town"},

	// Trees and bushes (canopy over the player, trunk solid)
	pine:      {src: [30, 0, 2, 5], above: 3, solid: [[0, 4, 2, 1]]},
	oak:       {src: [29, 28, 3, 4], above: 3, solid: [[1, 3, 1, 1]]},
	sapling:   {src: [27, 29, 2, 3], above: 2, solid: [[0, 2, 1, 1]]},
	bush_big:  {src: [24, 12, 3, 3], above: 1, solid: [[0, 1, 3, 2]]},
	bush_big2: {src: [27, 12, 3, 3], above: 1, solid: [[0, 1, 3, 2]]},

	// Props
	barrel:      {src: [9, 27, 1, 2], above: 1, solid: [[0, 1, 1, 1]]},
	barrels:     {src: [11, 27, 2, 2], above: 1, solid: [[0, 1, 2, 1]]},
	chest:       {src: [9, 24, 1, 1], solid: [[0, 0, 1, 1]]},
	crate_open:  {src: [10, 24, 1, 1], solid: [[0, 0, 1, 1]]},
	scarecrow:   {src: [10, 25, 1, 2], above: 1, solid: [[0, 1, 1, 1]]},
	signpost:    {src: [11, 24, 1, 1], solid: [[0, 0, 1, 1]]},
	signpost2:   {src: [11, 25, 1, 1], solid: [[0, 0, 1, 1]]},
	board:       {src: [12, 24, 1, 1], solid: [[0, 0, 1, 1]]},
	board_notes: {src: [12, 25, 1, 1], solid: [[0, 0, 1, 1]]},
	rope_fence:  {src: [13, 24, 3, 1], solid: [[0, 0, 3, 1]]},
	clothesline: {src: [13, 25, 3, 1], solid: [[0, 0, 1, 1], [2, 0, 1, 1]]},
	hay_cart:    {src: [13, 26, 3, 2], solid: [[0, 1, 3, 1]]},
	hay_bale:    {src: [14, 29, 2, 3], solid: [[0, 1, 2, 2]]},
	wheelbarrow: {src: [12, 30, 2, 2], solid: [[0, 1, 2, 1]]},
	bucket:      {src: [9, 31, 1, 1]},
	statue:      {src: [17, 12, 1, 2], above: 1, solid: [[0, 1, 1, 1]]},
	stump:       {src: [23, 18, 1, 1], solid: [[0, 0, 1, 1]]},
	picket:      {src: [19, 20, 3, 1], solid: [[0, 0, 3, 1]]},
	bridge:      {src: [16, 16, 3, 2]},      // the railed bridge, 3 wide: lay it over "b" water cells
	bridge_small:{src: [13, 16, 3, 2]},

	// Small decorations for scatter (walk-over)
	mushrooms:   {src: [27, 28, 1, 1], role: "decor"},
	toadstool:   {src: [26, 31, 1, 1], role: "decor"},
	cattails:    {src: [26, 29, 1, 2], role: "decor"},
	leaves:      {src: [13, 14, 1, 1], role: "decor"},
	leaves2:     {src: [13, 15, 1, 1], role: "decor"},
	sprout:      {src: [10, 31, 1, 1], role: "decor"},
	lilypads:    {src: [8, 30, 1, 1], role: "decor"},
	lilypads2:   {src: [8, 31, 1, 1], role: "decor"},
};

// The building library (tools/buildings/library.js --tileset): buildings on TS_buildings, by name
const library = require("./buildings.json");
for(const [name, def] of Object.entries(library)){
	if(things[name]) throw new Error("building " + name + " has the name of a thing already");
	things[name] = def;
}

module.exports = {terrains, legend, things};
