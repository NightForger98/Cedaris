/// Stats come alive (roadmap phase 3): one stat() for equipment plus food buffs, cooking, the cold, and Charm.
///
/// global.vitals.buff = {dish, stats: {<stat>: amount}, until} - one food buff at a time (eating another dish
/// replaces it), lasting until a time of day (until: minutes since midnight) or the night's sleep.
/// Dishes are item ids "f|<dish>", cooked at the hearth in the house (obj_kitchen) from produce of any quality.

/// @description A stat right now: what you're wearing (global.inv.stats) plus your food buff.
function stat(_key){
	var v = 0;
	if(variable_global_exists("inv") && is_struct(global.inv) && variable_struct_exists(global.inv, "stats")) v += global.inv.stats[$ _key] ?? 0;
	var b = food_buff();
	if(b != undefined) v += b.stats[$ _key] ?? 0;
	return v;
}

// ---------------------------------------------------------------- dishes

/// @description Dishes: ingredients (crop keys and how many, any quality), energy, and a timed buff.
/// minutes: how long the buff lasts in game minutes (it also ends when you sleep).
function dish_table(){
	static t = [
		{key: "hash_browns",  name: "Hash Browns",       ing: [["potato", 2]],                              energy: 70,  buff: {stamina: 3},          minutes: 300, colour: make_colour_rgb(215, 165, 80)},
		{key: "carrot_soup",  name: "Carrot Soup",       ing: [["carrot", 3]],                              energy: 80,  buff: {warmth: 4},           minutes: 360, colour: make_colour_rgb(240, 140, 50)},
		{key: "tomato_salad", name: "Tomato Salad",      ing: [["tomato", 2]],                              energy: 60,  buff: {speed: 2},            minutes: 240, colour: make_colour_rgb(220, 60, 50)},
		{key: "veg_stew",     name: "Vegetable Stew",    ing: [["potato", 1], ["carrot", 1], ["gourd", 1]], energy: 140, buff: {warmth: 6, stamina: 2}, minutes: 480, colour: make_colour_rgb(160, 100, 50)},
		{key: "fiery_chilli", name: "Fiery Chilli",      ing: [["chilli", 2], ["corn", 1]],                 energy: 90,  buff: {warmth: 8},           minutes: 360, colour: make_colour_rgb(190, 40, 30)},
		{key: "corn_fritters", name: "Corn Fritters",    ing: [["corn", 2]],                                energy: 80,  buff: {charm: 3},            minutes: 300, colour: make_colour_rgb(240, 200, 70)},
		{key: "stuffed_artichoke", name: "Stuffed Artichoke", ing: [["artichoke", 1], ["tomato", 1]],       energy: 100, buff: {luck: 4},             minutes: 360, colour: make_colour_rgb(120, 160, 80)},
		{key: "gourd_pie",    name: "Gourd Pie",         ing: [["gourd", 1], ["carrot", 1]],                energy: 120, buff: {charm: 2, luck: 2},   minutes: 360, colour: make_colour_rgb(220, 130, 60)},
		{key: "forest_stew",  name: "Forest Stew",       ing: [["w|mushroom", 2], ["w|herb", 1], ["potato", 1]], energy: 110, buff: {magic: 3, stamina: 2}, minutes: 360, colour: make_colour_rgb(130, 110, 80)},
	];
	return t;
}

function dish_def(_key){
	var t = dish_table();
	for(var i = 0; i < array_length(t); i++) if(t[i].key == _key) return t[i];
	return undefined;
}

/// @description A dish's ingredients as a recipe cost: a crop by name means any quality ({"p|<crop>": n}); anything
/// else is an exact item id ("w|mushroom").
function dish_cost(_d){
	var c = {};
	for(var i = 0; i < array_length(_d.ing); i++){
		var k = _d.ing[i][0];
		c[$ (string_pos("|", k) > 0) ? k : "p|" + k] = _d.ing[i][1];
	}
	return c;
}

/// @description Worth a bit more than its ingredients.
function dish_price(_d){
	var v = 0;
	for(var i = 0; i < array_length(_d.ing); i++){
		var k = _d.ing[i][0];
		v += ((string_pos("|", k) > 0) ? item_sell_price(k) : crop_table()[crop_index(k)].sell) * _d.ing[i][1];
	}
	return round(v * 1.5);
}

/// @description "+4 Warmth" style text for a buff, with how long it lasts.
function dish_buff_text(_d){
	return item_stats_text(_d.buff) + " for " + string(_d.minutes div 60) + " hours";
}

/// @description The cooking list for the hearth: [{id, cost}].
function dish_recipes(){
	static list = undefined;
	if(list != undefined) return list;
	list = [];
	var t = dish_table();
	for(var i = 0; i < array_length(t); i++) array_push(list, {id: "f|" + t[i].key, cost: dish_cost(t[i])});
	return list;
}

// ---------------------------------------------------------------- eating and buffs

/// @description The active food buff, or undefined. Ends at its time (checked in food_tick) or when you sleep.
function food_buff(){
	if(!variable_global_exists("vitals") || !is_struct(global.vitals)) return undefined;
	var b = global.vitals[$ "buff"];
	return is_struct(b) ? b : undefined;
}

/// @description Eat a dish from the hotbar: energy and health, and its buff replaces any other.
function food_eat(_stack){
	var d = dish_def(string_split(_stack.id, "|")[1]);
	if(d == undefined) return;
	global.vitals.energy = min(vitals_max_energy(), global.vitals.energy + d.energy);
	global.vitals.health = min(vitals_max_health(), global.vitals.health + d.energy * 0.4);
	global.vitals.buff = {dish: d.key, stats: d.buff, until: min(DAY_END, global.clock.minutes + d.minutes)};
	_stack.count--;
	if(_stack.count <= 0) global.inv.slots[global.inv.hotbar] = undefined;
	farm_message("Ate " + d.name + "  (+" + string(d.energy) + " energy, " + item_stats_text(d.buff) + ")");
}

/// @description Every frame of play: the buff wears off at its time, and the cold drains energy outdoors.
/// _minutes: game minutes that passed this frame.
function food_tick(_minutes){
	var b = food_buff();
	if(b != undefined && global.clock.minutes >= b.until){
		global.vitals.buff = undefined;
		global.vitals.energy = min(global.vitals.energy, vitals_max_energy());
		farm_message(dish_def(b.dish).name + " wore off");
	}
	var chill = climate_chill();
	if(chill > 0) global.vitals.energy = max(0, global.vitals.energy - chill * 0.04 * _minutes);
}

// ---------------------------------------------------------------- the cold

/// @description How cold it is here: 0 indoors; outdoors by season (spring 1, summer 0, fall 2, winter 5),
/// colder from 8 pm; in the mine, its band (the Frozen Halls are cold). Negative means heat: the Ember Depths
/// are -2, where any Warmth over 2 tires you instead.
function climate_cold(){
	if(!world_time_ready()) return 0;
	if(room == rm_mine) return mine_band(mine_state().floor).cold;
	if(!room_is_outdoors()) return 0;
	var s = global.clock.season mod 4;
	var c = [1, 0, 2, 5][s];
	if(global.clock.minutes >= 1200 || global.clock.minutes < DAY_START) c += (s == 1) ? 1 : 2;
	c += weather_cold(); // rain, storms and snow
	return c;
}

/// @description Cold your Warmth doesn't cover, or in heat, Warmth beyond what the heat allows (0 if you're dressed
/// for it). Each point drains energy.
function climate_chill(){
	var c = climate_cold();
	return (c >= 0) ? max(0, c - stat("warmth")) : max(0, stat("warmth") + c);
}

// ---------------------------------------------------------------- shared costs (materials and produce)

/// @description A recipe cost key as an item: "copper" is a material, "p|potato" is produce of any quality.
function cost_item_id(_key){
	if(string_pos("p|", _key) == 1) return _key + "|0";
	if(string_pos("|", _key) > 0) return _key; // an exact item ("w|mushroom", "f|carrot_soup")
	return "m|" + _key;
}

/// @description How many you have for a cost key (produce counts every quality).
function cost_count(_key){
	if(string_pos("p|", _key) == 1) return inv_count(_key + "|0") + inv_count(_key + "|1") + inv_count(_key + "|2");
	if(string_pos("|", _key) > 0) return inv_count(_key);
	return inv_count("m|" + _key);
}

/// @description Take _n for a cost key: produce goes lowest quality first, so the gold stars stay for shipping.
function cost_take(_key, _n){
	if(string_pos("p|", _key) != 1) return inv_take((string_pos("|", _key) > 0) ? _key : "m|" + _key, _n);
	for(var q = 0; q <= 2 && _n > 0; q++){
		var t = min(_n, inv_count(_key + "|" + string(q)));
		if(t > 0){ inv_take(_key + "|" + string(q), t); _n -= t; }
	}
	return _n <= 0;
}
