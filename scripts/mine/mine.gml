/// The mine (roadmap phase 4, plan in docs/LEVELS.md): one room, rm_mine, rebuilt for each floor while the game runs.
///
/// Layout: cellular-automata cave from a seed (the save's mine seed + the floor), so a floor's shape is the same
/// every visit. Contents (rocks, ore, monsters) are rolled fresh each visit, like Stardew, so nothing per floor
/// is saved. global.world.mine = {seed, deepest, floor}. Every 5th floor you reach unlocks the lift at the entrance.
/// Tiles are drawn with tilemap_set on layers made at Room Start; an invisible tilemap of walls (and lava) is what
/// the player and monsters collide with (global.mineWalls, see collision_solids).

#macro MINE_W 40           // cells (32 px)
#macro MINE_H 28
#macro MINE_FLOORS 30
#macro MINE_LIFT_EVERY 5

/// @description Bands of floors: how they look, how cold or hot they are, and what's in them.
/// ground: floor tiles (index = row * 32 + column in TS_terrain; only fully opaque ones). cold: like climate_cold (negative = heat).
/// dark: how dark it is away from your light. rocks / monsters: weighted kinds.
function mine_bands(){
	static b = [
		{name: "Earthen Caves", ground: [16 + 3 * 32, 17 + 5 * 32, 16 + 5 * 32, 17 + 5 * 32], cold: 0, dark: 0.35,
		 rocks: [["stone", 50], ["copper_vein", 22], ["coal_vein", 12], ["iron_vein", 6], ["boulder", 6], ["gem_node", 2]],
		 monsters: [["slime", 30], ["bat", 15], ["goblin", 30], ["zombie", 15], ["wolfkin", 10]]},
		{name: "Frozen Halls", ground: [30 + 15 * 32, 31 + 15 * 32, 31 + 16 * 32, 31 + 18 * 32], cold: 4, dark: 0.5,
		 rocks: [["stone", 35], ["ice_rock", 22], ["iron_vein", 15], ["silver_vein", 10], ["coal_vein", 8], ["boulder", 5], ["gem_node", 5]],
		 monsters: [["slime", 15], ["bat", 15], ["skeleton", 30], ["wolfkin", 20], ["troll", 10], ["orc", 10]]},
		{name: "Ember Depths", ground: [19 + 9 * 32, 19 + 11 * 32, 20 + 11 * 32], cold: -2, dark: 0.6,
		 rocks: [["stone", 25], ["ember_rock", 22], ["gold_vein", 15], ["coal_vein", 10], ["silver_vein", 8], ["mithril_vein", 0], ["gem_node", 6]],
		 monsters: [["bat", 15], ["skeleton", 15], ["orc", 25], ["troll", 20], ["lizardfolk", 25], ["witch", 12]]},
		// Below floor 30, once the Ember Drake falls: endless, every band's monsters (tougher each floor), void nodes
		{name: "The Deep", ground: [19 + 9 * 32, 19 + 11 * 32, 20 + 11 * 32], cold: 0, dark: 0.7,
		 rocks: [["stone", 20], ["gem_node", 10], ["gold_vein", 12], ["mithril_vein", 14], ["void_node", 4], ["ember_rock", 10], ["ice_rock", 10], ["silver_vein", 10], ["coal_vein", 10]],
		 monsters: [["slime", 8], ["bat", 8], ["ghost", 12], ["eyeball", 14], ["skeleton", 14], ["orc", 14], ["troll", 14], ["lizardfolk", 16], ["wolfkin", 8], ["witch", 10]]},
	];
	return b;
}

function mine_band(_floor){ return mine_bands()[(_floor <= 9) ? 0 : ((_floor <= 19) ? 1 : ((_floor <= MINE_FLOORS) ? 2 : 3))]; }

/// @description The mine's saved state (made on first use).
function mine_state(){
	if(!is_struct(global.world[$ "mine"])) global.world.mine = {seed: irandom(999999), deepest: 0, floor: 1};
	if(!is_array(global.world.mine[$ "bosses"])) global.world.mine.bosses = []; // floors whose boss you've beaten
	return global.world.mine;
}

/// @description Floors the lift can take you to: 1, then every 5th floor you've reached.
function mine_lift_floors(){
	var out = [1], d = mine_state().deepest;
	for(var f = MINE_LIFT_EVERY; f <= d; f += MINE_LIFT_EVERY) array_push(out, f);
	return out;
}

// ---------------------------------------------------------------- generation

/// @description Build a floor's layout: {grid[x][y] (1 = wall), entrance [gx, gy], ladder [gx, gy], lava [[gx, gy]...],
/// region [[gx, gy]...] (reachable floor cells), dist[x][y] (steps from the entrance, -1 = unreachable)}.
/// Seeded, so the same floor always has the same shape.
function mine_generate(_floor){
	var st = mine_state();
	random_set_seed(st.seed + _floor * 7919);
	var W = MINE_W, H = MINE_H, g, region;
	for(var attempt = 0; attempt < 10; attempt++){
		// Random fill, walls round the edge
		g = array_create(W);
		for(var x1 = 0; x1 < W; x1++){
			g[x1] = array_create(H, 1);
			for(var y1 = 1; y1 < H - 1; y1++) if(x1 > 0 && x1 < W - 1) g[x1][y1] = (random(1) < 0.46) ? 1 : 0;
		}
		// Smooth: a cell becomes wall with 5+ wall neighbours, floor with 3 or fewer
		repeat(5){
			var g2 = array_create(W);
			for(var x1 = 0; x1 < W; x1++){
				g2[x1] = array_create(H, 1);
				for(var y1 = 1; y1 < H - 1; y1++){
					if(x1 == 0 || x1 == W - 1) continue;
					var n = 0;
					for(var dx = -1; dx <= 1; dx++) for(var dy = -1; dy <= 1; dy++) if((dx != 0 || dy != 0) && g[x1 + dx][y1 + dy]) n++;
					g2[x1][y1] = (n >= 5) ? 1 : ((n <= 3) ? 0 : g[x1][y1]);
				}
			}
			g = g2;
		}
		// Keep only the biggest open area, so everything is reachable
		region = mine_largest_region(g);
		if(array_length(region) >= W * H * 0.3) break;
	}
	var inRegion = array_create(W);
	for(var x1 = 0; x1 < W; x1++) inRegion[x1] = array_create(H, false);
	for(var i = 0; i < array_length(region); i++) inRegion[region[i][0]][region[i][1]] = true;
	for(var x1 = 0; x1 < W; x1++) for(var y1 = 0; y1 < H; y1++) if(!inRegion[x1][y1]) g[x1][y1] = 1;

	// Entrance: a floor cell with wall above it (the ladder up leans on it), as far left as the cave allows
	var entrance = region[0], best = infinity;
	for(var i = 0; i < array_length(region); i++){
		var c = region[i];
		if(!g[c[0]][c[1] - 1] || g[c[0]][c[1] + 1]) continue;
		var score2 = c[0] + random(8);
		if(score2 < best){ best = score2; entrance = c; }
	}
	// Ladder down: somewhere far from the entrance
	var dist = mine_distances(g, entrance);
	var far = 0;
	for(var i = 0; i < array_length(region); i++) far = max(far, dist[region[i][0]][region[i][1]]);
	var cands = [];
	for(var i = 0; i < array_length(region); i++) if(dist[region[i][0]][region[i][1]] >= far * 0.8) array_push(cands, region[i]);
	var ladder = cands[irandom(array_length(cands) - 1)];

	// Ember Depths: single cells of lava, only where all 8 neighbours are open (so no path is ever cut)
	var lava = [];
	if(mine_band(_floor).cold < 0){
		for(var i = 0; i < array_length(region); i++){
			var c = region[i];
			if(random(1) > 0.05 || point_distance(c[0], c[1], entrance[0], entrance[1]) < 3 || point_distance(c[0], c[1], ladder[0], ladder[1]) < 2) continue;
			var open = true;
			for(var dx = -1; dx <= 1 && open; dx++) for(var dy = -1; dy <= 1 && open; dy++) if(g[c[0] + dx][c[1] + dy]) open = false;
			if(open){ g[c[0]][c[1]] = 2; array_push(lava, c); }
		}
	}
	randomize(); // contents are rolled fresh each visit
	return {grid: g, entrance: entrance, ladder: ladder, lava: lava, region: region, dist: dist};
}

/// @description The biggest 4-connected area of floor cells: [[gx, gy]...].
function mine_largest_region(_g){
	var W = array_length(_g), H = array_length(_g[0]);
	var seen = array_create(W);
	for(var x1 = 0; x1 < W; x1++) seen[x1] = array_create(H, false);
	var best = [];
	for(var x1 = 0; x1 < W; x1++) for(var y1 = 0; y1 < H; y1++){
		if(_g[x1][y1] || seen[x1][y1]) continue;
		var area = [], stack = [[x1, y1]];
		seen[x1][y1] = true;
		while(array_length(stack) > 0){
			var c = array_pop(stack);
			array_push(area, c);
			static nb = [[1, 0], [-1, 0], [0, 1], [0, -1]];
			for(var k = 0; k < 4; k++){
				var nx = c[0] + nb[k][0], ny = c[1] + nb[k][1];
				if(nx < 0 || ny < 0 || nx >= W || ny >= H || _g[nx][ny] || seen[nx][ny]) continue;
				seen[nx][ny] = true;
				array_push(stack, [nx, ny]);
			}
		}
		if(array_length(area) > array_length(best)) best = area;
	}
	return best;
}

/// @description Steps from a cell to every reachable floor cell (breadth first); -1 where unreachable.
function mine_distances(_g, _from){
	var W = array_length(_g), H = array_length(_g[0]);
	var d = array_create(W);
	for(var x1 = 0; x1 < W; x1++) d[x1] = array_create(H, -1);
	d[_from[0]][_from[1]] = 0;
	var queue = [_from], qi = 0;
	while(qi < array_length(queue)){
		var c = queue[qi++];
		static nb = [[1, 0], [-1, 0], [0, 1], [0, -1]];
		for(var k = 0; k < 4; k++){
			var nx = c[0] + nb[k][0], ny = c[1] + nb[k][1];
			if(nx < 0 || ny < 0 || nx >= W || ny >= H || _g[nx][ny] || d[nx][ny] != -1) continue;
			d[nx][ny] = d[c[0]][c[1]] + 1;
			array_push(queue, [nx, ny]);
		}
	}
	return d;
}

// ---------------------------------------------------------------- building the room

/// @description Room Start in rm_mine: generate the floor, paint its tiles, place ladders, rocks and monsters,
/// and put the player at the entrance.
function mine_room_start(){
	var st = mine_state();
	var fl = st.floor;
	var band = mine_band(fl);
	var m = mine_generate(fl);
	global.mineFloor = m;
	st.deepest = max(st.deepest, fl);

	// Tiles: ground everywhere (it shows under the cliff faces' ragged edge), then walls, then the collision map
	var lFloor = layer_create(400, "MineFloor");
	var lWall = layer_create(300, "MineWalls");
	var lCol = layer_create(350, "MineCollision");
	var tFloor = layer_tilemap_create(lFloor, 0, 0, TS_terrain, MINE_W, MINE_H);
	var tWall = layer_tilemap_create(lWall, 0, 0, TS_terrain, MINE_W, MINE_H);
	global.mineWalls = layer_tilemap_create(lCol, 0, 0, TS_terrain, MINE_W, MINE_H);
	layer_set_visible(lCol, false);
	var g = m.grid, ng = array_length(band.ground);
	static FRONT = 1 + 3 * 32;   // cliff face, for walls with open floor below
	static TOP = 10 + 8 * 32;    // dark rock
	static LAVA = [16 + 9 * 32, 17 + 9 * 32];
	for(var x1 = 0; x1 < MINE_W; x1++) for(var y1 = 0; y1 < MINE_H; y1++){
		tilemap_set(tFloor, band.ground[(x1 * 7 + y1 * 13) mod ng], x1, y1);
		if(g[x1][y1] == 2){ tilemap_set(tFloor, LAVA[(x1 + y1) mod 2], x1, y1); tilemap_set(global.mineWalls, 1, x1, y1); continue; }
		if(g[x1][y1] == 0) continue;
		var open = (y1 < MINE_H - 1) && g[x1][y1 + 1] != 1;
		tilemap_set(tWall, open ? FRONT : TOP, x1, y1);
		tilemap_set(global.mineWalls, 1, x1, y1);
	}

	// Ladders
	var e = m.entrance, l = m.ladder;
	instance_create_depth(e[0] * 32 + 16, e[1] * 32 + 16, 0, obj_mine_ladder, {down: false});
	// On a boss floor the ladder down only appears when the boss falls (see mine_boss_beaten); below 30 once the drake has
	var boss = mine_boss(fl);
	if(boss == "" && (fl < MINE_FLOORS || mine_deep_open())) instance_create_depth(l[0] * 32 + 16, l[1] * 32 + 16, 0, obj_mine_ladder, {down: true});

	// Rocks and ore, fresh each visit (the mine's store is emptied first)
	var objs = resource_objects("rm_mine");
	array_resize(objs, 0);
	for(var i = 0; i < array_length(m.region); i++){
		var c = m.region[i];
		if(m.dist[c[0]][c[1]] < 3 || (c[0] == l[0] && c[1] == l[1]) || random(1) > 0.12) continue;
		var kind = resource_pick_kind(mine_rock_kinds(fl));
		var d = resource_make(kind, c[0], c[1], -1);
		array_push(objs, d);
		resource_create_instance(d);
	}

	// A treasure chest the first time you reach a lift floor
	mine_place_chest(m, fl);

	// The boss waits where the ladder down will be
	if(boss != "") monster_spawn(boss, l[0] * 32 + 16, l[1] * 32 + 20, fl);

	// Monsters, away from the entrance
	var count = min(3 + fl div 3, 12);
	if(boss != "") count = count div 2;
	var spots = [];
	for(var i = 0; i < array_length(m.region); i++){
		var c = m.region[i];
		if(m.dist[c[0]][c[1]] >= 8 && !resource_at_cell(c[0], c[1])) array_push(spots, c);
	}
	repeat(min(count, array_length(spots))){
		var k = irandom(array_length(spots) - 1);
		var c = spots[k];
		array_delete(spots, k, 1);
		monster_spawn(resource_pick_kind(mine_monster_kinds(fl)), c[0] * 32 + 16, c[1] * 32 + 20, fl);
	}

	// The player arrives at the ladder up
	with(game){ spawnRoom = rm_mine; spawnX = e[0] * 32 + 16; spawnY = e[1] * 32 + 22; spawnPlayerFacing = dir.down; }
}

/// @description Rock kinds for a floor: the band's, with mithril only near the bottom.
function mine_rock_kinds(_floor){
	var k = mine_band(_floor).rocks;
	if(_floor < 25) return k;
	var out = [];
	for(var i = 0; i < array_length(k); i++) array_push(out, (k[i][0] == "mithril_vein") ? ["mithril_vein", min(20, 6 + (_floor - 25) * 2)] : k[i]);
	return out;
}

/// @description Monster kinds for a floor: the band's, each only from its first floor (see monster_table).
function mine_monster_kinds(_floor){
	var k = mine_band(_floor).monsters, out = [];
	for(var i = 0; i < array_length(k); i++) if(monster_table()[$ k[i][0]].from <= _floor) array_push(out, k[i]);
	if(array_length(out) == 0) out = [["slime", 1]];
	return out;
}

function resource_at_cell(_gx, _gy){
	var found = false;
	with(obj_resource) if(data.gx == _gx && data.gy == _gy) found = true;
	return found;
}

// ---------------------------------------------------------------- moving around

/// @description Go to a mine floor (fades out, rebuilds the room). From the farm, the lift or a ladder.
function mine_goto(_floor){
	var st = mine_state();
	st.floor = clamp(_floor, 1, mine_deep_open() ? 9999 : MINE_FLOORS); // the Deep has no bottom
	with(game){
		spawnRoom = rm_mine;
		spawnX = 0; spawnY = 0;            // mine_room_start puts you at the entrance
		spawnPlayerFacing = dir.down;
		restartRoom = (room == rm_mine);   // same room: it has to be rebuilt
		doTransition = true;
	}
}

/// @description Climb out at the cave mouth, under the cliff on North Road.
function mine_leave(){
	with(game){
		spawnRoom = rm_north;
		var p = layout_point("rm_north", "cave");
		spawnX = p[0]; spawnY = p[1];
		spawnPlayerFacing = dir.down;
		restartRoom = false;
		doTransition = true;
	}
}

/// @description What the player and monsters can't walk through: walls and things, plus the rock of the mine and
/// the trees and water of Whisperwood (rooms built at runtime keep them in the global.mineWalls tilemap).
function collision_solids(_withNpcs){
	var s = _withNpcs ? [obj_col_box, obj_npc_parent] : [obj_col_box];
	if(variable_global_exists("mineWalls") && global.mineWalls != -1) array_push(s, global.mineWalls);
	return s;
}

/// @description How dark the mine is here (0 = lit): the band's darkness, a little more each floor down; Light helps.
function mine_darkness(){
	if(room != rm_mine) return 0;
	var fl = mine_state().floor;
	var d = clamp(mine_band(fl).dark + (fl mod 10) * 0.02, 0, 0.8);
	return spell_light_on() ? d * 0.35 : d;   // the Light spell
}

/// @description True while the lift's floor list is open (the player stands still, Esc closes it).
function mine_menu_open(){ return instance_exists(obj_mine_door) && obj_mine_door.menuOpen; }

// ---------------------------------------------------------------- treasure

/// @description What the chest on each lift floor holds (opened once per game): [item id, count].
function mine_chest_loot(_floor){
	switch(_floor){
		case 5:  return [["m|copper", 5], ["m|coal", 5], ["m|gem", 1]];
		case 10: return [["k|fireball", 1], ["m|iron", 3], ["c|held|Simple staff", 1]];
		case 15: return [["k|heal", 1], ["m|frost_crystal", 2], ["m|silver", 2]];
		case 20: return [["m|steel", 3], ["m|gem", 3], ["m|pixie_dust", 1]];
		case 25: return [["m|gold", 3], ["m|ember_core", 1], ["c|held|Diamond staff", 1]];
		case 30: return [["m|mithril", 2], ["m|dragon_scale", 1], ["m|phoenix_feather", 1]];
	}
	return [];
}

/// @description Open a lift floor's chest: its loot into the bag, and it's marked opened. Returns the message.
function mine_chest_open(_floor){
	var st = mine_state();
	if(!is_array(st[$ "chests"])) st.chests = [];
	if(array_get_index(st.chests, _floor) != -1) return "Empty";
	array_push(st.chests, _floor);
	var loot = mine_chest_loot(_floor), msg = "Treasure!", full = false;
	for(var i = 0; i < array_length(loot); i++){
		if(inv_add(item_stack(loot[i][0], loot[i][1])) > 0) full = true;
		msg += "  +" + string(loot[i][1]) + " " + item_def(loot[i][0]).name;
	}
	if(full) msg += "  -  your bag is full, some fell back in the dark";
	return msg;
}

/// @description Put the floor's chest out if it's a lift floor whose chest hasn't been opened: a few steps from the
/// entrance, so it's the first thing you find.
function mine_place_chest(_m, _floor){
	var st = mine_state();
	if(_floor mod MINE_LIFT_EVERY != 0 || array_get_index(st[$ "chests"] ?? [], _floor) != -1 || array_length(mine_chest_loot(_floor)) == 0) return;
	for(var i = 0; i < array_length(_m.region); i++){
		var c = _m.region[i];
		var d = _m.dist[c[0]][c[1]];
		if(d < 3 || d > 6 || resource_at_cell(c[0], c[1])) continue;
		instance_create_depth(c[0] * 32 + 16, c[1] * 32 + 20, 0, obj_chest, {chestFloor: _floor});
		return;
	}
}

// ---------------------------------------------------------------- bosses and the Deep

/// @description The boss waiting on a floor ("" for none, or once it's beaten): floors 10, 20 and 30.
function mine_boss(_floor){
	var b = "";
	switch(_floor){
		case 10: b = "wraith"; break;   // the Frozen Halls
		case 20: b = "guardian"; break; // the Ember Depths
		case MINE_FLOORS: b = "drake"; break;
	}
	return (b != "" && array_get_index(mine_state().bosses, _floor) == -1) ? b : "";
}

/// @description The floors below 30 open once the Ember Drake is beaten.
function mine_deep_open(){ return world_time_ready() && array_get_index(mine_state().bosses, MINE_FLOORS) != -1; }

/// @description A boss falls (from monster_kill): remember it, and the ladder down appears where it stood.
function mine_boss_beaten(_inst){
	var st = mine_state();
	if(array_get_index(st.bosses, st.floor) == -1) array_push(st.bosses, st.floor);
	var gx = _inst.x div 32, gy = _inst.y div 32;
	// On solid rock (a big boss can end up against a wall) the ladder goes on the floor's planned spot instead
	if(variable_global_exists("mineWalls") && tilemap_get(global.mineWalls, gx, gy) > 0){ gx = global.mineFloor.ladder[0]; gy = global.mineFloor.ladder[1]; }
	instance_create_depth(gx * 32 + 16, gy * 32 + 16, 0, obj_mine_ladder, {down: true});
	popup(_inst.x, _inst.y - 90, (st.floor == MINE_FLOORS) ? "The Deep opens below..." : "The way down is open", make_colour_rgb(255, 220, 120));
}

/// @description The boss in this room still standing, or noone (for the HUD's health bar).
function mine_boss_here(){
	var b = noone;
	with(obj_monster) if((def[$ "boss"] ?? false) && !dying) b = id;
	return b;
}
