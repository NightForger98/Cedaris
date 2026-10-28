/// People (roadmap phase 6): named villagers, friendship hearts, gifts, and what they say.
///
/// The villagers are fixed people: each has a look made from their own seed (the same every visit) and a home
/// room. The generic NPC objects placed in rooms take the next villager living there (villager_take), so the
/// village stays the same people. Brom and Mara are people too.
/// global.world.people = {<key>: {points, talked, gifted, rewarded}} - points 0-2500 (250 per heart, 10 hearts);
/// talked / gifted: the day index you last did it (once a day each); rewarded: the hearts already rewarded.
/// Talking: E near someone opens obj_dialogue (G gives what you're holding, T trades with shopkeepers).

#macro HEART_POINTS 250
#macro HEARTS_MAX 10

/// @description Who lives here. slot: which placed NPC object they take ("man" / "woman"; "" for Brom and Mara, who
/// have their own objects). loves / likes / dislikes / hates: item ids or id prefixes ("p|" = any produce).
/// lines: what they say at 0-1, 2-5 and 6+ hearts. rewards: a gift at 2, 4, 6, 8 and 10 hearts.
function villager_table(){
	static t = {
		brom:  {name: "Brom", title: "the Blacksmith", room: "rm_1", slot: "", shop: "smith",
		        loves: ["m|steel", "m|mithril", "f|fiery_chilli"], likes: ["m|iron", "m|copper", "m|gold", "m|coal", "f|"], dislikes: ["p|", "m|fibre"], hates: ["m|silk", "m|pixie_dust"],
		        lines: [["Need tools? Bring ore and I'll make 'em sing.", "Hot forge, cold ale. That's the life.", "Mind the sparks."],
		                ["You've got a good arm for the pickaxe. Seen the iron down past floor five?", "The furnace never sleeps. Neither do I, some nights.", "Bars, bring me bars. I'll make you something worth holding."],
		                ["You're the best customer I've had in years. Don't tell the others.", "My father forged by this same anvil. He'd have liked you.", "Whatever you need, friend. Whatever you need."]],
		        rewards: [["m|coal", 10], ["m|iron", 5], ["d|metal|bronze", 1], ["m|steel", 5], ["m|mithril", 1]]},
		mara:  {name: "Mara", title: "the Seed Seller", room: "rm_1", slot: "", shop: "seeds",
		        loves: ["p|gourd", "f|tomato_salad", "f|gourd_pie", "m|gem"], likes: ["p|", "f|"], dislikes: ["m|stone", "m|coal"], hates: ["m|bone", "m|troll_hide"],
		        lines: [["Seeds for the season, fresh as the morning!", "Plant before it rains and the crops will thank you.", "Water every day. Every day!"],
		                ["Your field's looking greener. I've noticed.", "Corn takes its time, but it gives and gives.", "Did you know gourds love the fall? Like me."],
		                ["Some mornings I just come to watch your crops come up. Is that strange?", "You've made this valley bloom, you know.", "I saved the best seeds for you. Don't tell anyone."]],
		        rewards: [["s|carrot", 10], ["d|cloth|green", 1], ["s|corn", 5], ["d|cloth|yellow", 1], ["m|unicorn_hair", 1]]},
		pip:   {name: "Pip", title: "the Farmhand", room: "rm_1", slot: "man", race: "Halfling", body: "teen", seed: 1101,
		        loves: ["p|carrot", "f|carrot_soup", "f|hash_browns"], likes: ["p|", "f|", "m|wood"], dislikes: ["m|stone"], hates: ["m|coal", "f|fiery_chilli"],
		        lines: [["Morning! Or is it still night? Hard to tell with all this work.", "Don't step on the carrots. I named them.", "I'm not lazy, I'm resting between chores."],
		                ["You till straighter rows than the last farmer. Much straighter.", "I found a four-leaf weed once. I ate it.", "If you see my hat, it's not lost. It's on an adventure."],
		                ["Best farm in the valley. I tell everyone.", "When I'm old I want a farm just like this one.", "Thanks for keeping me on. Really."]],
		        rewards: [["s|potato", 10], ["d|cloth|orange", 1], ["f|hash_browns", 3], ["d|cloth|brown", 1], ["m|gem", 3]]},
		rowan: {name: "Rowan", title: "the Fence-mender", room: "rm_1", slot: "woman", race: "Beastkin", body: "female", seed: 1202,
		        loves: ["m|wood", "m|iron", "f|veg_stew"], likes: ["m|", "f|"], dislikes: ["p|tomato"], hates: ["m|silk"],
		        lines: [["Fences don't fix themselves. Well, they do, if you're me.", "Something's been at the posts again. Big teeth.", "Wood's best cut in the morning."],
		                ["You chop a mean tree. Bring me the offcuts sometime.", "I hear things from the cave at night. Scratching.", "My ears never lie: rain tomorrow. Maybe."],
		                ["You're good company. Quiet when it counts.", "I made you a gate latch. Don't tell Pip, he'll want one.", "Whatever's down in that mine, you'll beat it."]],
		        rewards: [["m|wood", 30], ["d|cloth|walnut", 1], ["m|leather", 5], ["d|cloth|forest", 1], ["m|fur", 5]]},
		elda:  {name: "Elda", title: "the Herbalist", room: "rm_2", slot: "woman", race: "Elf", body: "female", seed: 2101,
		        loves: ["p|artichoke", "f|stuffed_artichoke", "m|frost_crystal", "m|pixie_dust", "w|toadstool"], likes: ["p|", "m|gem", "m|fibre", "w|"], dislikes: ["m|bone", "m|coal"], hates: ["m|ember_core", "f|fiery_chilli"],
		        lines: [["The river remembers every leaf it carries.", "Weeds are only plants nobody's asked about.", "Mind the mushrooms by the bridge. Not all are friendly."],
		                ["Your hands smell of soil. Good. Honest.", "There's frost deep in the mine that never melts. I'd love a piece.", "Magic grows like crops: slowly, then all at once."],
		                ["I've seen four hundred springs. This one's my favourite.", "You listen to the land. Few do.", "Take this - for the road, and the dark under it."]],
		        rewards: [["k|rain", 1], ["d|cloth|teal", 1], ["m|moonsilk", 1], ["d|cloth|lavender", 1], ["m|pixie_dust", 2]]},
		thorne:{name: "Thorne", title: "the Carpenter", room: "rm_2", slot: "man", race: "Orc", body: "male", seed: 2202, shop: "animals",
		        loves: ["m|wood", "m|iron", "f|hash_browns", "f|fiery_chilli"], likes: ["m|stone", "m|copper", "f|"], dislikes: ["p|tomato", "f|tomato_salad"], hates: ["m|silk", "m|feather"],
		        lines: [["Measure twice. Cut once. Shout if you miss.", "Good oak is getting hard to find.", "Mind your feet, there's nails everywhere."],
		                ["You've got calluses. I respect that.", "I'm building the village a new bridge. Need wood. Lots of it.", "Orcs don't smile. This is my smile."],
		                ["You and me, we build things that last.", "I carved this for you. It's a duck. Or a dog. It's art.", "If the village ever needs a hero, I'm voting you."]],
		        rewards: [["m|wood", 50], ["m|stone", 30], ["d|cloth|charcoal", 1], ["m|iron", 5], ["m|dragon_scale", 1]]},
		hesta: {name: "Aunt Hesta", title: "", room: "rm_12", slot: "woman", race: "Human", body: "female", seed: 3101,
		        loves: ["f|gourd_pie", "f|veg_stew", "p|gourd"], likes: ["f|", "p|"], dislikes: ["m|bone"], hates: ["m|troll_hide", "m|coal"],
		        lines: [["Wipe your boots! I just swept.", "Your grandmother kept this farm for forty years. Keep it well.", "Eat something. You look thin."],
		                ["The house smells of soup again. I like that.", "You've your grandmother's stubbornness. Good.", "Don't go too deep in that mine, dear."],
		                ["I'm proud of you. There, I said it.", "This old house feels young again with you in it.", "I knitted you something. Wear it in winter."]],
		        rewards: [["f|veg_stew", 2], ["d|cloth|rose", 1], ["m|wool", 6], ["d|cloth|maroon", 1], ["m|phoenix_feather", 1]]},
		tobin: {name: "Tobin", title: "your Cousin", room: "rm_12", slot: "man", race: "Human", body: "teen", seed: 3202,
		        loves: ["m|gem", "m|feather", "f|corn_fritters"], likes: ["m|bone", "f|", "p|corn"], dislikes: ["p|potato", "f|veg_stew"], hates: ["p|artichoke", "f|stuffed_artichoke"],
		        lines: [["Did you see a monster? A real one? What did it look like?", "Aunt Hesta says I can't go in the mine. Not fair.", "I'm going to be a knight. Or a baker."],
		                ["Can I hold your sword? Just for a second?", "I counted all the chickens. There aren't any. We need chickens.", "Bring me a feather! A big one!"],
		                ["You're the coolest cousin ever.", "When I grow up I'm going to dig to floor thirty. Like you.", "I made you a map of the house. It's mostly the kitchen."]],
		        rewards: [["m|feather", 5], ["d|cloth|sky", 1], ["m|gem", 1], ["d|cloth|red", 1], ["m|void_pearl", 1]]},
	};
	return t;
}

function villager_def(_key){ return villager_table()[$ _key]; }

/// @description A day number that only goes up (for once-a-day things).
function day_index(){ return (global.clock.year - 1) * 4 * SEASON_DAYS + global.clock.season * SEASON_DAYS + global.clock.day; }

/// @description A villager's friendship record (made on first use).
function people_state(_key){
	if(!is_struct(global.world[$ "people"])) global.world.people = {};
	var p = global.world.people[$ _key];
	if(!is_struct(p)){ p = {points: 0, talked: -1, gifted: -1, rewarded: 0}; global.world.people[$ _key] = p; }
	return p;
}

function people_hearts(_key){ return min(HEARTS_MAX, people_state(_key).points div HEART_POINTS); }

/// @description Charm makes friends faster: +3% per point, up to +60%.
function people_charm_bonus(){ return 1 + clamp(stat("charm") * 0.03, 0, 0.6); }

/// @description Add friendship (negative takes it away). Gains are boosted by Charm.
function people_add(_key, _points){
	var p = people_state(_key);
	if(_points > 0) _points *= people_charm_bonus();
	p.points = clamp(p.points + round(_points), 0, HEART_POINTS * HEARTS_MAX);
}

/// @description The villager's look: made from their own seed, so it's the same every time.
function villager_look(_key){
	var v = villager_def(_key);
	random_set_seed(v.seed);
	var look = character_random_look(v.race);
	character_set_body(look, v.body);
	// Everyday clothes: no masks, armour or things in hand; beards only on men
	static plain = ["face", "bauldron", "shoulders", "back", "held"];
	for(var i = 0; i < array_length(plain); i++){ look.parts[$ plain[i]].item = -1; look.parts[$ plain[i]].want = -1; }
	if(v.body != "male"){ look.parts.beard.item = -1; look.parts.beard.want = -1; }
	character_validate(look);
	randomize();
	return look;
}

/// @description For a placed NPC object (Create): the next villager of this slot living in this room who isn't
/// here yet, or "" (it stays a passing stranger).
function villager_take(_slot){
	var names = variable_struct_get_names(villager_table());
	array_sort(names, true);
	var here = room_get_name(room);
	for(var i = 0; i < array_length(names); i++){
		var v = villager_def(names[i]);
		if(v.room != here || v.slot != _slot) continue;
		var taken = false;
		with(obj_npc_parent) if(id != other.id && variable_instance_exists(id, "who") && who == names[i]) taken = true;
		if(!taken) return names[i];
	}
	return "";
}

/// @description What they say when you talk: a line for how well they know you, varying by day.
function villager_line(_key){
	var v = villager_def(_key);
	var h = people_hearts(_key);
	var tier = (h >= 6) ? 2 : ((h >= 2) ? 1 : 0);
	var lines = v.lines[tier];
	var line = lines[(day_index() + string_length(_key)) mod array_length(lines)];
	// Aunt Hesta always knows tomorrow's weather
	return (_key == "hesta") ? weather_forecast_line() + "  " + line : line;
}

/// @description Talking once a day: +20 friendship. Returns a heart reward message if they have one for you, or "".
function people_talk(_key){
	var p = people_state(_key);
	if(p.talked != day_index()){
		p.talked = day_index();
		people_add(_key, 20);
	}
	return people_reward(_key);
}

/// @description A gift for each 2 hearts reached (2, 4, 6, 8, 10), given the next time you talk. Returns the message.
function people_reward(_key){
	var p = people_state(_key), v = villager_def(_key);
	var due = people_hearts(_key) div 2;
	if(due <= p.rewarded) return "";
	var r = v.rewards[min(p.rewarded, array_length(v.rewards) - 1)];
	p.rewarded += 1;
	inv_add(item_stack(r[0], r[1]));
	return v.name + " gave you " + ((r[1] > 1) ? string(r[1]) + " " : "") + item_def(r[0]).name + "!";
}

/// @description How much they like an item: "love", "like", "dislike", "hate" or "neutral".
function people_taste(_key, _id){
	var v = villager_def(_key);
	static order = ["loves", "hates", "likes", "dislikes"];
	static words = ["love", "hate", "like", "dislike"];
	for(var i = 0; i < 4; i++){
		var list = v[$ order[i]];
		for(var k = 0; k < array_length(list); k++) if(string_pos(list[k], _id) == 1) return words[i];
	}
	return "neutral";
}

/// @description Give the held stack (one of it) as today's gift. Returns what they say back.
function people_gift(_key, _stack){
	var p = people_state(_key), v = villager_def(_key);
	if(p.gifted == day_index()) return "You've already given " + v.name + " something today.";
	var d = item_def(_stack.id);
	if(d.type == "held" || d.type == "clothing") return "You can't give that away.";
	var taste = people_taste(_key, _stack.id);
	var pts = 20, reply = "Thank you.";
	switch(taste){
		case "love":    pts = 80;  reply = "Oh! " + d.name + "! I love this!"; break;
		case "like":    pts = 45;  reply = "A " + string_lower(d.name) + "? That's lovely, thank you."; break;
		case "dislike": pts = -20; reply = "...Oh. A " + string_lower(d.name) + ". Thanks."; break;
		case "hate":    pts = -40; reply = "Ugh. Please don't give me that again."; break;
	}
	if(pts > 0 && d.type == "produce") pts += d.quality * 10; // better quality, happier friend
	p.gifted = day_index();
	people_add(_key, pts);
	_stack.count--;
	if(_stack.count <= 0) global.inv.slots[global.inv.hotbar] = undefined;
	return reply;
}

// ---------------------------------------------------------------- talking

/// @description E near a villager: open the dialogue box (talking counts once a day).
function people_open(_npc){
	if(instance_exists(obj_dialogue) || instance_exists(obj_inventory) || instance_exists(obj_menu)) return;
	var key = _npc.who;
	var reward = people_talk(key);
	instance_create_depth(0, 0, -9000, obj_dialogue, {who: key, npc: _npc, text: villager_line(key), note: reward});
}

/// @description T in Brom's or Mara's dialogue: their shop.
function people_trade(_key){
	var v = villager_def(_key);
	var inv = instance_create_depth(0, 0, -9000, obj_inventory);
	inv.shop = true;
	if(v.shop == "smith") inv.smith = true;
	if(v.shop == "animals"){
		inv.shopStock = animal_stock();
		inv.shopTitle = "Thorne's Livestock";
	}
	if(v.shop == "seeds"){
		inv.shopStock = item_seed_stock();
		inv.shopTitle = "Mara's Seeds - " + season_name(global.clock.season);
	}
}

/// @description True while a dialogue box is open (the world holds still).
function dialogue_open(){ return instance_exists(obj_dialogue); }

/// @description True while any window is up (inventory, dialogue, the notice board, the lift): the player and
/// monsters hold still, and Esc / I belong to the window.
function ui_blocking(){
	return instance_exists(obj_inventory) || dialogue_open() || mine_menu_open() || instance_exists(obj_fishing)
	       || (instance_exists(obj_quest_board) && obj_quest_board.open);
}
