/// @description Insert description here
// You can write your code in this editor
if(keyboard_check_pressed(vk_insert)) {debug = !debug}
if(keyboard_check_pressed(vk_home)) {game_restart();}
if(hudTime > 0) hudTime--;
autotest_step();

// Ending the day: fade out, run the new day, wake up beside the bed
if(sleeping){
	blackAlpha = min(1, blackAlpha + 0.025);
	if(blackAlpha >= 1 && !sleepDone){
		sleepDone = true;
		dayReport = day_advance(passedOut);
		crops.loadPending = true; // the store already holds today's crops
		wakeAtBed = true;
		spawnRoom = -1;
		room_goto(BED_ROOM);
	}
}
// Knocked out in the mine: fade out, pay the penalty, wake beside the bed (no new day, no autosave)
if(dying){
	blackAlpha = min(1, blackAlpha + 0.025);
	if(blackAlpha >= 1 && !sleepDone){
		sleepDone = true;
		deathReport = death_penalty();
		revived = true;
		wakeAtBed = true;
		spawnRoom = -1;
		doTransition = false;
		room_goto(BED_ROOM);
	}
}
if(waking){
	blackAlpha = max(0, blackAlpha - 0.025);
	if(blackAlpha <= 0) waking = false;
}
if(autosavePending && instance_exists(obj_plyr)){
	autosavePending = false;
	// Autosave into this game's slot (the one you last saved or loaded). A new game takes the first empty
	// slot; it never overwrites another game's save.
	if(!variable_global_exists("saveSlot") || global.saveSlot == undefined){
		for(var s = 1; s <= SAVE_SLOTS; s++) if(!save_exists(s)){ global.saveSlot = s; break; }
	}
	var saved = (variable_global_exists("saveSlot") && global.saveSlot != undefined) && save_game(global.saveSlot);
	hudMessage = weekday_name(global.clock.day) + " " + string(global.clock.day) + " of " + season_name(global.clock.season)
	           + "  -  " + weather_name(weather_now())
	           + ((festival_today() != undefined) ? "  -  " + festival_today().name + " in the village today!" : "")
	           + (saved ? "  -  saved to slot " + string(global.saveSlot) : "  -  no free save slot: save from the pause menu")
	           + ((dayReport.paid > 0) ? "  -  shipping paid " + string(dayReport.paid) + " gold" : "")
	           + ((dayReport.died > 0) ? "  -  " + string(dayReport.died) + " crops died out of season" : "")
	           + (((dayReport[$ "blessed"] ?? 0) > 0) ? "  -  pixies blessed " + string(dayReport.blessed) + " crops" : "")
	           + ((dayReport.lost > 0) ? "  -  you passed out and lost " + string(dayReport.lost) + " gold" : "");
	hudTime = game_get_speed(gamespeed_fps) * 5;
}

if(game_is_playing_room() && !instance_exists(obj_menu)){
	playtime += delta_time / 1000000;
	var invOpen = ui_blocking(); // any window: inventory, dialogue, notice board, lift
	// The clock runs while you play (not in the inventory, menus or fades); at 2:00 am you pass out
	if(world_time_ready() && !invOpen && !sleeping && !dying && !waking && !doTransition){
		var before = global.clock.minutes;
		if(clock_tick()) sleep_now(true);
		food_tick(global.clock.minutes - before); // food buffs wear off; the cold drains energy outdoors
		mana_tick(global.clock.minutes - before);  // mana trickles back
	}
	if(resumeLock > 0) {resumeLock--;}
	else if(!invOpen && input_pressed(vk_escape)) {game_pause();}
	else if(!invOpen && input_pressed(ord("I")) && instance_exists(obj_plyr)) {instance_create_depth(0, 0, -9000, obj_inventory);}
	
	// Hotbar: 1-9 and 0 pick the held item
	for(var k = 0; k < INV_HOTBAR; k++){
		if(keyboard_check_pressed(ord(string((k + 1) mod 10)))){
			global.inv.hotbar = k;
			inv_apply_look(global.look);
		}
	}

	// Debug (Insert): T skips an hour
	if(debug && world_time_ready() && keyboard_check_pressed(ord("T"))) global.clock.minutes += 60;

	// Debug (Insert): Page Up / Page Down hop between play rooms
	if(debug && (keyboard_check_pressed(vk_pageup) || keyboard_check_pressed(vk_pagedown))){
		var rooms = [rm_1, rm_2, rm_3, rm_12, rm_123, rm_mine, rm_forest];
		var n = array_length(rooms);
		var i = array_get_index(rooms, room);
		spawnRoom = -1; // use the room's own player position
		room_goto(rooms[(i + (keyboard_check_pressed(vk_pagedown) ? 1 : -1) + n) mod n]);
	}
}











