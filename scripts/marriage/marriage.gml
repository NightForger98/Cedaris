/// Marriage, after Harvest Moon: Friends of Mineral Town (design/world_plan.md). Sixteen villagers can be courted
/// (6 men, 10 women) by a farmer of the other gender (player_gender(), chosen in the story-mode creator). Courting is
/// friendship (talk and gifts every day); each candidate has four courting events, at 2, 4, 6 and 8 hearts
/// (marriage_court_events, added to heart_event_table). After a candidate's 8-heart event the Blue Feather
/// (m|blue_feather) is sold at the tool store. To propose, give it to them with all of this:
///   10 hearts, their four events seen, and the farmhouse's first upgrade (house plans from Rowan's furniture shop,
///   built overnight: marriage_new_day) - the kitchen and the big bed.
/// The wedding is the next morning at the old church in Abda's Ascent; from then on your spouse lives in the
/// farmhouse (villager_routine gives them home there) and keeps their job.
/// State in global.world: spouse (key or ""), weddingDay (day_index), house (farmhouse upgrades, 0-3).

/// @description Who can be courted.
function marriage_candidates(){
	static t = ["boh", "fen", "edwin", "garth", "bryn", "alaric",
	            "coralie", "liora", "clara", "nerissa", "tauriel", "zenya", "mira", "dikhaj", "sylva", "posy"];
	return t;
}

function marriage_is_candidate(_key){ return array_get_index(marriage_candidates(), _key) != -1; }

/// @description A villager's gender, from their body ("male" for boys and men, "female" for girls and women).
function villager_gender(_key){ return (villager_def(_key).body == "female") ? "female" : "male"; }

function marriage_spouse(){ return global.world[$ "spouse"] ?? ""; }

/// @description True once the wedding day has come.
function marriage_married(){ return marriage_spouse() != "" && (global.world[$ "weddingDay"] ?? 0) <= day_index(); }

/// @description Farmhouse upgrades done (1: kitchen and big bed, 2: rooms and a nursery, 3: cellar).
function house_level(){ return global.world[$ "house"] ?? 0; }

/// @description Whether you could court this villager at all.
function marriage_can_court(_key){
	return marriage_is_candidate(_key) && villager_gender(_key) != player_gender() && marriage_spouse() == "";
}

function marriage_events_seen(_key){
	static hearts = [2, 4, 6, 8];
	for(var i = 0; i < 4; i++) if(!heart_event_seen(_key + "_court_" + string(hearts[i]))) return false;
	return true;
}

/// @description The Blue Feather is in the tool store once any candidate you can court has had their 8-heart event.
function marriage_feather_for_sale(){
	if(marriage_spouse() != "") return false;
	var c = marriage_candidates();
	for(var i = 0; i < array_length(c); i++) if(marriage_can_court(c[i]) && heart_event_seen(c[i] + "_court_8")) return true;
	return false;
}

/// @description What's still missing before _key would say yes ("" when nothing is).
function marriage_missing(_key){
	if(!marriage_is_candidate(_key) || villager_gender(_key) == player_gender()) return "not_candidate";
	if(marriage_spouse() != "") return "married";
	if(people_hearts(_key) < 10) return "hearts";
	if(!marriage_events_seen(_key)) return "events";
	if(house_level() < 1) return "house";
	return "";
}

/// @description Give the Blue Feather to _key: the proposal. Returns their answer. The feather is used up on a yes.
function marriage_propose(_key, _stack){
	var v = villager_def(_key);
	switch(marriage_missing(_key)){
		case "not_candidate": return "A blue feather? It's beautiful... but I think it's meant for someone else.";
		case "married":       return "You're already spoken for, farmer!";
		case "hearts":        return "...Oh. I like you, I really do. But I'm not ready for this. Not yet.";
		case "events":        return "We hardly know each other yet. Give it time.";
		case "house":         return "Yes - I mean - where would we live? That farmhouse barely fits you. Ask Rowan about a bigger one.";
	}
	global.world.spouse = _key;
	global.world.weddingDay = day_index() + 1;
	people_add(_key, 200);
	_stack.count--;
	if(_stack.count <= 0) global.inv.slots[global.inv.hotbar] = undefined;
	return "Yes! Yes, of course! ...Tomorrow, at the old church in Abda's Ascent. I'll tell Father Aldous. " + v.name + " is beaming.";
}

/// @description Each candidate's four courting events, made from their day (where they work, or their first stop)
/// and their own words. Placeholders until each gets written scenes.
function marriage_court_events(){
	var out = [], c = marriage_candidates();
	for(var i = 0; i < array_length(c); i++){
		var k = c[i], v = villager_def(k), rt = villager_routines();
		var r = rt[$ k];
		var rm = "", hours = [9, 17];
		if(r[$ "work"] != undefined){
			rm = string_copy(r.work.at, 1, string_pos(".", r.work.at) - 1);
			hours = [r.work.open, r.work.close];
		} else {
			var st = r.routine[0], nx = (array_length(r.routine) > 1) ? r.routine[1][0] : st[0] + 3;
			rm = string_copy(st[1], 1, string_pos(".", st[1]) - 1);
			hours = [st[0] + 0.5, nx];
		}
		var name = v.name;
		array_push(out,
			{id: k + "_court_2", who: k, hearts: 2, room: rm, hours: hours,
			 lines: ["Oh - it's you. I was hoping you'd come by.", v.lines[1][0], "...Anyway. Thanks for stopping."]},
			{id: k + "_court_4", who: k, hearts: 4, room: rm, hours: hours,
			 lines: ["Can I tell you something? I don't say it to many people.", v.lines[1][2], "It's easier, talking to you."],
			 choice: {ask: "What do you say?", options: [["\"I'm always glad to listen.\"", 60, "...Thank you. Really."],
			                                             ["\"Sorry, I'm in a hurry.\"", -30, "Oh. Of course."]]}},
			{id: k + "_court_6", who: k, hearts: 6, room: rm, hours: hours,
			 lines: ["You keep turning up when I most want you to.", v.lines[2][1], "Is that a coincidence? I hope not."]},
			{id: k + "_court_8", who: k, hearts: 8, room: rm, hours: hours,
			 lines: ["I've been thinking about us. A lot.", v.lines[2][2], "If you ever wanted to... no. Never mind. Not yet."],
			 choice: {ask: "What do you say?", options: [["\"I've been thinking about us too.\"", 80, "...Really? Then I'll be waiting. They sell blue feathers at the tool store, you know."],
			                                             ["\"We're good friends.\"", 0, "...Yes. Good friends. Of course."]]}}
		);
	}
	return out;
}

/// @description New-day part: house plans in your bag get built overnight (Rowan's crew), and the wedding.
/// Returns a note for the morning ("" if nothing happened).
function marriage_new_day(){
	var note = "";
	if(inv_count("m|house_plans") > 0 && house_level() < 3){
		inv_take("m|house_plans", 1);
		global.world.house = house_level() + 1;
		if(house_level() == 1) note = "Rowan's crew built your new kitchen and a big bed overnight!";
		else if(house_level() == 2) note = "Rowan's crew added new rooms and a nursery overnight!";
		else note = "Rowan's crew dug out a cellar overnight!";
	}
	if(marriage_spouse() != "" && (global.world[$ "weddingDay"] ?? 0) == day_index()){
		note += ((note != "") ? " " : "") + "Today you married " + villager_def(marriage_spouse()).name + " at the old church. They're moving into the farmhouse.";
	}
	return note;
}

/// @description Rowan's furniture shop: the next house upgrade's plans (built overnight).
function shop_furniture_stock(){
	var out = shop_list([["m|wood", 0], ["m|stone", 0]]);
	static prices = [10000, 50000, 100000];
	if(house_level() < 3 && inv_count("m|house_plans") == 0) array_push(out, {id: "m|house_plans", price: prices[house_level()]});
	return out;
}

/// @description The tool store: tools and sprinklers, and the Blue Feather once someone's ready for it.
function shop_tools_stock(){
	var out = shop_list([["o|sprinkler", 0], ["c|held|Axe", 400], ["c|held|Pickaxe", 400], ["c|held|Scythe", 300], ["m|fibre", 0], ["m|stone", 0]]);
	if(marriage_feather_for_sale()) array_push(out, {id: "m|blue_feather", price: 1000});
	return out;
}

/// @description Test: mark all of _key's courting events seen.
function autotest_court_events(_key){
	if(!is_struct(global.world[$ "events"])) global.world.events = {};
	static hearts = [2, 4, 6, 8];
	for(var i = 0; i < 4; i++) global.world.events[$ _key + "_court_" + string(hearts[i])] = true;
	return "seen";
}

/// @description Test: propose to _key with a Blue Feather (as giving it would). Returns their answer.
function autotest_propose(_key){
	var s = item_stack("m|blue_feather", 1);
	return marriage_propose(_key, s) + " | spouse " + marriage_spouse() + " | missing " + marriage_missing(_key);
}

/// @description Test: set the farmhouse's upgrades.
function autotest_house(_n){ global.world.house = real(_n); return "house " + string(house_level()); }

/// @description Test: who's married and where the spouse lives now.
function autotest_spouse(){
	var s = marriage_spouse();
	if(s == "") return "single";
	return s + (marriage_married() ? " married, home " + villager_routine(s).home : " engaged");
}

/// @description Test: buy (be given) the next house plans and sleep on them. Returns the farmhouse's upgrades.
function autotest_house_plans(){
	inv_add(item_stack("m|house_plans", 1));
	marriage_new_day();
	return "house " + string(house_level());
}

/// @description Test: the next morning (the new-day event, without the fade). Returns the morning's marriage note.
function autotest_next_day(){
	day_advance(false);
	return "day " + string(day_index()) + " " + (global.world[$ "morningNote"] ?? "");
}

/// @description Test: how many courting events there are (16 candidates x 4).
function autotest_court_event_count(){
	var t = heart_event_table(), n = 0;
	for(var i = 0; i < array_length(t); i++) if(string_pos("_court_", t[i].id) > 0) n++;
	return string(n);
}
