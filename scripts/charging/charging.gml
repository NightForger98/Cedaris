/// Charging (docs/CHARGING.md): hold the use button to wind a tool or weapon up, let go for a stronger action, like
/// Harvest Moon's charged tools on Stardew Valley's timing. A level fills every CHARGE_LEVEL_TIME seconds, up to the
/// item's maximum (one per tool tier); letting go before the first level is the normal tap. obj_plyr keeps the charge
/// ({item, t, level, max, flash}) and, on release, plays the swing with actCharge = the level reached; its hit step
/// calls action_hit, which hands a charged swing to charge_release.

#macro CHARGE_LEVEL_TIME 0.6

/// @description The highest level an item charges to (0: it doesn't charge, a press acts straight away).
function charge_max(_name){
	if(weapon_class(_name) != "") return 2; // weapons can't be upgraded: always two levels
	switch(_name){
		case "Hoe": case "Watering Can": case "Axe": case "Pickaxe": case "Scythe": return min(6, tool_tier(_name));
		case "Hammer": case "Shovel": return 2;
		case "Fishing Rod": return 3;
	}
	return 0;
}

/// @description What a charged release does: spin (scythe), water_spin, hoe_area, big_swing (axe, pickaxe, hammer,
/// shovel), cast (the rod throws further); for weapons spin_slash (swords), lunge (spears), slam (clubs, maces, flails,
/// waraxes), flurry (the dagger), draw (bows and slings shoot harder); or none.
function charge_kind(_name){
	switch(weapon_class(_name)){
		case "sword":  return "spin_slash";
		case "spear":  return "lunge";
		case "heavy":  return "slam";
		case "dagger": return "flurry";
		case "ranged": return "draw";
	}
	switch(_name){
		case "Scythe":       return "spin";
		case "Watering Can": return "water_spin";
		case "Hoe":          return "hoe_area";
		case "Axe": case "Pickaxe": case "Hammer": case "Shovel": return "big_swing";
		case "Fishing Rod":  return "cast";
	}
	return "none";
}

/// @description True while the use button is held (Left click or Space).
function charge_held(){
	if(autotest_running() && (global.autotest[$ "chargeTo"] ?? -1) >= 0) return true; // a test holding it (the charge command)
	return mouse_check_button(mb_left) || keyboard_check(key_of("use"));
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
		case "spin_slash": case "lunge": case "slam": case "flurry": case "draw":
			charge_weapon_hit(_user, _name, _level, _dir);
			return true;
		case "cast":
			fishing_cast(_user, _dir, _level);
			return true;
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

// ---------------------------------------------------------------- how a charge looks (docs/CHARGING.md, "Charge stages")

/// @description The stage a charge has reached, the same in every direction: windup (0-2: the tool pulled further back),
/// blush (the face red), anger (the mark on the head), outline (a Cursed tool's yellow glow), flames (a Blessed tool's).
/// Tools go wind-up, wind-up, red face at 3, anger at 4; weapons and the hammer and shovel (2 levels) red at 1, anger at 2.
function charge_stage(_c){
	var short = (_c.max <= 2 && tool_upgradable(_c.item) == "");
	var redAt = short ? 1 : 3, angerAt = short ? 2 : 4;
	var top = charge_top(_c.item, _c.level);
	return {windup: min(_c.level, 2), blush: _c.level >= redAt, anger: _c.level >= angerAt, outline: top >= 1, flames: top == 2};
}

/// @description The fx for character_draw while charging: the tool shifted and tilted back a little more at each wind-up
/// level (which way is "back" depends on the facing), glowing brighter each level, and the face's blush.
function charge_fx(_c, _dir){
	static back = [[0, 2, 6], [2, 1, -10], [0, -2, -8], [-2, 1, 10]];  // per wind-up level: dx, dy, degrees (n, w, s, e)
	var st = charge_stage(_c), b = back[_dir], k = st.windup;
	var glow = (_c.level > 0) ? 0.12 + 0.07 * _c.level + 0.06 * sin(current_time / 120) : 0;
	if(_c.flash > 0) glow += 0.05 * _c.flash;
	return {dx: b[0] * k, dy: b[1] * k, ang: b[2] * k, glow: clamp(glow, 0, 1), blush: st.blush ? (st.anger ? 0.36 : 0.26) : 0};
}

/// @description Behind the player while charging: a Cursed tool's yellow outline (the look drawn flat, a pixel out each
/// way, pulsing), and the back half of a Blessed tool's flames.
function charge_draw_behind(_user, _xx, _yy, _action){
	var st = charge_stage(_user.charge);
	if(st.outline){
		var a = st.flames ? 1 : 0.65 + 0.35 * sin(current_time / 90);
		draw_set_alpha(a);
		var col = make_colour_rgb(255, 226, 90);
		character_draw(_user.look, 0, 0, _xx - 1, _yy, 1, _action, col);
		character_draw(_user.look, 0, 0, _xx + 1, _yy, 1, _action, col);
		character_draw(_user.look, 0, 0, _xx, _yy - 1, 1, _action, col);
		character_draw(_user.look, 0, 0, _xx, _yy + 1, 1, _action, col);
		draw_set_alpha(1);
	}
	if(st.flames) charge_draw_flames(_xx, _yy, true);
}

/// @description In front of the player while charging: the front flames and the anger mark on the head.
function charge_draw_front(_user, _xx, _yy, _dir){
	static spot = [[32, 15], [27, 16], [39, 16], [37, 16]];
	var st = charge_stage(_user.charge);
	if(st.flames) charge_draw_flames(_xx, _yy, false);
	if(st.anger){
		// On the cap: the back of it facing up, the front facing down, the side facing left or right
		draw_sprite(spr_fx_anger, 0, _xx + spot[_dir][0] - 4, _yy + spot[_dir][1] - 4);
	}
}

/// @description A Blessed tool's fire: golden tongues licking up round the body, two frames swapped to flicker (the
/// second is the first with its tongues nudged), and sparks over the head. Symmetric, so it's the same mirrored left
/// and right. _back: the tongues behind the body (drawn first), else the ones in front.
function charge_draw_flames(_xx, _yy, _back){
	static tongues = [ // base angle round the body (0 right, 90 up), length, lean; behind = the top half
		[0, 9, 4], [35, 10, 2], [70, 11, 1], [110, 11, -1], [145, 10, -2], [180, 9, -4],
		[205, 8, -3], [235, 7, -1], [-55, 7, 1], [-25, 8, 3]];
	var f = (current_time div 110) mod 2, cx = _xx + 32, cy = _yy + 40, rx = 12, ry = 21;
	var inner = make_colour_rgb(255, 240, 140), outer = make_colour_rgb(255, 140, 30);
	gpu_set_blendmode(bm_add);
	draw_primitive_begin(pr_trianglelist);
	for(var i = 0; i < array_length(tongues); i++){
		var t = tongues[i];
		var behind = (t[0] > 0 && t[0] < 180);
		if(behind != _back) continue;
		var len = t[1] + ((f + i) mod 2 ? 2 : -1), lean = t[2] + ((f + i) mod 2 ? -1 : 1);
		var bx = cx + lengthdir_x(rx, t[0]), by = cy + lengthdir_y(ry, t[0]);
		var tx = bx + lean, ty = by - len - 3;
		draw_vertex_colour(bx - 3, by, outer, 0.6);
		draw_vertex_colour(bx + 3, by, outer, 0.6);
		draw_vertex_colour(tx, ty, inner, 0);
		draw_vertex_colour(bx - 1, by, inner, 0.6);
		draw_vertex_colour(bx + 1, by, inner, 0.6);
		draw_vertex_colour(tx * 0.6 + bx * 0.4, ty * 0.6 + by * 0.4, inner, 0.2);
	}
	draw_primitive_end();
	if(_back){
		// Sparks over the head
		for(var s = 0; s < 3; s++){
			var sx = cx - 8 + s * 8 + ((f + s) mod 2) * 2, sy = _yy + 2 - ((f * 3 + s * 5) mod 7);
			draw_set_colour(inner);
			draw_rectangle(sx, sy, sx + 1, sy + 1, false);
		}
	}
	gpu_set_blendmode(bm_normal);
}

// ---------------------------------------------------------------- the release: spins and big swings

#macro CHARGE_SPIN_STEP 4   // frames each facing shows while spinning: about 3 turns in 0.85 s, as in the reference
#macro CHARGE_SPIN_TURNS 3

/// @description How a charged swing plays out, set when the button's let go (obj_plyr): a spin (scythe, watering can)
/// or a big swing (axe, pickaxe, hammer, shovel), or undefined for a plain swing. A Blessed tool's flames flicker
/// twice before a spin starts (pre).
function charge_release_motion(_c, _dir){
	var kind = charge_kind(_c.item);
	if(_c.level <= 0) return undefined;
	if(kind == "spin" || kind == "water_spin"){
		var pre = charge_stage(_c).flames ? 4 * 7 : 0, turn = 4 * CHARGE_SPIN_STEP * CHARGE_SPIN_TURNS + CHARGE_SPIN_STEP;
		return {type: "spin", t: 0, pre: pre, total: pre + turn, hitAt: pre + turn div 3, start: _dir, water: kind == "water_spin", c: _c};
	}
	if(kind == "big_swing") return {type: "swing", t: 0, arc: charge_arc(_c.item, _c.level), c: _c};
	if(kind == "spin_slash"){
		var turn = 4 * CHARGE_SPIN_STEP * 2 + CHARGE_SPIN_STEP;  // a sword spins twice
		return {type: "spin", t: 0, pre: 0, total: turn, hitAt: turn div 2, start: _dir, water: false, white: true, c: _c};
	}
	if(kind == "lunge") return {type: "lunge", left: 56, dx: [0, -1, 0, 1][_dir], dy: [-1, 0, 1, 0][_dir], c: _c};
	if(kind == "flurry") return {type: "flurry", left: _c.level, c: _c};   // extra stabs after the first
	if(kind == "slam") return {type: "slam", c: _c};
	return undefined;
}

/// @description The facing a spin shows on its frame _t: it starts the way you face and turns clockwise (up, right,
/// down, left), and ends on the facing it started from.
function charge_spin_dir(_m){
	static order = [0, 3, 2, 1];
	var k = max(0, _m.t - _m.pre) div CHARGE_SPIN_STEP;
	return order[(array_get_index(order, _m.start) + k) mod 4];
}

/// @description Draw the player spinning (obj_plyr Draw): the trail's far half, the body, then its near half.
function charge_draw_spin(_user, _xx, _yy){
	var m = _user.motion, act = _user.act;
	if(m.t < m.pre){
		// The flames flicker twice on the wind-up before the spin
		charge_draw_flames(_xx, _yy, true);
		character_draw(_user.look, 0, 0, _xx, _yy, 1, {act: act, i: 0, dir: m.start, fx: charge_fx(m.c, m.start)});
		charge_draw_flames(_xx, _yy, false);
		return;
	}
	charge_draw_ring(_user, m, true);
	character_draw(_user.look, 0, 0, _xx, _yy, 1, {act: act, i: min(act.hit, act.frames - 1), dir: charge_spin_dir(m)});
	charge_draw_ring(_user, m, false);
}

/// @description A spin's trail: a flat oval swept round the feet behind the blade, fading as it goes - white-green
/// for the scythe, blue with droplets for the watering can. _back: the far half (behind the body).
function charge_draw_ring(_user, _m, _back){
	var turns = (_m.total - _m.pre - CHARGE_SPIN_STEP) / (4 * CHARGE_SPIN_STEP);
	var p = (_m.t - _m.pre) / (_m.total - _m.pre);
	var startAng = [90, 180, 270, 0][_m.start];
	var head = startAng - 360 * (turns + 0.25) * p;
	var cx = _user.x, cy = _user.y - 8, rx = 30, ry = 12;
	var col = _m.water ? make_colour_rgb(120, 190, 255) : ((_m[$ "white"] ?? false) ? c_white : make_colour_rgb(215, 255, 190));
	var fade = 1 - max(0, p - 0.85) / 0.15;   // the trail fades out as the spin ends
	for(var s = 0; s < 18; s++){
		var a1 = head + s * 9, a2 = a1 + 9;
		var mid = (a1 + a2) / 2;
		if((dsin(mid) > 0) != _back) continue;   // far side is the top of the oval
		var alpha = (1 - s / 18) * 0.85 * fade;
		draw_set_alpha(alpha);
		draw_line_width_colour(cx + dcos(a1) * rx, cy - dsin(a1) * ry, cx + dcos(a2) * rx, cy - dsin(a2) * ry, 3 - s / 9, col, col);
	}
	if(_m.water && !_back){
		// Droplets flung off the can
		draw_set_colour(col);
		for(var d = 0; d < 6; d++){
			var a = head + d * 25, r = 1 + (d * 7 + _m.t) mod 9;
			draw_set_alpha(0.8 * fade);
			draw_rectangle(cx + dcos(a) * (rx + r), cy - dsin(a) * (ry + r * 0.4), cx + dcos(a) * (rx + r) + 1, cy - dsin(a) * (ry + r * 0.4) + 1, false);
		}
	}
	draw_set_alpha(1);
}

/// @description A big swing's trail (axe, pickaxe): a white arc across the swing's width in front, swept as it plays.
function charge_draw_swing(_user){
	var m = _user.motion, act = _user.act;
	var p = clamp(_user.actStep / act.frames, 0, 1), ang = [90, 180, 270, 0][_user.actDir];
	var cx = _user.x, cy = _user.y - 20, r = 34;
	var from = ang + m.arc / 2, sweep = m.arc * p, steps = 16;
	for(var s = 0; s < steps; s++){
		var a1 = from - sweep * s / steps, a2 = from - sweep * (s + 1) / steps;
		draw_set_alpha(0.25 + 0.6 * (s + 1) / steps);
		draw_line_width_colour(cx + dcos(a1) * r, cy - dsin(a1) * r * 0.8, cx + dcos(a2) * r, cy - dsin(a2) * r * 0.8, 1 + 2 * (s + 1) / steps, c_white, c_white);
	}
	draw_set_alpha(1);
}

// ---------------------------------------------------------------- weapons

/// @description A charged weapon lands (from charge_release): stronger stats for its kind, then the usual hit.
/// Swords spin (all round, x1.5 / x2), spears lunge (longer reach, x1.5 / x2), heavy weapons slam the ground (all
/// round, double knockback, a one-second stun), the dagger stabs again (flurry - each stab a normal one), and bows and
/// slings shoot faster, further and harder (x1.35 a level).
function charge_weapon_hit(_user, _name, _level, _dir){
	var w = variable_clone(weapon_def(_name)), mult = 1 + 0.5 * _level;
	switch(charge_kind(_name)){
		case "spin_slash":
			w.arc = 360; w.reach *= 1.2; w.dmg = [round(w.dmg[0] * mult), round(w.dmg[1] * mult)];
			break;
		case "lunge":
			w.reach *= 1.5; w.dmg = [round(w.dmg[0] * mult), round(w.dmg[1] * mult)];
			break;
		case "slam":
			w.arc = 360; w.reach *= 1.3; w.knock = (w[$ "knock"] ?? 3) * 2; w.stun = 60;
			w.dmg = [round(w.dmg[0] * (1 + 0.25 * _level)), round(w.dmg[1] * (1 + 0.25 * _level))];
			break;
		case "draw":
			var b = 1 + 0.35 * _level;
			w.speed *= b; w.range *= b; w.dmg = [round(w.dmg[0] * b), round(w.dmg[1] * b)];
			break;
	}
	combat_player_hit(_user, _name, _dir, w);
	if(!(w[$ "ranged"] ?? false)) gather_hit(_user, _name, _dir);  // weeds in the way
}

/// @description A slam's shockwave (obj_plyr Draw, after the hit): a ring spreading out over the ground and fading.
function charge_draw_slam(_user){
	if(!_user.actHit) return;
	var p = clamp((_user.actStep - _user.act.hit) / max(1, _user.act.frames - _user.act.hit), 0, 1);
	var w = weapon_def(lpc_catalog().items[_user.look.parts.held.item].name), r = w.reach * 1.3 * (0.3 + 0.7 * p);
	draw_set_alpha(0.8 * (1 - p));
	draw_set_colour(make_colour_rgb(240, 220, 170));
	draw_ellipse(_user.x - r, _user.y - 6 - r * 0.4, _user.x + r, _user.y - 6 + r * 0.4, true);
	draw_ellipse(_user.x - r + 2, _user.y - 6 - r * 0.4 + 1, _user.x + r - 2, _user.y - 6 + r * 0.4 - 1, true);
	draw_set_alpha(1);
}
