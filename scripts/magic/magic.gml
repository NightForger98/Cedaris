/// Magic (roadmap phase 5): mana, spells learned from scrolls, cast with a staff in hand.
///
/// global.vitals.mana - the pool: 30 + 10 per point of Magic; it trickles back (1 per 10 game minutes) and fills
///   when you sleep. global.inv.spells = [keys you know], global.inv.spell = the one selected (Q changes it).
/// Holding a staff, F casts the selected spell; the better the staff (and your Magic), the stronger it is.
/// Scrolls are items "k|<spell>": hold one and use it to learn the spell. Mara sells the farm spells, Brom the
/// Light; Fireball and Heal come from the mine (treasure chests on lift floors, and rare drops).

/// @description Spells: mana cost, what it does (spell_effect), where the scroll comes from (for its description).
function spell_table(){
	static t = [
		{key: "grow",     name: "Grow",     mana: 10, colour: make_colour_rgb(120, 220, 90),  desc: "Crops in front of you grow a day (3 x 3, wider with a better staff).", from: "Mara"},
		{key: "rain",     name: "Rain",     mana: 15, colour: make_colour_rgb(90, 160, 255),  desc: "Waters the tilled soil around the spot in front of you (5 x 5).",       from: "Mara"},
		{key: "light",    name: "Light",    mana: 8,  colour: make_colour_rgb(255, 235, 150), desc: "A glow around you for three hours: the mine's dark draws back.",       from: "Brom"},
		{key: "fireball", name: "Fireball", mana: 6,  colour: make_colour_rgb(255, 120, 40),  desc: "Hurls fire at whatever's in front of you. Stronger with more Magic.",  from: "the mine"},
		{key: "heal",     name: "Heal",     mana: 12, colour: make_colour_rgb(240, 120, 200), desc: "Mends 30 health, and 3 more per point of Magic.",                     from: "the mine"},
	];
	return t;
}

function spell_def(_key){
	var t = spell_table();
	for(var i = 0; i < array_length(t); i++) if(t[i].key == _key) return t[i];
	return undefined;
}

/// @description How much a staff adds to spell power (anything else can't cast).
function staff_power(_name){
	switch(_name){
		case "Simple staff":  return 0;
		case "Gnarled staff": return 1;
		case "Loop staff":    return 2;
		case "S staff":       return 3;
		case "Diamond staff": return 5;
	}
	return -1;
}

/// @description Spell power: your Magic plus the staff's bonus.
function spell_power(_staff){ return max(0, stat("magic")) + max(0, staff_power(_staff)); }

function mana_max(){ return 30 + 10 * max(0, stat("magic")); }

function mana(){
	if(!variable_struct_exists(global.vitals, "mana")) global.vitals.mana = mana_max();
	return global.vitals.mana;
}

function spells_known(){
	if(!is_array(global.inv[$ "spells"])) global.inv.spells = [];
	return global.inv.spells;
}

function spell_selected(){
	var k = spells_known();
	if(array_length(k) == 0) return "";
	var s = global.inv[$ "spell"] ?? "";
	return (array_get_index(k, s) == -1) ? k[0] : s;
}

/// @description Q: the next spell you know.
function spell_cycle(){
	var k = spells_known();
	if(array_length(k) == 0) return;
	global.inv.spell = k[(array_get_index(k, spell_selected()) + 1) mod array_length(k)];
}

/// @description Use a scroll from the hotbar: learn its spell (the scroll is used up).
function spell_learn(_stack){
	var key = string_split(_stack.id, "|")[1];
	var d = spell_def(key);
	if(d == undefined) return;
	var k = spells_known();
	if(array_get_index(k, key) != -1){ farm_message("You already know " + d.name); return; }
	array_push(k, key);
	global.inv.spell = key;
	_stack.count--;
	if(_stack.count <= 0) global.inv.slots[global.inv.hotbar] = undefined;
	farm_message("Learned " + d.name + "!  Hold a staff: F casts, Q changes spell");
}

/// @description Mana comes back slowly while you play: 1 per 10 game minutes. _minutes: game minutes this frame.
function mana_tick(_minutes){
	global.vitals.mana = min(mana_max(), mana() + _minutes * 0.1);
}

// ---------------------------------------------------------------- casting

/// @description F with a staff in hand: the animation to play for casting, or a reason it can't happen.
/// Returns {act} or {why}.
function spell_begin(_look, _staff){
	if(staff_power(_staff) < 0) return {why: ""};
	var key = spell_selected();
	if(key == "") return {why: "You don't know any spells yet. Scrolls teach them"};
	var d = spell_def(key);
	if(mana() < d.mana) return {why: "Not enough mana for " + d.name + " (" + string(d.mana) + ")"};
	// The spellcast pose if the staff has art for it, else the staff's own thrust
	var it = lpc_catalog().items[_look.parts.held.item];
	var act;
	if(array_get_index(it.anims, "spellcast") != -1){
		var r = action_rows().spellcast;
		act = {name: "spellcast", custom: false, row: r.row, seq: r.seq, frames: array_length(r.seq), fs: 64, fps: r.fps, hit: r.hit};
	} else act = character_action_for(_look);
	if(act == undefined) return {why: ""};
	return {act: act, spell: key};
}

/// @description The spell lands (on the cast's hit step): spend the mana and do it.
function spell_effect(_user, _key, _dir, _staff){
	var d = spell_def(_key);
	if(d == undefined || mana() < d.mana) return;
	global.vitals.mana -= d.mana;
	var pw = spell_power(_staff);
	var cell = farm_front_cell(_user, _dir);
	switch(_key){
		case "grow":
			// Every crop in reach grows one day (watered or not), as if a day had passed
			var r = 1 + (pw >= 3), n = 0;
			for(var gx = cell[0] - r; gx <= cell[0] + r; gx++) for(var gy = cell[1] - r; gy <= cell[1] + r; gy++){
				var c = farm_crop_at(gx, gy);
				if(c == noone || c.growthStage >= c.maxGrowthStage) continue;
				with(c){
					daysOld += 1;
					growthStage = crop_stage(cropType, daysOld);
					if(growthStage >= maxGrowthStage){ growthStage = maxGrowthStage; fullyGrown = true; alarm[1] = 1; }
				}
				n++;
			}
			crops_store();
			farm_message((n > 0) ? string(n) + " crops grew" : "Nothing to grow here");
			break;
		case "rain":
			var tiles = farm_tiles(), n = 0;
			for(var gx = cell[0] - 2; gx <= cell[0] + 2; gx++) for(var gy = cell[1] - 2; gy <= cell[1] + 2; gy++){
				var k = farm_key(gx, gy);
				if(variable_struct_exists(tiles, k)){ tiles[$ k].watered = true; n++; }
			}
			farm_message((n > 0) ? "Rain falls on " + string(n) + " patches" : "Rain falls on bare ground");
			break;
		case "light":
			global.vitals.light = min(DAY_END, global.clock.minutes + 180 + pw * 30);
			farm_message("A warm light surrounds you");
			break;
		case "fireball":
			var ang = [90, 180, 270, 0][_dir];
			var w = {dmg: [14 + pw * 3, 20 + pw * 4], crit: 0.05, knock: 5, ammo: "", fire: true};
			instance_create_depth(_user.x + lengthdir_x(16, ang), _user.y - 20 + lengthdir_y(16, ang), _user.depth - 1, obj_projectile,
			                      {dx: lengthdir_x(6, ang), dy: lengthdir_y(6, ang), life: 50, weapon: w, ang: ang});
			break;
		case "heal":
			var h = 30 + 3 * pw;
			global.vitals.health = min(vitals_max_health(), global.vitals.health + h);
			popup(_user.x, _user.y - 62, "+" + string(h), d.colour);
			break;
	}
	// A burst of the spell's colour where it landed
	popup(_user.x, _user.y - 70, d.name, d.colour);
}

/// @description True while the Light spell is shining (the mine is far less dark).
function spell_light_on(){
	return world_time_ready() && (global.vitals[$ "light"] ?? 0) > global.clock.minutes;
}
