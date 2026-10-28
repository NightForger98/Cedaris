/// Time, energy/health, sleeping and the per-room world store (roadmap phase 0.3 - 0.5).
///
/// global.clock  {minutes, day, season, year}   minutes since midnight: 360 = 6:00 am, 1560 = 2:00 am
/// global.vitals {energy, health, buff}   buff: the food buff (see the food script)
/// global.world  {rooms: {<room name>: {crops: [{gx, gy, type, days}], tiles, objects: [resources], due, seeded}}}
/// The new-day event (day_advance) grows crops, refills energy and health and autosaves; later systems hook in there.

#macro DAY_START 360        // 6:00 am
#macro DAY_END 1560         // 2:00 am: pass out
#macro GAME_MIN_SECONDS 0.7 // real seconds per game minute (10 game minutes every 7 seconds)
#macro SEASON_DAYS 28
#macro BED_ROOM rm_12          // the room with your bed (obj_bed); you wake up next to it

function world_time_new(){
	global.clock = {minutes: DAY_START, day: 1, season: 0, year: 1, weather: "sun"}; // a sunny first day
	global.clock.tomorrow = weather_roll(0);
	global.vitals = {energy: 270, health: 100, buff: undefined};
	global.world = {rooms: {}};
	global.vitals.energy = vitals_max_energy();
	global.vitals.health = vitals_max_health();
}

function world_time_ready(){
	return variable_global_exists("clock") && is_struct(global.clock);
}

// ---------------------------------------------------------------- clock

function season_name(_s){ static n = ["Spring", "Summer", "Fall", "Winter"]; return n[_s mod 4]; }
function weekday_name(_day){ static n = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]; return n[(_day - 1) mod 7]; }

/// @description e.g. "6:40 am", in 10-minute steps like Stardew.
function clock_text(){
	var m = floor(global.clock.minutes / 10) * 10;
	var h = (m div 60) mod 24, mm = m mod 60;
	var ampm = (h < 12) ? "am" : "pm";
	var h12 = h mod 12; if(h12 == 0) h12 = 12;
	return string(h12) + ":" + ((mm < 10) ? "0" : "") + string(mm) + " " + ampm;
}

/// @description Advance the clock by one frame of play. Returns true when it's 2:00 am (time to pass out).
function clock_tick(){
	global.clock.minutes += 1 / (GAME_MIN_SECONDS * game_get_speed(gamespeed_fps));
	return global.clock.minutes >= DAY_END;
}

/// @description Rooms that get the day/night tint.
function room_is_outdoors(){ return room == rm_1 || room == rm_2 || room == rm_forest; }

/// @description Darkness 0-1: evening from 6 pm, full night by 10 pm, light again by 7 am.
function night_amount(){
	var m = global.clock.minutes;
	if(m < 400) return lerp(0.25, 0, (m - DAY_START) / 40);  // 6:00-6:40 sunrise
	if(m < 1080) return 0;                                    // day
	return clamp((m - 1080) / 240, 0, 1) * 0.6;               // 6 pm - 10 pm dusk, then night
}

// ---------------------------------------------------------------- energy and health

/// @description Max energy: 270 (as in Stardew) plus 10 per point of Stamina, and 40 once Hesta's pantry is stocked.
function vitals_max_energy(){ return 270 + 10 * stat("stamina") + (project_done("pantry") ? 40 : 0); } // + Hesta's pantry
function vitals_max_health(){ return 100; }

function vitals_exhausted(){ return global.vitals.energy <= 0; }

/// @description Energy a tool swing costs: 2, minus 2% per point of Stamina (down to half), minus 10% per tool tier.
function tool_energy_cost(_name = ""){
	// Each tool upgrade saves another 10%
	return 2 * (1 - clamp(stat("stamina") * 0.02, 0, 0.5)) * (1 - 0.1 * tool_tier(_name));
}

/// @description True for farm tools (they cost energy); weapons are free to swing, as in Stardew.
function item_is_tool(_name){
	static tools = ["Hoe", "Watering Can", "Axe", "Pickaxe", "Shovel", "Hammer", "Scythe", "Fishing Rod"];
	return array_get_index(tools, _name) != -1;
}

// ---------------------------------------------------------------- world store

/// @description The saved state of a room (created on first use).
function world_room(_name){
	var r = global.world.rooms[$ _name];
	if(r == undefined){ r = {crops: [], tiles: {}, objects: [], due: {}, seeded: false}; global.world.rooms[$ _name] = r; }
	if(!variable_struct_exists(r, "tiles")) r.tiles = {};
	if(!variable_struct_exists(r, "objects")) r.objects = []; // saves before version 3
	if(!variable_struct_exists(r, "due")) r.due = {};
	return r;
}

/// @description Copy the farm's live crop instances into the world store (call before leaving or saving).
function crops_store(){
	if(room != rm_1 || !instance_exists(crops)) return;
	var list = [];
	var cs = crops.cellSize;
	with(obj_crop){ array_push(list, {gx: x div cs, gy: y div cs, type: cropType, days: daysOld}); }
	world_room("rm_1").crops = list;
}

// ---------------------------------------------------------------- sleeping and the new day

/// @description End the day: sleeping in bed, or passing out at 2 am (lose 10% of gold, up to 100).
/// Fades out, runs the new-day event, and wakes you next to your bed at 6:00.
function sleep_now(_passedOut){
	with(game){
		if(sleeping) exit;
		sleeping = true;
		passedOut = _passedOut;
	}
}

/// @description The new-day event. Order matters: store today's world, grow it, then refresh you.
function day_advance(_passedOut){
	crops_store();

	// Calendar
	var ck = global.clock;
	ck.minutes = DAY_START;
	ck.day += 1;
	if(ck.day > SEASON_DAYS){ ck.day = 1; ck.season += 1; if(ck.season > 3){ ck.season = 0; ck.year += 1; } }
	ck.luck = random_range(-0.05, 0.05); // today's luck, added to the Luck stat for harvest quality

	// Farm: watered crops grow, out-of-season crops die, soil dries; resources return; then shipping pays out
	var died = farm_new_day(ck.season);
	weather_new_day(); // today's weather; rain waters the soil that just dried
	var blessed = project_pixie_blessing(); // the shrine's pixies
	resources_new_day(); // stumps regrow, rocks and weeds come back
	var paid = shipping_payout();

	// You: passing out costs gold and leaves you half rested
	var lost = 0;
	if(_passedOut && !inv_is_free()){
		lost = min(100, floor(global.inv.gold * 0.1));
		global.inv.gold -= lost;
	}
	global.vitals.buff = undefined; // food buffs last the day (cleared first: a Stamina buff raises max energy)
	global.vitals.energy = vitals_max_energy() * (_passedOut ? 0.5 : 1);
	global.vitals.health = vitals_max_health();
	global.vitals.mana = mana_max();   // a night's sleep restores your magic
	global.vitals.light = 0;
	return {lost: lost, died: died, paid: paid, blessed: blessed};
}
