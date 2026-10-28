/// Whisperwood (milestone 10.3, docs/MILESTONES.md): the forest east of the village, across the mended bridge.
///
/// A wild place, so it's generated (like a mine floor's shape) but from one fixed seed: the same wood every visit.
/// Clearings and paths among dense trees, a pond, and the old shrine in its heart. Trees, bushes, weeds and things
/// to forage come back each day through the gathering system (resource_areas has an area for rm_forest). At night,
/// pixies and moths come out: the sources of pixie dust and moonsilk.

#macro FOREST_W 48
#macro FOREST_H 30
#macro FOREST_SEED 7741

/// @description The wood's layout: {grid[x][y] (0 open, 1 trees, 3 water), entrance, shrine, pond [x, y, w, h], dist}.
/// Seeded, so it's always the same.
function forest_generate(){
	random_set_seed(FOREST_SEED);
	var W = FOREST_W, H = FOREST_H, g;
	// Cellular-automata clearings, with a thick wall of trees round the edge
	g = array_create(W);
	for(var x1 = 0; x1 < W; x1++){
		g[x1] = array_create(H, 1);
		for(var y1 = 2; y1 < H - 2; y1++) if(x1 > 1 && x1 < W - 2) g[x1][y1] = (random(1) < 0.42) ? 1 : 0;
	}
	repeat(4){
		var g2 = array_create(W);
		for(var x1 = 0; x1 < W; x1++){
			g2[x1] = array_create(H, 1);
			for(var y1 = 2; y1 < H - 2; y1++){
				if(x1 < 2 || x1 >= W - 2) continue;
				var n = 0;
				for(var dx = -1; dx <= 1; dx++) for(var dy = -1; dy <= 1; dy++) if((dx != 0 || dy != 0) && g[x1 + dx][y1 + dy]) n++;
				g2[x1][y1] = (n >= 5) ? 1 : ((n <= 3) ? 0 : g[x1][y1]);
			}
		}
		g = g2;
	}
	// A path in from the west edge, until it meets the biggest clearing
	var region = mine_largest_region(g);
	var inRegion = array_create(W);
	for(var x1 = 0; x1 < W; x1++) inRegion[x1] = array_create(H, false);
	for(var i = 0; i < array_length(region); i++) inRegion[region[i][0]][region[i][1]] = true;
	var ey = H div 2;
	for(var x1 = 1; x1 < W - 2; x1++){
		if(inRegion[x1][ey]) break;
		g[x1][ey] = 0; g[x1][ey - 1] = 0; g[x1][ey + 1] = 0;
	}
	// Everything not reachable from the entrance becomes trees
	var entrance = [2, ey];
	var dist = mine_distances(g, entrance);
	for(var x1 = 0; x1 < W; x1++) for(var y1 = 0; y1 < H; y1++) if(!g[x1][y1] && dist[x1][y1] < 0) g[x1][y1] = 1;
	// The shrine: the farthest point, in a clearing of its own
	var shrine = entrance, far = 0;
	for(var x1 = 3; x1 < W - 3; x1++) for(var y1 = 3; y1 < H - 3; y1++) if(dist[x1][y1] > far){ far = dist[x1][y1]; shrine = [x1, y1]; }
	for(var dx = -2; dx <= 2; dx++) for(var dy = -2; dy <= 2; dy++) g[shrine[0] + dx][shrine[1] + dy] = 0;
	// A pond where there's room for it and a ring of grass around it (so no path is ever cut)
	var pond = undefined;
	for(var tries = 0; tries < 400 && pond == undefined; tries++){
		var px = irandom_range(4, W - 10), py = irandom_range(4, H - 9);
		if(point_distance(px, py, entrance[0], entrance[1]) < 8 || point_distance(px, py, shrine[0], shrine[1]) < 7) continue;
		var ok = true;
		for(var dx = -1; dx <= 5 && ok; dx++) for(var dy = -1; dy <= 4 && ok; dy++) if(g[px + dx][py + dy] != 0) ok = false;
		if(ok){
			pond = [px, py, 5, 4];
			for(var dx = 0; dx < 5; dx++) for(var dy = 0; dy < 4; dy++) g[px + dx][py + dy] = 3;
		}
	}
	dist = mine_distances(g, entrance);
	randomize();
	return {grid: g, entrance: entrance, shrine: shrine, pond: pond, dist: dist};
}

/// @description Room Start in rm_forest: paint the ground, the pond and the deep wood; the trees at the edge of the
/// clearings; the shrine and the way out; and (at night) the pixies and moths. Resources come after (gathering).
function forest_room_start(){
	var f = forest_generate();
	global.forestMap = f;
	var g = f.grid;
	var lFloor = layer_create(400, "ForestGround");
	var lCol = layer_create(350, "ForestCollision");
	var tFloor = layer_tilemap_create(lFloor, 0, 0, TS_terrain, FOREST_W, FOREST_H);
	global.mineWalls = layer_tilemap_create(lCol, 0, 0, TS_terrain, FOREST_W, FOREST_H); // what collides (see collision_solids)
	layer_set_visible(lCol, false);
	static GRASS = [0 + 25 * 32, 0 + 25 * 32, 0 + 25 * 32, 1 + 25 * 32, 2 + 25 * 32];
	static DEEP = 7 + 25 * 32;
	for(var x1 = 0; x1 < FOREST_W; x1++) for(var y1 = 0; y1 < FOREST_H; y1++){
		var v = g[x1][y1];
		if(v == 1){
			tilemap_set(global.mineWalls, 1, x1, y1);
			// Trees stand along the edge of the clearings (the deep wood behind them is just canopy)
			var edge = false;
			for(var dx = -1; dx <= 1 && !edge; dx++) for(var dy = -1; dy <= 1 && !edge; dy++){
				var nx = x1 + dx, ny = y1 + dy;
				if(nx >= 0 && ny >= 0 && nx < FOREST_W && ny < FOREST_H && g[nx][ny] != 1) edge = true;
			}
			// Edge trees stand on grass; the deep wood behind is dark undergrowth under their canopies
			tilemap_set(tFloor, edge ? GRASS[0] : DEEP, x1, y1);
			if(edge) resource_create_instance({key: ((x1 * 7 + y1 * 3) mod 5 < 2) ? "ancient_pine" : "ancient_oak", gx: x1, gy: y1, hp: 999, days: 0, area: -2});
		} else tilemap_set(tFloor, GRASS[(x1 * 13 + y1 * 7) mod array_length(GRASS)], x1, y1);
	}
	// The pond: a 9-patch of the grass-ringed water tiles
	if(f.pond != undefined){
		var p = f.pond;
		for(var dx = 0; dx < p[2]; dx++) for(var dy = 0; dy < p[3]; dy++){
			var cx = (dx == 0) ? 6 : ((dx == p[2] - 1) ? 8 : 7);
			var cy = (dy == 0) ? 11 : ((dy == p[3] - 1) ? 13 : 12);
			tilemap_set(tFloor, cx + cy * 32, p[0] + dx, p[1] + dy);
			tilemap_set(global.mineWalls, 1, p[0] + dx, p[1] + dy);
		}
		// Water for the watering can (and fishing): the same invisible zone the farm pond uses
		instance_create_depth((p[0] + p[2] / 2) * 32, (p[1] + p[3] / 2) * 32, 0, obj_water_zone, {image_xscale: p[2] * 2, image_yscale: p[3] * 2});
	}
	// The shrine, and the path back to the village
	instance_create_depth(f.shrine[0] * 32 + 16, f.shrine[1] * 32 + 24, 0, obj_shrine);
	instance_create_depth(f.entrance[0] * 32, f.entrance[1] * 32 + 16, 0, obj_path, {target: "village"});
	// Night: pixies and moths flit about the clearings
	if(global.clock.minutes >= 1200 || global.clock.minutes < DAY_START) forest_spawn_night(f);
	with(game){ if(spawnRoom == rm_forest && spawnX <= 0){ spawnX = f.entrance[0] * 32 + 40; spawnY = f.entrance[1] * 32 + 22; } }
}

/// @description Pixies and moths, a few of each, somewhere open and away from the path in.
function forest_spawn_night(_f){
	var spots = [];
	for(var x1 = 4; x1 < FOREST_W - 2; x1++) for(var y1 = 2; y1 < FOREST_H - 2; y1++)
		if(_f.grid[x1][y1] == 0 && _f.dist[x1][y1] > 10) array_push(spots, [x1, y1]);
	repeat(min(array_length(spots), 7)){
		var k = irandom(array_length(spots) - 1), c = spots[k];
		array_delete(spots, k, 1);
		monster_spawn(choose("pixie", "pixie", "moth", "moth", "moth"), c[0] * 32 + 16, c[1] * 32 + 16, 1);
	}
}

// ---------------------------------------------------------------- the way in and out

/// @description Go to Whisperwood (it's across the east bridge), arriving at the path in.
function forest_goto(){
	with(game){
		spawnRoom = rm_forest;
		spawnX = 0; spawnY = 0;          // forest_room_start puts you at the path in
		spawnPlayerFacing = dir.right;
		restartRoom = false;
		doTransition = true;
	}
}

/// @description Back to the village, at the bridge.
function forest_leave(){
	with(game){
		spawnRoom = rm_2;
		var p = layout_point("rm_2", "bridge");
		spawnX = p[0]; spawnY = p[1];
		spawnPlayerFacing = dir.left;
		restartRoom = false;
		doTransition = true;
	}
}

// ---------------------------------------------------------------- foraging

/// @description Wild things to pick in Whisperwood: item ids "w|<key>". Eaten from the hotbar like produce (energy),
/// or sold. Art: a part of spr_tile_terrain, for the icon.
function forage_table(){
	static t = {
		mushroom:  {name: "Wild Mushroom", energy: 20, sell: 25, art: [862, 893, 43, 34], desc: "Earthy and good in a stew."},
		toadstool: {name: "Red Toadstool", energy: 0,  sell: 60, art: [830, 994, 32, 30], desc: "Pretty, but don't eat it. Elda might want it."},
		herb:      {name: "Wild Herb",     energy: 10, sell: 18, art: [416, 453, 30, 33], desc: "Fragrant leaves from the forest floor."},
	};
	return t;
}

/// @description Eat a forage item from the hotbar. Returns false if it isn't something you'd eat.
function forage_eat(_stack){
	var key = string_split(_stack.id, "|")[1];
	var f = forage_table()[$ key];
	if(f == undefined || f.energy <= 0){ farm_message("You'd rather not eat that"); return false; }
	global.vitals.energy = min(vitals_max_energy(), global.vitals.energy + f.energy);
	_stack.count--;
	if(_stack.count <= 0) global.inv.slots[global.inv.hotbar] = undefined;
	farm_message("Ate " + f.name + "  (+" + string(f.energy) + " energy)");
	return true;
}
