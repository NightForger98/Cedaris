/// Using things with E. Everything you can use (people, stations, the bed, ladders, chests, the notice board) has a
/// reach; when several are in reach, only the closest answers - so talking to Pip by the furnace doesn't also smelt.

/// @description Call from a usable thing's Step: true if the player is within _range and nothing usable is closer.
/// Remembers _range as interactRange, which is how the others compare against this one.
function interact_near(_range){
	interactRange = _range;
	if(!instance_exists(obj_plyr)) return false;
	var px = obj_plyr.x, py = obj_plyr.y;
	var d = point_distance(x, y, px, py);
	if(d >= _range) return false;
	static kinds = [obj_npc_parent, obj_crafting_table, obj_furnace, obj_shipping_bin, obj_bed, obj_kitchen,
	                obj_mine_door, obj_mine_ladder, obj_chest, obj_quest_board];
	var me = id, closer = false;
	for(var k = 0; k < array_length(kinds) && !closer; k++){
		with(kinds[k]){
			if(id == me || (variable_instance_exists(id, "interactRange") ? interactRange : 0) <= 0) continue;
			var dd = point_distance(x, y, px, py);
			if(dd < interactRange && dd < d) closer = true;
		}
	}
	return !closer;
}

/// @description True when E can use something: no window is open, and one didn't just close on this same press.
function interact_ready(){
	return !ui_blocking() && !instance_exists(obj_menu) && current_time > (variable_global_exists("talkCooldown") ? global.talkCooldown : 0);
}
