/// Skills, attributes, gear metals and dances (the user, 2026-11-07).
///
/// Skills, the Stardew Valley way: Farming, Mining, Foraging, Fishing and Combat, levelled 1-10 by doing them
/// (Stardew's experience table: 100, 380, 770, 1300, 2150, 3300, 4800, 6900, 10000, 15000). Each level makes that
/// work easier (less energy, better yields), and at levels 5 and 10 you choose a specialisation (one of two).
/// Attributes, the action-RPG way (Diablo, Divinity): every skill level gives a point to spend - Strength,
/// Agility, Intelligence, Vitality, Luck, Charisma - plus 5 to start. Strength decides which metal of weapon and
/// armour you can use; Agility which dances you can learn.
/// global.world.skills = {<skill>: {xp, spec5, spec10}}   global.world.attrs = {<attr>: points}
/// Gear metals: a metal weapon or armour piece is made of copper, iron, steel, silver, gold or mithril (stack.metal);
/// its dye only changes its colour.

#macro ATTR_START_POINTS 5

/// @description Experience needed for each level (total), Stardew's table.
function skill_xp_table(){ static t = [100, 380, 770, 1300, 2150, 3300, 4800, 6900, 10000, 15000]; return t; }

/// @description The skills: name, what levels them, and their specialisations at 5 and 10 ([key, name, what it does]).
function skill_table(){
	static t = {
		farming:  {name: "Farming",  how: "Harvest crops and collect from your animals",
		           perk: "Better crop quality; the hoe and watering can cost less energy",
		           spec5:  [["rancher", "Rancher", "Milk, eggs and wool sell for 20% more"], ["tiller", "Tiller", "Crops sell for 10% more"]],
		           spec10: [["agriculturist", "Agriculturist", "Crops grow faster (a 1 in 5 chance of an extra day's growth each night)"], ["green_thumb", "Green Thumb", "Far more gold-star crops"]]},
		mining:   {name: "Mining",   how: "Break rocks and ore veins",
		           perk: "The pickaxe costs less energy; ore veins give more",
		           spec5:  [["miner", "Miner", "+1 ore from every vein"], ["geologist", "Geologist", "Gems and coal turn up twice as often"]],
		           spec10: [["blacksmith", "Blacksmith", "Metal bars sell for 50% more"], ["prospector", "Prospector", "A 1 in 4 chance of breaking a rock twice over"]]},
		foraging: {name: "Foraging", how: "Chop trees, cut weeds and bushes, gather wild things",
		           perk: "The axe and scythe cost less energy; more wood",
		           spec5:  [["forester", "Forester", "+25% wood from trees"], ["gatherer", "Gatherer", "A 1 in 5 chance of double wild finds"]],
		           spec10: [["lumberjack", "Lumberjack", "The axe costs half the energy"], ["herbalist", "Herbalist", "Wild herbs and mushrooms restore twice the energy"]]},
		fishing:  {name: "Fishing",  how: "Catch fish",
		           perk: "A wider catch zone",
		           spec5:  [["fisher", "Fisher", "Fish sell for 25% more"], ["patient", "Patient", "A much wider catch zone"]],
		           spec10: [["angler", "Angler", "Fish sell for 50% more"], ["lucky_line", "Lucky Line", "Rare fish bite more often"]]},
		combat:   {name: "Combat",   how: "Defeat monsters",
		           perk: "+5 max health a level",
		           spec5:  [["fighter", "Fighter", "+10% damage and +15 max health"], ["scout", "Scout", "Critical hits twice as often"]],
		           spec10: [["brute", "Brute", "+15% melee damage"], ["desperado", "Desperado", "Critical hits deal triple damage"]]},
	};
	return t;
}
function skill_keys(){ static k = ["farming", "mining", "foraging", "fishing", "combat"]; return k; }

/// @description The attributes: name and what they do.
function attr_table(){
	static t = {
		strength:     {name: "Strength",     desc: "+3% melee damage a point. Heavier metals of weapon and armour need more."},
		agility:      {name: "Agility",      desc: "+1% attack speed and move speed, +1% dodge a point. Harder dances need more."},
		intelligence: {name: "Intelligence", desc: "+1 Magic a point: stronger spells, more mana; +2% better crafting value."},
		vitality:     {name: "Vitality",     desc: "+5 max health and +4 max energy a point."},
		luck:         {name: "Luck",         desc: "+1 Luck a point: critical hits, rare drops, better crops and fish."},
		charisma:     {name: "Charisma",     desc: "+1 Charm a point: friendships grow faster, better prices."},
	};
	return t;
}
function attr_keys(){ static k = ["strength", "agility", "intelligence", "vitality", "luck", "charisma"]; return k; }

// ---------------------------------------------------------------- state

function skill_state(_key){
	if(!is_struct(global.world[$ "skills"])) global.world.skills = {};
	var s = global.world.skills[$ _key];
	if(!is_struct(s)){ s = {xp: 0, spec5: "", spec10: ""}; global.world.skills[$ _key] = s; }
	return s;
}

/// @description A skill's level, 0-10.
function skill_level(_key){
	if(!world_time_ready()) return 0;
	var xp = skill_state(_key).xp, t = skill_xp_table(), n = 0;
	while(n < 10 && xp >= t[n]) n++;
	return n;
}

/// @description Your character level: all your skill levels together (0-50).
function skill_total_level(){
	var k = skill_keys(), n = 0;
	for(var i = 0; i < array_length(k); i++) n += skill_level(k[i]);
	return n;
}

/// @description Whether you have a specialisation.
function skill_has(_spec){
	if(!world_time_ready()) return false;
	var k = skill_keys();
	for(var i = 0; i < array_length(k); i++){ var s = skill_state(k[i]); if(s.spec5 == _spec || s.spec10 == _spec) return true; }
	return false;
}

/// @description Gain experience in a skill: a message and a sparkle on a level-up, and a specialisation to choose at 5
/// and 10 (the character screen, K).
function skill_add_xp(_key, _n){
	if(!world_time_ready() || _n <= 0) return;
	var before = skill_level(_key);
	skill_state(_key).xp += round(_n);
	var after = skill_level(_key);
	if(after > before){
		var nm = skill_table()[$ _key].name;
		var msg = nm + " level " + string(after) + "!  +1 attribute point";
		if(after == 5 || after == 10) msg += " - choose a specialisation";
		msg += " (" + key_label("skills") + ")";
		farm_message(msg);
		if(instance_exists(obj_plyr)) popup(obj_plyr.x, obj_plyr.y - 80, nm + " " + string(after) + "!", make_colour_rgb(120, 230, 140));
		global.skillNotice = true;
	}
}

/// @description Choose a specialisation (at 5 or 10). Returns "" or why not.
function skill_choose(_key, _tier, _spec){
	var s = skill_state(_key), lv = skill_level(_key), t = skill_table()[$ _key];
	var opts = (_tier == 5) ? t.spec5 : t.spec10, ok = false;
	for(var i = 0; i < array_length(opts); i++) if(opts[i][0] == _spec) ok = true;
	if(!ok) return "No such specialisation";
	if(lv < _tier) return "Reach level " + string(_tier) + " first";
	if(_tier == 5){ if(s.spec5 != "") return "Already chosen"; s.spec5 = _spec; }
	else { if(s.spec10 != "") return "Already chosen"; s.spec10 = _spec; }
	return "";
}

/// @description Specialisations waiting to be chosen.
function skill_pending_choices(){
	var k = skill_keys(), n = 0;
	for(var i = 0; i < array_length(k); i++){
		var s = skill_state(k[i]), lv = skill_level(k[i]);
		if(lv >= 5 && s.spec5 == "") n++;
		if(lv >= 10 && s.spec10 == "") n++;
	}
	return n;
}

// ---------------------------------------------------------------- attributes

function attr_state(){
	if(!is_struct(global.world[$ "attrs"])) global.world.attrs = {strength: 0, agility: 0, intelligence: 0, vitality: 0, luck: 0, charisma: 0};
	return global.world.attrs;
}

/// @description An attribute's points.
function attr(_key){ return world_time_ready() ? (attr_state()[$ _key] ?? 0) : 0; }

/// @description Points earned: 5 to start, 1 a skill level.
function attr_points_earned(){ return ATTR_START_POINTS + skill_total_level(); }

function attr_points_spent(){
	var k = attr_keys(), n = 0;
	for(var i = 0; i < array_length(k); i++) n += attr(k[i]);
	return n;
}

function attr_points_free(){ return attr_points_earned() - attr_points_spent(); }

/// @description Spend a point. Returns "" or why not.
function attr_spend(_key){
	if(attr_points_free() <= 0) return "No points to spend - level a skill";
	attr_state()[$ _key] = attr(_key) + 1;
	if(variable_global_exists("inv") && is_struct(global.inv) && instance_exists(obj_plyr)) inv_apply_look(obj_plyr.look);
	return "";
}

/// @description What attributes add to the game's stats (stat() adds these): Intelligence to Magic, Luck to Luck,
/// Charisma to Charm, Agility a little Speed.
function attr_stat_bonus(_stat){
	switch(_stat){
		case "magic": return attr("intelligence");
		case "luck":  return attr("luck");
		case "charm": return attr("charisma");
		case "speed": return attr("agility") * 0.2;   // +1% move speed a point (speed: +5% a point)
	}
	return 0;
}

/// @description Melee damage multiplier: Strength, Combat specialisations.
function attr_melee_mult(){ return (1 + attr("strength") * 0.03) * (skill_has("fighter") ? 1.1 : 1) * (skill_has("brute") ? 1.15 : 1); }

/// @description Attack speed multiplier from Agility (+1% a point, up to +40%).
function attr_attack_speed(){ return 1 + min(0.4, attr("agility") * 0.01); }

/// @description Chance to dodge a hit, from Agility (1% a point, up to 25%).
function attr_dodge(){ return min(0.25, attr("agility") * 0.01); }

/// @description Max health and energy bonuses: Vitality, Combat.
function attr_health_bonus(){ return attr("vitality") * 5 + skill_level("combat") * 5 + (skill_has("fighter") ? 15 : 0); }
function attr_energy_bonus(){ return attr("vitality") * 4; }

// ---------------------------------------------------------------- skill perks (hooks)

/// @description Energy a tool costs, after its skill (2% less a level) and Lumberjack.
function skill_tool_energy_mult(_tool){
	var k = "";
	switch(_tool){
		case "Hoe": case "Watering Can": k = "farming"; break;
		case "Pickaxe": k = "mining"; break;
		case "Axe": case "Scythe": k = "foraging"; break;
	}
	if(k == "") return 1;
	return (1 - 0.02 * skill_level(k)) * ((_tool == "Axe" && skill_has("lumberjack")) ? 0.5 : 1);
}

/// @description A sale price after specialisations: Rancher, Tiller, Blacksmith, Fisher, Angler.
function skill_sell_mult(_id){
	var t = string_char_at(_id, 1), m = 1;
	if(t == "a" && skill_has("rancher")) m *= 1.2;
	if(t == "m" && string_pos("m|wool", _id) == 1 && skill_has("rancher")) m *= 1.2;
	if(t == "p" && skill_has("tiller")) m *= 1.1;
	if(t == "x"){ if(skill_has("fisher")) m *= 1.25; if(skill_has("angler")) m *= 1.5; }
	if(t == "m" && skill_has("blacksmith")){
		var k = string_delete(_id, 1, 2);
		if(k == "copper" || k == "iron" || k == "steel" || k == "silver" || k == "gold" || k == "mithril") m *= 1.5;
	}
	return m;
}

/// @description XP for breaking a resource, and which skill: [skill, xp].
function skill_gather_xp(_key, _def){
	var mining = array_get_index(_def.tools, "Pickaxe") != -1;
	var xp = 1;
	switch(_key){
		case "stone": xp = 1; break;   case "boulder": xp = 3; break;
		case "copper_vein": xp = 5; break; case "coal_vein": xp = 5; break; case "iron_vein": xp = 12; break;
		case "silver_vein": xp = 15; break; case "gold_vein": xp = 18; break; case "mithril_vein": xp = 30; break;
		case "gem_node": xp = 20; break; case "ice_rock": case "ember_rock": xp = 10; break; case "void_node": xp = 30; break;
		case "oak": case "pine": xp = 12; break; case "ancient_oak": case "ancient_pine": xp = 25; break;
		case "oak_stump": case "pine_stump": xp = 2; break; case "bush": xp = 2; break; case "weeds": xp = 1; break;
		default: if(string_pos("forage_", _key) == 1) xp = 7;
	}
	return [mining ? "mining" : "foraging", xp];
}

/// @description Extra drops for a resource from your skills: Mining level (+3% an extra ore a level), Miner,
/// Forester, Gatherer. Returns how many extra of a drop.
function skill_extra_drops(_key, _drop){
	var extra = 0, isOre = (string_pos("_ore", _drop) > 0);
	if(isOre){
		if(random(1) < skill_level("mining") * 0.03) extra++;
		if(skill_has("miner")) extra++;
	}
	if(_drop == "m|wood"){
		if(random(1) < skill_level("foraging") * 0.03) extra++;
		if(skill_has("forester") && random(1) < 0.25) extra++;
	}
	if(string_pos("forage_", _key) == 1 && skill_has("gatherer") && random(1) < 0.2) extra++;
	return extra;
}

// ---------------------------------------------------------------- gear metals

/// @description The metals of weapons and armour, weakest first: Strength needed, damage / defence multiplier,
/// their palette, and the bar they're made from.
function gear_metals(){
	static t = [
		{key: "copper",  name: "Copper",  str: 0,  mult: 0.85, pal: "lpc_pal_metal_copper"},
		{key: "iron",    name: "Iron",    str: 4,  mult: 1.0,  pal: "lpc_pal_metal_iron"},
		{key: "steel",   name: "Steel",   str: 8,  mult: 1.15, pal: "lpc_pal_metal_steel"},
		{key: "silver",  name: "Silver",  str: 12, mult: 1.25, pal: "lpc_pal_metal_silver"},
		{key: "gold",    name: "Gold",    str: 16, mult: 1.35, pal: "lpc_pal_metal_gold"},
		{key: "mithril", name: "Mithril", str: 22, mult: 1.6,  pal: "lpc_pal_metal_mithril"},
	];
	return t;
}

function gear_metal(_key){
	var t = gear_metals();
	for(var i = 0; i < array_length(t); i++) if(t[i].key == _key) return t[i];
	return undefined;
}

/// @description The melee weapons made of metal (staffs, bows, clubs and canes aren't), and the metal each comes in
/// when bought.
function weapon_default_metal(_name){
	switch(_name){
		case "Dagger": case "Spear": return "copper";
		case "Arming Sword": case "Saber": case "Mace": case "Long spear": return "iron";
		case "Rapier": case "Scimitar": case "Longsword": case "Longsword alt": case "Flail": case "Waraxe": return "steel";
		case "Katana": case "Trident": return "silver";
		case "Halberd": return "gold";
		case "Glowsword": case "Dragon spear": return "mithril";
	}
	return "";
}

/// @description A stack's metal ("" if it isn't metal gear): what it was made of, or, for older things, iron armour
/// and the weapon's usual metal.
function gear_stack_metal(_stack){
	if(_stack == undefined) return "";
	var m = _stack[$ "metal"] ?? "";
	if(m != "") return m;
	var d = item_def(_stack.id);
	if(d == undefined) return "";
	if(d.type == "clothing" && (d[$ "material"] ?? "") == "metal") return "iron";
	if(d.type == "held") return weapon_default_metal(d.name);
	return "";
}

/// @description Strength a stack needs (0 if none).
function gear_strength_needed(_stack){
	var m = gear_metal(gear_stack_metal(_stack));
	return (m == undefined) ? 0 : m.str;
}

/// @description Whether your Strength is enough for a stack; "" if so, else why not.
function gear_too_heavy(_stack){
	if(inv_is_free()) return "";   // free mode: the sandbox has no requirements
	var need = gear_strength_needed(_stack);
	if(need <= attr("strength")) return "";
	return gear_metal(gear_stack_metal(_stack)).name + " is too heavy: it needs " + string(need) + " Strength (you have " + string(attr("strength")) + ")";
}

/// @description A metal stack's stats: its recipe in its own metal (armour: copper weaker, mithril stronger).
function gear_stack_stats(_stack){
	var d = item_def(_stack.id), m = gear_metal(gear_stack_metal(_stack));
	if(m == undefined || d.type != "clothing") return d.stats;
	var base = d.stats, out = {}, k = variable_struct_get_names(base);
	for(var i = 0; i < array_length(k); i++) out[$ k[i]] = (k[i] == "defense") ? round(base[$ k[i]] * m.mult * 10) / 10 : base[$ k[i]];
	if(variable_struct_exists(out, "defense") == false) out.defense = round(m.mult * 2);
	return out;
}

/// @description A weapon's stats with its metal: damage times the metal's multiplier and Strength's.
function gear_weapon_stats(_w, _stack){
	var m = gear_metal(gear_stack_metal(_stack));
	var w = {}, k = variable_struct_get_names(_w);
	for(var i = 0; i < array_length(k); i++) w[$ k[i]] = _w[$ k[i]];
	if(!(_w[$ "ranged"] ?? false)){
		var mult = ((m == undefined) ? 1 : m.mult) * attr_melee_mult();
		w.dmg = [max(1, round(_w.dmg[0] * mult)), max(1, round(_w.dmg[1] * mult))];
	}
	if(skill_has("scout")) w.crit = (_w[$ "crit"] ?? 0) * 2;
	return w;
}

/// @description The metal armour recipes: one per metal, costing that metal's bars.
function gear_recipe_cost(_cost, _metal){
	var n = 0, names = variable_struct_get_names(_cost);
	for(var i = 0; i < array_length(names); i++) n += _cost[$ names[i]];
	var out = {};
	out[$ _metal] = n;
	return out;
}

// ---------------------------------------------------------------- tool colours

/// @description The palette a tool shows in your hand at its upgrade level: dull iron, then copper, steel grey,
/// bright silver, gold, sea-blue mithril; cursed dark, blessed pale gold.
function tool_tier_pal(_t){
	switch(_t){
		case 0: return "lpc_pal_metal_iron";
		case 1: return "lpc_pal_metal_copper";
		case 2: return "lpc_pal_metal_steel";
		case 3: return "lpc_pal_metal_silver";
		case 4: return "lpc_pal_metal_gold";
		case 5: return "lpc_pal_metal_mithril";
		case TOOL_CURSED: return "lpc_pal_metal_iron";
		case TOOL_BLESSED: return "lpc_pal_metal_brass";
	}
	return "";
}

// ---------------------------------------------------------------- dances

/// @description The dances Ayla teaches at the tavern (evenings): Agility needed, price, and how they go - steps of
/// [row, frames per step, hop, sway] (rows: the walk's n w s e are 8-11, arms raised 0-3).
function dance_table(){
	static t = {
		two_step: {name: "Two-Step",       agi: 0,  price: 300,  power: 1, steps: [[10, 6, 0, 3], [10, 6, 0, -3]]},
		spin:     {name: "The Spin",       agi: 4,  price: 800,  power: 2, steps: [[10, 5, 0, 0], [11, 5, 0, 0], [8, 5, 0, 0], [9, 5, 0, 0]]},
		dabke:    {name: "Dabke",          agi: 8,  price: 1500, power: 3, steps: [[10, 6, 6, 0], [10, 6, 0, 2], [10, 6, 6, 0], [10, 6, 0, -2]]},
		raise:    {name: "Raise the Roof", agi: 12, price: 2500, power: 4, steps: [[2, 5, 4, 0], [10, 5, 0, 0], [2, 5, 4, 0], [10, 5, 0, 0]]},
		moonwalk: {name: "Moonwalk",       agi: 18, price: 4000, power: 5, steps: [[9, 4, 0, 4], [9, 4, 0, 2], [11, 4, 0, -2], [11, 4, 0, -4]]},
	};
	return t;
}
function dance_keys(){ static k = ["two_step", "spin", "dabke", "raise", "moonwalk"]; return k; }

function dance_known(){
	if(!is_array(global.world[$ "dances"])) global.world.dances = [];
	return global.world.dances;
}

function dance_knows(_key){ return array_get_index(dance_known(), _key) != -1; }

/// @description The best dance you know ("" if none).
function dance_best(){
	var k = dance_keys(), best = "";
	for(var i = 0; i < array_length(k); i++) if(dance_knows(k[i])) best = k[i];
	return best;
}

/// @description Ayla's lessons (people_trade, shop "dance"): the dances you don't know yet.
function dance_stock(){
	var out = [], k = dance_keys();
	for(var i = 0; i < array_length(k); i++) if(!dance_knows(k[i])) array_push(out, {id: "v|" + k[i], price: dance_table()[$ k[i]].price});
	return out;
}

/// @description Use a lesson from the hotbar: learn the dance, if you're agile enough.
function dance_learn(_stack){
	var k = string_split(_stack.id, "|")[1], d = dance_table()[$ k];
	if(dance_knows(k)){ farm_message("You already know " + d.name); return; }
	if(attr("agility") < d.agi){ farm_message(d.name + " needs " + string(d.agi) + " Agility (you have " + string(attr("agility")) + ")"); return; }
	array_push(dance_known(), k);
	_stack.count--;
	if(_stack.count <= 0) global.inv.slots[global.inv.hotbar] = undefined;
	farm_message("You learned " + d.name + "!  Press " + key_label("dance") + " to dance");
}

/// @description The dance key: dance your best dance. Villagers nearby who haven't seen you dance today like it
/// (friendship by the dance's power); on a festival day, your first dance there is the town's dance contest.
function dance_start(){
	if(!instance_exists(obj_plyr)) return;
	var k = dance_best();
	if(k == ""){ farm_message("You don't know any dances. Ayla teaches them at the tavern in the evenings"); return; }
	var d = dance_table()[$ k];
	with(obj_plyr){ danceKey = k; danceT = 150; danceStep = 0; moveX = 0; moveY = 0; }
	// friends nearby
	if(!is_struct(global.world[$ "dancedFor"])) global.world.dancedFor = {};
	var n = 0, px = obj_plyr.x, py = obj_plyr.y;
	with(obj_villager){
		if(point_distance(x, y, px, py) > 140) continue;
		if((global.world.dancedFor[$ who] ?? -1) == day_index()) continue;
		global.world.dancedFor[$ who] = day_index();
		people_add(who, 10 * d.power);
		popup(x, y - 70, "Bravo!", make_colour_rgb(255, 210, 120));
		n++;
	}
	var msg = d.name + "!" + ((n > 0) ? "  " + string(n) + " watching cheered" : "");
	var f = festival_today();
	if(f != undefined && room == rm_beirut && !festival_done_key("dance_contest")){
		festival_mark_key("dance_contest");
		var place = (d.power >= 4) ? "First prize" : ((d.power >= 2) ? "Second prize" : "A ribbon for trying");
		var prize = [100, 250, 250, 600, 600, 1200][d.power];
		if(!inv_is_free()) global.inv.gold += prize;
		msg = "The festival's dance contest: your " + d.name + " wins " + place + "!  +" + string(prize) + " gold";
	}
	farm_message(msg);
}

/// @description Festival activities by name, once a festival (dance contest): done / mark.
function festival_done_key(_k){ var fd = global.world[$ "festDone"]; return is_struct(fd) && (fd[$ _k] ?? -1) == day_index(); }
function festival_mark_key(_k){ if(!is_struct(global.world[$ "festDone"])) global.world.festDone = {}; global.world.festDone[$ _k] = day_index(); }

// ---------------------------------------------------------------- tests

function autotest_skill_xp(_key, _n){ skill_add_xp(_key, real(_n)); return _key + " " + string(skill_level(_key)) + " xp " + string(skill_state(_key).xp); }
function autotest_attr(_key, _n){ attr_state()[$ _key] = real(_n); return _key + " " + string(attr(_key)); }
function autotest_skills_line(){ return "level " + string(skill_total_level()) + " points " + string(attr_points_free()) + " str " + string(attr("strength")); }
function autotest_gear_heavy(_id, _metal){ var st = item_stack(_id); if(_metal != "") st.metal = _metal; var w = gear_too_heavy(st); return (w == "") ? "fine" : w; }
function autotest_tool_pal(_name){ return tool_tier_pal(tool_tier(_name)); }
