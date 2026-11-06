/// Heart events: short scenes with a villager you've become friends with, as in Stardew Valley. When you're near them
/// in the right place at the right hours with enough hearts, the scene plays by itself (obj_dialogue, event mode):
/// a few lines (E for the next), sometimes a choice at the end (1 or 2) that matters to them, sometimes a gift.
/// Each plays once a game: global.world.events = {<id>: true}.

/// @description The events. room: where you meet (they must be there too, on their schedule); hours: [from, to);
/// lines: what they say; choice: {ask, options: [[your words, friendship, their reply]...]}; gift: [item id, n].
function heart_event_table(){
	static t = [
		{id: "elda_2", who: "elda", hearts: 2, room: "rm_town_apothecary", hours: [10, 18],
		 lines: ["Shh. Listen.", "The river's telling the reeds about the spring flood - the one forty years back.",
		         "Most people walk past and hear water. You stopped."],
		 choice: {ask: "What do you say?", options: [["\"I hear it too. Tell me more.\"", 60, "Then sit. It's a long story, and the river tells it better than I do."],
		                                             ["\"It's just water, Elda.\"", -20, "...Of course. Just water."]]}},
		{id: "brom_4", who: "brom", hearts: 4, room: "rm_village_smithy", hours: [9, 17],
		 lines: ["See this hammer? My father's. His father's before him.", "The handle's been replaced six times. The head, never.",
		         "Here - I made a few bars too many this week. Don't tell anyone I'm soft."],
		 gift: ["m|steel", 2]},
		{id: "pip_2", who: "pip", hearts: 2, room: "rm_ovenswindow", hours: [7, 16],
		 lines: ["Have you seen a sheep? Small, grumpy, answers to Pudding?", "Wren's going to have my ears if I lose another one."],
		 choice: {ask: "Help Pip look?", options: [["\"Let's find her together.\"", 80, "There! In the reeds! Pudding, you menace. ...Thanks. I owe you one."],
		                                           ["\"Sorry, I'm busy.\"", 0, "Right. Course you are. Pudding! PUDDING!"]]}},
		{id: "tobin_2", who: "tobin", hearts: 2, room: "rm_sthereza", hours: [9, 12],
		 lines: ["Psst! I caught a monster!", "It's in my hat. Look. Carefully.", "...It's a frog. But it's a BIG frog."],
		 choice: {ask: "What do you think?", options: [["\"That's the bravest catch I've ever seen.\"", 60, "I KNEW it. I'm naming him Sir Croaks."],
		                                               ["\"It's just a frog, Tobin.\"", -10, "...He's a big frog."]]}},
		{id: "hesta_4", who: "hesta", hearts: 4, room: "rm_village_hesta", hours: [7, 21],
		 lines: ["Come in, come in. I found your grandmother's recipe book.", "Her vegetable stew. She'd make it every winter, and the whole valley came.",
		         "Take some. And take the book's secret: more pepper than you think."],
		 gift: ["f|veg_stew", 2]},
		{id: "thorne_4", who: "thorne", hearts: 4, room: "rm_victoryhill", hours: [7, 16],
		 lines: ["Don't laugh.", "I carve things. Small things. When the big work's done.", "This one's for you. It's a duck. Or a dog."],
		 choice: {ask: "What is it?", options: [["\"It's clearly a duck. It's wonderful.\"", 60, "...It was a dog. But I like duck better now."],
		                                        ["\"Is it... a potato?\"", 10, "Hah! Fair. Keep it anyway."]]}},
		{id: "marlo_2", who: "marlo", hearts: 2, room: "rm_whitesand", hours: [6, 12],
		 lines: ["Sea's quiet today. Good for thinking.", "Fifty years I've fished this pier. The secret? Patience.",
		         "And this lure. Don't tell the gulls."],
		 gift: ["x|perch", 3]},
		{id: "mara_6", who: "mara", hearts: 6, room: "rm_toolstore", hours: [9, 18],
		 lines: ["I've been saving these for someone who'd treat them right.", "Seeds from my mother's garden. Gourds the size of a cart wheel, she swore.",
		         "Plant them in fall. And come show me when they're ripe."],
		 gift: ["s|gourd", 5]},
		{id: "lysa_2", who: "lysa", hearts: 2, room: "rm_town_inn", hours: [17, 22],
		 lines: ["Busy night. Garrick's telling the bear story again - it gets bigger every year.", "You know, the valley was half empty before you came.",
		         "Now look at it. Sit, the first drink's on the house."],
		 choice: {ask: "Join them?", options: [["\"Only if Garrick tells the bear story.\"", 50, "Oh, he will. He always will."],
		                                       ["\"I should get back to the farm.\"", 10, "Another night, then."]]}},
		{id: "garrick_4", who: "garrick", hearts: 4, room: "rm_beaconhill", hours: [8, 18],
		 lines: ["Seen lights deep in Whispering Woods at night. Pinkish. Dancing.", "My grandmother called them pixies. Said they bless a farm that's kind to them.",
		         "Me, I just keep watch. But if you're out there at night... be kind."]},
	];
	static withCourting = array_concat(t, marriage_court_events());   // the courting events (scripts/marriage)
	return withCourting;
}

function heart_event_seen(_id){
	if(!is_struct(global.world[$ "events"])) global.world.events = {};
	return global.world.events[$ _id] ?? false;
}

/// @description Every so often (from the game's Step): start an event if one is due here and now. Only one at a time,
/// and never over a window or during a fade.
function heart_events_check(){
	if(!world_time_ready() || !instance_exists(obj_plyr) || ui_blocking() || instance_exists(obj_menu) || game.doTransition) return;
	var here = room_get_name(room), h = global.clock.minutes / 60, t = heart_event_table();
	for(var i = 0; i < array_length(t); i++){
		var e = t[i];
		if(world_alias(e.room) != here || h < e.hours[0] || h >= e.hours[1] || heart_event_seen(e.id) || people_hearts(e.who) < e.hearts) continue;
		var npc = noone;
		with(obj_villager) if(who == e.who && point_distance(x, y, obj_plyr.x, obj_plyr.y) < 220) npc = id;
		if(npc == noone) continue;
		global.world.events[$ e.id] = true;
		instance_create_depth(0, 0, -9000, obj_dialogue, {who: e.who, npc: npc, text: e.lines[0], note: "", event: e, line: 0, chosen: -1});
		return;
	}
}

/// @description The event's last step: friendship for being there, plus the choice's, and the gift. Returns a note.
function heart_event_finish(_e, _choice){
	if(variable_struct_exists(_e, "onChoose")) return _e.onChoose(_choice);   // not a heart event: a choice that does something (priest_offer)
	var pts = 40, note = "";
	if(_choice >= 0) pts += _e.choice.options[_choice][1];
	people_add(_e.who, pts);
	if(variable_struct_exists(_e, "gift")){
		inv_add(item_stack(_e.gift[0], _e.gift[1]));
		note = villager_def(_e.who).name + " gave you " + ((_e.gift[1] > 1) ? string(_e.gift[1]) + " " : "") + item_def(_e.gift[0]).name + "!";
	}
	return note;
}
