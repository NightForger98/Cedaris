/// Save slots, new game, and player settings.
/// Saves are JSON files in the game's save folder (saves/slotN.json); settings live in settings.ini.

#macro SAVE_SLOTS 3
#macro SAVE_VERSION 12// 3: resources in the world store, tool tiers and water in the inventory; 4: the mine (world.mine);
                      // 5: spells (inv.spells) and mana (vitals.mana); 6: weather (clock), projects, people, quests (world);
                      // 7: the built farm and village (see save_upgrade_rooms); 8: beaten mine bosses (world.mine.bosses);
                      // 9: heart events seen (world.events); 10: the farm, the vale and the coast grown (save_upgrade_grown);
                      // 11: the farm rebuilt below Hollow Vale (save_upgrade_farm_moved); 12: the new world - 25 rooms
                      // laid out like Beirut (save_upgrade_new_world)

function save_path(_slot){ return "saves/slot" + string(_slot) + ".json"; }

function save_exists(_slot){ return file_exists(save_path(_slot)); }

/// @description Friendly name for a room, shown on save slots, signposts and the map: the place it's in.
function save_room_name(_roomName){
	var place = world_place_name(_roomName);   // scripts/world_rooms (tools/world/world.js)
	if(place != undefined) return place;
	switch(_roomName){
		case "rm_1": return "The Farm";
		case "rm_2": return "Village";
		case "rm_mine": return "The Mine";
		case "rm_forest": return "Whisperwood";
		case "rm_town": return "Brindlemoor";
		case "rm_beach": return "Saltmere Coast";
		case "rm_valley": return "Hollow Vale";
		case "rm_north": return "North Road";
		case "rm_south": return "South Road";
		case "rm_cross": return "Crossroads";
		default:
			// Houses take their place's name
			if(string_pos("rm_town_", _roomName) == 1) return "Brindlemoor";
			if(string_pos("rm_village_", _roomName) == 1) return "Village";
			if(string_pos("rm_valley_", _roomName) == 1) return "Hollow Vale";
			if(string_pos("rm_beach_", _roomName) == 1) return "Saltmere Coast";
			return "Indoors";
	}
}

/// @description Read a slot's save data, or undefined if empty or unreadable.
function save_read(_slot){
	if(!save_exists(_slot)) return undefined;
	var f = file_text_open_read(save_path(_slot));
	var text = "";
	while(!file_text_eof(f)){ text += file_text_readln(f); }
	file_text_close(f);
	try { return json_parse(text); }
	catch(e) { return undefined; }
}

/// @description Save the current game. Only works in a room with the player in it.
function save_game(_slot){
	// Automated test runs never write real saves (only the "test" slot, which no menu shows)
	if(autotest_running() && _slot != "test") return false;
	// The pause menu deactivates the world; wake it up long enough to read it
	var frozen = instance_exists(obj_menu) && obj_menu.isPause;
	instance_activate_all();
	crops_store(); // the farm's live crops into the world store
	if(!instance_exists(obj_plyr)){ if(frozen) game_freeze(); return false; }
	var data = {
		version: SAVE_VERSION,
		savedAt: date_current_datetime(),
		playtime: game.playtime,
		room: room_get_name(room),
		x: obj_plyr.x,
		y: obj_plyr.y,
		row: obj_plyr.y_frame,
		look: character_look_to_save(obj_plyr.look),
		inv: inv_to_save(),
		clock: global.clock,
		vitals: global.vitals,
		world: global.world,
	};
	if(!directory_exists("saves")) directory_create("saves");
	global.saveSlot = _slot; // sleeping autosaves here
	var f = file_text_open_write(save_path(_slot));
	file_text_write_string(f, json_stringify(data));
	file_text_close(f);
	if(frozen) game_freeze();
	return true;
}

/// @description Load a slot and go to the room it was saved in.
function load_game(_slot){
	var data = save_read(_slot);
	if(data == undefined) return false;
	var rm = asset_get_index(data.room);
	// Saves from before the new world may be in a room that's gone: they wake up on the farm
	if(rm == -1 && (data[$ "version"] ?? 1) < 12){ rm = rm_1; data.room = "rm_1"; }
	if(rm == -1) return false;

	instance_activate_all(); // in case the game was paused
	global.look = character_look_from_save(data.look);
	// Saves from before the inventory existed become free-mode inventories of what you wore
	global.inv = variable_struct_exists(data, "inv") ? inv_from_save(data.inv) : inv_new_free(global.look);
	global.gameMode = global.inv.mode;
	// Story saves from before the gender choice: fix it from the body and head (character_gender), kept from now on
	if(global.gameMode == "story" && !variable_struct_exists(global.look, "gender")) global.look.gender = character_gender(global.look);
	inv_apply_look(global.look);
	game.playtime = data.playtime;
	// Version 1 saves kept only the farm's crops
	if(variable_struct_exists(data, "world")){
		global.world = data.world;
		global.clock = data.clock;
		global.vitals = data.vitals;
	} else {
		world_time_new();
		world_room("rm_1").crops = variable_struct_exists(data, "crops") ? data.crops : [];
	}
	global.saveSlot = _slot;
	crops.loadPending = true; // don't let the farm's Room End overwrite the loaded crops
	var oldRooms = (data[$ "version"] ?? 1) < 7;
	if(oldRooms) save_upgrade_rooms();
	var grown = save_grown_shift();
	var oldGrown = !oldRooms && (data[$ "version"] ?? 1) < 10;
	if(oldGrown) save_upgrade_grown();
	var oldFarm = !oldRooms && (data[$ "version"] ?? 1) < 11;
	if(oldFarm) save_upgrade_farm_moved();
	var oldWorld = (data[$ "version"] ?? 1) < 12;
	if(oldWorld) save_upgrade_new_world();

	// Sheet row back to a facing direction (rows: 8 up, 9 left, 10 down, 11 right)
	var facing = dir.down;
	switch(data.row){
		case 8:  facing = dir.up;    break;
		case 9:  facing = dir.left;  break;
		case 11: facing = dir.right; break;
	}
	var at = [data.x, data.y];
	if(oldRooms && rm == rm_1) at = layout_point("rm_1", "start");
	
	var g = grown[$ data.room];
	if(oldGrown && g != undefined) at = [at[0] + g[0] * 32, at[1] + g[1] * 32];
	if(oldFarm && rm == rm_1) at = layout_point("rm_1", "start");
	if(oldWorld && rm != rm_1 && rm != rm_12 && rm != rm_123){ rm = rm_1; at = layout_point("rm_1", "start"); }
	with(game){
		spawnRoom = rm;
		spawnX = at[0];
		spawnY = at[1];
		spawnPlayerFacing = facing;
		doTransition = false;
		blackAlpha = 0;
	}
	room_goto(rm);
	return true;
}

/// @description Saves before version 7 were made on the first test farm and village, whose layout is gone. The
/// farm's crops move into the new field in order (keeping what they are, how old, and whether they were watered),
/// sprinklers and other placed things go back in the bag, and rocks, weeds and trees are rolled again.
function save_upgrade_rooms(){
	var farm = world_room("rm_1");
	var f = layout_cells("rm_1", "field");
	var w = f[2] - f[0] + 1, n = w * (f[3] - f[1] + 1);
	var oldTiles = farm.tiles;
	farm.tiles = {};
	if(array_length(farm.crops) > n) array_resize(farm.crops, n);
	for(var i = 0; i < array_length(farm.crops); i++){
		var c = farm.crops[i];
		var old = oldTiles[$ farm_key(c.gx, c.gy)];
		c.gx = f[0] + (i mod w);
		c.gy = f[1] + (i div w);
		farm.tiles[$ farm_key(c.gx, c.gy)] = {watered: (old != undefined) && old.watered};
	}
	var names = ["rm_1", "rm_2"];
	for(var i = 0; i < 2; i++){
		var r = world_room(names[i]);
		var p = r[$ "placed"];
		if(is_array(p)) for(var k = 0; k < array_length(p); k++) inv_add(item_stack("o|" + p[k].kind, 1));
		r.placed = [];
		r.objects = [];
		r.due = {};
		r.seeded = false;
	}
}

/// @description How far (in cells) everything moved in the rooms that grew in version 10: the farm and Hollow Vale
/// grew 17 columns west, the coast 46 rows north.
function save_grown_shift(){ return {rm_1: [17, 0], rm_valley: [17, 0], rm_beach: [0, 46]}; }

/// @description Saves before version 10: move what is stored in the grown rooms (crops, tilled soil, placed things,
/// rocks and trees) along with the ground, so it stays where you left it.
function save_upgrade_grown(){
	var shift = save_grown_shift(), names = variable_struct_get_names(shift);
	for(var i = 0; i < array_length(names); i++){
		var r = world_room(names[i]), dx = shift[$ names[i]][0], dy = shift[$ names[i]][1];
		var lists = [r.crops, r.objects, r[$ "placed"] ?? []];
		for(var l = 0; l < 3; l++) for(var k = 0; k < array_length(lists[l]); k++){ lists[l][k].gx += dx; lists[l][k].gy += dy; }
		var tiles = {}, keys = variable_struct_get_names(r.tiles);
		for(var k = 0; k < array_length(keys); k++){
			var xy = string_split(keys[k], "_");
			tiles[$ farm_key(real(xy[0]) + dx, real(xy[1]) + dy)] = r.tiles[$ keys[k]];
		}
		r.tiles = tiles;
	}
}

/// @description Saves before version 11: the farm moved below Hollow Vale and was rebuilt round the same field and
/// farmhouse. What's on the field stays (crops, tilled soil, sprinklers); other placed things go back in the bag, and
/// rocks, weeds and trees are rolled again for the new farm.
function save_upgrade_farm_moved(){
	var farm = world_room("rm_1"), f = layout_cells("rm_1", "field");
	var onField = function(_gx, _gy, _f){ return _gx >= _f[0] && _gx <= _f[2] && _gy >= _f[1] && _gy <= _f[3]; };
	var keep = [], p = farm[$ "placed"];
	if(is_array(p)) for(var k = 0; k < array_length(p); k++){
		if(onField(p[k].gx, p[k].gy, f)) array_push(keep, p[k]);
		else inv_add(item_stack("o|" + p[k].kind, 1));
	}
	farm.placed = keep;
	var tiles = {}, keys = variable_struct_get_names(farm.tiles);
	for(var k = 0; k < array_length(keys); k++){
		var xy = string_split(keys[k], "_");
		if(onField(real(xy[0]), real(xy[1]), f)) tiles[$ keys[k]] = farm.tiles[$ keys[k]];
	}
	farm.tiles = tiles;
	var crops_ = [];
	for(var k = 0; k < array_length(farm.crops); k++) if(onField(farm.crops[k].gx, farm.crops[k].gy, f)) array_push(crops_, farm.crops[k]);
	farm.crops = crops_;
	farm.objects = [];
	farm.seeded = false;
}

function save_delete(_slot){
	if(save_exists(_slot)) file_delete(save_path(_slot));
}

/// @description Slot with the newest save, or -1 if there are none.
function save_latest_slot(){
	var best = -1, bestTime = -1;
	for(var s = 1; s <= SAVE_SLOTS; s++){
		var d = save_read(s);
		if(d != undefined && d.savedAt > bestTime){ bestTime = d.savedAt; best = s; }
	}
	return best;
}

/// @description Start a fresh game in "story" or "free" mode: clear the farm and go to the character creator.
function game_new(_mode){
	instance_activate_all();
	global.gameMode = _mode;
	global.look = undefined;
	global.inv = undefined;
	global.saveSlot = undefined;
	world_time_new();
	game.playtime = 0;
	game.spawnRoom = -1;
	game.doTransition = false;
	room_goto(rm_creator);
}

/// @description Format seconds as h:mm.
function save_format_time(_seconds){
	var m = floor(_seconds / 60);
	var mm = string(m mod 60);
	if(string_length(mm) < 2) mm = "0" + mm;
	return string(m div 60) + ":" + mm;
}

// ---------------------------------------------------------------- looks
// Looks are saved by item and palette name, so saves survive catalog changes.

function character_look_to_save(_look){
	var cat = lpc_catalog();
	var out = {race: _look.race, body: _look.body, parts: {}};
	// Story mode's chosen gender (character_story_rules); looks without one don't save it
	if(variable_struct_exists(_look, "gender")) out.gender = _look.gender;
	var keys = variable_struct_get_names(_look.parts);
	for(var i = 0; i < array_length(keys); i++){
		var p = _look.parts[$ keys[i]];
		var want = p[$ "want"] ?? p.item;
		out.parts[$ keys[i]] = {
			item: (p.item == -1) ? "" : cat.items[p.item].name,
			want: (want == -1) ? "" : cat.items[want].name,
			pal:  (p.pal == -1) ? "" : sprite_get_name(p.pal),
		};
	}
	return out;
}

function character_look_from_save(_data){
	var look = character_empty_look(_data.race, _data.body);
	if(variable_struct_exists(_data, "gender")) look.gender = _data.gender;
	var keys = variable_struct_get_names(_data.parts);
	for(var i = 0; i < array_length(keys); i++){
		var k = keys[i];
		var s = _data.parts[$ k];
		if(!variable_struct_exists(look.parts, k)) continue;
		var p = look.parts[$ k];
		p.item = (s.item == "") ? -1 : character_find_item(k, s.item);
		p.want = (s.want == "") ? -1 : character_find_item(k, s.want);
		p.pal  = (s.pal == "") ? -1 : asset_get_index(s.pal);
	}
	character_validate(look);
	return look;
}

// ---------------------------------------------------------------- settings

function settings_load(){
	ini_open("settings.ini");
	global.settings = {
		fullscreen: ini_read_real("display", "fullscreen", 0),
		showFps:    ini_read_real("display", "show_fps", 0),
		volume:     ini_read_real("audio", "master", 80),
		alwaysRun:  ini_read_real("controls", "always_run", 1),   // R toggles it: your pace running (on) or walking (off); Shift sprints
		keys:       {},
	};
	// Rebound keys (Options > Controls); anything not in the file keeps its default
	var def = keys_default(), names = variable_struct_get_names(def);
	for(var i = 0; i < array_length(names); i++) global.settings.keys[$ names[i]] = ini_read_real("keys", names[i], def[$ names[i]]);
	ini_close();
	settings_apply();
}

function settings_save(){
	ini_open("settings.ini");
	ini_write_real("display", "fullscreen", global.settings.fullscreen);
	ini_write_real("display", "show_fps", global.settings.showFps);
	ini_write_real("audio", "master", global.settings.volume);
	ini_write_real("controls", "always_run", global.settings[$ "alwaysRun"] ?? 1);
	var names = variable_struct_get_names(global.settings.keys);
	for(var i = 0; i < array_length(names); i++) ini_write_real("keys", names[i], global.settings.keys[$ names[i]]);
	ini_close();
}

// ---------------------------------------------------------------- keys

/// @description The actions you can rebind, in the order the Controls screen lists them, with their default keys.
function keys_default(){
	static k = {up: vk_up, down: vk_down, left: vk_left, right: vk_right, run: vk_shift, walk: vk_control, autorun: ord("R"),
	            use: vk_space, interact: ord("E"), inventory: ord("I"), map: ord("M"), cast: ord("F"), spell: ord("Q")};
	return k;
}

/// @description What each action does, for the Controls screen (same order as it lists them).
function keys_actions(){
	static a = [["up", "Walk up"], ["down", "Walk down"], ["left", "Walk left"], ["right", "Walk right"],
	            ["run", "Run (hold)"], ["walk", "Walk slowly (hold)"], ["autorun", "Walk / run pace (toggle)"], ["use", "Use the held tool (or click)"],
	            ["interact", "Talk / use / open"], ["inventory", "Inventory"], ["map", "World map"],
	            ["cast", "Cast with a staff"], ["spell", "Change spell"]];
	return a;
}

/// @description The key an action is bound to. Test runs use the defaults (so your keys can't break them), unless a
/// test rebinds one itself (autotest_rebind).
function key_of(_action){
	var def = keys_default()[$ _action];
	if((autotest_running() && !(variable_global_exists("keysInTests") && global.keysInTests)) || !variable_global_exists("settings") || !is_struct(global.settings[$ "keys"])) return def;
	return global.settings.keys[$ _action] ?? def;
}

/// @description Always run (on / off): your pace - running (on, the default) or walking (off). Shift sprints either
/// way, Ctrl walks. In tests on, unless a test turns it off (autotest_always_run), so your setting can't change them.
function always_run(){
	if(autotest_running()) return !variable_global_exists("testAlwaysRun") || global.testAlwaysRun;
	return !variable_global_exists("settings") || !is_struct(global.settings) || (global.settings[$ "alwaysRun"] ?? 1) == 1;
}

/// @description Turn always run on or off (the autorun key), saved with the settings, and say so over the player.
function always_run_toggle(){
	if(autotest_running()) global.testAlwaysRun = !always_run();
	else { global.settings.alwaysRun = always_run() ? 0 : 1; settings_save(); }
	with(obj_plyr) popup(x, y - 60, always_run() ? "Pace: running" : "Pace: walking", c_white);
}

/// @description A key's name for the screen: "E", "Space", "Shift"...
function key_name(_key){
	switch(_key){
		case vk_space: return "Space";     case vk_shift: return "Shift";    case vk_control: return "Ctrl";
		case vk_alt: return "Alt";         case vk_enter: return "Enter";    case vk_tab: return "Tab";
		case vk_backspace: return "Backspace";
		case vk_up: return "Up";           case vk_down: return "Down";      case vk_left: return "Left";
		case vk_right: return "Right";     case vk_home: return "Home";      case vk_end: return "End";
		case vk_delete: return "Delete";   case vk_insert: return "Insert";
		case vk_pageup: return "PgUp";     case vk_pagedown: return "PgDn";
	}
	if(_key >= vk_numpad0 && _key <= vk_numpad9) return "Num " + string(_key - vk_numpad0);
	if(_key >= vk_f1 && _key <= vk_f12) return "F" + string(_key - vk_f1 + 1);
	if((_key >= ord("A") && _key <= ord("Z")) || (_key >= ord("0") && _key <= ord("9"))) return chr(_key);
	return "Key " + string(_key);
}

/// @description "[E]" for an action, for the prompts over things you can use.
function key_label(_action){ return "[" + key_name(key_of(_action)) + "]"; }

/// @description Keys you can't bind an action to: Esc (back / pause), Insert and the page keys (debug), the
/// hotbar's number keys.
function key_reserved(_key){
	return _key == vk_escape || _key == vk_insert || _key == vk_pageup || _key == vk_pagedown || (_key >= ord("0") && _key <= ord("9"));
}

function settings_apply(){
	window_set_fullscreen(global.settings.fullscreen);
	audio_master_gain(global.settings.volume / 100);
}

// ---------------------------------------------------------------- pausing

/// @description True in rooms where the game is actually being played (not menus).
function game_is_playing_room(){
	return room != rm_0 && room != rm_menu && room != rm_creator;
}

/// @description Freeze everything except the game controller, crops and the menu.
function game_freeze(){
	instance_deactivate_all(true);
	instance_activate_object(game);
	instance_activate_object(crops);
	instance_activate_object(obj_menu);
}

/// @description Open the pause menu over a snapshot of the current frame.
function game_pause(){
	if(instance_exists(obj_menu)) return;
	with(game){
		pauseShot = sprite_create_from_surface(application_surface, 0, 0,
			surface_get_width(application_surface), surface_get_height(application_surface), false, false, 0, 0);
	}
	crops.planting = false;
	var m = instance_create_depth(0, 0, -10000, obj_menu);
	m.isPause = true;
	m.screen = "pause";
	game_freeze();
}

function game_unpause(){
	instance_activate_all();
	with(obj_menu) instance_destroy();
	with(game){
		if(pauseShot != -1){ sprite_delete(pauseShot); pauseShot = -1; }
		resumeLock = 2;
	}
}

/// @description Saves before version 12: the world was rebuilt (25 new rooms). The farm and the farmhouse keep
/// everything; every other room's rocks, trees and placed things are rolled again (placed things go back in the bag),
/// and resource regrowth starts afresh (resource_areas changed).
function save_upgrade_new_world(){
	var names = variable_struct_get_names(global.world.rooms ?? {});
	for(var i = 0; i < array_length(names); i++){
		if(names[i] == "rm_1" || names[i] == "rm_12" || names[i] == "rm_123") continue;
		var r = world_room(names[i]);
		var p = r[$ "placed"];
		if(is_array(p)) for(var k = 0; k < array_length(p); k++) inv_add(item_stack("o|" + p[k].kind, 1));
		r.placed = [];
		r.objects = [];
		r.due = {};
		r.seeded = false;
	}
	var farm = world_room("rm_1");
	farm.objects = [];
	farm.due = {};
	farm.seeded = false;
}
