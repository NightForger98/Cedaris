/// Charging (docs/CHARGING.md): hold the use button to wind a tool or weapon up, let go for a stronger action, like
/// Harvest Moon's charged tools on Stardew Valley's timing. A level fills every CHARGE_LEVEL_TIME seconds, up to the
/// item's maximum (one per tool tier); letting go before the first level is the normal tap. obj_plyr keeps the charge
/// ({item, t, level, max, flash}) and, on release, plays the swing with actCharge = the level reached; its hit step
/// calls action_hit, which hands a charged swing to charge_release.

#macro CHARGE_LEVEL_TIME 0.6

/// @description The highest level an item charges to (0: it doesn't charge, a press acts straight away).
function charge_max(_name){
	switch(_name){
		case "Hoe": case "Watering Can": case "Axe": case "Pickaxe": case "Scythe": return min(6, tool_tier(_name));
		case "Hammer": case "Shovel": return 2;
	}
	return 0;
}

/// @description What a charged release does: spin (scythe), water_spin, hoe_area, big_swing (axe, pickaxe, hammer,
/// shovel), or none.
function charge_kind(_name){
	switch(_name){
		case "Scythe":       return "spin";
		case "Watering Can": return "water_spin";
		case "Hoe":          return "hoe_area";
		case "Axe": case "Pickaxe": case "Hammer": case "Shovel": return "big_swing";
	}
	return "none";
}

/// @description True while the use button is held (Left click or Space).
function charge_held(){
	if(autotest_running() && (global.autotest[$ "chargeTo"] ?? -1) >= 0) return true; // a test holding it (the charge command)
	return mouse_check_button(mb_left) || keyboard_check(vk_space);
}

/// @description 0 for an ordinary top level, 1 when it's a Cursed tool's, 2 when it's a Blessed tool's.
function charge_top(_name, _level){
	if(_level < 6) return 0;
	return (tool_tier(_name) >= 7) ? 2 : 1;
}

/// @description The hoe's patch in front of you at a level: [cells forward, cells across].
function charge_hoe_size(_name, _level){
	static sizes = [[1, 1], [3, 1], [5, 1], [3, 3], [6, 3], [9, 3]];
	var top = charge_top(_name, _level);
	if(top == 1) return [9, 5];
	if(top == 2) return [11, 7];
	return sizes[min(_level, 5)];
}

/// @description A spin's radius in cells (scythe and watering can).
function charge_radius(_name, _level){
	var top = charge_top(_name, _level);
	if(_name == "Scythe") return (top == 2) ? 9 : ((top == 1) ? 7 : 1 + _level);
	return (top == 2) ? 8 : ((top == 1) ? 6 : _level);
}

/// @description A big swing's arc in degrees and reach in pixels.
function charge_arc(_name, _level){
	var top = charge_top(_name, _level);
	return (top == 2) ? 240 : ((top == 1) ? 180 : 60 + 18 * min(_level, 5));
}
function charge_reach(_level){ return 40 + 8 * _level; }

/// @description The most hits anything this tool breaks can take (trees for the axe, a void node for the pickaxe),
/// from the resource table, so the full-charge damage keeps up with whatever's added later.
function charge_toughest(_name){
	var t = resource_table(), keys = variable_struct_get_names(t), best = 1;
	for(var i = 0; i < array_length(keys); i++){
		var d = t[$ keys[i]];
		if(d.hp < 999 && array_get_index(d.tools, _name) != -1) best = max(best, d.hp);
	}
	return best;
}

/// @description A charged axe or pickaxe hit: at full charge a share of the toughest thing it breaks (Mithril about
/// a third - three swings; Cursed half - two; Blessed all of it - one), and never less than a tap.
function charge_tool_damage(_name, _level){
	static share = [0, 0.1, 0.15, 0.2, 0.25, 0.35, 0.5, 1];
	var tier = min(tool_tier(_name), 7), top = max(1, charge_max(_name));
	return max(1 + tier, floor(share[tier] * charge_toughest(_name) * min(_level, top) / top));
}

/// @description The field cells a release works: the hoe's patch, or every cell within a spin's radius. For the
/// outline on the ground as well as the release itself, so they always agree. [[gx, gy]...]
function charge_cells(_name, _level, _user, _dir){
	var out = [];
	if(!instance_exists(crops)) return out;
	var cs = crops.cellSize;
	switch(charge_kind(_name)){
		case "hoe_area":
			var s = charge_hoe_size(_name, _level), f = farm_front_cell(_user, _dir);
			var dx = [0, -1, 0, 1][_dir], dy = [-1, 0, 1, 0][_dir], half = (s[1] - 1) div 2;
			for(var i = 0; i < s[0]; i++) for(var j = -half; j <= half; j++) array_push(out, [f[0] + dx * i + dy * j, f[1] + dy * i + dx * j]);
			break;
		case "spin":
		case "water_spin":
			var r = charge_radius(_name, _level), cx = _user.x div cs, cy = (_user.y - 4) div cs;
			for(var i = -r; i <= r; i++) for(var j = -r; j <= r; j++) if(i * i + j * j <= r * r + r) array_push(out, [cx + i, cy + j]);
			break;
	}
	return out;
}

/// @description A charged release lands (from action_hit). Returns false when it's just a harder tap (the hammer and
/// shovel), so action_hit carries on as usual.
function charge_release(_user, _name, _level, _dir){
	var kind = charge_kind(_name);
	switch(kind){
		case "hoe_area":
			var cells = charge_cells(_name, _level, _user, _dir);
			for(var i = 0; i < array_length(cells); i++) farm_till(cells[i][0], cells[i][1]);
			return true;
		case "water_spin":
			if(!instance_exists(crops)) return true;
			// Facing the pond still fills the can
			var front = farm_front_cell(_user, _dir), cs = crops.cellSize;
			if(farm_water(_user, front[0], front[1]) == "refill") return true;
			var cells = charge_cells(_name, _level, _user, _dir);
			for(var i = 0; i < array_length(cells); i++){
				if(collision_point(cells[i][0] * cs + cs / 2, cells[i][1] * cs + cs / 2, obj_water_zone, false, true) != noone) continue;
				farm_water(_user, cells[i][0], cells[i][1]);
			}
			return true;
		case "spin":
			// Everything the scythe cuts, all the way round: the same circle of cells as the outline
			if(!instance_exists(obj_resource) || !instance_exists(crops)) return true;
			var r = charge_radius(_name, _level), cs = crops.cellSize, cx = _user.x div cs, cy = (_user.y - 4) div cs, list = [];
			with(obj_resource){
				var i = data.gx - cx, j = data.gy - cy;
				if(i * i + j * j <= r * r + r && resource_tool_ok(def, _name)) array_push(list, id);
			}
			for(var i = 0; i < array_length(list); i++) if(instance_exists(list[i])) gather_damage(list[i], _name);
			return true;
		case "big_swing":
			if(_name != "Axe" && _name != "Pickaxe") return false;
			// Every tree (or rock) in a wide arc in front, each hit hard
			if(!instance_exists(obj_resource)) return true;
			var ang = [90, 180, 270, 0][_dir], arc = charge_arc(_name, _level), reach = charge_reach(_level);
			var dmg = charge_tool_damage(_name, _level), list = [];
			with(obj_resource){
				if(!resource_tool_ok(def, _name)) continue;
				var d = point_distance(_user.x, _user.y, x, y);
				if(d > reach || (d > 12 && abs(angle_difference(ang, point_direction(_user.x, _user.y, x, y))) > arc / 2)) continue;
				array_push(list, id);
			}
			if(array_length(list) == 0) return gather_hit(_user, _name, _dir) || true; // nothing in the arc: say why, as a tap would
			for(var i = 0; i < array_length(list); i++) if(instance_exists(list[i])) gather_damage(list[i], _name, dmg);
			return true;
	}
	return false;
}

/// @description While charging: outline the cells the release will work (Draw, before the player).
function charge_draw_cells(_user){
	var c = _user.charge;
	if(c == undefined || !instance_exists(crops)) return;
	var cells = charge_cells(c.item, max(1, c.level), _user, _user.actDir), cs = crops.cellSize;
	draw_set_alpha(0.22);
	draw_set_colour(c_white);
	for(var i = 0; i < array_length(cells); i++){
		var x1 = cells[i][0] * cs, y1 = cells[i][1] * cs;
		draw_rectangle(x1 + 1, y1 + 1, x1 + cs - 2, y1 + cs - 2, false);
	}
	draw_set_alpha(0.6);
	for(var i = 0; i < array_length(cells); i++){
		var x1 = cells[i][0] * cs, y1 = cells[i][1] * cs;
		draw_rectangle(x1 + 1, y1 + 1, x1 + cs - 2, y1 + cs - 2, true);
	}
	draw_set_alpha(1);
}
