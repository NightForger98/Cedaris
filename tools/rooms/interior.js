// Interiors built from TS_interior pieces, for rooms without a captured stamp (the town's inn, shops and homes).
// interior({...}) returns a room spec: a cream border, a back wall two cells high, a floor, a doorway in the bottom
// edge with its exit, and furniture. Like the farmhouse, everything draws under the player and its whole art is
// solid, so you can never stand behind a piece and be hidden by it.
//
//   w, h        size in cells, border included (the floor is rows 3 to h-2, columns 1 to w-2)
//   wall        "blue" | "panel" | "stone" | "paper"        floor  "wood" | "parquet" | "stone" | "checker"
//   door        the left column of the two-cell doorway in the bottom edge
//   exit        {room, x, y}: where the doorway leads (you arrive facing down)
//   furniture   [{is, at, ...}]: pieces from the table below; a piece can be repeated ("repeat": [nx, ny]),
//               walk: true leaves it walkable (rugs), wall: true hangs it on the back wall (not solid)
//   instances, points, areas: added to the spec as they are
const pieces = {
	// Back wall and windows (2 x 2)
	window:       {src: [7, 18, 2, 2], wall: true},
	window_wood:  {src: [9, 18, 2, 2], wall: true},
	// On the wall
	clock:        {src: [21, 5, 1, 1], wall: true},
	swords:       {src: [21, 8, 1, 1], wall: true},
	bows:         {src: [21, 9, 1, 1], wall: true},
	axe:          {src: [21, 10, 1, 1], wall: true},
	shield:       {src: [21, 11, 1, 1], wall: true},
	painting:     {src: [23, 15, 3, 1], wall: true},
	portrait:     {src: [23, 17, 1, 2], wall: true},
	antlers:      {src: [25, 11, 1, 1], wall: true},
	notice:       {src: [28, 16, 1, 1], wall: true},
	// Against the wall (their top row overlaps the wall, so stand them at row 1 or 2)
	cupboard:     {src: [25, 9, 1, 2]},
	bookshelf:    {src: [26, 9, 1, 2]},
	dish_shelf:   {src: [27, 9, 1, 2]},
	drawers:      {src: [28, 9, 1, 2]},
	shelf_low:    {src: [29, 9, 1, 2]},
	shelf_books:  {src: [30, 9, 1, 2]},
	shelf_dishes: {src: [31, 9, 1, 2]},
	shelf_open:   {src: [26, 11, 1, 2]},
	kitchen_sink: {src: [27, 11, 1, 2]},
	stove:        {src: [29, 11, 1, 2]},
	stove_pipe:   {src: [25, 5, 1, 3]},
	oven:         {src: [26, 8, 1, 1]},
	pump:         {src: [26, 5, 1, 2]},
	pots:         {src: [26, 7, 1, 1]},
	// The counter: a top and a front, 1 wide - repeat it along a row
	counter:      {src: [28, 11, 1, 2]},
	// Freestanding
	bed:          {src: [21, 0, 2, 3]},
	bed_big:      {src: [23, 0, 2, 3]},
	bed_small:    {src: [27, 5, 2, 3]},
	barrels:      {src: [21, 3, 2, 2]},
	crate_tall:   {src: [23, 3, 1, 2]},
	chest:        {src: [21, 18, 1, 1]},
	chest2:       {src: [22, 18, 1, 1]},
	cask:         {src: [27, 14, 1, 2]},
	lamp:         {src: [25, 3, 1, 1]},
	weapon_rack:  {src: [21, 6, 1, 2]},
	armour:       {src: [21, 14, 4, 1]},
	table:        {src: [25, 0, 2, 3]},   // a long dining table, seen from above
	spinning_wheel:{src: [22, 6, 2, 2]},
	table_small:  {src: [24, 6, 1, 1]},
	table_round:  {src: [26, 13, 1, 1]},
	table_round2: {src: [27, 16, 1, 2]},
	stool:        {src: [31, 7, 1, 1]},
	chair:        {src: [29, 3, 1, 1]},
	chair_left:   {src: [29, 5, 1, 1]},
	chair_right:  {src: [31, 5, 1, 1]},
	plant:        {src: [29, 7, 1, 1]},
	plant_big:    {src: [21, 15, 1, 1]},
	tree_pot:     {src: [22, 15, 1, 1]},
	vase:         {src: [30, 7, 1, 1]},
	flowers:      {src: [21, 16, 1, 2]},
	flower_box:   {src: [22, 16, 1, 2]},
	sofa:         {src: [19, 17, 2, 2]},
	// Small things for counters and tables (not solid by themselves)
	potions:      {src: [22, 13, 2, 1], small: true},
	sacks:        {src: [21, 13, 1, 1], small: true},
	bottles:      {src: [22, 10, 2, 1], small: true},
	jars:         {src: [24, 11, 1, 1], small: true},
	bowl:         {src: [24, 13, 1, 1], small: true},
	candle:       {src: [25, 13, 1, 1], small: true},
	books:        {src: [25, 12, 1, 1], small: true},
	scroll:       {src: [24, 12, 1, 1], small: true},
	lantern:      {src: [22, 11, 1, 1], small: true},
	plates:       {src: [22, 8, 1, 1], small: true},
	skull:        {src: [21, 12, 1, 1], small: true},
	rope:         {src: [24, 9, 1, 2], small: true},
};

const walls = {blue: [7, 16], panel: [9, 16], stone: [11, 16], paper: [7, 20]};
const floors = {wood: [3, 10, 2, 3], parquet: [3, 16, 2, 3], stone: [5, 16, 2, 3], checker: [5, 10, 2, 3]};

function interior(o){
	const {w, h, door} = o;
	const TS = "TS_interior";
	const map = [];
	for(let y = 0; y < h; y++){
		let row = "";
		for(let x = 0; x < w; x++){
			const floor = y >= 3 && y <= h - 2 && x >= 1 && x <= w - 2;
			const doorway = y === h - 1 && (x === door || x === door + 1);
			row += (floor || doorway) ? "." : "#";
		}
		map.push(row);
	}

	const [wc, wr] = walls[o.wall || "blue"], [fc, fr, fw, fh] = floors[o.floor || "wood"];
	const span = (n, k) => Math.ceil(n / k);
	const things = [
		// Floor and back wall (the floor runs under the doorway too)
		{src: [fc, fr, fw, fh], tileset: TS, role: "ground", repeat: [span(w - 2, fw), span(h - 3, fh)], at: [1, 3]},
		{src: [wc, wr, 2, 2], tileset: TS, role: "ground", repeat: [span(w - 2, 2), 1], at: [1, 1]},
		// The border: cream trim around the room, the doorway's threshold in the bottom edge
		{src: [3, 15, 2, 1], tileset: TS, role: "terrain", repeat: [span(w, 2), 1], at: [0, 0]},
		{src: [4, 13, 1, 3], tileset: TS, role: "terrain", repeat: [1, span(h - 1, 3)], at: [0, 1]},
		{src: [3, 13, 1, 3], tileset: TS, role: "terrain", repeat: [1, span(h - 1, 3)], at: [w - 1, 1]},
		{src: [3, 13, 1, 1], tileset: TS, role: "terrain", repeat: [door - 1, 1], at: [1, h - 1]},
		{src: [3, 13, 1, 1], tileset: TS, role: "terrain", repeat: [w - door - 3, 1], at: [door + 2, h - 1]},
		{src: [13, 14, 1, 1], tileset: TS, role: "buildings", repeat: [2, 1], at: [door, h - 1]},
	];

	for(const f of o.furniture || []){
		const p = pieces[f.is];
		if(!p) throw new Error(`interior: unknown piece "${f.is}"`);
		const def = Object.assign({tileset: TS, role: "buildings"}, p, f);
		delete def.is;
		const [, , pw, ph] = def.src, [nx, ny] = def.repeat || [1, 1];
		if(!def.solid && !def.walk && !def.wall && !def.small) def.solid = [[0, 0, pw * nx, ph * ny]];
		things.push(def);
	}

	// The way out, and where you arrive coming in (just inside the doorway, facing up)
	const doorX = (door + 1) * 32, arriveY = h * 32 - 40;
	const instances = [
		{obj: "obj_plyr", x: doorX, y: arriveY},
		{obj: "camera", x: doorX, y: arriveY},
		{obj: "obj_transition", x: doorX, y: h * 32 - 16, sx: 4, sy: 2,
		 code: `targetRoom = ${o.exit.room};\ntargetX = ${o.exit.x};\ntargetY = ${o.exit.y};\nPlayerFacingBefore = dir.down;\nPlayerFacingAfter = dir.down;`},
		...(o.instances || []),
	];
	return {base: "none", view: [375, 210], legend: {".": {}, "#": {solid: true}}, map, things, instances,
	        points: Object.assign({door: [doorX, arriveY]}, o.points || {}), areas: o.areas || {}};
}

// A shopkeeper or resident who stands still at their post (behind a counter), facing down, and can be talked to
// across it. slot: "man" or "woman" (the villager living in this room takes it, see villager_take in people).
function keeper(slot, cx, cy){
	return {obj: slot === "woman" ? "obj_npc_womantest" : "obj_npc_mantest", x: cx * 32 + 16, y: cy * 32 + 24,
	        code: "alarm[1] = -1; // stays at the counter\nmoveX = 0;\nmoveY = 0;\ny_frame = 10;\ntalkRange = 96;"};
}

module.exports = {interior, keeper, pieces};
