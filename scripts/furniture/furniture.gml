/// Furniture, the Stardew Valley way: buy pieces from Rowan's catalogue (items "u|<kind>"), hold one in your farmhouse
/// (rm_12, rm_123) and a see-through preview shows where it goes - green if it fits, red if not - on the cells in
/// front of you, or under the mouse when you've just moved it near you. Use places it; use with an empty hand (or the
/// pickaxe) on a piece picks it back up. Rugs lie flat (you walk over them, other pieces go on them).
/// Saved per room: world_room(<room>).furniture = [{kind, gx, gy}] - gx, gy: the cell of its bottom-left corner.
/// Art: PixelLab (art/furniture, spr_furn_<kind>).

/// @description The pieces: name, price, how many rows of cells at its foot are solid (rugs: flat).
function furniture_table(){
	static t = {
		bed_single:  {name: "Single Bed",         price: 600,  rows: 2},
		bed_double:  {name: "Double Bed",         price: 1500, rows: 2},
		table_round: {name: "Round Table",        price: 350,  rows: 1},
		table_long:  {name: "Dining Table",       price: 800,  rows: 1},
		chair:       {name: "Wooden Chair",       price: 120,  rows: 1},
		armchair:    {name: "Armchair",           price: 450,  rows: 1},
		sofa:        {name: "Sofa",               price: 900,  rows: 1},
		bookcase:    {name: "Bookcase",           price: 700,  rows: 1},
		dresser:     {name: "Chest of Drawers",   price: 500,  rows: 1},
		wardrobe:    {name: "Wardrobe",           price: 800,  rows: 1},
		rug_red:     {name: "Red Rug",            price: 400,  flat: true},
		rug_round:   {name: "Round Rug",          price: 300,  flat: true},
		lamp:        {name: "Floor Lamp",         price: 250,  rows: 1},
		plant:       {name: "Potted Plant",       price: 150,  rows: 1},
		fireplace:   {name: "Fireplace",          price: 2000, rows: 1},
		stove:       {name: "Old Stove",          price: 1200, rows: 1},
		painting:    {name: "Landscape Painting", price: 500,  rows: 1},
		clock:       {name: "Grandfather Clock",  price: 1000, rows: 1},
		cabinet:     {name: "Kitchen Cabinet",    price: 700,  rows: 1},
		chest:       {name: "Storage Chest",      price: 300,  rows: 1},
	};
	return t;
}

function furniture_def(_kind){ return furniture_table()[$ _kind]; }

/// @description A piece's sprite (-1 if its art isn't in the game).
function furniture_sprite(_kind){ return asset_get_index("spr_furn_" + _kind); }

/// @description A piece's size in cells: [columns, rows it stands on].
function furniture_size(_kind){
	var d = furniture_def(_kind), s = furniture_sprite(_kind);
	var w = (s == -1) ? 1 : max(1, ceil((sprite_get_width(s) - 4) / 32));
	var h = (d[$ "flat"] ?? false) ? ((s == -1) ? 1 : max(1, ceil((sprite_get_height(s) - 4) / 32))) : (d[$ "rows"] ?? 1);
	return [w, h];
}

/// @description Whether furniture can go in this room (your farmhouse).
function furniture_room_ok(){ var n = room_get_name(room); return n == "rm_12" || n == "rm_123"; }

function furniture_list(_roomName){
	var r = world_room(_roomName);
	if(!is_array(r[$ "furniture"])) r.furniture = [];
	return r.furniture;
}

/// @description The piece standing on a cell, or undefined. _flat: rugs too.
function furniture_at(_gx, _gy, _flat){
	var p = furniture_list(room_get_name(room));
	for(var i = array_length(p) - 1; i >= 0; i--){
		var d = furniture_def(p[i].kind);
		if(d == undefined || (!_flat && (d[$ "flat"] ?? false))) continue;
		var sz = furniture_size(p[i].kind);
		if(_gx >= p[i].gx && _gx < p[i].gx + sz[0] && _gy <= p[i].gy && _gy > p[i].gy - sz[1]) return p[i];
	}
	return undefined;
}

/// @description Whether you've moved the mouse lately, near you (then placing and picking up follow it).
function furniture_mouse_aim(){
	return variable_global_exists("mouseAimUntil") && current_time < global.mouseAimUntil && instance_exists(obj_plyr)
	       && point_distance(mouse_x, mouse_y, obj_plyr.x, obj_plyr.y) < 200;
}

/// @description Where the held piece would go: [gx, gy] of its bottom-left cell - under the mouse if you've moved it
/// lately near you, otherwise in front of you (centred, its near edge on the cell you face).
function furniture_target(_kind){
	var sz = furniture_size(_kind), p = obj_plyr;
	if(furniture_mouse_aim()) return [floor(mouse_x / 32) - (sz[0] div 2), floor(mouse_y / 32)];
	var dirn = clamp(p.y_frame - 8, 0, 3);   // up, left, down, right
	var fx = floor((p.x + [0, -26, 0, 26][dirn]) / 32), fy = floor((p.y - 6 + [-26, 0, 30, 0][dirn]) / 32);
	switch(dirn){
		case 0: return [fx - (sz[0] div 2), fy];
		case 1: return [fx - sz[0] + 1, fy];
		case 2: return [fx - (sz[0] div 2), fy + sz[1] - 1];
		default: return [fx, fy];
	}
}

/// @description Whether a piece fits with its bottom-left cell at (_gx, _gy): inside the room, clear of walls, doors,
/// other pieces (rugs only clash with rugs) and you.
function furniture_fits(_kind, _gx, _gy){
	var sz = furniture_size(_kind), flat = furniture_def(_kind)[$ "flat"] ?? false;
	for(var c = _gx; c < _gx + sz[0]; c++) for(var r = _gy - sz[1] + 1; r <= _gy; r++){
		var cx = c * 32 + 16, cy = r * 32 + 16;
		if(c < 1 || r < 1 || cx > room_width - 32 || cy > room_height - 32) return false;
		if(collision_rectangle(cx - 12, cy - 12, cx + 12, cy + 12, obj_col_box, false, true) != noone) return false;
		if(collision_rectangle(cx - 20, cy - 20, cx + 20, cy + 20, obj_transition, false, true) != noone) return false;
		if(flat){
			var p = furniture_list(room_get_name(room));
			for(var i = 0; i < array_length(p); i++){
				if(!(furniture_def(p[i].kind)[$ "flat"] ?? false)) continue;
				var s2 = furniture_size(p[i].kind);
				if(c >= p[i].gx && c < p[i].gx + s2[0] && r <= p[i].gy && r > p[i].gy - s2[1]) return false;
			}
		} else {
			if(furniture_at(c, r, false) != undefined) return false;
			if(point_in_rectangle(obj_plyr.x, obj_plyr.y - 4, cx - 16, cy - 16, cx + 16, cy + 16)) return false;
		}
	}
	return true;
}

/// @description Place the held piece (where furniture_target says). Returns true if placed.
function furniture_place(_stack){
	var kind = string_split(_stack.id, "|")[1];
	if(!furniture_room_ok()){ farm_message("Furniture goes in your farmhouse"); return false; }
	var t = furniture_target(kind);
	if(!furniture_fits(kind, t[0], t[1])){ farm_message("There's no room for it there"); return false; }
	var d = {kind: kind, gx: t[0], gy: t[1]};
	array_push(furniture_list(room_get_name(room)), d);
	instance_create_depth(0, 0, 0, obj_furniture, {data: d});
	_stack.count--;
	if(_stack.count <= 0) global.inv.slots[global.inv.hotbar] = undefined;
	return true;
}

/// @description Pick up the piece in front of you (or under the mouse): solid pieces first, then a rug. Returns true if
/// there was one (picked up, or your bag was full).
function furniture_pick_up(){
	if(!furniture_room_ok() || !instance_exists(obj_plyr)) return false;
	var p = obj_plyr, cells = [];
	if(furniture_mouse_aim()) array_push(cells, [floor(mouse_x / 32), floor(mouse_y / 32)]);
	var dirn = clamp(p.y_frame - 8, 0, 3);
	array_push(cells, [floor((p.x + [0, -26, 0, 26][dirn]) / 32), floor((p.y - 6 + [-26, 0, 30, 0][dirn]) / 32)]);
	var d = undefined;
	for(var i = 0; i < array_length(cells) && d == undefined; i++) d = furniture_at(cells[i][0], cells[i][1], false);
	for(var i = 0; i < array_length(cells) && d == undefined; i++) d = furniture_at(cells[i][0], cells[i][1], true);
	if(d == undefined) return false;
	if(inv_add(item_stack("u|" + d.kind)) > 0){ farm_message("Your bag is full"); return true; }
	var l = furniture_list(room_get_name(room));
	array_delete(l, array_get_index(l, d), 1);
	with(obj_furniture) if(data == d) instance_destroy();
	farm_message("Picked up the " + string_lower(furniture_def(d.kind).name));
	return true;
}

/// @description Room Start: this room's furniture.
function furniture_room_start(){
	if(!furniture_room_ok()) return;
	var p = furniture_list(room_get_name(room));
	for(var i = 0; i < array_length(p); i++) instance_create_depth(0, 0, 0, obj_furniture, {data: p[i]});
}

/// @description Each step: has the mouse moved? (then the preview and placing follow it for 3 seconds)
function furniture_mouse_track(){
	// (the window position: mouse_x moves with the camera even when the mouse doesn't)
	var wx = window_mouse_get_x(), wy = window_mouse_get_y();
	if(!variable_global_exists("mouseLast")) global.mouseLast = [wx, wy];
	if(abs(wx - global.mouseLast[0]) + abs(wy - global.mouseLast[1]) > 2 && !autotest_running()) global.mouseAimUntil = current_time + 3000;
	global.mouseLast = [wx, wy];
}

/// @description The see-through preview of the held piece where it would go (green fits, red doesn't).
function furniture_draw_preview(){
	if(!furniture_room_ok() || !instance_exists(obj_plyr) || ui_blocking()) return;
	var held = inv_held_stack();
	if(held == undefined || item_def(held.id).type != "furniture") return;
	var kind = string_split(held.id, "|")[1], s = furniture_sprite(kind), sz = furniture_size(kind), t = furniture_target(kind);
	var ok = furniture_fits(kind, t[0], t[1]), col = ok ? make_colour_rgb(140, 255, 140) : make_colour_rgb(255, 120, 120);
	draw_set_alpha(0.25);
	draw_set_colour(col);
	draw_rectangle(t[0] * 32, (t[1] - sz[1] + 1) * 32, (t[0] + sz[0]) * 32 - 1, (t[1] + 1) * 32 - 1, false);
	draw_set_alpha(1);
	draw_set_colour(c_white);
	if(s != -1) draw_sprite_ext(s, 0, t[0] * 32 + (sz[0] * 32 - sprite_get_width(s)) / 2, (t[1] + 1) * 32 - sprite_get_height(s), 1, 1, 0, col, 0.6);
}

/// @description Draw a piece as an icon in a slot.
function furniture_draw_icon(_kind, _cx, _cy, _size){
	var s = furniture_sprite(_kind);
	if(s == -1){
		draw_set_colour(make_colour_rgb(150, 110, 70));
		draw_rectangle(_cx - _size * 0.3, _cy - _size * 0.3, _cx + _size * 0.3, _cy + _size * 0.3, false);
		draw_set_colour(c_white);
		return;
	}
	var k = min(_size * 0.8 / sprite_get_width(s), _size * 0.8 / sprite_get_height(s));
	draw_sprite_ext(s, 0, _cx - sprite_get_width(s) * k / 2, _cy - sprite_get_height(s) * k / 2, k, k, 0, c_white, 1);
}

/// @description Rowan's furniture catalogue (shop_furniture_stock adds it): every piece with art, by name.
function furniture_catalogue(){
	var out = [], names = variable_struct_get_names(furniture_table());
	array_sort(names, true);
	for(var i = 0; i < array_length(names); i++) if(furniture_sprite(names[i]) != -1) array_push(out, {id: "u|" + names[i], price: furniture_def(names[i]).price});
	return out;
}
