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
///   season <0-3>              set the season
///   mine <floor>              go down to a mine floor
///   equip <item id>           put that item on hotbar slot 10 and hold it
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
				// Item names can have spaces ("c|held|Arming Sword"); a number at the end is the count
				var n = 1, last = array_length(a) - 1;
				if(last > 1 && string_digits(a[last]) == a[last]){ n = real(a[last]); last--; }
				var gid = a[1];
				for(var i = 2; i <= last; i++) gid += " " + a[i];
				inv_add(item_stack(gid, n));
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
			case "season": global.clock.season = real(a[1]); break;
			case "mine": mine_goto(real(a[1])); t.wait = 40; break;
			case "equip":
				// Move the first stack of an item onto hotbar slot 10 and hold it
				var eid = string_delete(line, 1, 6);
				for(var i = 0; i < INV_SIZE; i++){
					var st = global.inv.slots[i];
					if(st == undefined || st.id != eid) continue;
					global.inv.slots[i] = global.inv.slots[9];
					global.inv.slots[9] = st;
					break;
				}
				global.inv.hotbar = 9;
				inv_apply_look(global.look);
				with(obj_plyr) look = global.look;
				break;
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

/// @description Energy, warmth and the food buff, for logs.
function autotest_vitals(){
	var b = food_buff();
	return "energy " + string_format(global.vitals.energy, 1, 1) + "/" + string(vitals_max_energy()) + "  mana " + string_format(mana(), 1, 1) + "/" + string(mana_max()) + "  cold " + string(climate_cold())
	       + "  warmth " + string(stat("warmth")) + "  buff " + ((b == undefined) ? "none" : b.dish + " until " + string(b.until));
}

/// @description Stand just south of the nearest monster (of a kind, or any), facing it. Returns what it is.
function autotest_goto_monster(_kind = ""){
	var best = noone, bd = infinity;
	with(obj_monster){
		if(dying || (_kind != "" && kind != _kind) || !instance_exists(obj_plyr)) continue;
		var d = point_distance(x, y, obj_plyr.x, obj_plyr.y);
		if(d < bd){ bd = d; best = id; }
	}
	if(best == noone) return "none";
	with(obj_plyr){ x = best.x; y = best.y + 24; y_frame = 8; facing = -1; }
	return best.kind + " hp " + string(best.hp) + "/" + string(best.hpMax);
}

/// @description Count of each monster kind here.
function autotest_monsters(){
	var counts = {};
	with(obj_monster) if(!dying) counts[$ kind] = (counts[$ kind] ?? 0) + 1;
	return json_stringify(counts);
}

/// @description Stand on the mine's ladder down.
function autotest_goto_ladder(){
	with(obj_mine_ladder) if(down){ obj_plyr.x = x; obj_plyr.y = y + 10; return "ladder at " + string(x) + "," + string(y); }
	return "none";
}

/// @description A monster-sized hit on the player, for testing being knocked out.
function autotest_hurt(_n){ obj_plyr.iframes = 0; player_hurt(real(_n), obj_plyr.x, obj_plyr.y - 30); return global.vitals.health; }

/// @description Where the mine is: floor, deepest, health.
function autotest_mine(){
	return "floor " + string(mine_state().floor) + " deepest " + string(mine_state().deepest) + "  health " + string(global.vitals.health) + "  cold " + string(climate_cold());
}

/// @description The crop and soil in front of the player: stage, days, watered.
function autotest_crop_front(){
	var c = farm_front_cell(obj_plyr, clamp(obj_plyr.y_frame - 8, 0, 3));
	var t = farm_tiles()[$ farm_key(c[0], c[1])];
	var cr = farm_crop_at(c[0], c[1]);
	return "cell " + string(c[0]) + "," + string(c[1]) + (t == undefined ? " untilled" : (t.watered ? " watered" : " dry"))
	       + ((cr == noone) ? " no crop" : " crop stage " + string(cr.growthStage) + " days " + string(cr.daysOld));
}

/// @description Stand by the mine floor's treasure chest.
function autotest_goto_chest(){
	with(obj_chest){ obj_plyr.x = x; obj_plyr.y = y + 24; return "chest for floor " + string(chestFloor); }
	return "none";
}

/// @description Select a known spell and fill the mana pool, for tests.
function autotest_spell(_key){ global.inv.spell = _key; global.vitals.mana = mana_max(); return spell_selected(); }

/// @description Villagers in this room.
function autotest_people(){
	var s = "";
	with(obj_npc_parent) if(who != "") s += who + "@" + string(round(x)) + "," + string(round(y)) + " ";
	return s;
}

/// @description Stand just below a villager, facing them.
function autotest_goto_person(_key){
	with(obj_npc_parent) if(who == _key){ obj_plyr.x = x; obj_plyr.y = y + 30; obj_plyr.y_frame = 8; return _key; }
	return "none";
}

function autotest_friend(_key){
	var p = people_state(_key);
	return _key + " points " + string(p.points) + " hearts " + string(people_hearts(_key)) + " rewarded " + string(p.rewarded) + " taste of held: "
	       + ((inv_held_stack() == undefined) ? "-" : people_taste(_key, inv_held_stack().id));
}

function autotest_set_friend(_key, _pts){ people_state(_key).points = real(_pts); return people_hearts(_key); }

function autotest_quest_accept(_i){ return quest_accept(real(_i)); }
function autotest_quest_hand_in(_i){ return quest_hand_in(real(_i)); }

/// @description Make the first taken request ready: give the items, or count the kills.
function autotest_quest_fill(){
	var act = quests_state().active;
	if(array_length(act) == 0) return "no requests";
	var q = act[0];
	if(q.kind == "slay") q.got = q.n;
	else inv_add(item_stack(cost_item_id(q.item), q.n));
	return quest_goal_text(q);
}

/// @description What's open: dialogue, inventory (shop), board.
function autotest_ui(){
	return "dialogue " + string(instance_exists(obj_dialogue)) + " inventory " + string(instance_exists(obj_inventory))
	       + " board " + string(instance_exists(obj_quest_board) && obj_quest_board.open);
}

/// @description Set today's or tomorrow's weather, for tests.
function autotest_weather(_today, _tomorrow = ""){
	global.clock.weather = _today;
	if(_tomorrow != "") global.clock.tomorrow = _tomorrow;
	return weather_now() + " / " + weather_tomorrow();
}

/// @description Finish a village project at once (hand in everything), for tests.
function autotest_project_finish(_key){
	var d = project_def(_key), p = project_state(_key);
	for(var i = 0; i < array_length(d.need); i++) p.given[$ d.need[i][0]] = d.need[i][1];
	p.done = true;
	return project_done(_key);
}

/// @description The forest's layout, in short.
function autotest_forest(){
	if(!variable_global_exists("forestMap")) return "no map";
	var f = global.forestMap, open = 0;
	for(var x1 = 0; x1 < FOREST_W; x1++) for(var y1 = 0; y1 < FOREST_H; y1++) if(f.grid[x1][y1] == 0) open++;
	return "open " + string(open) + " entrance " + string(f.entrance) + " shrine " + string(f.shrine) + " pond " + string(f.pond)
	       + " trees " + string(instance_number(obj_resource));
}

/// @description Stand south of the shrine.
function autotest_goto_shrine(){ with(obj_shrine){ obj_plyr.x = x; obj_plyr.y = y + 30; return "shrine"; } return "none"; }

/// @description Switch the open notice board to a page ("requests" / "projects").
function autotest_board_page(_page){ with(obj_quest_board) page = _page; return instance_exists(obj_quest_board) && obj_quest_board.open; }

/// @description Make one of the Build list (sprinklers) as a click would.
function autotest_build(_id){
	var list = placeable_recipes();
	for(var i = 0; i < array_length(list); i++) if(list[i].id == _id) return inv_craft(_id, list[i].cost);
	return "not on the list";
}
