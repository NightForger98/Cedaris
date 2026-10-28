/// Things you place in the world (milestone 10.4, docs/MILESTONES.md): sprinklers first.
///
/// Items "o|<kind>"; held and used (Space) on the cell in front, they're placed there and saved in the world store:
/// world_room(<room>).placed = [{kind, gx, gy}], shown by obj_placeable. The pickaxe picks them back up.
/// Sprinklers water the tilled soil around them every morning (in the new-day event, after the soil dries).
/// Made at the crafting table (its Build list) once the Old Well project is done.

/// @description Placeable kinds: name, what it costs to build, its colour, and for sprinklers the cells they water
/// (range 1 + "plus": the 4 cells around it; range 1: 3x3; range 2: 5x5).
function placeable_table(){
	static t = {
		sprinkler:       {name: "Sprinkler",         cost: {copper: 2, iron: 1},          colour: make_colour_rgb(205, 120, 70),  range: 1, plus: true,
		                  desc: "Waters the 4 cells around it every morning."},
		sprinkler_good:  {name: "Quality Sprinkler", cost: {iron: 2, gold: 1},            colour: make_colour_rgb(200, 205, 215), range: 1, plus: false,
		                  desc: "Waters the 8 cells around it every morning."},
		sprinkler_great: {name: "Great Sprinkler",   cost: {gold: 2, steel: 1, gem: 1},   colour: make_colour_rgb(245, 205, 60),  range: 2, plus: false,
		                  desc: "Waters a 5 x 5 patch around it every morning."},
	};
	return t;
}

function placeable_def(_kind){ return placeable_table()[$ _kind]; }

/// @description The Build list at the crafting table: [{id, cost}] (once the well is raised).
function placeable_recipes(){
	if(!project_done("well")) return [];
	var out = [], names = ["sprinkler", "sprinkler_good", "sprinkler_great"];
	for(var i = 0; i < array_length(names); i++) array_push(out, {id: "o|" + names[i], cost: placeable_def(names[i]).cost});
	return out;
}

function placed_list(_roomName){
	var r = world_room(_roomName);
	if(!is_array(r[$ "placed"])) r.placed = [];
	return r.placed;
}

function placed_at(_gx, _gy){
	var p = placed_list(room_get_name(room));
	for(var i = 0; i < array_length(p); i++) if(p[i].gx == _gx && p[i].gy == _gy) return p[i];
	return undefined;
}

/// @description Place the held stack's thing on the cell in front. Returns true if placed.
function placeable_place(_stack, _gx, _gy){
	var kind = string_split(_stack.id, "|")[1];
	var cs = RES_CELL, cx = _gx * cs + cs / 2, cy = _gy * cs + cs / 2;
	if(placed_at(_gx, _gy) != undefined || farm_crop_at(_gx, _gy) != noone
	   || collision_rectangle(cx - 12, cy - 12, cx + 12, cy + 12, obj_col_box, false, true) != noone
	   || collision_rectangle(cx - 12, cy - 12, cx + 12, cy + 12, obj_water_zone, false, true) != noone
	   || (variable_global_exists("mineWalls") && global.mineWalls != -1 && tilemap_get_at_pixel(global.mineWalls, cx, cy) > 0)){
		farm_message("There's no room for it there");
		return false;
	}
	var d = {kind: kind, gx: _gx, gy: _gy};
	array_push(placed_list(room_get_name(room)), d);
	instance_create_depth(cx, cy, 0, obj_placeable, {data: d});
	_stack.count--;
	if(_stack.count <= 0) global.inv.slots[global.inv.hotbar] = undefined;
	return true;
}

/// @description The pickaxe on a placed thing: back into the bag. Returns true if it picked something up.
function placeable_pick_up(_gx, _gy){
	var d = placed_at(_gx, _gy);
	if(d == undefined) return false;
	if(inv_add(item_stack("o|" + d.kind)) > 0){ farm_message("Your bag is full"); return true; }
	var p = placed_list(room_get_name(room));
	array_delete(p, array_get_index(p, d), 1);
	with(obj_placeable) if(data == d) instance_destroy();
	farm_message("Picked up the " + string_lower(placeable_def(d.kind).name));
	return true;
}

/// @description Room Start: show this room's placed things.
function placeables_room_start(){
	var p = placed_list(room_get_name(room));
	for(var i = 0; i < array_length(p); i++)
		instance_create_depth(p[i].gx * RES_CELL + RES_CELL / 2, p[i].gy * RES_CELL + RES_CELL / 2, 0, obj_placeable, {data: p[i]});
}

/// @description New-day part (after the soil dries): sprinklers water the tilled soil around them.
function placeables_new_day(){
	var names = variable_struct_get_names(global.world.rooms);
	for(var n = 0; n < array_length(names); n++){
		var r = global.world.rooms[$ names[n]];
		var p = r[$ "placed"] ?? [], tiles = r[$ "tiles"] ?? {};
		for(var i = 0; i < array_length(p); i++){
			var d = placeable_def(p[i].kind);
			if(d == undefined || !variable_struct_exists(d, "range")) continue;
			for(var dx = -d.range; dx <= d.range; dx++) for(var dy = -d.range; dy <= d.range; dy++){
				if((dx == 0 && dy == 0) || (d.plus && dx != 0 && dy != 0)) continue;
				var t = tiles[$ farm_key(p[i].gx + dx, p[i].gy + dy)];
				if(t != undefined) t.watered = true;
			}
		}
	}
}

/// @description Draw a sprinkler at (_x, _y) (its cell centre) at a scale: a metal base, the pipe and its head.
function placeable_draw(_kind, _x, _y, _s){
	var d = placeable_def(_kind);
	draw_set_colour(merge_colour(d.colour, c_black, 0.5));
	draw_ellipse(_x - 10 * _s, _y - 2 * _s, _x + 10 * _s, _y + 8 * _s, false);
	draw_set_colour(d.colour);
	draw_ellipse(_x - 8 * _s, _y - 3 * _s, _x + 8 * _s, _y + 5 * _s, false);
	draw_rectangle(_x - 2 * _s, _y - 14 * _s, _x + 2 * _s, _y, false);
	draw_set_colour(merge_colour(d.colour, c_white, 0.4));
	draw_circle(_x, _y - 15 * _s, 4 * _s, false);
	draw_set_colour(c_white);
}
