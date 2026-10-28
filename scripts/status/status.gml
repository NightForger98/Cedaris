/// Status effects (docs/CHARGING.md, "Status effects and the witch"): poison and the curse, both from the witch's shots.
///
/// Poison (global.vitals.poison: seconds left) takes a little health every couple of seconds, never below 1; Defence
/// shortens it and softens each tick, Luck can shrug a hit off, and an Antidote (Morga's) cures it.
/// The curse lives on the inventory: global.inv.cursed is the cursed item's id ("" for none), and cursePending is a
/// curse waiting for the next tool or weapon you pick up. A cursed item stays in your hand - the hotbar won't leave it
/// except for food - and can't be moved, sold or shipped; it costs double energy and takes 30% off your Defence.
/// A cursed Mithril tool becomes the Cursed tier (6); Father Aldous lifts curses (Blessed tier 7 for those).

#macro POISON_TICK 2       // seconds between poison ticks

/// @description The witch's green shot lands: poisoned for a while (Defence shortens it), unless Luck shrugs it off.
function status_poison(_secs){
	if(random(1) < min(0.3, stat("luck") * 0.02)){ farm_message("You shrug off the poison"); return; }
	var secs = _secs * (1 - min(0.5, stat("defense") * 0.03));
	global.vitals.poison = max(global.vitals[$ "poison"] ?? 0, secs);
	farm_message("You've been poisoned!");
}

function status_poisoned(){ return (global.vitals[$ "poison"] ?? 0) > 0; }

function status_cure_poison(){
	if(!status_poisoned()) return false;
	global.vitals.poison = 0;
	return true;
}

/// @description Every frame of play (game's Step): poison ticks down, taking health (never below 1).
function status_step(){
	if(!status_poisoned() || game.sleeping || game.dying) return;
	var dt = 1 / game_get_speed(gamespeed_fps);
	var before = global.vitals.poison;
	global.vitals.poison = max(0, before - dt);
	if(floor(before / POISON_TICK) != floor(global.vitals.poison / POISON_TICK) && global.vitals.health > 1){
		var dmg = max(1, 3 - floor(stat("defense") / 4));
		global.vitals.health = max(1, global.vitals.health - dmg);
		if(instance_exists(obj_plyr)) popup(obj_plyr.x, obj_plyr.y - 62, "-" + string(dmg), make_colour_rgb(110, 220, 90));
	}
	if(global.vitals.poison <= 0) farm_message("The poison has worn off");
}

// ---------------------------------------------------------------- the curse

function curse_item(){ return global.inv[$ "cursed"] ?? ""; }
function curse_active(){ return curse_item() != "" || (global.inv[$ "cursePending"] ?? false); }

/// @description True for what a curse can latch onto: tools and weapons.
function curse_can_take(_stack){
	return _stack != undefined && item_def(_stack.id).type == "held";
}

/// @description The witch's black shot lands: the held tool or weapon is cursed, or the next one you pick up.
function status_curse(){
	if(curse_item() != ""){ farm_message("The curse tightens its grip"); return; }
	var held = inv_held_stack();
	if(curse_can_take(held)) curse_apply(held.id);
	else {
		global.inv.cursePending = true;
		farm_message("Cursed! The next tool you pick up will be cursed");
	}
}

/// @description Curse an item: locked in your hand; a Mithril tool becomes the Cursed tier.
function curse_apply(_id){
	global.inv.cursed = _id;
	global.inv.cursePending = false;
	var d = item_def(_id), name = d.name;
	if(tool_upgradable(name) != "" && tool_tier(name) == TOOL_MITHRIL){
		global.inv.tools[$ name] = TOOL_CURSED;
		farm_message("Your " + string_lower(name) + " is cursed! It burns with a dark power...");
	}
	else farm_message("Your " + string_lower(name) + " is cursed! You can't let go of it");
}

/// @description The priest lifts the curse: a Cursed tool becomes Blessed, anything else goes back to normal.
/// Returns what happened, for the dialogue.
function curse_lift(){
	var id_ = curse_item();
	global.inv.cursePending = false;
	if(id_ == "") return "";
	global.inv.cursed = "";
	var name = item_def(id_).name;
	if(tool_upgradable(name) != "" && tool_tier(name) == TOOL_CURSED){
		global.inv.tools[$ name] = TOOL_BLESSED;
		return "Your " + string_lower(name) + " is Blessed!";
	}
	return "The curse on your " + string_lower(name) + " is lifted";
}

/// @description The cost of lifting the curse you carry: 5,000 to bless a Cursed tool, 1,000 for anything else.
function curse_lift_price(){
	var id_ = curse_item();
	if(id_ == "") return 0;
	var name = item_def(id_).name;
	return (tool_upgradable(name) != "" && tool_tier(name) == TOOL_CURSED) ? 5000 : 1000;
}

/// @description While cursed, may the hotbar move to slot _k? Onto the cursed item, or food to eat; nothing else.
/// A pending curse latches onto the tool or weapon you pick.
function curse_hotbar_ok(_k){
	var st = global.inv.slots[_k];
	if(global.inv[$ "cursePending"] ?? false){
		if(curse_can_take(st)) curse_apply(st.id);
		return true;
	}
	var c = curse_item();
	if(c == "") return true;
	if(st != undefined && st.id == c) return true;
	if(st != undefined){
		static food = ["food", "produce", "fish", "forage", "animalproduct"];
		if(array_get_index(food, item_def(st.id).type) != -1) return true;
	}
	farm_message("The curse won't let go of your " + string_lower(item_def(c).name));
	return false;
}

/// @description True if this stack is the cursed one (it can't be moved, sold or shipped).
function curse_locked(_stack){ return _stack != undefined && _stack.id == curse_item(); }

// ---------------------------------------------------------------- HUD

/// @description Poison and curse icons beside the bars (game's Draw GUI): a green drop with seconds left, a purple
/// mark for the curse.
function status_draw_hud(_x, _y){
	var c = ui_colours(), yy = _y;
	if(status_poisoned()){
		draw_set_colour(make_colour_rgb(30, 60, 30));
		draw_circle(_x, yy, 11, false);
		draw_set_colour(make_colour_rgb(110, 220, 90));
		draw_circle(_x, yy + 2, 6, false);
		draw_triangle(_x - 5, yy, _x + 5, yy, _x, yy - 9, false);
		ui_text(_x - 16, yy, "Poisoned " + string(ceil(global.vitals.poison)) + "s", 0.45, make_colour_rgb(110, 220, 90), fa_right);
		yy -= 28;
	}
	if(curse_active()){
		draw_set_colour(make_colour_rgb(40, 15, 55));
		draw_circle(_x, yy, 11, false);
		draw_set_colour(make_colour_rgb(170, 80, 230));
		draw_line_width(_x - 5, yy - 5, _x + 5, yy + 5, 2);
		draw_line_width(_x + 5, yy - 5, _x - 5, yy + 5, 2);
		var what = (curse_item() == "") ? "Cursed: your next tool" : "Cursed  -30% Defence";
		ui_text(_x - 16, yy, what, 0.45, make_colour_rgb(190, 120, 240), fa_right);
	}
}

// ---------------------------------------------------------------- Father Aldous

/// @description Talking to Father Aldous while cursed: he offers to lift it, for a price (curse_lift_price; a curse
/// still waiting for a tool, 500). Played as a dialogue event with a choice (obj_dialogue); onChoose pays and lifts.
function priest_offer(_npc){
	var c = curse_item(), price = (c == "") ? 500 : curse_lift_price();
	var what = (c == "") ? "a curse hanging over you, waiting for something to hold" : "a curse on your " + string_lower(item_def(c).name);
	var e = {id: "", who: "aldous", hearts: 0, room: "", hours: [0, 24],
	         lines: ["Ah. I can feel it from here - " + what + ".",
	                 (c != "" && tool_tier(item_def(c).name) == TOOL_CURSED) ? "That tool has drunk deep of the dark. Lifted, it will shine all the brighter - blessed." : "It can be lifted, with prayer and a gift to the temple fund."],
	         choice: {ask: "Lift the curse for " + string(price) + " gold?",
	                  options: [["\"Please, Father.\"", 0, "Kneel, child, and be still."], ["\"Not today.\"", 0, "Then may it not weigh on you too long."]]},
	         price: price};
	e.onChoose = method(e, function(_choice){
		if(_choice != 0) return "";
		if(!inv_is_free() && global.inv.gold < price) return "You need " + string(price) + " gold";
		if(!inv_is_free()) global.inv.gold -= price;
		var r = curse_lift();
		people_add("aldous", 30);
		return "Paid " + string(price) + " gold.  " + ((r == "") ? "The curse is gone" : r);
	});
	instance_create_depth(0, 0, -9000, obj_dialogue, {who: "aldous", npc: _npc, text: e.lines[0], note: "", event: e, line: 0, chosen: -1});
}
