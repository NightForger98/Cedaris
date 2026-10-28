/// Combat (roadmap phase 4): weapons, monsters, getting hurt and getting knocked out.
///
/// Swinging a weapon (or a tool) hits monsters in front of you on the swing's hit step (action_hit calls
/// combat_player_hit). Monsters are obj_monster: humanoids are LPC looks from the race table holding a weapon,
/// creatures are sheets from the [LPC] Monsters pack. Damage taken is damage - Defence (at least 1); Luck adds
/// to crits. At 0 health you're knocked out: you wake at home and lose some gold and a few things from your bag.

/// @description Weapon stats by catalog name: damage [min, max], reach (px), arc (degrees), knockback, crit chance.
/// ranged: fires a shot instead (ammo: an item it uses up). Anything not listed hits like a tool (weak).
function weapon_table(){
	static t = {
		"Dagger":        {dmg: [5, 8],   reach: 26, arc: 70,  knock: 3, crit: 0.08},
		"Cane":          {dmg: [3, 5],   reach: 30, arc: 90,  knock: 4, crit: 0.02},
		"Club":          {dmg: [6, 10],  reach: 32, arc: 110, knock: 7, crit: 0.02},
		"Arming Sword":  {dmg: [8, 12],  reach: 36, arc: 110, knock: 4, crit: 0.04},
		"Saber":         {dmg: [10, 14], reach: 38, arc: 110, knock: 4, crit: 0.05},
		"Rapier":        {dmg: [11, 15], reach: 40, arc: 60,  knock: 2, crit: 0.12},
		"Scimitar":      {dmg: [12, 17], reach: 38, arc: 120, knock: 4, crit: 0.06},
		"Katana":        {dmg: [16, 22], reach: 40, arc: 110, knock: 3, crit: 0.12},
		"Longsword":     {dmg: [18, 24], reach: 44, arc: 120, knock: 5, crit: 0.05},
		"Longsword alt": {dmg: [20, 26], reach: 44, arc: 120, knock: 5, crit: 0.05},
		"Glowsword":     {dmg: [26, 34], reach: 44, arc: 120, knock: 5, crit: 0.08},
		"Mace":          {dmg: [12, 18], reach: 34, arc: 110, knock: 9, crit: 0.03},
		"Flail":         {dmg: [14, 22], reach: 40, arc: 130, knock: 8, crit: 0.03},
		"Waraxe":        {dmg: [18, 26], reach: 38, arc: 120, knock: 8, crit: 0.04},
		"Spear":         {dmg: [9, 14],  reach: 52, arc: 40,  knock: 4, crit: 0.05},
		"Long spear":    {dmg: [13, 19], reach: 60, arc: 36,  knock: 4, crit: 0.05},
		"Trident":       {dmg: [17, 24], reach: 54, arc: 44,  knock: 5, crit: 0.05},
		"Halberd":       {dmg: [20, 28], reach: 56, arc: 70,  knock: 7, crit: 0.05},
		"Dragon spear":  {dmg: [28, 36], reach: 60, arc: 44,  knock: 6, crit: 0.08},
		"Simple staff":  {dmg: [5, 8],   reach: 36, arc: 100, knock: 5, crit: 0.03},
		"Gnarled staff": {dmg: [7, 10],  reach: 36, arc: 100, knock: 5, crit: 0.03},
		"Loop staff":    {dmg: [8, 12],  reach: 36, arc: 100, knock: 5, crit: 0.03},
		"S staff":       {dmg: [9, 13],  reach: 36, arc: 100, knock: 5, crit: 0.03},
		"Diamond staff": {dmg: [12, 16], reach: 38, arc: 100, knock: 5, crit: 0.05},
		"Slingshot":     {dmg: [6, 10],  ranged: true, ammo: "m|stone", speed: 7,  range: 260, crit: 0.05},
		"Crossbow":      {dmg: [16, 24], ranged: true, ammo: "",        speed: 10, range: 340, crit: 0.08},
		"Boomerang":     {dmg: [8, 12],  ranged: true, ammo: "",        speed: 6,  range: 200, crit: 0.04},
		// Tools work in a pinch
		"Axe":           {dmg: [3, 5],   reach: 32, arc: 90,  knock: 4, crit: 0.02},
		"Pickaxe":       {dmg: [3, 5],   reach: 32, arc: 90,  knock: 4, crit: 0.02},
		"Scythe":        {dmg: [2, 4],   reach: 38, arc: 150, knock: 3, crit: 0.02},
	};
	return t;
}

/// @description Stats for a held item; tools and other things hit for 1-3.
function weapon_def(_name){
	return weapon_table()[$ _name] ?? {dmg: [1, 3], reach: 28, arc: 90, knock: 2, crit: 0.01};
}

// ---------------------------------------------------------------- monsters

/// @description Monsters. Humanoids: race, body, head, skins, clothes [[slot, item, material, colour]...], weapon.
/// Creatures: spr (a [LPC] Monsters sheet: 64 px frames, rows up/left/down/right), frames in the attack row.
/// from: first floor it appears on (it gets a little tougher each floor below that). drops: [id, min, max, chance].
function monster_table(){
	static t = {
		slime:      {name: "Slime",      spr: spr_mon_slime,   frames: 6, from: 1,  hp: 14, dmg: [3, 5],   def: 0, speed: 0.9, reach: 22,
		             drops: [["m|copper_ore", 1, 2, 0.3], ["m|gem", 1, 1, 0.02]], gold: [1, 3]},
		bat:        {name: "Bat",        spr: spr_mon_bat,     frames: 7, from: 2,  hp: 10, dmg: [3, 6],   def: 0, speed: 1.7, reach: 22, flies: true,
		             drops: [["m|feather", 1, 1, 0.3]], gold: [1, 4]},
		snake:      {name: "Snake",      spr: spr_mon_snake,   frames: 7, from: 4,  hp: 16, dmg: [4, 7],   def: 0, speed: 1.2, reach: 24,
		             drops: [["m|leather", 1, 1, 0.25]], gold: [2, 5]},
		ghost:      {name: "Ghost",      spr: spr_mon_ghost,   frames: 6, from: 10, hp: 26, dmg: [7, 11],  def: 1, speed: 1.1, reach: 24, flies: true,
		             drops: [["m|frost_crystal", 1, 1, 0.05], ["m|linen", 1, 2, 0.3]], gold: [4, 9]},
		eyeball:    {name: "Watcher",    spr: spr_mon_eyeball, frames: 7, from: 20, hp: 32, dmg: [10, 14], def: 2, speed: 1.0, reach: 24, flies: true,
		             drops: [["m|gem", 1, 1, 0.12]], gold: [8, 15]},
		goblin:     {name: "Goblin",     race: "Goblin",  body: "teen",     head: "Goblin",      skins: ["green", "dark_green", "olive"],
		             wear: [["pants", "Pants", "cloth", "brown"], ["shirt", "Longsleeve", "cloth", "leather"]], weapon: "Dagger",
		             from: 1,  hp: 22, dmg: [4, 7],   def: 0, speed: 1.3, reach: 26, drops: [["m|leather", 1, 1, 0.3], ["m|bone", 1, 1, 0.1]], gold: [3, 8]},
		zombie:     {name: "Zombie",     race: "Undead",  body: "male",     head: "Zombie",      skins: ["zombie", "zombie_green"],
		             wear: [["pants", "Pants", "cloth", "gray"]], weapon: "",
		             from: 3,  hp: 30, dmg: [5, 8],   def: 1, speed: 0.8, reach: 26, drops: [["m|bone", 1, 2, 0.4], ["m|linen", 1, 1, 0.2]], gold: [2, 6]},
		wolfkin:    {name: "Wolf Raider", race: "Wolfkin", body: "male",    head: "Wolf male",   skins: ["fur_grey", "fur_black", "fur_brown"],
		             wear: [["pants", "Pants", "cloth", "brown"]], weapon: "Spear",
		             from: 6,  hp: 34, dmg: [6, 10],  def: 1, speed: 1.5, reach: 44, drops: [["m|fur", 1, 2, 0.5], ["m|leather", 1, 1, 0.25]], gold: [4, 10]},
		skeleton:   {name: "Skeleton",   race: "Undead",  body: "male",     head: "Skeleton",    skins: ["zombie"],
		             wear: [], weapon: "Arming Sword",
		             from: 10, hp: 36, dmg: [8, 12],  def: 2, speed: 1.2, reach: 32, drops: [["m|bone", 1, 3, 0.6], ["m|iron", 1, 1, 0.1]], gold: [5, 12]},
		orc:        {name: "Orc",        race: "Orc",     body: "male",     head: "Orc male",    skins: ["green", "olive", "dark_green"],
		             wear: [["pants", "Pants", "cloth", "brown"], ["shirt", "Longsleeve", "cloth", "charcoal"]], weapon: "Waraxe",
		             from: 12, hp: 55, dmg: [10, 15], def: 3, speed: 1.1, reach: 34, drops: [["m|leather", 1, 2, 0.4], ["m|iron", 1, 1, 0.15]], gold: [8, 16]},
		troll:      {name: "Troll",      race: "Troll",   body: "muscular", head: "Troll",       skins: ["blue", "lavender", "dark_green"],
		             wear: [["pants", "Pants", "cloth", "brown"]], weapon: "Club",
		             from: 15, hp: 90, dmg: [13, 20], def: 4, speed: 0.8, reach: 32, drops: [["m|troll_hide", 1, 1, 0.25], ["m|stone", 3, 6, 1]], gold: [10, 20]},
		lizardfolk: {name: "Lizard Warrior", race: "Lizardfolk", body: "male", head: "Lizard male", skins: ["green", "dark_green", "blue"],
		             wear: [["pants", "Pants", "cloth", "black"]], weapon: "Trident",
		             from: 20, hp: 70, dmg: [14, 20], def: 3, speed: 1.3, reach: 46, drops: [["m|leather", 1, 2, 0.3], ["m|ember_core", 1, 1, 0.04], ["m|dragon_scale", 1, 1, 0.01]], gold: [12, 24]},
	};
	return t;
}

/// @description A humanoid monster's look: its race's head and a skin, a few clothes, its weapon.
function monster_look(_m){
	var look = character_empty_look(_m.race, _m.body);
	var p = look.parts;
	p.body.pal = character_find_palette("body", _m.skins[irandom(array_length(_m.skins) - 1)]);
	p.head = {item: character_find_item("head", _m.head), pal: -1};
	for(var i = 0; i < array_length(_m.wear); i++){
		var w = _m.wear[i];
		p[$ w[0]] = {item: character_find_item(w[0], w[1]), pal: character_find_palette(w[2], w[3])};
	}
	if(_m.weapon != "") p.held = {item: character_find_item("held", _m.weapon), pal: -1};
	character_validate(look);
	return look;
}

/// @description Put a monster in the room; floors past its first make it tougher.
function monster_spawn(_key, _x, _y, _floor){
	var m = monster_table()[$ _key];
	var scale = 1 + max(0, _floor - m.from) * 0.04;
	return instance_create_depth(_x, _y, 0, obj_monster, {kind: _key, def: m, hp: round(m.hp * scale), hpMax: round(m.hp * scale), toughness: scale});
}

// ---------------------------------------------------------------- the player hits

/// @description A swing lands (from action_hit): hit every monster in reach and in the swing's arc, or fire a shot.
/// Returns true if it hit something (or fired).
function combat_player_hit(_user, _item, _dir){
	var w = weapon_def(_item);
	var ang = [90, 180, 270, 0][_dir];
	if(w[$ "ranged"] ?? false){
		if(w.ammo != "" && !inv_is_free()){
			if(inv_count(w.ammo) <= 0){ farm_message("No " + string_lower(item_def(w.ammo).name) + " to shoot"); return false; }
			inv_take(w.ammo, 1);
		}
		instance_create_depth(_user.x + lengthdir_x(16, ang), _user.y - 20 + lengthdir_y(16, ang), _user.depth - 1, obj_projectile,
		                      {dx: lengthdir_x(w.speed, ang), dy: lengthdir_y(w.speed, ang), life: w.range / w.speed, weapon: w, ang: ang});
		return true;
	}
	if(!instance_exists(obj_monster)) return false;
	var cx = _user.x, cy = _user.y - 14, hit = false;
	with(obj_monster){
		if(dying) continue;
		var d = point_distance(cx, cy, x, y - 14);
		if(d > w.reach + 12) continue;
		if(d > 16 && abs(angle_difference(ang, point_direction(cx, cy, x, y - 14))) > w.arc / 2) continue;
		monster_damage(id, w, ang);
		hit = true;
	}
	return hit;
}

/// @description Damage a monster with a weapon: Luck adds to the crit chance, Defence takes some off.
function monster_damage(_inst, _w, _ang){
	var crit = random(1) < _w.crit + stat("luck") * 0.005;
	var dmg = irandom_range(_w.dmg[0], _w.dmg[1]) * (crit ? 2 : 1);
	dmg = max(1, dmg - _inst.def.def);
	with(_inst){
		hp -= dmg;
		flash = 8;
		hurtT = 10;
		attacking = false;
		kx = lengthdir_x(_w[$ "knock"] ?? 3, _ang);
		ky = lengthdir_y(_w[$ "knock"] ?? 3, _ang);
	}
	popup(_inst.x, _inst.y - 58, (crit ? "Crit! " : "") + string(dmg), crit ? make_colour_rgb(255, 220, 80) : c_white);
	if(_inst.hp <= 0) monster_kill(_inst);
}

/// @description A monster is beaten: its drops and gold go into the bag.
function monster_kill(_inst){
	var m = _inst.def, got = "";
	_inst.dying = true;
	var g = irandom_range(m.gold[0], m.gold[1]);
	if(!inv_is_free()) global.inv.gold += g;
	got = "+" + string(g) + " gold";
	for(var i = 0; i < array_length(m.drops); i++){
		var dr = m.drops[i];
		if(random(1) >= dr[3] + stat("luck") * 0.002) continue;
		var n = irandom_range(dr[1], dr[2]);
		if(n <= 0) continue;
		inv_add(item_stack(dr[0], n));
		got += ",  +" + string(n) + " " + item_def(dr[0]).name;
	}
	farm_message(m.name + " defeated  " + got);
}

// ---------------------------------------------------------------- the player gets hurt

/// @description A monster hits the player: damage less Defence (at least 1), a moment of invulnerability and a
/// shove away from the hit. At 0 health you're knocked out.
function player_hurt(_dmg, _fromX, _fromY){
	if(!instance_exists(obj_plyr) || obj_plyr.iframes > 0 || game.sleeping || game.dying) return;
	var dmg = max(1, round(_dmg) - stat("defense"));
	global.vitals.health = max(0, global.vitals.health - dmg);
	popup(obj_plyr.x, obj_plyr.y - 62, "-" + string(dmg), make_colour_rgb(240, 80, 70));
	with(obj_plyr){
		iframes = 60;
		var a = point_direction(_fromX, _fromY, x, y);
		var solids = collision_solids(false);
		repeat(12){
			var nx = x + lengthdir_x(1, a), ny = y + lengthdir_y(1, a);
			if(!place_meeting(nx, y, solids)) x = nx;
			if(!place_meeting(x, ny, solids)) y = ny;
		}
	}
	if(global.vitals.health <= 0) player_knocked_out();
}

/// @description Out cold: fade out, then death_penalty and wake beside the bed (see game's Step).
function player_knocked_out(){
	with(game){ if(dying || sleeping) exit; dying = true; }
}

/// @description What being knocked out costs (Stardew-like): 10% of your gold (up to 500) and up to 3 random
/// stacks from your bag - never tools, weapons or what you're wearing. You wake two hours later at half strength.
/// Returns the message for when you wake up.
function death_penalty(){
	var lostGold = 0, lost = [];
	if(!inv_is_free()){
		lostGold = min(500, floor(global.inv.gold * 0.1));
		global.inv.gold -= lostGold;
		var cands = [];
		for(var i = 0; i < INV_SIZE; i++){
			var st = global.inv.slots[i];
			if(st != undefined && item_def(st.id).type != "held") array_push(cands, i);
		}
		repeat(min(3, array_length(cands))){
			var k = irandom(array_length(cands) - 1);
			var st = global.inv.slots[cands[k]];
			array_push(lost, string(st.count) + " " + item_def(st.id).name);
			global.inv.slots[cands[k]] = undefined;
			array_delete(cands, k, 1);
		}
	}
	global.vitals.buff = undefined;
	global.vitals.health = vitals_max_health() * 0.5;
	global.vitals.energy = vitals_max_energy() * 0.5;
	global.clock.minutes = min(DAY_END - 30, global.clock.minutes + 120);
	var msg = "Someone found you in the mine and carried you home";
	if(lostGold > 0) msg += "  -  lost " + string(lostGold) + " gold";
	if(array_length(lost) > 0){
		msg += "  -  lost ";
		for(var i = 0; i < array_length(lost); i++) msg += ((i > 0) ? ", " : "") + lost[i];
	}
	return msg;
}

// ---------------------------------------------------------------- popups

/// @description A number or word that floats up and fades (damage, crits).
function popup(_x, _y, _text, _colour){
	instance_create_depth(_x, _y, -9500, obj_popup, {text: _text, colour: _colour});
}

// ---------------------------------------------------------------- monster movement

/// @description Move the calling monster, sliding along whatever blocks it.
function monster_move(_dx, _dy, _solids){
	if(_dx != 0){ if(!place_meeting(x + _dx, y, _solids)) x += _dx; else moveX = 0; }
	if(_dy != 0){ if(!place_meeting(x, y + _dy, _solids)) y += _dy; else moveY = 0; }
}

/// @description Facing (0 north, 1 west, 2 south, 3 east) for a direction in degrees.
function monster_dir(_a){
	if(_a >= 45 && _a < 135) return 0;
	if(_a >= 135 && _a < 225) return 1;
	if(_a >= 225 && _a < 315) return 2;
	return 3;
}
