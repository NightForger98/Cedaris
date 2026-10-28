/// Automated test runs: if autotest.txt is in the save folder at startup, the game plays it line by line,
/// then deletes it. tools/test/autotest.sh writes the file, runs the game and collects the screenshots.
/// While a test runs nothing is saved, so real save slots are never touched.
///
/// Commands (one per line, # starts a comment):
///   start free|story          new game with the default look, straight onto the farm
///   room <rm> [x y]           go to a room (at x, y)
///   pos <x> <y>               move the player
///   face n|w|s|e              turn the player
///   give <item id> [n]        add items, e.g. give m|wood 10, give c|held|Axe
///   hold <slot>               select a hotbar slot (1-10)
///   key <key>                 press a key (seen by input_pressed): space, e, i, esc, insert, pgup, pgdn or a letter
///   debug on|off              debug mode (Insert)
///   use [n]                   press space n times, waiting for each action to finish
///   wait <frames>             let the game run
///   time <hour>               set the clock (6-25)
///   gold <n>                  set gold
///   sleep                     sleep in bed (ends the day)
///   call <function> [args]    call a script function, e.g. call smelt m|copper (strings only)
///   log <text>                write a line to autotest/log.txt
///   inv                       log the inventory
///   shot <name>               save a screenshot to autotest/<name>.png
///   quit                      close the game

function autotest_start(){
	global.autotest = undefined;
	if(!file_exists("autotest.txt")) return;
	var lines = [];
	var f = file_text_open_read("autotest.txt");
	while(!file_text_eof(f)){
		var l = string_trim(file_text_readln(f));
		if(l != "" && string_char_at(l, 1) != "#") array_push(lines, l);
	}
	file_text_close(f);
	file_delete("autotest.txt");
	if(!directory_exists("autotest")) directory_create("autotest");
	var lf = file_text_open_write("autotest/log.txt");
	file_text_close(lf);
	global.autotest = {lines: lines, i: 0, wait: 30, press: -1, uses: 0};
}

function autotest_running(){ return variable_global_exists("autotest") && is_struct(global.autotest); }

/// @description keyboard_check_pressed that also sees presses from a test run (simulated key presses don't reach it).
function input_pressed(_key){
	return keyboard_check_pressed(_key) || (variable_global_exists("autotestKey") && global.autotestKey == _key);
}

function autotest_log(_text){
	var f = file_text_open_append("autotest/log.txt");
	file_text_write_string(f, _text);
	file_text_writeln(f);
	file_text_close(f);
}

function autotest_key(_name){
	switch(string_lower(_name)){
		case "space":  return vk_space;
		case "esc":    return vk_escape;
		case "insert": return vk_insert;
		case "pgup":   return vk_pageup;
		case "pgdn":   return vk_pagedown;
		case "shift":  return vk_shift;
	}
	return ord(string_upper(_name));
}

/// @description Run from the game object's Step: one command per frame, or wait.
function autotest_step(){
	if(!autotest_running()){ global.autotestKey = -1; return; }
	var t = global.autotest;
	// A test press lasts from this Step to the next one, so every object sees it exactly once
	global.autotestKey = t.press;
	t.press = -1;
	if(t.wait > 0){ t.wait--; return; }
	// Nothing happens while an action plays out, so its hit lands where it was aimed
	if(instance_exists(obj_plyr) && obj_plyr.act != undefined) return;
	if(t.uses > 0){
		t.uses--;
		t.press = vk_space;
		t.wait = 3;
		return;
	}
	if(t.i >= array_length(t.lines)){ global.autotest = undefined; return; }

	var line = t.lines[t.i++];
	var a = string_split(line, " ", true);
	autotest_log("> " + line);
	try {
		switch(a[0]){
			case "start":
				global.gameMode = a[1];
				global.look = character_default_look();
				world_time_new();
				global.inv = (a[1] == "story") ? inv_new_story() : inv_new_free(global.look);
				global.saveSlot = undefined;
				inv_apply_look(global.look);
				game.spawnRoom = -1;
				room_goto(rm_1);
				t.wait = 20;
				break;
			case "room":
				var rm = asset_get_index(a[1]);
				with(game){
					spawnRoom = (array_length(a) > 3) ? rm : -1;
					if(array_length(a) > 3){ spawnX = real(a[2]); spawnY = real(a[3]); spawnPlayerFacing = dir.down; }
				}
				room_goto(rm);
				t.wait = 20;
				break;
			case "pos":  with(obj_plyr){ x = real(a[1]); y = real(a[2]); } break;
			case "face": with(obj_plyr){ y_frame = 8 + string_pos(a[1], "nwse") - 1; facing = -1; } break;
			case "give":
				var n = (array_length(a) > 2) ? real(a[2]) : 1;
				inv_add(item_stack(a[1], n));
				inv_apply_look(global.look);
				break;
			case "hold":
				global.inv.hotbar = real(a[1]) - 1;
				inv_apply_look(global.look);
				with(obj_plyr) look = global.look;
				break;
			case "key":
				var k = autotest_key(a[1]);
				t.press = k;
				t.wait = 2;
				break;
			case "use":  t.uses = (array_length(a) > 1) ? real(a[1]) : 1; break;
			case "debug": game.debug = (a[1] == "on"); break;
			case "wait": t.wait = real(a[1]); break;
			case "time": global.clock.minutes = real(a[1]) * 60; break;
			case "gold": global.inv.gold = real(a[1]); break;
			case "sleep": sleep_now(false); t.wait = 150; break;
			case "call":
				var fn = asset_get_index(a[1]);
				var args = [];
				for(var i = 2; i < array_length(a); i++) array_push(args, a[i]);
				var r = script_execute_ext(fn, args);
				autotest_log("  = " + string(r));
				break;
			case "log":  autotest_log(string_delete(line, 1, 4)); break;
			case "inv":
				var s = "  gold " + string(global.inv.gold) + ":";
				for(var i = 0; i < INV_SIZE; i++){
					var st = global.inv.slots[i];
					if(st != undefined) s += " " + st.id + "x" + string(st.count);
				}
				autotest_log(s);
				break;
			case "shot":
				screen_save("autotest/" + a[1] + ".png");
				break;
			case "quit": game_end(); break;
			default: autotest_log("  unknown command");
		}
	} catch(e) {
		autotest_log("  ERROR " + e.message);
	}
}

/// @description Stand just south of the nearest resource of a kind, facing it. Returns its position or "none".
function autotest_goto(_key){
	var best = noone, bd = infinity;
	with(obj_resource){
		if(data.key != _key || !instance_exists(obj_plyr)) continue;
		var d = point_distance(x, y, obj_plyr.x, obj_plyr.y);
		if(d < bd){ bd = d; best = id; }
	}
	if(best == noone) return "none";
	with(obj_plyr){ x = best.x; y = best.y + 30; y_frame = 8; facing = -1; }
	return string(best.x) + "," + string(best.y) + " hp " + string(best.data.hp);
}

/// @description Make one of a station recipe (the furnace or weaving list), as a click on it would.
function autotest_station(_station, _id){
	var list = station_recipes(_station);
	for(var i = 0; i < array_length(list); i++) if(list[i].id == _id) return inv_craft(_id, list[i].cost);
	return "no recipe";
}

/// @description Switch the open shop to Brom's Upgrades tab.
function autotest_upgrades_tab(){ with(obj_inventory) upgrades = true; return instance_exists(obj_inventory); }

/// @description Count of each resource kind in this room.
function autotest_resources(){
	var counts = {};
	with(obj_resource) counts[$ data.key] = (counts[$ data.key] ?? 0) + 1;
	return json_stringify(counts);
}

/// @description Put a resource of a kind in a cell of this room (replacing what's there), for tests.
function autotest_spawn(_key, _gx, _gy){
	var objs = resource_objects(room_get_name(room));
	var gx = real(_gx), gy = real(_gy);
	with(obj_resource) if(data.gx == gx && data.gy == gy){ array_delete(objs, array_get_index(objs, data), 1); instance_destroy(); }
	var d = resource_make(_key, gx, gy, -1);
	array_push(objs, d);
	resource_create_instance(d);
	return _key;
}
