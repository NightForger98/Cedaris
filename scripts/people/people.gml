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
		// Brindlemoor, the town up the cliff path north of the farm, and its shops (rm_town_*)
		lysa:  {name: "Lysa", title: "the Innkeeper", room: "rm_town_inn", slot: "woman", race: "Human", body: "female", seed: 4101, shop: "inn",
		        loves: ["f|veg_stew", "f|gourd_pie", "x|salmon"], likes: ["f|", "p|", "x|"], dislikes: ["m|bone", "m|coal"], hates: ["m|troll_hide"],
		        lines: [["Welcome to Brindlemoor! Mind the cobbles, they bite ankles.", "The inn's always got a pot on. Usually.", "Farmers come up the ladder with the best appetites."],
		                ["You again! The usual? We don't have a usual. We should.", "Garrick says the road west is all salt and gulls now.", "A traveller paid me in fish once. Best tip I ever had."],
		                ["You're practically family at this inn.", "I've kept a room for you, if you ever want to stay in town.", "Here - my grandmother's recipe. Don't tell a soul."]],
		        rewards: [["f|veg_stew", 2], ["d|cloth|rose", 1], ["m|wool", 6], ["d|cloth|teal", 1], ["m|gem", 2]]},
		garrick:{name: "Garrick", title: "the Watchman", room: "rm_town", slot: "man", race: "Dwarf", body: "male", seed: 4202,
		        loves: ["m|iron", "m|steel", "f|fiery_chilli"], likes: ["m|", "f|"], dislikes: ["p|artichoke"], hates: ["m|silk", "m|pixie_dust"],
		        lines: [["Halt! Oh. Just a farmer. Carry on.", "Nothing gets past me. Except pigeons.", "Quiet night. I like quiet nights."],
		                ["You walk like someone who's been down a mine. Respect.", "Saw lights over the sea again. Don't like it.", "Brom makes a fine blade. Tell him I said so. Don't."],
		                ["If trouble ever follows you up that ladder, I'll be waiting for it.", "You've earned the town's trust. Mine too.", "Take this. A watchman's spare. Keep it sharp."]],
		        rewards: [["m|iron", 5], ["d|cloth|charcoal", 1], ["m|coal", 10], ["d|cloth|maroon", 1], ["m|steel", 3]]},
		bryn:  {name: "Bryn", title: "the Outfitter", room: "rm_town_outfitter", slot: "man", race: "Beastkin", body: "male", seed: 4303, shop: "outfitter",
		        loves: ["m|leather", "m|fur", "m|silk", "m|moonsilk"], likes: ["m|wool", "m|fibre", "m|iron", "f|"], dislikes: ["w|toadstool"], hates: ["m|bone", "m|coal"],
		        lines: [["Boots, belts, britches. If it's worn, I sell it.", "Stand still, I'm guessing your size. Done.", "Garrick keeps asking for a cape. Watchmen don't need capes."],
		                ["You wear your clothes like you work in them. Good. That's what they're for.", "Leather from the valley, wool from the vale. Best in the north.", "Brom makes the swords. I make sure you look good holding one."],
		                ["I'd dress you for free if I could afford it. I can't. Sorry.", "You're the best-turned-out farmer I've ever met.", "I stitched this one with you in mind. Go on."]],
		        rewards: [["m|leather", 5], ["d|cloth|walnut", 1], ["m|silk", 3], ["d|cloth|navy", 1], ["m|moonsilk", 1]]},
		morga: {name: "Morga", title: "the Apothecary", room: "rm_town_apothecary", slot: "woman", race: "Orc", body: "female", seed: 4404, shop: "apothecary",
		        loves: ["w|toadstool", "m|pixie_dust", "m|frost_crystal", "f|forest_stew"], likes: ["w|", "m|gem", "x|", "f|"], dislikes: ["p|corn"], hates: ["f|fiery_chilli", "m|ember_core"],
		        lines: [["Don't touch the green jar. Or the blue one. Just - don't touch.", "Scrolls, staves, simples. Spells cost mana, my prices cost gold.", "Bring me toadstools. The ugly ones."],
		                ["You've a feel for magic, farmer. I can smell it on you. Also soil.", "Heal is the first spell anyone should learn. Fireball is the second.", "The forest across the river grows things even I can't name."],
		                ["You're my favourite customer. You actually read the labels.", "I brewed this for you. Don't ask what's in it.", "Magic is just patience with a staff. You have both."]],
		        rewards: [["w|herb", 5], ["d|cloth|lavender", 1], ["m|pixie_dust", 2], ["d|cloth|teal", 1], ["k|heal", 1]]},
		// Brindlemoor's townsfolk: Posy keeps a flower stall in the square; the rest live in the town's homes and spend
		// the day (9 am - 5 pm, see villager_room) out in the square
		posy:  {name: "Posy", title: "the Flower-seller", room: "rm_town", slot: "woman", race: "Halfling", body: "female", seed: 4505,
		        loves: ["w|herb", "m|pixie_dust", "f|gourd_pie"], likes: ["w|", "p|", "f|"], dislikes: ["m|stone"], hates: ["m|coal", "m|bone"],
		        lines: [["Flowers! Fresh flowers! Well. Fresh-ish.", "Everything I sell, I picked on the cliff path this morning.", "You've got soil under your nails. I like you already."],
		                ["Daisies for luck, roses for trouble. You look like a daisy person.", "Garrick pretends he doesn't like flowers. He buys one every week.", "The valley's full of herbs this time of year. Bring me some?"],
		                ["You make this town brighter, you know.", "I saved you the best bunch. Don't let it wilt.", "If I ever have a garden as big as your farm I'll never leave it."]],
		        rewards: [["w|herb", 4], ["d|cloth|rose", 1], ["m|fibre", 10], ["d|cloth|lavender", 1], ["m|pixie_dust", 2]]},
		edwin: {name: "Edwin", title: "the Scribe", room: "rm_town_home_nw", day: "rm_town", slot: "man", race: "Elf", body: "male", seed: 4606,
		        loves: ["m|silk", "m|gem", "f|moonfin_soup"], likes: ["m|", "x|", "f|"], dislikes: ["p|corn"], hates: ["m|troll_hide", "f|fiery_chilli"],
		        lines: [["Mind the ink. It's older than you.", "I copy the town's records. Births, deaths, the price of turnips.", "Quiet, please. I'm thinking in Elvish."],
		                ["Ah, the farmer. I wrote you down in the ledger. Favourably.", "Brindlemoor was a waystation once, before the ladder. I have the maps.", "Morga borrows my books and returns them smelling of toadstools."],
		                ["I've started a chapter about you. It's mostly about turnips.", "You're the most interesting thing to happen to this town in a century.", "Here. A page from my own collection. Treat it kindly."]],
		        rewards: [["m|fibre", 10], ["d|cloth|navy", 1], ["m|silk", 3], ["d|cloth|charcoal", 1], ["m|gem", 2]]},
		nell:  {name: "Nell", title: "the Weaver", room: "rm_town_home_e", day: "rm_town", slot: "woman", race: "Human", body: "female", seed: 4707,
		        loves: ["m|wool", "m|silk", "m|moonsilk", "f|carrot_soup"], likes: ["m|fibre", "m|", "f|"], dislikes: ["m|coal"], hates: ["m|bone", "m|ember_core"],
		        lines: [["Wool in, cloth out. That's the whole secret.", "Bryn sells what I weave. He takes the credit, too.", "My wheel's been going since before you were born."],
		                ["Bring me wool and I'll be your friend for life. Probably.", "That's a good stitch on your sleeve. Did you do it? No? Shame.", "The sheep in the vale make the softest fleece. Wren knows it."],
		                ["I wove this pattern after you. It's mostly green and stubborn.", "You've got a weaver's patience. Ever thought of trying?", "Take this. It's the best I've made all year."]],
		        rewards: [["m|wool", 8], ["d|cloth|teal", 1], ["m|silk", 3], ["d|cloth|maroon", 1], ["m|moonsilk", 2]]},
		hask:  {name: "Hask", title: "the Hunter", room: "rm_town_home_sw", day: "rm_town", slot: "man", race: "Human", body: "male", seed: 4808,
		        loves: ["m|fur", "m|leather", "f|veg_stew"], likes: ["m|bone", "m|", "f|"], dislikes: ["m|silk"], hates: ["m|pixie_dust", "w|toadstool"],
		        lines: [["Tracks in the valley again. Big ones.", "Don't bother me before the sun's up. Or after.", "The forest over the river's no place for a farmer."],
		                ["You've been in the mine? Then you know what it's like to be hunted.", "Wolves keep to the woods. Mostly.", "Garrick watches the gate. I watch the trees."],
		                ["You'd make a fair hunter, if you ever put down the hoe.", "I'd trust you at my back in the forest. That's rare.", "Here. Good hide, well cured. Make something warm."]],
		        rewards: [["m|leather", 5], ["d|cloth|walnut", 1], ["m|fur", 5], ["d|cloth|forest", 1], ["m|troll_hide", 1]]},
		ida:   {name: "Ida", title: "the Baker", room: "rm_town_home_se", day: "rm_town", slot: "woman", race: "Dwarf", body: "female", seed: 4909,
		        loves: ["p|corn", "f|corn_fritters", "f|gourd_pie"], likes: ["p|", "a|", "f|"], dislikes: ["m|stone"], hates: ["m|coal", "f|fiery_chilli"],
		        lines: [["Bread's up at dawn and so am I.", "Fen! Stop climbing the - oh, hello.", "Flour everywhere. Always. You get used to it."],
		                ["Lysa buys my loaves for the inn. Says they're the best in the north.", "Your corn makes a fine fritter. Bring me more.", "Fen talks about you all day. 'The farmer this, the farmer that.'"],
		                ["You're welcome at our table any night.", "I've baked you a loaf with your name on it. Literally. Look.", "Fen's drawn you a picture. It's on the wall. Next to the stove."]],
		        rewards: [["f|corn_fritters", 2], ["d|cloth|red", 1], ["p|corn", 6], ["d|cloth|rose", 1], ["f|gourd_pie", 2]]},
		fen:   {name: "Fen", title: "Ida's son", room: "rm_town_home_se", day: "rm_town", slot: "man", race: "Dwarf", body: "teen", seed: 5010,
		        loves: ["m|gem", "m|feather", "f|corn_fritters"], likes: ["m|bone", "x|", "f|"], dislikes: ["p|artichoke"], hates: ["f|veg_stew", "m|coal"],
		        lines: [["Are you the farmer? From down the ladder? Is it true you've got a cave?", "Mum says I can't go to the mine till I'm tall. Dwarves don't get tall!", "I found a shiny rock. It's probably a diamond."],
		                ["Tobin's my friend. We're going to be knights together.", "I climbed the town hall. Don't tell Garrick.", "Can you bring me a feather? For my hat?"],
		                ["When I grow up I'm going to have a farm. And a dragon.", "You're the best grown-up in Brindlemoor. Don't tell Mum.", "I made you this! It's a... it's a thing. It's for you."]],
		        rewards: [["m|feather", 4], ["d|cloth|sky", 1], ["m|gem", 1], ["d|cloth|green", 1], ["m|void_pearl", 1]]},
		// The Saltmere Coast, west of the farm
		marlo: {name: "Old Marlo", title: "the Fisher", room: "rm_beach", slot: "man", race: "Human", body: "male", seed: 5101,
		        loves: ["x|mooneel", "x|seabass", "f|grilled_perch"], likes: ["x|", "f|"], dislikes: ["p|potato"], hates: ["m|ember_core"],
		        lines: [["Fish don't care how early you got up. But it helps.", "Cast past the end of the pier. That's where the big ones sulk.", "Salt in the air, salt in the beard."],
		                ["You've got patience. The sea likes that.", "Eels come up at night when the moon's on the water.", "Crabs walk sideways 'cause they're shy. Like me."],
		                ["You're a better fisher than I was at your age. Don't let it go to your head.", "This old rod caught a whale. Well. A big sardine.", "The sea gives back to those who wait. Here."]],
		        rewards: [["x|sardine", 5], ["d|cloth|sky", 1], ["m|leather", 5], ["d|cloth|teal", 1], ["x|mooneel", 1]]},
		// Hollow Vale, through the woods south of the farm
		wren:  {name: "Wren", title: "the Shepherd", room: "rm_valley", slot: "woman", race: "Halfling", body: "teen", seed: 6101,
		        loves: ["m|wool", "w|herb", "f|carrot_soup"], likes: ["p|", "w|", "m|fibre"], dislikes: ["m|coal"], hates: ["m|bone", "m|troll_hide"],
		        lines: [["The vale's quiet. That's why I like it.", "My sheep wander off. I wander after them. It works.", "Herbs grow thick by the river. Help yourself."],
		                ["You came all the way down here again? You must like the view.", "The old willows by the bridge are older than the town.", "If you hear singing in the trees, don't follow it."],
		                ["You're always welcome at my hut, rain or shine.", "I spun this from the softest fleece I had. For you.", "The vale knows you now. It'll look after you."]],
		        rewards: [["m|wool", 8], ["d|cloth|green", 1], ["w|herb", 5], ["d|cloth|lavender", 1], ["m|unicorn_hair", 1]]},
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
	villager_dress(look);
	character_validate(look);
	randomize();
	return look;
}

/// @description What villagers wear day to day: a shirt, legs and shoes always (never bandages, armour or bare
/// hose), only everyday hats and coats, no gauntlets or bracers. need: never left empty; only: the allowed items
/// (anything else is swapped for one of them, or left off); never: items never worn; none: always left off.
function villager_wardrobe(){
	static w = {
		shirt:  {need: true, never: ["Bandages"]},
		pants:  {need: true, never: ["Armour", "Hose", "Pregnancy pants", "Legion skirt"]},
		shoes:  {need: true, never: ["Armour", "Hoofs"]},
		vest:   {never: ["Chainmail"]},
		coat:   {only: ["Collared coat", "Frock coat", "Iverness cloak", "Trench coat", "Tabard"]},
		hat:    {only: ["Bandana", "Bordered Bandana", "Bonnie", "Hood", "Kerchief", "Leather Cap", "Large Hat",
		                "Formal Bowler Hat", "Sack Cloth Hood", "Thick Headband", "Tied Headband", "Hijab"]},
		gloves: {none: true},
		wrist:  {none: true},
	};
	return w;
}

/// @description Swap anything in a random look that isn't everyday wear (see villager_wardrobe). Uses the random
/// state, so inside villager_look it stays the same for each villager's seed.
function villager_dress(_look){
	var w = villager_wardrobe();
	var keys = variable_struct_get_names(w);
	array_sort(keys, true); // the same order every time, so the seed gives the same clothes
	var items = lpc_catalog().items;
	for(var k = 0; k < array_length(keys); k++){
		var rule = w[$ keys[k]];
		var part = _look.parts[$ keys[k]];
		var only = variable_struct_exists(rule, "only") ? rule.only : [];
		var never = variable_struct_exists(rule, "never") ? rule.never : [];
		var need = variable_struct_exists(rule, "need");
		if(variable_struct_exists(rule, "none")){ part.item = -1; part.want = -1; continue; }
		// What this body and race can wear from the allowed list
		var opts = character_slot_options(character_slot_by_key(keys[k]), _look);
		var ok = [];
		for(var i = 0; i < array_length(opts); i++){
			var n = items[opts[i]].name;
			if(!character_item_fits(opts[i], _look.body)) continue; // walking art for this body, not just a tool swing
			if(array_length(only) > 0 && array_get_index(only, n) == -1) continue;
			if(array_get_index(never, n) != -1) continue;
			array_push(ok, opts[i]);
		}
		if(array_get_index(ok, part.item) != -1 || (part.item == -1 && !need)){ part.want = part.item; continue; }
		// Not everyday wear (or missing and needed): something that is, in one of its colours
		part.item = (array_length(ok) > 0 && (need || part.item != -1)) ? ok[irandom(array_length(ok) - 1)] : -1;
		part.want = part.item;
		var cols = character_palettes_for(keys[k], part.item, _look);
		var np = array_length(cols.pals);
		part.pal = (np > 0) ? cols.pals[irandom(np - 1)] : -1;
	}
}

/// @description Where a villager is right now: their home room, or for townsfolk with a "day" room, out there from
/// 9 am to 5 pm (homes stand empty by day, the square fills up).
function villager_room(_key){
	var v = villager_def(_key);
	var day = v[$ "day"];
	if(day != undefined && global.clock.minutes >= 540 && global.clock.minutes < 1020) return day;
	return v.room;
}

/// @description For a placed NPC object (Create): the next villager of this slot living in this room who isn't
/// here yet, or "" (it stays a passing stranger).
function villager_take(_slot){
	var names = variable_struct_get_names(villager_table());
	array_sort(names, true);
	var here = room_get_name(room);
	for(var i = 0; i < array_length(names); i++){
		var v = villager_def(names[i]);
		if(villager_room(names[i]) != here || v.slot != _slot) continue;
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
		people_add(_key, (festival_today() != undefined) ? 40 : 20); // double on festival days
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

/// @description T in a shopkeeper's dialogue: their shop.
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
	if(v.shop == "inn"){
		inv.shopStock = shop_inn_stock();
		inv.shopTitle = "The Brindle Inn - today's menu";
	}
	if(v.shop == "outfitter"){
		inv.shopStock = shop_outfitter_stock();
		inv.shopTitle = "Bryn's Outfitters";
	}
	if(v.shop == "apothecary"){
		inv.shopStock = shop_apothecary_stock();
		inv.shopTitle = "Morga's Apothecary";
	}
}

// ---------------------------------------------------------------- Brindlemoor's shops

/// @description The inn's menu: five of the dishes you can cook, a different five each day, at half again what they're worth.
/// Buying a meal is the quick way to a food buff before you can grow the ingredients.
function shop_inn_stock(){
	var t = dish_table(), out = [], n = array_length(t);
	for(var i = 0; i < min(5, n); i++){
		var d = t[(day_index() * 3 + i) mod n];
		array_push(out, {id: "f|" + d.key, price: round(dish_price(d) * 1.5)});
	}
	return out;
}

/// @description Bryn's clothes and armour: three common or uncommon pieces of each kind that come in your size,
/// spread through the catalogue (not three of the same hat), at twice what they're worth - making your own at the
/// crafting table is cheaper.
function shop_outfitter_stock(){
	static slots = ["hat", "shirt", "vest", "coat", "cape", "belt", "pants", "shoes", "gloves"];
	var per = 3, out = [], rs = item_recipes();
	for(var s = 0; s < array_length(slots); s++){
		var fit = [];
		for(var i = 0; i < array_length(rs); i++){
			var r = rs[i];
			if(r.slot == slots[s] && item_cost_tier(r.cost) <= 1 && inv_recipe_ok(r, global.look)) array_push(fit, r.id);
		}
		var n = array_length(fit);
		for(var k = 0; k < min(per, n); k++){
			var pick = fit[(k * n) div per];
			array_push(out, {id: pick, price: max(40, item_def(pick).price * 2)});
		}
	}
	return out;
}

/// @description Morga's shelves: the spells you'd otherwise find deep in the mine, staves to cast them, forage, tonics.
function shop_apothecary_stock(){
	static ids = [["k|heal", 700], ["k|fireball", 900], ["c|held|Simple staff", 140], ["c|held|Gnarled staff", 220],
	              ["w|herb", 0], ["w|mushroom", 0], ["w|toadstool", 0], ["m|pixie_dust", 0], ["f|forest_stew", 0], ["f|moonfin_soup", 0]];
	var out = [];
	// 0: what it's worth, and a bit more for the trouble of gathering it
	for(var i = 0; i < array_length(ids); i++) array_push(out, {id: ids[i][0], price: (ids[i][1] > 0) ? ids[i][1] : round(item_def(ids[i][0]).price * 1.5)});
	return out;
}

/// @description True while a dialogue box is open (the world holds still).
function dialogue_open(){ return instance_exists(obj_dialogue); }

/// @description True while any window is up (inventory, dialogue, the notice board, the lift): the player and
/// monsters hold still, and Esc / I belong to the window.
function ui_blocking(){
	return instance_exists(obj_inventory) || dialogue_open() || mine_menu_open() || instance_exists(obj_fishing)
	       || (instance_exists(obj_quest_board) && obj_quest_board.open);
}
