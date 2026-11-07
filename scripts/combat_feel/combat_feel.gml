/// Combat feel (the user, 2026-11-07): blocking and parrying, monsters' wind-ups, hit-stop and shake, smooth
/// knockback, a buffered three-hit combo, aiming with the mouse, cancels, and a dodge (a dash with afterimages, or
/// a hop back). Sound hooks (sfx) play snd_<name> once there are sounds.
///
/// Block: hold the block key (V) or the right mouse button. You move at half speed and can't attack; hits from in
/// front are cut by your weapon's guard (block_power) for 2 energy each. Pressed just as a hit lands (parry_window,
/// longer with Agility): no damage, the attacker is stunned and your next hit is a critical.
/// Dodge (Z): a dash where you're heading - or, standing still or heading away from where you face, a hop back -
/// with a moment no hit can land. It costs 4 energy and cancels a swing or a block. Agility makes it go further.

/// @description Play a sound if the game has it (snd_<name>); quiet until sounds are added.
function sfx(_name){
	var s = asset_get_index("snd_" + _name);
	if(s != -1 && asset_get_type("snd_" + _name) == asset_sound) audio_play_sound(s, 1, false);
}

/// @description Freeze the action for a few frames when a hit lands (the player's Step counts it down).
function combat_hitstop(_n){ global.hitStop = max(variable_global_exists("hitStop") ? global.hitStop : 0, _n); }
function combat_hitstopped(){ return variable_global_exists("hitStop") && global.hitStop > 0; }

/// @description How much of a hit from in front your guard stops: 35% with a tool, 25% empty-handed, 60% with a
/// weapon (70% a heavy one), more for a better metal (up to 90%).
function block_power(_stack){
	if(_stack == undefined) return 0.25;
	var d = item_def(_stack.id);
	if(d == undefined || d.type != "held") return 0.25;
	if(item_is_tool(d.name)) return 0.35;
	var cls = weapon_class(d.name), base = (cls == "heavy") ? 0.7 : ((cls == "") ? 0.45 : 0.6);
	var m = gear_metal(gear_stack_metal(_stack));
	return min(0.9, base + ((m == undefined) ? 0 : (m.mult - 1) * 0.3));
}

/// @description Frames after pressing block in which a hit is parried: 9, and 1 more for every 2.5 Agility (up to 24).
function parry_window(){ return min(24, 9 + floor(attr("agility") * 0.4)); }

/// @description The angle the player faces (the walk rows 8-11 are n, w, s, e).
function player_face_angle(){ return [90, 180, 270, 0][clamp(obj_plyr.y_frame - 8, 0, 3)]; }

/// @description Where a swing or shot goes: toward the mouse if you've moved it lately (8 ways), else where you face;
/// a monster close to that line pulls it onto them (a little aim help).
function combat_aim_angle(_user){
	var a = [90, 180, 270, 0][clamp(_user.y_frame - 8, 0, 3)];
	if(furniture_mouse_aim()) a = round(point_direction(_user.x, _user.y - 14, mouse_x, mouse_y) / 45) * 45;
	var best = -1, bd = 120;
	with(obj_monster){
		if(dying || (def[$ "passive"] ?? false)) continue;
		var d = point_distance(_user.x, _user.y - 14, x, y - 14);
		if(d > bd) continue;
		var ma = point_direction(_user.x, _user.y - 14, x, y - 14);
		if(abs(angle_difference(a, ma)) > 35) continue;
		bd = d; best = ma;
	}
	return (best == -1) ? a : best;
}

/// @description The walk row (8-11) closest to an angle.
function combat_row_for_angle(_a){
	var k = round(((_a mod 360) + 360) mod 360 / 90) mod 4;   // 0 e, 1 n, 2 w, 3 s
	return [11, 8, 9, 10][k];
}

/// @description The swing's place in the combo: the third in a row (within half a second of the last) is a finisher -
/// half again the damage, twice the knockback, a step forward.
function combat_combo_mult(_user){ return (_user.object_index == obj_plyr && _user.comboN == 2) ? 1.5 : 1; }

/// @description Start a dodge (obj_plyr). Returns true if it started.
function dodge_start(){
	var mx = input_held(key_of("right")) - input_held(key_of("left")), my = input_held(key_of("down")) - input_held(key_of("up"));
	var face = clamp(y_frame - 8, 0, 3), fx = [0, -1, 0, 1][face], fy = [-1, 0, 1, 0][face];
	var hop = false;
	if(mx == 0 && my == 0){ mx = -fx; my = -fy; hop = true; }   // standing still: a hop back
	else if(mx * fx + my * fy < 0) hop = true;                    // heading away from where you face: a hop
	if(world_time_ready() && !inv_is_free()){
		if(global.vitals.energy < 4){ farm_message("Too tired to dodge"); return false; }
		global.vitals.energy -= 4;
	}
	var l = point_distance(0, 0, mx, my);
	mx /= l; my /= l;
	act = undefined; charge = undefined; motion = undefined; castSpell = ""; blocking = false;
	dodgeHop = hop;
	dodgeT = hop ? 14 : 12;
	dodgeTotal = dodgeT;
	var dist = (hop ? 64 : 96) * (1 + min(0.3, attr("agility") * 0.01));
	dodgeVX = mx * dist / dodgeT;
	dodgeVY = my * dist / dodgeT;
	if(!hop) y_frame = combat_row_for_angle(point_direction(0, 0, mx, my));
	dodgeCool = dodgeT + 14;
	sfx("dodge");
	return true;
}

/// @description A frame of the dodge (obj_plyr): move, leave an afterimage (the dash), count down.
function dodge_step(){
	var sol = collision_solids(false);
	if(!place_meeting(x + dodgeVX, y, sol)) x += dodgeVX;
	if(!place_meeting(x, y + dodgeVY, sol)) y += dodgeVY;
	if(!dodgeHop && (dodgeT mod 2) == 0) array_push(afterimages, {x: x, y: y, frame: 1 + (dodgeTotal - dodgeT) mod 8, row: y_frame + 17, a: 0.45});
	dodgeT--;
	moveX = dodgeVX; moveY = dodgeVY;   // (the camera leads the way)
}

/// @description The afterimages fade (obj_plyr, every step).
function afterimages_fade(){
	for(var i = array_length(afterimages) - 1; i >= 0; i--){
		afterimages[i].a -= 0.05;
		if(afterimages[i].a <= 0) array_delete(afterimages, i, 1);
	}
}

/// @description A hit coming at the player from (_fromX, _fromY): blocked or parried if they're guarding that way.
/// Returns "parried", "blocked" (with the damage left in global.blockLeft) or "" (it lands).
function combat_guard(_dmg, _fromX, _fromY, _src){
	var p = obj_plyr;
	if(!p.blocking) return "";
	if(abs(angle_difference(player_face_angle(), point_direction(p.x, p.y - 14, _fromX, _fromY))) > 75) return "";
	if(p.blockT <= parry_window()){
		// a parry: nothing gets through, the attacker reels, your next hit is a critical
		if(_src != noone && instance_exists(_src) && _src.object_index == obj_monster){
			_src.hurtT = monster_stun_time(_src);
			_src.flash = 8;
			_src.attacking = false;
			_src.windT = 0;
			var a = point_direction(p.x, p.y, _src.x, _src.y);
			_src.kx = lengthdir_x(5, a); _src.ky = lengthdir_y(5, a);
		}
		p.parryCrit = true;
		p.iframes = 18;
		popup(p.x, p.y - 70, "Parry!", make_colour_rgb(255, 235, 120));
		combat_hitstop(6);
		global.camShake = 6;
		sfx("parry");
		return "parried";
	}
	var left = _dmg * (1 - block_power(inv_held_stack()));
	if(world_time_ready() && !inv_is_free()) global.vitals.energy = max(0, global.vitals.energy - 2);
	global.blockLeft = left;
	popup(p.x, p.y - 70, "Blocked", make_colour_rgb(190, 210, 255));
	sfx("block");
	return "blocked";
}

// ---------------------------------------------------------------- tests

function autotest_guard(_on, _t){ obj_plyr.blocking = (real(_on) != 0); obj_plyr.blockT = real(_t); return "blocking " + string(obj_plyr.blocking); }
function autotest_dodge(){ with(obj_plyr) dodge_start(); return "dodging " + string(obj_plyr.dodgeT) + (obj_plyr.dodgeHop ? " hop" : " dash"); }
/// @description Test: a hit of _dmg from _dx px to the side (+ right, - left) of the player: the outcome and health.
function autotest_hit_from(_dx, _dmg){ obj_plyr.iframes = 0; var r = player_hurt(real(_dmg), obj_plyr.x + real(_dx), obj_plyr.y - 14, noone); return r + " health " + string(global.vitals.health); }
/// @description Test: the longest wind-up of the monsters here, and the player's combo step.
function autotest_windup(){ var w = 0; with(obj_monster) w = max(w, windT); return "windup " + string(w); }
function autotest_combo(){ return "combo " + string(obj_plyr.comboN); }
function autotest_monsters_ready(){ with(obj_monster) cooldown = 0; return "ready"; }
