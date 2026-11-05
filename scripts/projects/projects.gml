/// Village projects (milestone 10.2, docs/MILESTONES.md): the long-term goal. The notice board's Projects page lists
/// them; you hand things in bit by bit, and finishing one rebuilds part of the valley.
///
/// global.world.projects = {<key>: {given: {<cost key>: n}, done}}. Cost keys are like recipe costs: "wood" is a
/// material, "p|carrot" any quality of a crop, and "f|carrot_soup" (an item id with "|") that exact item.

/// @description The projects. need: [[cost key, n]...]. who: the villager behind it (helping is friendship).
function project_table(){
	static t = [
		{key: "bridge", name: "Mend the Beach Bridge", who: "thorne",
		 desc: "The footbridge over the river on the beach at Plummet's Point fell in years ago. Mend it and the beach path from Hangar 12 opens.",
		 need: [["wood", 60], ["stone", 40], ["iron", 5]], reward: "The beach path to Plummet's Point is open"},
		{key: "well", name: "Raise the Old Well", who: "elda",
		 desc: "The village well is dry and choked with rubble. A working well means water piped to your field.",
		 need: [["stone", 50], ["copper", 10], ["frost_crystal", 1]], reward: "Sprinklers can be made at the crafting table"},
		{key: "pantry", name: "Stock Aunt Hesta's Pantry", who: "hesta",
		 desc: "Aunt Hesta wants a pantry worthy of the farm: one of each of her favourite dishes.",
		 need: [["f|hash_browns", 1], ["f|carrot_soup", 1], ["f|tomato_salad", 1], ["f|corn_fritters", 1], ["f|veg_stew", 1]],
		 reward: "Hesta's cooking keeps you going: +40 max energy for good"},
		{key: "shrine", name: "Light the Forest Shrine", who: "elda",
		 desc: "Deep in Whispering Woods stands a shrine the pixies once loved. Bring it light and treasures, and they'll return.",
		 need: [["moonsilk", 2], ["gem", 5], ["frost_crystal", 1], ["ember_core", 1]], reward: "Pixies visit your farm at night and bless your crops"},
	];
	return t;
}

function project_def(_key){
	var t = project_table();
	for(var i = 0; i < array_length(t); i++) if(t[i].key == _key) return t[i];
	return undefined;
}

function project_state(_key){
	if(!is_struct(global.world[$ "projects"])) global.world.projects = {};
	var p = global.world.projects[$ _key];
	if(!is_struct(p)){ p = {given: {}, done: false}; global.world.projects[$ _key] = p; }
	return p;
}

function project_done(_key){ return world_time_ready() && project_state(_key).done; }

/// @description Item id for a project cost key (for names and icons).
function project_item_id(_k){
	if(string_pos("f|", _k) == 1) return _k;
	return cost_item_id(_k);
}

/// @description How many you're holding of a project cost key.
function project_have(_k){
	return (string_pos("f|", _k) == 1) ? inv_count(_k) : cost_count(_k);
}

/// @description Hand in as much of one thing as you have (up to what's still needed). Returns a message.
function project_give(_key, _k){
	var d = project_def(_key), p = project_state(_key);
	if(p.done) return d.name + " is finished";
	var need = 0;
	for(var i = 0; i < array_length(d.need); i++) if(d.need[i][0] == _k) need = d.need[i][1];
	var left = need - (p.given[$ _k] ?? 0);
	var n = min(left, inv_is_free() ? left : project_have(_k));
	if(n <= 0) return (left <= 0) ? "That part is done" : "You don't have any " + item_def(project_item_id(_k)).name;
	if(!inv_is_free()){
		if(string_pos("f|", _k) == 1) inv_take(_k, n); else cost_take(_k, n);
	}
	p.given[$ _k] = (p.given[$ _k] ?? 0) + n;
	people_add(d.who, n * 4); // they notice who helps
	if(project_complete(_key)){
		p.done = true;
		people_add(d.who, 200);
		return d.name + " is done!  " + d.reward + ".";
	}
	return "Handed in " + string(n) + " " + item_def(project_item_id(_k)).name;
}

function project_complete(_key){
	var d = project_def(_key), p = project_state(_key);
	for(var i = 0; i < array_length(d.need); i++) if((p.given[$ d.need[i][0]] ?? 0) < d.need[i][1]) return false;
	return true;
}

/// @description How far along a project is, 0-1.
function project_progress(_key){
	var d = project_def(_key), p = project_state(_key), got = 0, all_n = 0;
	for(var i = 0; i < array_length(d.need); i++){ all_n += d.need[i][1]; got += min(d.need[i][1], p.given[$ d.need[i][0]] ?? 0); }
	return (all_n > 0) ? got / all_n : 1;
}

/// @description Pixie blessing (the shrine's reward): each night, a patch of crops on the farm grows an extra day.
/// Called in the new-day event. Returns how many crops were blessed.
function project_pixie_blessing(){
	if(!project_done("shrine")) return 0;
	var crops_ = world_room("rm_1").crops;
	if(array_length(crops_) == 0) return 0;
	var c = crops_[irandom(array_length(crops_) - 1)], n = 0;
	for(var i = 0; i < array_length(crops_); i++){
		if(abs(crops_[i].gx - c.gx) <= 1 && abs(crops_[i].gy - c.gy) <= 1){ crops_[i].days += 1; n++; }
	}
	return n;
}
