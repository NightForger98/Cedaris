/// Gathering (roadmap phase 2): trees, rocks, ore veins and weeds in the world, smelting and tool upgrades.
///
/// Resources live in the world store: world_room(<room>).objects = [{key, gx, gy, hp, days, area}], one per
/// 32 px cell, shown by obj_resource instances (which point at the stored struct, so hits change it in place).
/// Spawn areas fill up a little each day; a room only spawns when you enter it, because free cells can only be
/// checked against a loaded room's collisions. Felled trees leave stumps that grow back into trees.
///
/// Tools have tiers (global.inv.tools = {<tool name>: tier}), upgraded at Brom's with our metal bars.
/// Ore is smelted into bars at Brom's furnace; fibre is woven into linen and cotton at the crafting table.

#macro RES_CELL 32

/// @description Resource kinds. Art is a part of spr_tile_terrain [x, y, w, h] drawn with its ground point
/// [ax, ay] on the cell centre, at an optional scale. tools: what can hit it ("any" = any tool or weapon); hard: tool tier needed.
/// drops: [item id, min, max, chance]. becomes: what's left when it breaks; grow: {days, into} for stumps.
/// ore: colour of the specks drawn on a vein.
function resource_table(){
	static t = {
		oak:          {name: "Oak Tree",     tools: ["Axe"],     hp: 10, hard: 0, art: [931, 902, 90, 117], anchor: [46, 112], foot: [1.5, 1],
		               drops: [["m|wood", 8, 12, 1]], becomes: "oak_stump"},
		pine:         {name: "Pine Tree",    tools: ["Axe"],     hp: 10, hard: 0, art: [961, 5, 63, 147],   anchor: [31, 141], foot: [1.5, 1],
		               drops: [["m|wood", 8, 12, 1]], becomes: "pine_stump"},
		oak_stump:    {name: "Stump",        tools: ["Axe"],     hp: 4,  hard: 0, art: [390, 395, 51, 42],  anchor: [25, 34],  foot: [1.75, 1],
		               drops: [["m|wood", 3, 5, 1]], grow: {days: 7, into: "oak"}},
		pine_stump:   {name: "Stump",        tools: ["Axe"],     hp: 4,  hard: 0, art: [390, 395, 51, 42],  anchor: [25, 34],  foot: [1.75, 1],
		               drops: [["m|wood", 3, 5, 1]], grow: {days: 7, into: "pine"}},
		stone:        {name: "Stone",        tools: ["Pickaxe"], hp: 2,  hard: 0, art: [864, 845, 60, 50],  anchor: [30, 42],  foot: [1.25, 1], scale: 0.6,
		               drops: [["m|stone", 1, 3, 1], ["m|coal", 1, 1, 0.06], ["m|gem", 1, 1, 0.01]]},
		boulder:      {name: "Boulder",      tools: ["Pickaxe"], hp: 8,  hard: 1, art: [858, 753, 62, 46],  anchor: [31, 40],  foot: [2, 1.25],
		               drops: [["m|stone", 6, 10, 1], ["m|coal", 1, 2, 0.3], ["m|gem", 1, 1, 0.03]]},
		copper_vein:  {name: "Copper Vein",  tools: ["Pickaxe"], hp: 4,  hard: 0, art: [578, 392, 56, 53],  anchor: [28, 46],  foot: [1.5, 1.25], scale: 0.75,
		               ore: make_colour_rgb(225, 130, 70),  drops: [["m|copper_ore", 2, 4, 1], ["m|stone", 0, 1, 1]]},
		coal_vein:    {name: "Coal Seam",    tools: ["Pickaxe"], hp: 4,  hard: 0, art: [578, 392, 56, 53],  anchor: [28, 46],  foot: [1.5, 1.25], scale: 0.75,
		               ore: make_colour_rgb(30, 28, 32),    drops: [["m|coal", 1, 3, 1], ["m|stone", 0, 1, 1]]},
		iron_vein:    {name: "Iron Vein",    tools: ["Pickaxe"], hp: 6,  hard: 1, art: [578, 392, 56, 53],  anchor: [28, 46],  foot: [1.5, 1.25], scale: 0.75,
		               ore: make_colour_rgb(200, 175, 160), drops: [["m|iron_ore", 2, 4, 1], ["m|stone", 0, 1, 1]]},
		silver_vein:  {name: "Silver Vein",  tools: ["Pickaxe"], hp: 8,  hard: 2, art: [578, 392, 56, 53],  anchor: [28, 46],  foot: [1.5, 1.25], scale: 0.75,
		               ore: make_colour_rgb(235, 240, 250), drops: [["m|silver_ore", 2, 3, 1], ["m|gem", 1, 1, 0.04]]},
		gold_vein:    {name: "Gold Vein",    tools: ["Pickaxe"], hp: 10, hard: 3, art: [578, 392, 56, 53],  anchor: [28, 46],  foot: [1.5, 1.25], scale: 0.75,
		               ore: make_colour_rgb(250, 210, 60),  drops: [["m|gold_ore", 2, 3, 1], ["m|gem", 1, 1, 0.06]]},
		// Not spawned on the surface: waiting for the mine's deepest floors (phase 4)
		mithril_vein: {name: "Mithril Vein", tools: ["Pickaxe"], hp: 14, hard: 4, art: [578, 392, 56, 53],  anchor: [28, 46],  foot: [1.5, 1.25], scale: 0.75,
		               ore: make_colour_rgb(180, 240, 255), drops: [["m|mithril_ore", 1, 3, 1], ["m|gem", 1, 1, 0.1]]},
		// Mine only: rocks tinted by their band, and gem nodes (see mine_bands)
		ice_rock:     {name: "Frozen Rock",  tools: ["Pickaxe"], hp: 4,  hard: 1, art: [864, 845, 60, 50],  anchor: [30, 42],  foot: [1.25, 1], scale: 0.7,
		               tint: make_colour_rgb(170, 210, 255), drops: [["m|stone", 1, 3, 1], ["m|frost_crystal", 1, 1, 0.06]]},
		ember_rock:   {name: "Ember Rock",   tools: ["Pickaxe"], hp: 6,  hard: 2, art: [864, 845, 60, 50],  anchor: [30, 42],  foot: [1.25, 1], scale: 0.7,
		               tint: make_colour_rgb(255, 140, 100), drops: [["m|stone", 1, 3, 1], ["m|coal", 1, 2, 0.3], ["m|ember_core", 1, 1, 0.05]]},
		gem_node:     {name: "Gem Node",     tools: ["Pickaxe"], hp: 5,  hard: 1, art: [578, 392, 56, 53],  anchor: [28, 46],  foot: [1.5, 1.25], scale: 0.75,
		               ore: make_colour_rgb(90, 220, 230),  drops: [["m|gem", 1, 2, 1]]},
		void_node:    {name: "Void Node",    tools: ["Pickaxe"], hp: 16, hard: 4, art: [578, 392, 56, 53],  anchor: [28, 46],  foot: [1.5, 1.25], scale: 0.8,
		               tint: make_colour_rgb(150, 120, 190), ore: make_colour_rgb(95, 40, 145), drops: [["m|void_pearl", 1, 1, 0.08], ["m|gem", 1, 2, 0.6], ["m|stone", 1, 2, 1]]},
		// Whisperwood: the old trees that make its walls (they can't be cut), and things to forage
		ancient_oak:  {name: "Ancient Oak",  tools: ["none"], hp: 999, hard: 0, art: [931, 902, 90, 117], anchor: [46, 112], foot: [2, 2], fixed: true, drops: []},
		ancient_pine: {name: "Ancient Pine", tools: ["none"], hp: 999, hard: 0, art: [961, 5, 63, 147],   anchor: [31, 141], foot: [2, 2], fixed: true, drops: []},
		forage_mushroom:  {name: "Mushrooms",     tools: ["any"], hp: 1, hard: 0, art: [862, 893, 43, 34], anchor: [21, 30], foot: [1, 0.75], scale: 0.7, drops: [["w|mushroom", 1, 2, 1]]},
		forage_toadstool: {name: "Red Toadstool", tools: ["any"], hp: 1, hard: 0, art: [830, 994, 32, 30], anchor: [16, 28], foot: [1, 0.75], scale: 0.8, drops: [["w|toadstool", 1, 1, 1]]},
		forage_herb:      {name: "Wild Herbs",    tools: ["any"], hp: 1, hard: 0, art: [416, 453, 30, 33], anchor: [15, 30], foot: [1, 0.75], tint: make_colour_rgb(200, 255, 170), drops: [["w|herb", 1, 2, 1]]},
		weeds:        {name: "Weeds",        tools: ["any"],     hp: 1,  hard: 0, art: [191, 767, 30, 33],  anchor: [15, 30],  foot: [1.25, 1],
		               drops: [["m|fibre", 1, 2, 1]]},
		bush:         {name: "Bush",         tools: ["Scythe", "Axe"], hp: 2, hard: 0, art: [289, 447, 29, 33], anchor: [14, 30], foot: [1.5, 1],
		               drops: [["m|fibre", 2, 4, 1], ["m|wood", 0, 1, 1]]},
	};
	return t;
}

/// @description Where resources spawn: cells [gx1, gy1, gx2, gy2] in a room, a cap, how many come back each
/// day, how many on the first visit, and weighted kinds. Each cell is checked against the room's collisions.
function resource_areas(){
	// The farm's own areas, then every generated room's (scripts/world_rooms, from tools/world).
	// Saves count regrowth by place in this list: the new world (save version 12) started it afresh.
	static a = array_concat([
		// Farm (areas named in tools/rooms/specs/rm_1.js): the meadow by the path - weeds, bushes and stones (no trees)
		{room: "rm_1", cells: layout_cells("rm_1", "meadow"), max: 12, perDay: 3, start: 9,
		 kinds: [["weeds", 55], ["bush", 25], ["stone", 20]]},
		// Farm: the grass west of the field
		{room: "rm_1", cells: layout_cells("rm_1", "west"), max: 10, perDay: 2, start: 7,
		 kinds: [["weeds", 40], ["bush", 15], ["stone", 30], ["boulder", 5], ["copper_vein", 5], ["oak", 5]]},
		// Farm: the edge of the woods in the south - a young wood
		{room: "rm_1", cells: layout_cells("rm_1", "woods"), max: 10, perDay: 2, start: 7,
		 kinds: [["oak", 25], ["pine", 25], ["weeds", 30], ["bush", 10], ["stone", 10]]},
		{room: "rm_1", cells: layout_cells("rm_1", "far_west"), max: 8, perDay: 2, start: 6,
		 kinds: [["weeds", 40], ["bush", 15], ["stone", 25], ["oak", 10], ["pine", 10]]},
	], world_resource_areas());
	return a;
}

function resource_def(_key){ return resource_table()[$ _key]; }

// ---------------------------------------------------------------- tools

/// @description Tool tiers, in order. Upgrading to a tier costs bars of its metal plus gold at Brom's.
function tool_tiers(){
	static t = [
		{name: "Basic",   bar: "",        bars: 0, gold: 0},
		{name: "Copper",  bar: "copper",  bars: 5, gold: 200},
		{name: "Iron",    bar: "iron",    bars: 5, gold: 500},
		{name: "Steel",   bar: "steel",   bars: 5, gold: 1000},
		{name: "Gold",    bar: "gold",    bars: 5, gold: 2000},
		{name: "Mithril", bar: "mithril", bars: 3, gold: 5000},
	];
	return t;
}

/// @description Tools that can be upgraded, and what an upgrade does for each.
function tool_upgradable(_name){
	switch(_name){
		case "Hoe":          return "Charges one level further: a bigger patch";
		case "Watering Can": return "Holds more and charges one level further";
		case "Axe":          return "Chops harder and charges one level further";
		case "Pickaxe":      return "Breaks harder rock and charges one level further";
		case "Scythe":       return "Charges one level further: a wider spin";
	}
	return "";
}

function tool_tier(_name){
	if(!variable_global_exists("inv") || !is_struct(global.inv)) return 0;
	var t = global.inv[$ "tools"];
	return is_struct(t) ? (t[$ _name] ?? 0) : 0;
}

/// @description "Copper Axe"; basic tools keep their plain name.
function tool_display_name(_name){
	var t = tool_tier(_name);
	return (t == 0 || tool_upgradable(_name) == "") ? _name : tool_tier_name(t) + " " + _name;
}

/// @description Past Mithril (the last tier Brom forges, TOOL_MITHRIL) a tool can only be Cursed (6, by a witch) and then
/// Blessed (7, by the priest) - see docs/CHARGING.md.
#macro TOOL_MITHRIL 5
#macro TOOL_CURSED 6
#macro TOOL_BLESSED 7
function tool_tier_name(_t){ return (_t == TOOL_CURSED) ? "Cursed" : ((_t == TOOL_BLESSED) ? "Blessed" : tool_tiers()[_t].name); }

function tool_tier_colour(_t){
	if(_t == TOOL_CURSED) return make_colour_rgb(150, 60, 200);
	if(_t == TOOL_BLESSED) return make_colour_rgb(255, 215, 90);
	return (_t <= 0) ? c_white : item_material(tool_tiers()[_t].bar).colour;
}

/// @description Watering can capacity: 40, plus 15 per tier.
function tool_water_max(){ return 40 + 15 * tool_tier("Watering Can"); }

/// @description Upgrade a tool you own to its next tier. Returns "" or why not.
function tool_upgrade(_name){
	var cur = tool_tier(_name);
	var tiers = tool_tiers();
	if(cur == TOOL_CURSED) return "Brom won't touch a cursed tool. The priest can lift it";
	if(cur >= TOOL_MITHRIL) return "Your " + string_lower(_name) + " can't get any better";
	if(inv_count("c|held|" + _name) <= 0) return "Bring your " + string_lower(_name) + " first";
	var next = tiers[cur + 1];
	if(!inv_is_free()){
		if(inv_count("m|" + next.bar) < next.bars) return "You need " + string(next.bars) + " " + item_material(next.bar).name + "s";
		if(global.inv.gold < next.gold) return "Not enough gold";
		inv_take("m|" + next.bar, next.bars);
		global.inv.gold -= next.gold;
	}
	if(!is_struct(global.inv[$ "tools"])) global.inv.tools = {};
	global.inv.tools[$ _name] = cur + 1;
	if(_name == "Watering Can") global.inv.water = tool_water_max();
	return "";
}

/// @description The tools you carry that Brom can upgrade.
function tool_upgrade_list(){
	static names = ["Hoe", "Watering Can", "Axe", "Pickaxe", "Scythe"];
	var out = [];
	for(var i = 0; i < array_length(names); i++) if(inv_count("c|held|" + names[i]) > 0) array_push(out, names[i]);
	return out;
}

// ---------------------------------------------------------------- stations

/// @description Recipes made at a station: the furnace smelts ore, the crafting table weaves fibre, the hearth cooks.
function station_recipes(_station){
	static r = {
		furnace: [
			{id: "m|copper",  cost: {copper_ore: 5, coal: 1}},
			{id: "m|iron",    cost: {iron_ore: 5, coal: 1}},
			{id: "m|steel",   cost: {iron: 1, coal: 2}},
			{id: "m|silver",  cost: {silver_ore: 5, coal: 1}},
			{id: "m|gold",    cost: {gold_ore: 5, coal: 1}},
			{id: "m|mithril", cost: {mithril_ore: 5, coal: 2}},
		],
		weave: [
			{id: "m|linen",  cost: {fibre: 4}},
			{id: "m|cotton", cost: {fibre: 6}},
		],
	};
	if(_station == "cook") return dish_recipes(); // built from the dish table (scripts/food)
	return r[$ _station] ?? [];
}

// ---------------------------------------------------------------- the world

function resource_objects(_roomName){
	var r = world_room(_roomName);
	if(!variable_struct_exists(r, "objects")) r.objects = [];
	return r.objects;
}

/// @description True if a resource could go in this cell of the current room: no walls, people, water,
/// doors or field soil, and not right under the player.
function resource_cell_free(_gx, _gy){
	var cx = _gx * RES_CELL + RES_CELL / 2, cy = _gy * RES_CELL + RES_CELL / 2;
	if(cx < 0 || cy < 0 || cx >= room_width || cy >= room_height) return false;
	if(instance_exists(crops) && farm_is_soil(_gx, _gy)) return false;
	// Rooms built at runtime (the mine, Whisperwood) keep their walls and water in a tilemap
	if(variable_global_exists("mineWalls") && global.mineWalls != -1 && tilemap_get_at_pixel(global.mineWalls, cx, cy) > 0) return false;
	var x1 = cx - 15, y1 = cy - 15, x2 = cx + 15, y2 = cy + 15;
	if(collision_rectangle(x1, y1, x2, y2, obj_col_box, false, true) != noone) return false;
	if(collision_rectangle(x1, y1, x2, y2, obj_npc_parent, false, true) != noone) return false;
	if(collision_rectangle(x1 - 16, y1 - 16, x2 + 16, y2 + 16, obj_transition, false, true) != noone) return false;
	if(collision_rectangle(x1, y1, x2, y2, obj_water_zone, false, true) != noone) return false;
	if(instance_exists(obj_plyr) && point_distance(cx, cy, obj_plyr.x, obj_plyr.y) < 48) return false;
	return true;
}

function resource_pick_kind(_kinds){
	var total = 0;
	for(var i = 0; i < array_length(_kinds); i++) total += _kinds[i][1];
	var r = random(total);
	for(var i = 0; i < array_length(_kinds); i++){
		r -= _kinds[i][1];
		if(r < 0) return _kinds[i][0];
	}
	return _kinds[0][0];
}

function resource_make(_key, _gx, _gy, _area){
	return {key: _key, gx: _gx, gy: _gy, hp: resource_def(_key).hp, days: 0, area: _area};
}

function resource_create_instance(_data){
	// Depth is set by depth_sort in its Step, among the player and NPCs
	return instance_create_depth(_data.gx * RES_CELL + RES_CELL / 2, _data.gy * RES_CELL + RES_CELL / 2, 0, obj_resource, {data: _data});
}

/// @description Room Start: show this room's resources, then spawn what's due in its areas.
function resources_room_start(){
	if(!world_time_ready()) return;
	var name = room_get_name(room);
	var r = world_room(name);
	var objs = resource_objects(name);
	var areas = resource_areas();
	if(!variable_struct_exists(r, "due")) r.due = {};
	// First visit: every area starts partly filled
	if(!(r[$ "seeded"] ?? false)){
		r.seeded = true;
		for(var i = 0; i < array_length(areas); i++) if(areas[i].room == name) r.due[$ string(i)] = areas[i].start;
	}
	for(var i = 0; i < array_length(objs); i++) resource_create_instance(objs[i]);

	for(var i = 0; i < array_length(areas); i++){
		var a = areas[i];
		if(a.room != name) continue;
		var have = 0;
		for(var o = 0; o < array_length(objs); o++) if(objs[o].area == i) have++;
		var n = min(r.due[$ string(i)] ?? 0, a.max - have);
		r.due[$ string(i)] = 0;
		var c = a.cells;
		repeat(n){
			// A few random tries per resource; a crowded area just spawns less
			repeat(12){
				var gx = irandom_range(c[0], c[2]), gy = irandom_range(c[1], c[3]);
				if(!resource_cell_free(gx, gy)) continue;
				var d = resource_make(resource_pick_kind(a.kinds), gx, gy, i);
				array_push(objs, d);
				resource_create_instance(d);
				break;
			}
		}
	}
}

/// @description New-day part: stumps grow back into trees, and every area gets a few more resources due.
function resources_new_day(){
	var areas = resource_areas();
	var names = variable_struct_get_names(global.world.rooms);
	for(var n = 0; n < array_length(names); n++){
		var r = global.world.rooms[$ names[n]];
		var objs = r[$ "objects"] ?? [];
		for(var i = 0; i < array_length(objs); i++){
			var g = resource_def(objs[i].key)[$ "grow"];
			if(g == undefined) continue;
			objs[i].days += 1;
			if(objs[i].days >= g.days){ objs[i].key = g.into; objs[i].hp = resource_def(g.into).hp; objs[i].days = 0; }
		}
		if(!(r[$ "seeded"] ?? false)) continue;
		for(var i = 0; i < array_length(areas); i++){
			if(areas[i].room != names[n]) continue;
			var k = string(i);
			r.due[$ k] = min(areas[i].max, (r.due[$ k] ?? 0) + areas[i].perDay);
		}
	}
}

// ---------------------------------------------------------------- hitting things

/// @description True if this held item can hit this kind of resource.
function resource_tool_ok(_def, _item){
	return array_get_index(_def.tools, "any") != -1 || array_get_index(_def.tools, _item) != -1;
}

/// @description A tool or weapon swing lands (from action_hit): hit the resource in front, or everything in
/// the scythe's sweep. Returns true if something was hit.
function gather_hit(_user, _item, _dir){
	if(!instance_exists(obj_resource)) return false;
	var fx = _user.x + [0, -24, 0, 24][_dir];
	var fy = _user.y + [-24, 0, 24, 0][_dir];
	if(_item == "Scythe"){
		var reach = 44; // three cells; holding it to charge spins it round (charging script)
		var list = [];
		with(obj_resource) if(point_distance(x, y, fx, fy) < reach && resource_tool_ok(def, _item)) array_push(list, id);
		for(var i = 0; i < array_length(list); i++) gather_damage(list[i], _item);
		return array_length(list) > 0;
	}
	var best = noone, bestD = 26;
	with(obj_resource){
		var d = point_distance(x, y, fx, fy);
		if(d < bestD){ best = id; bestD = d; }
	}
	if(best == noone) return false;
	if(!resource_tool_ok(best.def, _item)){
		// Only say so for tools; weapons just bounce off (and the ancient trees aren't for cutting)
		if(item_is_tool(_item) && !(best.def[$ "fixed"] ?? false)) farm_message("That needs " + ((best.def.tools[0] == "Axe") ? "an axe" : "a " + string_lower(best.def.tools[0])));
		return false;
	}
	gather_damage(best, _item);
	return true;
}

/// @description One hit on a resource instance: the tool's tier sets the damage and what it can break.
function gather_damage(_inst, _item, _dmg = -1){
	var def = _inst.def;
	var tier = tool_tier(_item);
	if(tier < def.hard){
		farm_message("Too hard. Upgrade your " + string_lower(_item) + " at Brom's (" + tool_tiers()[def.hard].name + " or better)");
		_inst.shake = 6;
		return;
	}
	_inst.data.hp -= (_dmg >= 0) ? _dmg : 1 + tier; // a charged swing hits harder (charge_tool_damage)
	_inst.shake = 10;
	if(_inst.data.hp > 0) return;
	gather_break(_inst);
}

/// @description A resource breaks: drops go into the bag (luck helps with gems), and it's replaced by what it
/// becomes (a stump) or removed.
function gather_break(_inst){
	var def = _inst.def, d = _inst.data;
	var luck = stat("luck") * 0.002 + (global.clock[$ "luck"] ?? 0) * 0.1;
	var got = "", lost = false;
	for(var i = 0; i < array_length(def.drops); i++){
		var dr = def.drops[i];
		var chance = dr[3] + ((dr[0] == "m|gem" || dr[0] == "m|coal") ? luck : 0);
		if(random(1) >= chance) continue;
		var n = irandom_range(dr[1], dr[2]);
		if(n <= 0) continue;
		if(inv_add(item_stack(dr[0], n)) > 0) lost = true;
		got += ((got == "") ? "+" : ",  +") + string(n) + " " + item_def(dr[0]).name;
	}
	if(lost) got += "  -  your bag is full";
	if(got != "") farm_message(got);

	var objs = resource_objects(room_get_name(room));
	if(variable_struct_exists(def, "becomes")){
		d.key = def.becomes;
		d.hp = resource_def(d.key).hp;
		d.days = 0;
		resource_create_instance(d);
	} else {
		var i = array_get_index(objs, d);
		if(i != -1) array_delete(objs, i, 1);
	}
	instance_destroy(_inst);
}
