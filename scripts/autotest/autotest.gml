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
///   expect <text>             fail unless the last call (or inv) result contains <text>
///   expectnot <text>          fail if it does
///   shot <name>               save a screenshot to autotest/<name>.png
///   quit                      close the game
///
/// A run fails on a failed expect, an ERROR (a runtime error or a missing function) or an unknown command; quit
/// writes autotest/result.txt (PASS or FAIL n), which autotest.sh reports. No result file means it never got to quit.

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
	global.autotest = {lines: lines, i: 0, wait: 30, press: -1, uses: 0, last: "", fails: 0};
}

/// @description A failure: logged, counted, and the run's result becomes FAIL.
function autotest_fail(_text){
	autotest_log("  FAIL " + _text);
	global.autotest.fails++;
}

function autotest_running(){ return variable_global_exists("autotest") && is_struct(global.autotest); }

/// @description keyboard_check_pressed that also sees presses from a test run (simulated key presses don't reach it).
function input_pressed(_key){
	return keyboard_check_pressed(_key) || (variable_global_exists("autotestKey") && global.autotestKey == _key);
}

/// @description A key held down, or held by a test (keydown / keyup), which works even when the window isn't focused.
function input_held(_key){
	return keyboard_check(_key) || (variable_global_exists("autotestHeld") && array_get_index(global.autotestHeld, _key) != -1);
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
		case "left":   return vk_left;
		case "right":  return vk_right;
		case "up":     return vk_up;
		case "down":   return vk_down;
		case "enter":  return vk_enter;
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
	// snap N name: a screenshot N frames on, even mid-action (spins, swings)
	if((t[$ "snapIn"] ?? 0) > 0 && --t.snapIn == 0) screen_save("autotest/" + t.snapName + ".png");
	if(t.wait > 0){ t.wait--; return; }
	// Holding the button to charge (the charge command): let go once the level is reached, or if nothing charges
	if((t[$ "chargeTo"] ?? -1) >= 0){
		var c = instance_exists(obj_plyr) ? obj_plyr.charge : undefined;
		t.chargeWait = (t[$ "chargeWait"] ?? 0) + 1;
		if(c == undefined ? t.chargeWait > 6 : (c.level >= min(t.chargeTo, c.max) && (t[$ "chargeShot"] ?? "") == "")){
			t.chargeTo = -1;
			t.wait = 2;
		}
		else if(c != undefined && c.level >= min(t.chargeTo, c.max) && t.chargeShot != ""){ screen_save("autotest/" + t.chargeShot + ".png"); t.chargeShot = ""; }
		return;
	}
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
			// Held keys (walking): keyboard_check sees a simulated press until it's released
			case "keydown":
				if(!variable_global_exists("autotestHeld")) global.autotestHeld = [];
				array_push(global.autotestHeld, autotest_key(a[1]));
				break;
			case "keyup":
				if(variable_global_exists("autotestHeld")){ var hi = array_get_index(global.autotestHeld, autotest_key(a[1])); if(hi != -1) array_delete(global.autotestHeld, hi, 1); }
				break;
			// charge N [shot]: hold the button until the held tool reaches level N (a screenshot just before letting go)
			case "charge":
				t.chargeTo = real(a[1]);
				t.chargeWait = 0;
				t.chargeShot = (array_length(a) > 2) ? a[2] : "";
				t.press = vk_space;
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
				if(fn == -1){ t.last = ""; autotest_fail("no function " + a[1]); break; }
				var args = [];
				for(var i = 2; i < array_length(a); i++) array_push(args, a[i]);
				var r = script_execute_ext(fn, args);
				t.last = string(r);
				autotest_log("  = " + t.last);
				break;
			case "expect":
			case "expectnot":
				var want = string_trim(string_delete(line, 1, string_length(a[0])));
				var has = string_pos(want, t.last) > 0;
				if(has != (a[0] == "expect")) autotest_fail(a[0] + " \"" + want + "\" in \"" + t.last + "\"");
				break;
			case "log":  autotest_log(string_delete(line, 1, 4)); break;
			case "inv":
				var s = "  gold " + string(global.inv.gold) + ":";
				for(var i = 0; i < INV_SIZE; i++){
					var st = global.inv.slots[i];
					if(st != undefined) s += " " + st.id + "x" + string(st.count);
				}
				t.last = s;
				autotest_log(s);
				break;
			case "snap": t.snapIn = real(a[1]); t.snapName = a[2]; break;
			case "shot":
				screen_save("autotest/" + a[1] + ".png");
				break;
			case "quit":
				var rf = file_text_open_write("autotest/result.txt");
				file_text_write_string(rf, (t.fails == 0) ? "PASS" : ("FAIL " + string(t.fails)));
				file_text_close(rf);
				autotest_log((t.fails == 0) ? "RESULT PASS" : ("RESULT FAIL " + string(t.fails)));
				game_end();
				break;
			default: autotest_fail("unknown command " + a[0]);
		}
	} catch(e) {
		autotest_log("  ERROR " + e.message);
		t.fails++;
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

/// @description Stand the player beside the mine's lift car, and log its floor choice.
function autotest_goto_lift(){
	with(obj_mine_door) if(inMine){ obj_plyr.x = x; obj_plyr.y = y + 14; return "lift at " + string(x) + "," + string(y); }
	return "none";
}

/// @description The lift's state: open, the floor picked, and the deepest it goes to.
function autotest_lift(){
	var s = "no lift";
	with(obj_mine_door) s = "lift open " + string(menuOpen) + " pick " + string(pick) + " top " + string(mine_lift_top()) + " inMine " + string(inMine);
	return s;
}

/// @description Turn first-time hints on for this run (off by default so screenshots stay clean), and say which
/// have been shown and what is showing.
function autotest_hints(){
	global.hintsInTests = true;
	return "seen " + string(global.world[$ "hints"] ?? []) + " showing " + game.hintText + " queued " + string(array_length(game.hintQueue));
}

/// @description Bind an action to a key for this run only (never saved to settings.ini), e.g. call autotest_rebind interact R.
function autotest_rebind(_action, _key){
	global.keysInTests = true;
	global.settings.keys[$ _action] = autotest_key(_key);
	return _action + " = " + key_name(key_of(_action));
}

/// @description Open the pause menu's Controls screen (for a screenshot).
function autotest_controls(){
	game_pause();
	with(obj_menu){ justOpened = false; openScreen("controls"); }
	return instance_exists(obj_menu);
}

/// @description The signposts in this room: where each leads, and which side it stands on.
function autotest_signs(){
	var s = "";
	with(obj_signpost) s += text + "@" + side + " ";
	return (s == "") ? "none" : s;
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

/// @description Fishing for tests: skip the wait, and put the marker in the middle of the green zone.
function autotest_fish_ready(){
	with(obj_fishing){ state = "bite"; marker = zoneAt + zone / 2; markerSpeed = 0; return fish; }
	return "not fishing";
}

/// @description The farm's animals, in short.
function autotest_animals(){
	var s = "";
	var list = animals_list();
	for(var i = 0; i < array_length(list); i++) s += list[i].name + "(" + list[i].kind + " love " + string(list[i].love) + (list[i].ready ? " ready" : "") + ") ";
	return s + " instances " + string(instance_number(obj_animal));
}

/// @description Stand beside the first animal of a kind.
function autotest_goto_animal(_kind){
	with(obj_animal) if(data.kind == _kind){ moveX = 0; moveY = 0; wanderT = 600; obj_plyr.x = x; obj_plyr.y = y + 22; return data.name; }
	return "none";
}

/// @description Set the calendar (season, day), for tests.
/// @description Write an old save (version _v) to the test slot, saved in _room at (_x, _y) as that version had it:
/// a watered crop and a sprinkler on the field, a second sprinkler off it (in the old yard). Before version 10 the farm
/// was 17 columns narrower, so the farm's things are 17 cells further west. Load it with: call load_game test
function autotest_old_save(_v, _room, _x, _y){
	var v = real(_v), dx = (v < 10) ? -17 : 0;
	var farm = world_room("rm_1");
	farm.crops = [{gx: 40 + dx, gy: 25, type: 0, days: 3}];
	farm.tiles = {};
	farm.tiles[$ farm_key(40 + dx, 25)] = {watered: true};
	farm.placed = [{kind: "sprinkler", gx: 41 + dx, gy: 25}, {kind: "sprinkler", gx: 45 + dx, gy: 5}];
	var data = {version: v, savedAt: date_current_datetime(), playtime: 0, room: _room, x: real(_x), y: real(_y), row: 10,
		look: character_look_to_save(obj_plyr.look), inv: inv_to_save(), clock: global.clock, vitals: global.vitals, world: global.world};
	if(!directory_exists("saves")) directory_create("saves");
	var f = file_text_open_write(save_path("test"));
	file_text_write_string(f, json_stringify(data));
	file_text_close(f);
	return "wrote a version " + string(v) + " save in " + _room;
}

/// @description The farm's stored crops, soil and placed things, and sprinklers in the bag (after loading a save)
function autotest_farm_state(){
	var farm = world_room("rm_1"), s = "crops";
	for(var i = 0; i < array_length(farm.crops); i++){ var c = farm.crops[i]; s += " " + string(c.gx) + "," + string(c.gy) + (farm_is_soil(c.gx, c.gy) ? "" : " NOT ON THE FIELD"); }
	s += " | soil " + string_join_ext(",", variable_struct_get_names(farm.tiles)) + " | placed";
	var p = farm[$ "placed"] ?? [];
	for(var i = 0; i < array_length(p); i++) s += " " + p[i].kind + " " + string(p[i].gx) + "," + string(p[i].gy);
	return s + " | sprinklers in bag " + string(inv_count("o|sprinkler"));
}

/// @description A ripe crop of _type at (_x, _y) on the farm's field, twinkling (for a screenshot of the look)
function autotest_ripe_crop(_x, _y, _type){
	instance_create_crop(real(_x), real(_y), real(_type));
	var c = instance_nearest(real(_x), real(_y), obj_crop);
	if(c == noone) return "no crop";
	with(c){ growthStage = maxGrowthStage; fullyGrown = true; sparkle = 2; }
	return "ripe crop " + string(c.cropType);
}

/// @description The frame rate now: fps (capped at the game speed) and fps_real (how fast it could go), and how many
/// instances the room holds.
function autotest_fps_now(){ return "fps " + string(fps) + "  real " + string(round(fps_real)) + "  instances " + string(instance_count); }

/// @description Plan everyone's day afresh and report what's wrong with it: late for work (arriving after opening),
/// home after midnight, or a route that can't be walked. "all on time" if nothing; the longest walk either way.
function autotest_schedule_check(){
	global.schedPlans = {};
	global.schedRoutes = {};
	global.schedProblems = [];
	var names = villager_names(), s = "", longest = 0, longWho = "";
	for(var i = 0; i < array_length(names); i++){
		var k = names[i], p = villager_plan(k);
		for(var l = 0; l < array_length(p.legs); l++){
			var g = p.legs[l], mins = g.t1 - g.t0;
			if(mins > longest){ longest = mins; longWho = k; }
			if(g.work && g.t1 > g.open + 5) s += k + " late for work (" + string(floor(g.t1 / 60)) + ":" + ((floor(g.t1) mod 60 < 10) ? "0" : "") + string(floor(g.t1) mod 60) + ", opens " + string(g.open / 60) + "); ";
		}
		var n = array_length(p.legs);
		if(n > 0 && p.legs[n - 1].t1 > 24 * 60) s += k + " home after midnight; ";
	}
	for(var i = 0; i < array_length(global.schedProblems); i++) s += global.schedProblems[i] + "; ";
	global.schedPlans = {};
	return ((s == "") ? "all on time" : s) + " | longest walk " + string(round(longest)) + " min (" + longWho + ")";
}

/// @description The longest walks today (minutes, who, from, to), longest first: _n of them.
function autotest_long_walks(_n = "10"){
	global.schedPlans = {};
	var names = villager_names(), walks = [];
	for(var i = 0; i < array_length(names); i++){
		var p = villager_plan(names[i]), from = p.start.room;
		for(var l = 0; l < array_length(p.legs); l++){
			var g = p.legs[l];
			array_push(walks, [round(g.t1 - g.t0), names[i], from, g.to.room]);
			from = g.to.room;
		}
	}
	array_sort(walks, function(_a, _b){ return _b[0] - _a[0]; });
	var s = "";
	for(var i = 0; i < min(real(_n), array_length(walks)); i++) s += string(walks[i][0]) + " " + walks[i][1] + " " + walks[i][2] + ">" + walks[i][3] + "; ";
	global.schedPlans = {};
	return s;
}

function autotest_date(_season, _day){ global.clock.season = real(_season); global.clock.day = real(_day); return (festival_today() == undefined) ? "no festival" : festival_today().name; }

/// @description Take part in today's festival event (lantern or weigh-in), as the board's button would.
function autotest_festival_event(){
	var f = festival_today();
	if(f == undefined) return "no festival";
	return (f.kind == "lanterns") ? festival_light_lantern(f) : festival_weigh_in(f);
}

/// @description The player's position, for logs (checking they can walk away from where they start).
function autotest_where(){
	with(obj_plyr) return room_get_name(room) + " " + string(x) + "," + string(y) + (place_meeting(x, y, obj_col_box) ? " inside a solid" : "");
	return "no player";
}

/// @description Pretend the farm came from an old save (crops and a sprinkler on the first test farm's cells), run
/// the save upgrade, and report where things went.
function autotest_upgrade_rooms(){
	var farm = world_room("rm_1");
	farm.crops = [{gx: 3, gy: 3, type: 0, days: 2}, {gx: 4, gy: 3, type: 0, days: 5}];
	farm.tiles = {};
	farm.tiles[$ farm_key(3, 3)] = {watered: true};
	farm.placed = [{kind: "sprinkler", gx: 6, gy: 6}];
	save_upgrade_rooms();
	var s = "";
	for(var i = 0; i < array_length(farm.crops); i++){
		var c = farm.crops[i];
		var t = farm.tiles[$ farm_key(c.gx, c.gy)];
		s += string(c.gx) + "," + string(c.gy) + (farm_is_soil(c.gx, c.gy) ? " soil" : " NOT SOIL") + (t.watered ? " watered  " : "  ");
	}
	return s + "placed " + string(array_length(farm.placed)) + "  sprinklers in bag " + string(inv_count("o|sprinkler"));
}

/// @description The open shop: its title, how many things it sells, and the first few.
function autotest_shop_stock(){
	with(obj_inventory){
		var s = shopTitle + ": " + string(array_length(shopStock)) + " -";
		for(var i = 0; i < min(4, array_length(shopStock)); i++) s += " " + item_def(shopStock[i].id).name + " " + string(shopStock[i].price);
		return s;
	}
	return "no shop";
}

/// @description Every villager's shirt, legs and shoes, e.g. "fen: Tunic / Child pants / Basic Shoes".
function autotest_villager_clothes(){
	var names = variable_struct_get_names(villager_table());
	array_sort(names, true);
	var items = lpc_catalog().items, out = "";
	static slots = ["shirt", "pants", "shoes", "hat", "coat"];
	for(var i = 0; i < array_length(names); i++){
		if(villager_def(names[i])[$ "look"] != undefined) continue;   // dressed by hand
		var look = villager_look(names[i]);
		out += "\n    " + names[i] + " (" + look.body + "):";
		for(var k = 0; k < array_length(slots); k++){
			var it = look.parts[$ slots[k]].item;
			out += " " + ((it == -1) ? "-" : items[it].name) + (character_item_fits(max(it, 0), look.body) || it == -1 ? "" : "(!)") + " /";
		}
	}
	return out;
}

/// @description Where every villager is now, e.g. "brom rm_village_smithy 272,184 work" (walking: "->").
function autotest_schedules(){
	var names = villager_names(), out = "";
	for(var i = 0; i < array_length(names); i++){
		var w = villager_where(names[i]);
		out += "\n    " + names[i] + " " + w.room + " " + string(round(w.x)) + "," + string(round(w.y)) + (w.moving ? " ->" : "") + (w.work ? " work" : "");
	}
	return out;
}

/// @description Today's stops for one villager, and their shop's state.
function autotest_day(_key){
	var p = villager_plan(_key), out = "start " + p.start.room;
	for(var i = 0; i < array_length(p.legs); i++){
		var l = p.legs[i];
		out += " | " + hour_text(l.t0 / 60) + "-" + hour_text(l.t1 / 60) + " " + l.to.room + (l.work ? " (work)" : "");
	}
	return out + ((villager_routine(_key)[$ "work"] != undefined) ? " | shop open now: " + string(villager_shop_open(_key)) : "");
}

/// @description What the open dialogue says.
function autotest_dialogue_text(){ return instance_exists(obj_dialogue) ? obj_dialogue.text : "(no dialogue)"; }

/// @description Point the open world map at a building (the room inside), as the mouse would.
function autotest_map_hover(_room){
	if(!instance_exists(obj_world_map)) return "no map";
	obj_world_map.testHover = _room;
	return building_label(_room);
}

/// @description Frame rate now (fps_real: how fast a frame could run), and how long the schedules' first plans took.
function autotest_fps(){
	var t0 = get_timer();
	global.schedPlans = {};
	var names = villager_names();
	for(var i = 0; i < array_length(names); i++) villager_plan(names[i]);
	return "fps " + string(fps) + " real " + string(round(fps_real)) + "  plans " + string(round((get_timer() - t0) / 1000)) + " ms, routes kept " + string(variable_struct_names_count(global.schedRoutes));
}

/// @description Beat this room's boss at once, as if the last blow landed.
function autotest_kill_boss(){
	var b = mine_boss_here();
	if(b == noone) return "no boss";
	var n = b.def.name;
	monster_kill(b);
	return n + " beaten";
}

/// @description Stand _dist px south of the nearest monster of a kind (to be shot at), facing it.
function autotest_stand_off(_kind, _dist){
	with(obj_monster) if(kind == _kind && !dying){ obj_plyr.x = x; obj_plyr.y = y + real(_dist); obj_plyr.y_frame = 8; cooldown = 0; return kind + " at " + string(round(x)) + "," + string(round(y)); }
	return "none";
}

/// @description Monster shots in flight: how many, and the first one's position, speed and life.
function autotest_shots(){
	var s = "shots " + string(instance_number(obj_enemy_shot));
	with(obj_enemy_shot){ s += " first at " + string(round(x)) + "," + string(round(y)) + " d " + string(dx) + "," + string(dy) + " life " + string(life); break; }
	return s;
}

/// @description Like autotest_stand_off, but picks a side (S, N, E, W) where the player stands on open floor with a
/// clear line of open floor to the monster.
function autotest_stand_clear(_kind, _dist){
	var dd = real(_dist);
	with(obj_monster){
		if(kind != _kind || dying) continue;
		static dirs = [[0, 1], [0, -1], [1, 0], [-1, 0]];
		for(var k = 0; k < 4; k++){
			var px = x + dirs[k][0] * dd, py = y + dirs[k][1] * dd, clear = true;
			for(var t = 0; t <= 1 && clear; t += 0.05)
				if(tilemap_get_at_pixel(global.mineWalls, lerp(x, px, t), lerp(y, py, t)) > 0) clear = false;
			if(!clear) continue;
			obj_plyr.x = px; obj_plyr.y = py; cooldown = 0;
			return kind + " side " + string(k);
		}
	}
	return "no clear side";
}

/// @description Where a villager is now, as "room x,y" (and whether they're at work).
function autotest_villager_at(_key){
	var w = villager_where(_key);
	return w.room + " " + string(round(w.x)) + "," + string(round(w.y)) + (w.work ? " (work)" : "") + (w.moving ? " (walking)" : "");
}

/// @description A villager in this room's sidestep offset, after standing the player right where they'd be.
function autotest_block(_key){
	with(obj_villager) if(who == _key){ obj_plyr.x = x; obj_plyr.y = y; return "blocking " + _key; }
	return "not here";
}
function autotest_side(_key){
	with(obj_villager) if(who == _key) return "offset " + string(round(sideX)) + "," + string(round(sideY));
	return "not here";
}

/// @description Move the player by (dx, dy).
function autotest_nudge(_dx, _dy){ obj_plyr.x += real(_dx); obj_plyr.y += real(_dy); return "moved"; }

/// @description Set a tool's tier for charging tests ("Watering_Can" for names with spaces).
function autotest_tool_tier(_name, _tier){
	var n = string_replace_all(_name, "_", " ");
	if(!is_struct(global.inv[$ "tools"])) global.inv.tools = {};
	global.inv.tools[$ n] = real(_tier);
	if(n == "Watering Can") global.inv.water = tool_water_max();
	return n + " tier " + string(_tier) + ", charges to " + string(charge_max(n));
}

/// @description Tilled and watered cells in this room, and the can's water.
function autotest_field(){
	var tiles = farm_tiles(), keys = variable_struct_get_names(tiles), w = 0;
	for(var i = 0; i < array_length(keys); i++) if(tiles[$ keys[i]].watered) w++;
	return "tilled " + string(array_length(keys)) + "  watered " + string(w) + "  water " + string(global.inv[$ "water"] ?? 0);
}

/// @description Untill this room's field (between test steps).
function autotest_field_reset(){
	var tiles = farm_tiles(), keys = variable_struct_get_names(tiles);
	for(var i = 0; i < array_length(keys); i++) variable_struct_remove(tiles, keys[i]);
	return "cleared " + string(array_length(keys));
}

/// @description Put a resource of a kind on every cell in a ring round the player (radius in cells).
function autotest_ring(_key, _r){
	var cs = crops.cellSize, cx = obj_plyr.x div cs, cy = (obj_plyr.y - 4) div cs, r = real(_r), n = 0;
	for(var i = -r; i <= r; i++) for(var j = -r; j <= r; j++){
		if(i == 0 && j == 0) continue;
		var d = sqrt(i * i + j * j);
		if(d < r - 0.5 || d > r + 0.5) continue;
		autotest_spawn(_key, cx + i, cy + j);
		n++;
	}
	return n;
}

/// @description The player's charge right now, for logs.
function autotest_charge(){
	var c = obj_plyr.charge;
	return (c == undefined) ? "not charging (last swing level " + string(obj_plyr.actCharge) + ")" : c.item + " level " + string(c.level) + "/" + string(c.max);
}

/// @description Spawn monsters of a kind round the player: up, left, down and right, _dist pixels away.
function autotest_monster_ring(_kind, _dist){
	var d = real(_dist);
	with(obj_monster) instance_destroy();
	with(obj_enemy_shot) instance_destroy();
	monster_spawn(_kind, obj_plyr.x, obj_plyr.y - d, 1);
	monster_spawn(_kind, obj_plyr.x - d, obj_plyr.y, 1);
	monster_spawn(_kind, obj_plyr.x, obj_plyr.y + d, 1);
	monster_spawn(_kind, obj_plyr.x + d, obj_plyr.y, 1);
	return 4;
}

/// @description One monster of a kind _dist pixels in front of the player (facing right).
function autotest_monster_ahead(_kind, _dist){
	with(obj_monster) instance_destroy();
	with(obj_enemy_shot) instance_destroy();
	monster_spawn(_kind, obj_plyr.x + real(_dist), obj_plyr.y, 1);
	with(obj_plyr){ y_frame = 11; facing = -1; }
	return obj_plyr.x;
}

/// @description Every monster's health, and the player's position, for logs.
function autotest_monster_hps(){
	var s = "";
	with(obj_monster) s += kind + " " + string(hp) + "/" + string(hpMax) + (dying ? " (down)" : "") + "  ";
	return s + " player x " + string(round(obj_plyr.x));
}

function autotest_fishing_now(){ return instance_exists(obj_fishing) ? "fishing" : "not fishing"; }

/// @description In the mine: stand on a spot with open floor _left px to the left, _right px to the right and _ud px
/// up and down (no rock), clearing any resources there. Returns the spot or "none".
function autotest_open_floor(_left, _right, _ud){
	var l = real(_left), r = real(_right), u = real(_ud);
	for(var yy = 64 + u; yy < room_height - 64 - u; yy += 16){
		for(var xx = 64 + l; xx < room_width - 64 - r; xx += 16){
			var ok = true;
			for(var px = xx - l; px <= xx + r && ok; px += 8)
				for(var py = yy - u; py <= yy + u && ok; py += 8)
					if(tilemap_get_at_pixel(global.mineWalls, px, py) > 0) ok = false;
			if(!ok) continue;
			obj_plyr.x = xx; obj_plyr.y = yy;
			with(obj_resource) if(x > xx - l - 16 && x < xx + r + 16 && y > yy - u - 16 && y < yy + u + 16) instance_destroy();
			return string(xx) + "," + string(yy);
		}
	}
	return "none";
}

/// @description The player's shot in flight: its speed and how far it will go.
function autotest_projectile(){
	with(obj_projectile) return "speed " + string(point_distance(0, 0, dx, dy)) + "  reach " + string(round(point_distance(0, 0, dx, dy) * life)) + "  damage " + string(weapon.dmg);
	return "no shot";
}

/// @description A witch's bolt hits the player: "poison" or "curse" (as obj_enemy_shot does).
function autotest_bolt(_kind){
	obj_plyr.iframes = 0;
	player_hurt(3, obj_plyr.x, obj_plyr.y - 30);
	if(_kind == "poison") status_poison(14);
	if(_kind == "curse") status_curse();
	return autotest_status();
}

/// @description Health, poison, the curse and the Defence it costs, for logs.
function autotest_status(){
	return "health " + string(global.vitals.health) + "  poison " + string(ceil(global.vitals[$ "poison"] ?? 0)) + "s  cursed '" + curse_item()
	       + "' pending " + string(global.inv[$ "cursePending"] ?? false) + "  hotbar " + string(global.inv.hotbar + 1) + "  defense " + string(stat("defense"));
}

/// @description Press a hotbar number key (1-10) the way the game's Step does, curse and all.
function autotest_hotbar(_n){
	var k = real(_n) - 1;
	if(curse_hotbar_ok(k)){ global.inv.hotbar = k; inv_apply_look(global.look); with(obj_plyr) look = global.look; }
	return autotest_status();
}

/// @description Choose option _i in the open dialogue's choice (as pressing 1 or 2 does).
function autotest_choose(_i){
	with(obj_dialogue){
		var pick = real(_i);
		chosen = pick; text = event.choice.options[pick][2]; note = heart_event_finish(event, pick); eventDone = true;
		return text + " / " + note;
	}
	return "no dialogue";
}

/// @description Witches on a floor, and one spawned beside the player if asked.
function autotest_witch(_spawn = "0"){
	if(real(_spawn) > 0) monster_spawn("witch", obj_plyr.x + 160, obj_plyr.y, mine_state().floor);
	var n = 0;
	with(obj_monster) if(kind == "witch") n++;
	return n;
}

/// @description Whether the clock moves here: ticks once and reports "frozen" (indoors, the mine) or "ticking".
function autotest_clock_frozen(){
	var m = global.clock.minutes;
	clock_tick();
	var moved = global.clock.minutes != m;
	global.clock.minutes = m;
	return moved ? "ticking" : "frozen";
}

/// @description Whether the player stands on road (the road boost) and their speed now.
function autotest_road_here(){
	if(!instance_exists(obj_plyr)) return "no player";
	var on = world_is_road(room_get_name(room), floor(obj_plyr.x / 32), floor(obj_plyr.y / 32));
	return (on ? "road" : "off road") + " at " + string(floor(obj_plyr.x / 32)) + "," + string(floor(obj_plyr.y / 32)) + ", speed " + string(obj_plyr.spd);
}

/// @description The room the player is in, by name.
function autotest_room_name(){ return room_get_name(room); }

/// @description Every way between two outdoor rooms: you arrive on walkable ground, and there's a way back.
/// Returns "all linked (n ways)" or the problems.
function autotest_world_links(){
	var w = room_walk(), rooms = world_outdoors(), s = "", n = 0;
	for(var i = 0; i < array_length(rooms); i++){
		var a = rooms[i], wa = w[$ a];
		if(wa == undefined) continue;   // Whisperwood: built at runtime
		for(var d = 0; d < array_length(wa.doors); d++){
			var door = wa.doors[d], b = door[2];
			if(!world_is_outdoors(b)) continue;
			n++;
			var wb = w[$ b];
			if(wb == undefined){ s += a + ">" + b + " no such room; "; continue; }
			var cx = door[3] div 32, cy = door[4] div 32;
			if(cx < 0 || cy < 0 || cx >= wb.w || cy >= wb.h || string_char_at(wb.grid, cy * wb.w + cx + 1) == "0") s += a + ">" + b + " arrives on a wall; ";
			var back = false;
			for(var k = 0; k < array_length(wb.doors); k++) if(wb.doors[k][2] == a) back = true;
			if(!back) s += a + ">" + b + " no way back; ";
		}
	}
	return (s == "") ? "all linked (" + string(n) + " ways)" : s;
}
