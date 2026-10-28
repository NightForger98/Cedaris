/// Fishing (milestone 10.5, docs/MILESTONES.md): cast the rod at water, wait for a bite, then press Space while the
/// sweeping marker is in the green zone (obj_fishing). Which fish bite depends on the water, season, time and weather.
/// Fish are items "x|<fish>": sell them, eat them, or cook them.

/// @description Fish. where: the waters it lives in ("farm" pond, "forest" pond); seasons ([] = all); time: "day",
/// "night" or "any"; rain: only when it's raining; hard: 0-1 (a narrower zone and a faster marker); weight: how common.
function fish_table(){
	static t = {
		perch:    {name: "Pond Perch",    where: ["farm", "forest"], seasons: [],     time: "any",   rain: false, hard: 0.15, weight: 30, sell: 30,  energy: 20, colour: make_colour_rgb(150, 170, 90)},
		carp:     {name: "Mud Carp",      where: ["farm"],           seasons: [0, 2], time: "any",   rain: false, hard: 0.3,  weight: 20, sell: 45,  energy: 25, colour: make_colour_rgb(150, 120, 70)},
		sunfish:  {name: "Sunfish",       where: ["farm", "forest"], seasons: [1],    time: "day",   rain: false, hard: 0.35, weight: 18, sell: 55,  energy: 25, colour: make_colour_rgb(240, 190, 60)},
		trout:    {name: "Glimmer Trout", where: ["forest"],         seasons: [],     time: "any",   rain: true,  hard: 0.55, weight: 14, sell: 95,  energy: 35, colour: make_colour_rgb(160, 200, 230)},
		pike:     {name: "Frost Pike",    where: ["farm", "forest"], seasons: [3],    time: "any",   rain: false, hard: 0.5,  weight: 16, sell: 80,  energy: 35, colour: make_colour_rgb(190, 220, 240)},
		moonfin:  {name: "Moonfin",       where: ["forest"],         seasons: [],     time: "night", rain: false, hard: 0.75, weight: 8,  sell: 150, energy: 40, colour: make_colour_rgb(200, 190, 255)},
		boot:     {name: "Old Boot",      where: ["farm", "forest"], seasons: [],     time: "any",   rain: false, hard: 0.05, weight: 6,  sell: 1,   energy: 0,  colour: make_colour_rgb(110, 80, 55), junk: true},
	};
	return t;
}

function fish_def(_key){ return fish_table()[$ _key]; }

/// @description Which water this room's fishing is in.
function fishing_place(){
	if(room == rm_forest) return "forest";
	return "farm";
}

/// @description Pick what bites here and now (weighted), or undefined if nothing lives here.
function fish_roll(){
	var t = fish_table(), names = variable_struct_get_names(t);
	var place = fishing_place(), night = global.clock.minutes >= 1200 || global.clock.minutes < DAY_START;
	var cands = [], total = 0;
	for(var i = 0; i < array_length(names); i++){
		var f = t[$ names[i]];
		if(array_get_index(f.where, place) == -1) continue;
		if(array_length(f.seasons) > 0 && array_get_index(f.seasons, global.clock.season mod 4) == -1) continue;
		if((f.time == "day" && night) || (f.time == "night" && !night)) continue;
		if(f.rain && !weather_is_wet()) continue;
		array_push(cands, names[i]);
		total += f.weight;
	}
	if(total <= 0) return undefined;
	var r = random(total);
	for(var i = 0; i < array_length(cands); i++){ r -= t[$ cands[i]].weight; if(r < 0) return cands[i]; }
	return cands[0];
}

/// @description The rod's swing lands (from action_hit): if there's water within two cells in front, start fishing.
function fishing_cast(_user, _dir){
	var dx = [0, -1, 0, 1][_dir], dy = [-1, 0, 1, 0][_dir];
	for(var reach = 1; reach <= 3; reach++){
		var px = _user.x + dx * reach * 28, py = _user.y - 8 + dy * reach * 28;
		if(collision_point(px, py, obj_water_zone, false, true) != noone){
			var fish = fish_roll();
			if(fish == undefined){ farm_message("Nothing seems to live here"); return; }
			instance_create_depth(px, py, -9000, obj_fishing, {fish: fish, bobX: px, bobY: py});
			with(_user) if(act != undefined) actStep = act.frames; // the cast is done; you stand and wait
			return;
		}
	}
	farm_message("Cast it at the water");
}

/// @description The green zone's width (0-1 of the bar) for a fish: harder fish, narrower; Luck widens it.
function fishing_zone_width(_fish){
	return clamp(0.36 - fish_def(_fish).hard * 0.28 + stat("luck") * 0.006, 0.07, 0.5);
}

/// @description You landed it: into the bag (a lucky catch is silver or gold quality - not yet; one size fits all).
function fishing_catch(_fish){
	var f = fish_def(_fish);
	if(inv_add(item_stack("x|" + _fish)) > 0){ farm_message("Your bag is full - it got away"); return; }
	farm_message((f[$ "junk"] ?? false) ? "You fished up an " + f.name + ". Lovely." : "Caught a " + f.name + "!");
}

/// @description Eat a fish raw from the hotbar (cooking it is better).
function fish_eat(_stack){
	var f = fish_def(string_split(_stack.id, "|")[1]);
	if(f == undefined || f.energy <= 0){ farm_message("You'd rather not eat that"); return; }
	global.vitals.energy = min(vitals_max_energy(), global.vitals.energy + f.energy);
	_stack.count--;
	if(_stack.count <= 0) global.inv.slots[global.inv.hotbar] = undefined;
	farm_message("Ate a raw " + string_lower(f.name) + "  (+" + string(f.energy) + " energy)");
}

/// @description A fish icon (body, tail, eye) in the fish's colour, centred at (_cx, _cy), _r across.
function fish_draw_icon(_key, _cx, _cy, _r){
	var f = fish_def(_key);
	if(f[$ "junk"] ?? false){
		// An old boot
		draw_set_colour(merge_colour(f.colour, c_black, 0.4));
		draw_rectangle(_cx - _r * 0.3, _cy - _r * 0.8, _cx + _r * 0.2, _cy + _r * 0.3, false);
		draw_roundrect_ext(_cx - _r * 0.3, _cy, _cx + _r * 0.9, _cy + _r * 0.6, 6, 6, false);
		draw_set_colour(f.colour);
		draw_rectangle(_cx - _r * 0.2, _cy - _r * 0.7, _cx + _r * 0.1, _cy + _r * 0.2, false);
		draw_set_colour(c_white);
		return;
	}
	var dark = merge_colour(f.colour, c_black, 0.45);
	draw_set_colour(dark);
	draw_triangle(_cx + _r * 0.55, _cy, _cx + _r, _cy - _r * 0.45, _cx + _r, _cy + _r * 0.45, false);
	draw_ellipse(_cx - _r, _cy - _r * 0.5, _cx + _r * 0.7, _cy + _r * 0.5, false);
	draw_set_colour(f.colour);
	draw_ellipse(_cx - _r * 0.9, _cy - _r * 0.4, _cx + _r * 0.6, _cy + _r * 0.4, false);
	draw_set_colour(merge_colour(f.colour, c_white, 0.5));
	draw_ellipse(_cx - _r * 0.6, _cy - _r * 0.3, _cx + _r * 0.2, _cy, false);
	draw_set_colour(c_black);
	draw_circle(_cx - _r * 0.6, _cy - _r * 0.1, max(1, _r * 0.1), false);
	draw_set_colour(c_white);
}
