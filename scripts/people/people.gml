/// People (roadmap phase 6): named villagers, friendship hearts, gifts, and what they say.
///
/// The villagers are fixed people: each has a look made from their own seed (the same every visit; Brom and Mara
/// are dressed by hand), a home and a day (see the schedules script: where they are is an obj_villager, made
/// when they're in the room you're in).
/// global.world.people = {<key>: {points, talked, gifted, rewarded}} - points 0-2500 (250 per heart, 10 hearts);
/// talked / gifted: the day index you last did it (once a day each); rewarded: the hearts already rewarded.
/// Talking: E near someone opens obj_dialogue (G gives what you're holding, T trades with shopkeepers).

#macro HEART_POINTS 250
#macro HEARTS_MAX 10

/// @description Who lives here (where they live and work: villager_routines). shop: what T in their dialogue sells.
/// look: a hand-made look (villager_look_<name>) instead of one from race, body and seed.
/// loves / likes / dislikes / hates: item ids or id prefixes ("p|" = any produce).
/// lines: what they say at 0-1, 2-5 and 6+ hearts. rewards: a gift at 2, 4, 6, 8 and 10 hearts.
function villager_table(){
	static t = {
		brom:  {name: "Brom", title: "the Blacksmith", shop: "smith", look: "brom",
		        loves: ["m|steel", "m|mithril", "f|fiery_chilli"], likes: ["m|iron", "m|copper", "m|gold", "m|coal", "f|"], dislikes: ["p|", "m|fibre"], hates: ["m|silk", "m|pixie_dust"],
		        lines: [["Need tools? Bring ore and I'll make 'em sing.", "Hot forge, cold ale. That's the life.", "Mind the sparks."],
		                ["You've got a good arm for the pickaxe. Seen the iron down past floor five?", "The furnace never sleeps. Neither do I, some nights.", "Bars, bring me bars. I'll make you something worth holding."],
		                ["You're the best customer I've had in years. Don't tell the others.", "My father forged by this same anvil. He'd have liked you.", "Whatever you need, friend. Whatever you need."]],
		        rewards: [["m|coal", 10], ["m|iron", 5], ["d|metal|bronze", 1], ["m|steel", 5], ["m|mithril", 1]]},
		mara:  {name: "Mara Whitlow", title: "of the Tool Store", shop: "tools", look: "mara",
		        loves: ["p|gourd", "f|tomato_salad", "f|gourd_pie", "m|gem"], likes: ["p|", "f|"], dislikes: ["m|stone", "m|coal"], hates: ["m|bone", "m|troll_hide"],
		        lines: [["Seeds for the season, fresh as the morning!", "Plant before it rains and the crops will thank you.", "Water every day. Every day!"],
		                ["Your field's looking greener. I've noticed.", "Corn takes its time, but it gives and gives.", "Did you know gourds love the fall? Like me."],
		                ["Some mornings I just come to watch your crops come up. Is that strange?", "You've made this valley bloom, you know.", "I saved the best seeds for you. Don't tell anyone."]],
		        rewards: [["s|carrot", 10], ["d|cloth|green", 1], ["s|corn", 5], ["d|cloth|yellow", 1], ["m|unicorn_hair", 1]]},
		pip:   {name: "Pip", title: "the Ranch Hand", race: "Halfling", body: "teen", seed: 1101,
		        loves: ["p|carrot", "f|carrot_soup", "f|hash_browns"], likes: ["p|", "f|", "m|wood"], dislikes: ["m|stone"], hates: ["m|coal", "f|fiery_chilli"],
		        lines: [["Morning! Or is it still night? Hard to tell with all this work.", "Wren's sheep know my name. I don't know theirs.", "I'm not lazy, I'm resting between chores."],
		                ["You till straighter rows than the last farmer. Much straighter.", "I found a four-leaf weed once. I ate it.", "If you see my hat, it's not lost. It's on an adventure."],
		                ["Best farm in the valley. I tell everyone.", "When I'm old I want a farm just like this one.", "Thanks for stopping by the ranch. Really."]],
		        rewards: [["s|potato", 10], ["d|cloth|orange", 1], ["f|hash_browns", 3], ["d|cloth|brown", 1], ["m|gem", 3]]},
		rowan: {name: "Rowan", title: "the Furniture-maker", race: "Beastkin", body: "female", seed: 1202, shop: "furniture",
		        loves: ["m|wood", "m|iron", "f|veg_stew"], likes: ["m|", "f|"], dislikes: ["p|tomato"], hates: ["m|silk"],
		        lines: [["Fences don't fix themselves. Well, they do, if you're me.", "Something's been at the posts again. Big teeth.", "Wood's best cut in the morning."],
		                ["You chop a mean tree. Bring me the offcuts sometime.", "I hear things from the cave at night. Scratching.", "My ears never lie: rain tomorrow. Maybe."],
		                ["You're good company. Quiet when it counts.", "I made you a gate latch. Don't tell Pip, he'll want one.", "Whatever's down in that mine, you'll beat it."]],
		        rewards: [["m|wood", 30], ["d|cloth|walnut", 1], ["m|leather", 5], ["d|cloth|forest", 1], ["m|fur", 5]]},
		elda:  {name: "Elda", title: "the Potion-seller", race: "Elf", body: "female", seed: 2101, shop: "apothecary",
		        loves: ["p|artichoke", "f|stuffed_artichoke", "m|frost_crystal", "m|pixie_dust", "w|toadstool"], likes: ["p|", "m|gem", "m|fibre", "w|"], dislikes: ["m|bone", "m|coal"], hates: ["m|ember_core", "f|fiery_chilli"],
		        lines: [["The river remembers every leaf it carries.", "Weeds are only plants nobody's asked about.", "Mind the mushrooms by the bridge. Not all are friendly."],
		                ["Your hands smell of soil. Good. Honest.", "There's frost deep in the mine that never melts. I'd love a piece.", "Magic grows like crops: slowly, then all at once."],
		                ["I've seen four hundred springs. This one's my favourite.", "You listen to the land. Few do.", "Take this - for the road, and the dark under it."]],
		        rewards: [["k|rain", 1], ["d|cloth|teal", 1], ["m|moonsilk", 1], ["d|cloth|lavender", 1], ["m|pixie_dust", 2]]},
		thorne:{name: "Thorne", title: "the Lumberjack", race: "Orc", body: "male", seed: 2202,
		        loves: ["m|wood", "m|iron", "f|hash_browns", "f|fiery_chilli"], likes: ["m|stone", "m|copper", "f|"], dislikes: ["p|tomato", "f|tomato_salad"], hates: ["m|silk", "m|feather"],
		        lines: [["Measure twice. Cut once. Shout if you miss.", "Good oak is getting hard to find.", "Mind your feet, there's nails everywhere."],
		                ["You've got calluses. I respect that.", "The footbridge over the river on the Mountain wants mending. Need wood. Lots of it.", "Orcs don't smile. This is my smile."],
		                ["You and me, we build things that last.", "I carved this for you. It's a duck. Or a dog. It's art.", "If the town ever needs a hero, I'm voting you."]],
		        rewards: [["m|wood", 50], ["m|stone", 30], ["d|cloth|charcoal", 1], ["m|iron", 5], ["m|dragon_scale", 1]]},
		hesta: {name: "Aunt Hesta", title: "", race: "Human", body: "female", seed: 3101,
		        loves: ["f|gourd_pie", "f|veg_stew", "p|gourd"], likes: ["f|", "p|"], dislikes: ["m|bone"], hates: ["m|troll_hide", "m|coal"],
		        lines: [["Wipe your boots! I just swept.", "Your grandmother kept this farm for forty years. Keep it well.", "Eat something. You look thin."],
		                ["The house smells of soup again. I like that.", "You've your grandmother's stubbornness. Good.", "Don't go too deep in that mine, dear."],
		                ["I'm proud of you. There, I said it.", "The old farm feels young again with you on it.", "I knitted you something. Wear it in winter."]],
		        rewards: [["f|veg_stew", 2], ["d|cloth|rose", 1], ["m|wool", 6], ["d|cloth|maroon", 1], ["m|phoenix_feather", 1]]},
		tobin: {name: "Tobin", title: "your Cousin", race: "Human", body: "teen", seed: 3202,
		        loves: ["m|gem", "m|feather", "f|corn_fritters"], likes: ["m|bone", "f|", "p|corn"], dislikes: ["p|potato", "f|veg_stew"], hates: ["p|artichoke", "f|stuffed_artichoke"],
		        lines: [["Did you see a monster? A real one? What did it look like?", "Aunt Hesta says I can't go in the mine. Not fair.", "I'm going to be a knight. Or a baker."],
		                ["Can I hold your sword? Just for a second?", "I counted all the chickens. There aren't any. We need chickens.", "Bring me a feather! A big one!"],
		                ["You're the coolest cousin ever.", "When I grow up I'm going to dig to floor thirty. Like you.", "I made you a map of the house. It's mostly the kitchen."]],
		        rewards: [["m|feather", 5], ["d|cloth|sky", 1], ["m|gem", 1], ["d|cloth|red", 1], ["m|void_pearl", 1]]},
		// Brindlemoor, the town up the cliff path north of the farm, and its shops (rm_town_*)
		lysa:  {name: "Lysa", title: "the Innkeeper", race: "Human", body: "female", seed: 4101, shop: "inn",
		        loves: ["f|veg_stew", "f|gourd_pie", "x|salmon"], likes: ["f|", "p|", "x|"], dislikes: ["m|bone", "m|coal"], hates: ["m|troll_hide"],
		        lines: [["Welcome to the Tavern! Mind the step, it bites ankles.", "The inn's always got a pot on. Usually.", "Farmers come up the ladder with the best appetites."],
		                ["You again! The usual? We don't have a usual. We should.", "Garrick says the road west is all salt and gulls now.", "A traveller paid me in fish once. Best tip I ever had."],
		                ["You're practically family at this inn.", "I've kept a room for you, if you ever want to stay in town.", "Here - my grandmother's recipe. Don't tell a soul."]],
		        rewards: [["f|veg_stew", 2], ["d|cloth|rose", 1], ["m|wool", 6], ["d|cloth|teal", 1], ["m|gem", 2]]},
		garrick:{name: "Garrick", title: "the Miner", race: "Dwarf", body: "male", seed: 4202,
		        loves: ["m|iron", "m|steel", "f|fiery_chilli"], likes: ["m|", "f|"], dislikes: ["p|artichoke"], hates: ["m|silk", "m|pixie_dust"],
		        lines: [["Halt! Oh. Just a farmer. Carry on.", "Nothing gets past me. Except pigeons.", "Quiet night. I like quiet nights."],
		                ["You walk like someone who's been down a mine. Respect.", "Saw lights over the sea again. Don't like it.", "Brom makes a fine blade. Tell him I said so. Don't."],
		                ["If trouble ever follows you up that ladder, I'll be waiting for it.", "You've earned the town's trust. Mine too.", "Take this. A watchman's spare. Keep it sharp."]],
		        rewards: [["m|iron", 5], ["d|cloth|charcoal", 1], ["m|coal", 10], ["d|cloth|maroon", 1], ["m|steel", 3]]},
		bryn:  {name: "Bryn", title: "the Leatherworker", race: "Beastkin", body: "male", seed: 4303,
		        loves: ["m|leather", "m|fur", "m|silk", "m|moonsilk"], likes: ["m|wool", "m|fibre", "m|iron", "f|"], dislikes: ["w|toadstool"], hates: ["m|bone", "m|coal"],
		        lines: [["Boots, belts, britches. If it's worn, I sell it.", "Stand still, I'm guessing your size. Done.", "Garrick keeps asking for a cape. Watchmen don't need capes."],
		                ["You wear your clothes like you work in them. Good. That's what they're for.", "Leather from the woods, wool from Meadowlark Farm. Best in Dahya.", "Brom makes the swords. I make sure you look good holding one."],
		                ["I'd dress you for free if I could afford it. I can't. Sorry.", "You're the best-turned-out farmer I've ever met.", "I stitched this one with you in mind. Go on."]],
		        rewards: [["m|leather", 5], ["d|cloth|walnut", 1], ["m|silk", 3], ["d|cloth|navy", 1], ["m|moonsilk", 1]]},
		morga: {name: "Morga", title: "the Witch", race: "Orc", body: "female", seed: 4404,
		        loves: ["w|toadstool", "m|pixie_dust", "m|frost_crystal", "f|forest_stew"], likes: ["w|", "m|gem", "x|", "f|"], dislikes: ["p|corn"], hates: ["f|fiery_chilli", "m|ember_core"],
		        lines: [["Don't touch the green jar. Or the blue one. Just - don't touch.", "Scrolls, staves, simples. Spells cost mana, my prices cost gold.", "Bring me toadstools. The ugly ones."],
		                ["You've a feel for magic, farmer. I can smell it on you. Also soil.", "Heal is the first spell anyone should learn. Fireball is the second.", "The forest across the river grows things even I can't name."],
		                ["You're my favourite customer. You actually read the labels.", "I brewed this for you. Don't ask what's in it.", "Magic is just patience with a staff. You have both."]],
		        rewards: [["w|herb", 5], ["d|cloth|lavender", 1], ["m|pixie_dust", 2], ["d|cloth|teal", 1], ["k|heal", 1]]},
		// Brindlemoor's townsfolk: Posy keeps a flower stall in the square, Edwin, Nell, Hask, Ida and Fen live in the
		// town's homes
		posy:  {name: "Posy", title: "the Flower-seller", race: "Halfling", body: "female", seed: 4505, shop: "flowers",
		        loves: ["w|herb", "m|pixie_dust", "f|gourd_pie"], likes: ["w|", "p|", "f|"], dislikes: ["m|stone"], hates: ["m|coal", "m|bone"],
		        lines: [["Flowers! Fresh flowers! Well. Fresh-ish.", "Everything I sell, I picked on the cliff path this morning.", "You've got soil under your nails. I like you already."],
		                ["Daisies for luck, roses for trouble. You look like a daisy person.", "Garrick pretends he doesn't like flowers. He buys one every week.", "The valley's full of herbs this time of year. Bring me some?"],
		                ["You make this town brighter, you know.", "I saved you the best bunch. Don't let it wilt.", "If I ever have a garden as big as your farm I'll never leave it."]],
		        rewards: [["w|herb", 4], ["d|cloth|rose", 1], ["m|fibre", 10], ["d|cloth|lavender", 1], ["m|pixie_dust", 2]]},
		edwin: {name: "Edwin", title: "the Librarian", race: "Elf", body: "male", seed: 4606,
		        loves: ["m|silk", "m|gem", "f|moonfin_soup"], likes: ["m|", "x|", "f|"], dislikes: ["p|corn"], hates: ["m|troll_hide", "f|fiery_chilli"],
		        lines: [["Mind the ink. It's older than you.", "I copy the town's records. Births, deaths, the price of turnips.", "Quiet, please. I'm thinking in Elvish."],
		                ["Ah, the farmer. I wrote you down in the ledger. Favourably.", "Downtown was a waystation once, before the port. I have the maps.", "Morga borrows my books and returns them smelling of toadstools."],
		                ["I've started a chapter about you. It's mostly about turnips.", "You're the most interesting thing to happen to this town in a century.", "Here. A page from my own collection. Treat it kindly."]],
		        rewards: [["m|fibre", 10], ["d|cloth|navy", 1], ["m|silk", 3], ["d|cloth|charcoal", 1], ["m|gem", 2]]},
		nell:  {name: "Nell", title: "the Clothier", race: "Human", body: "female", seed: 4707, shop: "outfitter",
		        loves: ["m|wool", "m|silk", "m|moonsilk", "f|carrot_soup"], likes: ["m|fibre", "m|", "f|"], dislikes: ["m|coal"], hates: ["m|bone", "m|ember_core"],
		        lines: [["Wool in, cloth out. That's the whole secret.", "Bryn sells what I weave. He takes the credit, too.", "My wheel's been going since before you were born."],
		                ["Bring me wool and I'll be your friend for life. Probably.", "That's a good stitch on your sleeve. Did you do it? No? Shame.", "Poupry's sheep make the softest fleece. Wren knows it."],
		                ["I wove this pattern after you. It's mostly green and stubborn.", "You've got a weaver's patience. Ever thought of trying?", "Take this. It's the best I've made all year."]],
		        rewards: [["m|wool", 8], ["d|cloth|teal", 1], ["m|silk", 3], ["d|cloth|maroon", 1], ["m|moonsilk", 2]]},
		hask:  {name: "Hask", title: "the Huntsman", race: "Elf", body: "male", seed: 4808, shop: "guild_ranged",
		        loves: ["m|fur", "m|leather", "f|veg_stew"], likes: ["m|bone", "m|", "f|"], dislikes: ["m|silk"], hates: ["m|pixie_dust", "w|toadstool"],
		        lines: [["Tracks in the valley again. Big ones.", "Don't bother me before the sun's up. Or after.", "The forest over the river's no place for a farmer."],
		                ["You've been in the mine? Then you know what it's like to be hunted.", "Wolves keep to the woods. Mostly.", "Garrick watches the gate. I watch the trees."],
		                ["You'd make a fair hunter, if you ever put down the hoe.", "I'd trust you at my back in the forest. That's rare.", "Here. Good hide, well cured. Make something warm."]],
		        rewards: [["m|leather", 5], ["d|cloth|walnut", 1], ["m|fur", 5], ["d|cloth|forest", 1], ["m|troll_hide", 1]]},
		ida:   {name: "Ida", title: "of the Tavern", race: "Dwarf", body: "female", seed: 4909,
		        loves: ["p|corn", "f|corn_fritters", "f|gourd_pie"], likes: ["p|", "a|", "f|"], dislikes: ["m|stone"], hates: ["m|coal", "f|fiery_chilli"],
		        lines: [["Bread's up at dawn and so am I.", "Fen! Stop climbing the - oh, hello.", "Flour everywhere. Always. You get used to it."],
		                ["Lysa buys my loaves for the inn. Says they're the best in the north.", "Your corn makes a fine fritter. Bring me more.", "Fen talks about you all day. 'The farmer this, the farmer that.'"],
		                ["You're welcome at our table any night.", "I've baked you a loaf with your name on it. Literally. Look.", "Fen's drawn you a picture. It's on the wall. Next to the stove."]],
		        rewards: [["f|corn_fritters", 2], ["d|cloth|red", 1], ["p|corn", 6], ["d|cloth|rose", 1], ["f|gourd_pie", 2]]},
		fen:   {name: "Fen", title: "the Explosives Seller", race: "Dwarf", body: "male", seed: 5010, shop: "explosives",
		        loves: ["m|gem", "m|feather", "f|corn_fritters"], likes: ["m|bone", "x|", "f|"], dislikes: ["p|artichoke"], hates: ["f|veg_stew", "m|coal"],
		        lines: [["Are you the farmer? From down the ladder? Is it true you've got a cave?", "Mum says I can't go to the mine till I'm tall. Dwarves don't get tall!", "I found a shiny rock. It's probably a diamond."],
		                ["Tobin's my friend. We're going to be knights together.", "I climbed the town hall. Don't tell Garrick.", "Can you bring me a feather? For my hat?"],
		                ["When I grow up I'm going to have a farm. And a dragon.", "Best customer this stall's ever had. Don't tell Mum.", "I made you this! It's a... it's a thing. It's for you."]],
		        rewards: [["m|feather", 4], ["d|cloth|sky", 1], ["m|gem", 1], ["d|cloth|green", 1], ["m|void_pearl", 1]]},
		// The Saltmere Coast, west of the farm
		marlo: {name: "Old Marlo", title: "the Fisher", race: "Human", body: "male", seed: 5101, shop: "fish",
		        loves: ["x|mooneel", "x|seabass", "f|grilled_perch"], likes: ["x|", "f|"], dislikes: ["p|potato"], hates: ["m|ember_core"],
		        lines: [["Fish don't care how early you got up. But it helps.", "Cast past the end of the pier. That's where the big ones sulk.", "Salt in the air, salt in the beard."],
		                ["You've got patience. The sea likes that.", "Eels come up at night when the moon's on the water.", "Crabs walk sideways 'cause they're shy. Like me."],
		                ["You're a better fisher than I was at your age. Don't let it go to your head.", "This old rod caught a whale. Well. A big sardine.", "The sea gives back to those who wait. Here."]],
		        rewards: [["x|sardine", 5], ["d|cloth|sky", 1], ["m|leather", 5], ["d|cloth|teal", 1], ["x|mooneel", 1]]},
		// Hollow Vale, through the woods south of the farm
		wren:  {name: "Wren", title: "the Farmhand", race: "Halfling", body: "teen", seed: 6101,
		        loves: ["m|wool", "w|herb", "f|carrot_soup"], likes: ["p|", "w|", "m|fibre"], dislikes: ["m|coal"], hates: ["m|bone", "m|troll_hide"],
		        lines: [["Oven's Window is quiet. That's why I like it.", "My sheep wander off. I wander after them. It works.", "Herbs grow thick by the river. Help yourself."],
		                ["You came all the way down here again? You must like the view.", "The old willows by the bridge are older than the town.", "If you hear singing in the trees, don't follow it."],
		                ["You're always welcome at my hut, rain or shine.", "I spun this from the softest fleece I had. For you.", "The animals know you now. They'll look after you."]],
		        rewards: [["m|wool", 8], ["d|cloth|green", 1], ["w|herb", 5], ["d|cloth|lavender", 1], ["m|unicorn_hair", 1]]},
		// No house or temple yet (that comes with the world map): he stands in the town square by day and lodges at the
		// inn. Holding a cursed tool, he offers to lift the curse (priest_offer; status script)
		// The Mayor (2026-11-07): City Hall by the square; sells plots of land (scripts/pshops)
		mayor:  {name: "Mayor Haddad", title: "of Beirut", race: "Human", body: "male", seed: 8801, shop: "land", look: "mayor",
		        loves: ["m|gold", "f|gourd_pie", "m|olive_oil"], likes: ["f|", "m|glass_jar", "a|"], dislikes: ["m|bone", "m|fibre"], hates: ["m|troll_hide", "w|toadstool"],
		        lines: [["Welcome to City Hall."], ["Good to see you."], ["Always a pleasure."]],
		        rewards: [["m|olive_oil", 2], ["d|cloth|navy", 1], ["m|gold", 3], ["d|cloth|maroon", 1], ["m|gem", 3]]},
		aldous: {name: "Father Aldous", title: "the Priest", race: "Human", body: "male", seed: 6101, look: "aldous",
		        loves: ["f|veg_stew", "w|herb", "m|moonsilk"], likes: ["f|", "p|", "w|"], dislikes: ["m|bone"], hates: ["m|void_pearl", "m|troll_hide"],
		        lines: [["Peace be with you, child.", "I've no roof over my altar yet. The square will do; the sky is a fine ceiling.", "If the mine ever lays a curse on you, come to me."],
		                ["You work hard. The valley notices, and so do I.", "There are witches deep in the mine, where the mithril runs. Their bolts carry curses.", "A cursed tool is a burden - but a blessed one is a gift. I can make the one the other."],
		                ["You've a good heart. I'd stake my collar on it.", "When the temple is built, I'll keep a pew for you at the front.", "Take this, with my blessing. Literally."]],
		        rewards: [["w|herb", 6], ["d|cloth|white", 1], ["f|antidote", 3], ["d|cloth|gold", 1], ["m|moonsilk", 3]]},

		// ---------------- The new world's people (design/world_plan.md). (M) marriage candidates are marked in
		// villager_candidates (schedules).
		yubaba: {name: "Yubaba", title: "of the Riviera Hotel", race: "Human", body: "female", seed: 7001,
		        loves: ["m|gold", "m|gem", "f|moonfin_soup"], likes: ["m|silver", "f|", "x|"], dislikes: ["m|stone", "w|"], hates: ["m|bone", "m|troll_hide"],
		        lines: [["Guests pay first. Everyone pays first.", "Wipe your feet. This floor is older than you.", "The sea air is free. The rooms are not."],
		                ["You're not as scruffy as you look, farmer.", "Boh! Stop eating the guests' breakfast!", "Forty years I've run this hotel. Nothing gets past me."],
		                ["You're welcome here any time. Don't tell the others I said so.", "My son likes you. I approve. Mostly.", "Sit. Have tea. On the house - just this once."]],
		        rewards: [["m|silver", 3], ["f|moonfin_soup", 1], ["m|gold", 2], ["d|cloth|purple", 1], ["m|gem", 2]]},
		boh:    {name: "Boh", title: "of the Riviera Hotel", race: "Human", body: "male", seed: 7002,
		        loves: ["f|gourd_pie", "f|corn_fritters", "a|milk"], likes: ["f|", "p|"], dislikes: ["m|stone", "m|coal"], hates: ["w|toadstool", "m|bone"],
		        lines: [["Mother says I mustn't talk to guests. You're not a guest, are you?", "I carry the bags. Big bags. Heavy bags.", "Hello! Do you have any snacks?"],
		                ["I'm stronger than I look. I lifted a whole trunk today.", "Mother worries too much. I can look after myself.", "The lighthouse looks lonely at night. Like me, sometimes."],
		                ["You're my favourite person. Don't tell Mother.", "I'd like a farm one day. With you showing me how.", "I saved you the best pastry from breakfast."]],
		        rewards: [["f|corn_fritters", 2], ["d|cloth|red", 1], ["f|gourd_pie", 2], ["d|cloth|gold", 1], ["m|gem", 1]]},
		coralie:{name: "Coralie", title: "the Lighthouse Keeper", race: "Human", body: "female", seed: 7003,
		        loves: ["x|mooneel", "m|frost_crystal", "f|moonfin_soup"], likes: ["x|", "m|", "f|"], dislikes: ["p|potato"], hates: ["m|coal", "m|ember_core"],
		        lines: [["The lamp needs oil and I need sleep. One of us gets it.", "Ships trust the light. I trust the ships.", "Mind the stairs. All two hundred of them."],
		                ["You can see the whole bay from the top. Come up some evening.", "I keep a log of every ship. And every storm.", "Lonely? No. The sea talks plenty."],
		                ["I wrote your name in the log today. Under 'good things'.", "Stay for the sunset. It's better with company.", "The light's brighter when you visit. I'm sure of it."]],
		        rewards: [["x|sardine", 3], ["d|cloth|navy", 1], ["x|seabass", 2], ["d|cloth|sky", 1], ["m|frost_crystal", 2]]},
		rook:   {name: "Rook", title: "the Witch's son", race: "Orc", body: "teen", seed: 7004, kid: true,
		        loves: ["m|feather", "m|bone", "m|gem"], likes: ["m|", "w|"], dislikes: ["f|veg_stew"], hates: ["m|pixie_dust", "a|milk"],
		        lines: [["Mum says strangers bring trouble. Are you trouble?", "I'm not allowed past the cliff.", "Do you know any knights?"],
		                ["Mum's teaching me potions. Mostly they explode.", "I found a crow feather. It's lucky.", "Some nights I watch the road. Waiting for someone."],
		                ["You're the only one who visits. Thanks.", "When I'm grown I'll be a knight. A real one.", "Here. A lucky feather. For you."]],
		        rewards: [["m|feather", 3], ["m|bone", 3], ["m|gem", 1], ["d|cloth|charcoal", 1], ["m|pixie_dust", 1]]},
		// The five families added on 2026-11-06 (design/world_plan.md), each with a workshop
		rami:   {name: "Rami Saba", title: "the Olive Presser", race: "Human", body: "male", seed: 7101, shop: "olive",
		        loves: ["m|olive_oil", "f|veg_stew", "p|tomato"], likes: ["p|", "f|"], dislikes: ["m|coal"], hates: ["m|bone", "m|troll_hide"],
		        lines: [["Olives don't hurry. Neither do I.", "Three generations of Sabas have turned this stone.", "Taste that. That's the bay in a bottle."],
		                ["The old press groans every autumn. Like me.", "Noor picks faster than anyone in the valley.", "Bring me good soil and I'll show you good oil."],
		                ["You're welcome at our table any night. Noor insists.", "I saved you the first pressing. Don't tell the bank.", "The grove likes you. I can tell."]],
		        rewards: [["m|olive_oil", 2], ["p|tomato", 3], ["f|veg_stew", 1], ["m|olive_oil", 4], ["d|cloth|olive", 1]]},
		noor:   {name: "Noor Saba", title: "the Olive Picker", race: "Human", body: "female", seed: 7102,
		        loves: ["w|herb", "a|honey", "m|olive_oil"], likes: ["w|", "f|"], dislikes: ["m|iron_ore"], hates: ["m|troll_hide", "x|"],
		        lines: [["Mind the nets under the trees. They're for olives, not feet.", "Up a ladder by dawn, every day of harvest.", "Rami talks to the press. I talk to the trees."],
		                ["The old trees on the hill are older than the town.", "My grandmother said the grove remembers everyone.", "Come at harvest. I'll teach you to pick."],
		                ["You've got olive-picker's hands now. That's a compliment.", "Stay for supper. There's always too much.", "The bay looks kinder with you around."]],
		        rewards: [["w|herb", 3], ["a|honey", 1], ["m|olive_oil", 1], ["d|cloth|sage", 1], ["w|mushroom", 3]]},
		ottilie:{name: "Ottilie Brassbolt", title: "the Tinker", race: "Dwarf", body: "female", seed: 7103, shop: "tinker",
		        loves: ["m|gear", "m|copper", "m|iron"], likes: ["m|", "o|"], dislikes: ["w|"], hates: ["m|troll_hide", "a|milk"],
		        lines: [["Don't touch that. Or that. Especially that.", "Hangar 12 used to hold airships. Now it holds me.", "Everything's broken. That's what keeps me in work."],
		                ["Give me copper and time and I'll give you a miracle.", "I'm drawing up a cart that runs on rails. Under the hills.", "Gus thinks he'll be a better tinker than me. He might."],
		                ["You've got a tinker's patience. Rare thing.", "I named a gear after you. It's a good gear.", "When the rail cart runs, you get the first ride."]],
		        rewards: [["m|gear", 2], ["m|copper", 3], ["m|iron", 2], ["o|sprinkler", 1], ["m|gear", 4]]},
		gus:    {name: "Gus Brassbolt", title: "the Tinker's son", race: "Dwarf", body: "teen", seed: 7104, kid: true,
		        loves: ["m|gear", "f|corn_fritters", "m|gem"], likes: ["m|", "f|"], dislikes: ["w|herb"], hates: ["p|gourd", "m|fibre"],
		        lines: [["I built a clockwork beetle. It bit me.", "Mum says I'm not allowed to fly yet.", "Want to see a gear that spins backwards?"],
		                ["There's an old airship frame in the hangar roof.", "One day I'll fix it. Then I'm going everywhere.", "Do you think the ruins up north had machines?"],
		                ["You're the only grown-up who listens to my plans.", "I'll take you up in the airship. First passenger.", "Here, a spare gear. For luck."]],
		        rewards: [["m|gear", 1], ["f|corn_fritters", 1], ["m|copper_ore", 3], ["d|cloth|charcoal", 1], ["m|gem", 1]]},
		hal:    {name: "Captain Hal Saltwhistle", title: "the Boatwright", race: "Human", body: "male", seed: 7105, shop: "boatyard",
		        loves: ["m|rope", "x|seabass", "m|wood"], likes: ["x|", "m|"], dislikes: ["p|"], hates: ["m|pixie_dust", "m|wool"],
		        lines: [["Forty years at sea and I build the boats now. Safer.", "A boat's only as good as its keel. Same with folk.", "Sand in my boots since the day I was born."],
		                ["There's an island out past the shallows. I'll get you there one day.", "Marina caulks better than I ever did.", "The shipwreck down the beach? Not one of mine."],
		                ["You'd have made a fine deckhand.", "Next boat I build, she's named after you.", "Fair winds, friend. Always."]],
		        rewards: [["m|rope", 3], ["x|sardine", 4], ["m|wood", 10], ["x|seabass", 2], ["d|cloth|navy", 1]]},
		marina: {name: "Marina Saltwhistle", title: "the Boatwright's daughter", race: "Human", body: "female", seed: 7106,
		        loves: ["x|mooneel", "m|rope", "f|moonfin_soup"], likes: ["x|", "f|"], dislikes: ["m|coal"], hates: ["m|troll_hide", "p|potato"],
		        lines: [["Tar on my hands, salt in my hair. Good morning.", "Dad thinks I'll take over the yard. He's right.", "Swimming's better than walking. Fight me."],
		                ["I race the gulls to the end of the pier every morning.", "Turtles nest down the beach in summer. Mind your feet.", "The sea was calm today. That means you were around."],
		                ["Come sailing with me when the boat's done.", "I keep a shell for you. Every time I find a good one.", "You're good company. Better than the gulls."]],
		        rewards: [["x|sardine", 3], ["m|rope", 2], ["x|mooneel", 1], ["d|cloth|sky", 1], ["f|moonfin_soup", 1]]},
		iris:   {name: "Iris Fairglass", title: "the Glassblower", race: "Elf", body: "female", seed: 7107, shop: "glassworks",
		        loves: ["m|glass", "m|gem", "m|frost_crystal"], likes: ["m|", "w|"], dislikes: ["m|coal"], hates: ["m|troll_hide", "m|bone"],
		        lines: [["Sand, fire and breath. That's all glass is.", "Careful. Everything in here is either hot or sharp.", "Well's Head sand is the finest on the coast."],
		                ["I'm making windows for the hotel. Colour in every one.", "Tomas hauls sand. I make it sing.", "Bring me sand from the beach and I'll pay you in jars."],
		                ["I blew a little glass bird for you. Don't drop it.", "The light through my windows is prettier when you visit.", "You see things clearly. Like good glass."]],
		        rewards: [["m|glass_jar", 3], ["m|glass", 3], ["m|gem", 1], ["m|glass_jar", 5], ["d|cloth|sky", 1]]},
		tomas:  {name: "Tomas Fairglass", title: "the Sand-hauler", race: "Human", body: "male", seed: 7108,
		        loves: ["f|hash_browns", "m|glass", "a|milk"], likes: ["f|", "p|"], dislikes: ["w|herb"], hates: ["m|pixie_dust", "x|"],
		        lines: [["Two hundred buckets of sand a day. Someone's got to.", "Iris makes it beautiful. I just carry it.", "The old ruins up the hill? Don't go at night."],
		                ["Stone walls up there older than the town. Wardens' work, they say.", "Hot furnace, cold sea. Best of both.", "Strong back, simple life. Can't complain."],
		                ["You're all right, farmer. More than all right.", "Iris made you something. Act surprised.", "Sit a while. The sea's not going anywhere."]],
		        rewards: [["f|hash_browns", 1], ["m|glass", 2], ["m|stone", 10], ["a|milk", 2], ["m|glass_jar", 2]]},
		bram:   {name: "Bram Hayward", title: "the Stablemaster", race: "Beastkin", body: "male", seed: 7109, shop: "stables",
		        loves: ["m|horse_feed", "p|carrot", "a|egg"], likes: ["p|", "a|"], dislikes: ["x|"], hates: ["m|troll_hide", "m|ember_core"],
		        lines: [["A horse knows a kind hand. So do I.", "Mind the end stall. Thistle bites.", "Every farmer needs a good horse. You'll see."],
		                ["Bring me carrots and I'll have a foal ready for you by spring.", "Della keeps the books. I keep the horses happy.", "The valley's big. Big enough to need a horse."],
		                ["Thistle let you pat her. She doesn't do that.", "When you're ready, the best horse in the stable's yours.", "You've got a rider's heart."]],
		        rewards: [["m|horse_feed", 3], ["p|carrot", 4], ["m|saddle", 1], ["a|egg", 3], ["d|cloth|tan", 1]]},
		della:  {name: "Della Hayward", title: "the Stable-keeper", race: "Human", body: "female", seed: 7110,
		        loves: ["a|egg", "w|herb", "f|veg_stew"], likes: ["a|", "f|"], dislikes: ["x|"], hates: ["m|troll_hide", "m|coal"],
		        lines: [["Morning! Muck to shovel, hay to fork.", "Bram talks to the horses more than to me.", "The monks over the hill buy our hay."],
		                ["I keep a ledger for every horse. Names, birthdays, moods.", "The old track to the north was a horse road once.", "You smell like a farm. That's a good thing here."],
		                ["You're family at the stables now.", "I'm saving the gentlest mare for you.", "Come by for tea. The horses won't mind."]],
		        rewards: [["a|egg", 4], ["w|herb", 2], ["m|horse_feed", 2], ["f|veg_stew", 1], ["d|cloth|sage", 1]]},
		cassius:{name: "Cassius Goldcrest", title: "the Banker", race: "Human", body: "male", seed: 7005,
		        loves: ["m|gold", "m|mithril", "m|gem"], likes: ["m|silver", "m|", "f|"], dislikes: ["w|", "p|"], hates: ["m|bone", "m|fibre"],
		        lines: [["Money never sleeps. I do, occasionally.", "Interest compounds. So does trouble.", "A farmer. How... earthy."],
		                ["Your accounts are looking healthier. I'm impressed.", "My daughter says I work too much. She's right.", "Gold is honest. People, less so."],
		                ["You've done well for this town. Truly.", "Liora talks about you at dinner. Often.", "A good investment, you are. The best I've made."]],
		        rewards: [["m|silver", 5], ["m|gold", 3], ["d|cloth|gold", 1], ["m|gem", 2], ["m|mithril", 1]]},
		liora:  {name: "Liora Goldcrest", title: "the Banker's daughter", race: "Human", body: "female", seed: 7006,
		        loves: ["m|silk", "m|moonsilk", "f|gourd_pie"], likes: ["m|", "f|", "w|herb"], dislikes: ["m|coal", "m|stone"], hates: ["m|bone", "m|troll_hide"],
		        lines: [["Red Street's the best street. Everyone says so. Mostly me.", "Father wants me to learn the books. I want to see the world.", "Oh! You're the new farmer."],
		                ["I read about faraway places every night.", "Do you ever just want to leave everything and sail off?", "Your hands are all calluses. That's rather nice."],
		                ["Maybe the world can come to me. Maybe it already has.", "I kept a seat for you at the tavern.", "You're the most interesting thing that's happened here."]],
		        rewards: [["m|silk", 2], ["d|cloth|rose", 1], ["f|gourd_pie", 2], ["d|cloth|lavender", 1], ["m|moonsilk", 1]]},
		kael:   {name: "Kael Ashford", title: "the Blacksmith's son", race: "Human", body: "male", seed: 7007,
		        loves: ["m|iron", "m|steel", "f|fiery_chilli"], likes: ["m|", "f|"], dislikes: ["p|artichoke"], hates: ["m|silk", "m|pixie_dust"],
		        lines: [["Dad does the hard bits. I do the hot bits.", "Mind the anvil. It bites.", "Ore in, ingots out. That's the trade."],
		                ["I made my first sword last week. It bent.", "Dad won't say it, but he's proud of you.", "The forge sings when the iron's right."],
		                ["I'll make you something special one day.", "You're good for the old man. Keeps him smiling.", "Thanks for always bringing the good ore."]],
		        rewards: [["m|coal", 10], ["m|iron", 5], ["m|steel", 2], ["d|metal|bronze", 1], ["m|gold", 2]]},
		clara:  {name: "Clara Whitlow", title: "Mara's daughter", race: "Human", body: "female", seed: 7008,
		        loves: ["p|tomato", "f|tomato_salad", "w|herb"], likes: ["p|", "f|", "w|"], dislikes: ["m|coal"], hates: ["m|bone", "x|"],
		        lines: [["Mum's at the tool store. I'm at the window, watching the world.", "Grace Tower chimes every hour. You get used to it.", "Hello, farmer."],
		                ["I grow tomatoes on the windowsill. Don't laugh.", "Mum wants me to take over the store. I'd rather paint.", "The old quarter has the best stories."],
		                ["You make this place feel new.", "I painted you. Badly. Want to see?", "Stay for supper? Mum won't mind. Much."]],
		        rewards: [["s|tomato", 10], ["d|cloth|teal", 1], ["f|tomato_salad", 2], ["d|cloth|green", 1], ["m|gem", 1]]},
		nerissa:{name: "Nerissa Gullwater", title: "the Fisher's daughter", race: "Human", body: "female", seed: 7009,
		        loves: ["x|salmon", "x|seabass", "f|grilled_perch"], likes: ["x|", "f|"], dislikes: ["p|potato"], hates: ["m|ember_core", "m|coal"],
		        lines: [["Pigeon Rocks. Two rocks, a thousand pigeons.", "Dad says I've salt in my veins.", "Mind the nets."],
		                ["I can out-swim anyone in this town.", "Ever seen the rocks at sunset? Pink as coral.", "Dad's getting old. I worry."],
		                ["Come swimming with me sometime.", "I named a gull after you. He's very handsome. Or pretty.", "You're the best catch on the whole coast."]],
		        rewards: [["x|sardine", 4], ["d|cloth|sky", 1], ["x|salmon", 2], ["d|cloth|navy", 1], ["x|moonfin", 1]]},
		wynn:   {name: "Wynn Quill", title: "Edwin's sister", race: "Elf", body: "teen", seed: 7010, kid: true,
		        loves: ["m|feather", "m|gem", "f|corn_fritters"], likes: ["m|", "f|"], dislikes: ["p|potato"], hates: ["m|bone", "m|coal"],
		        lines: [["Edwin says I'm too loud for the library.", "I've read every book in Uptown. Twice.", "Are you the farmer? Is farming boring?"],
		                ["I'm writing a story. You're in it.", "Edwin pretends to be stern. He's soft as butter.", "Do you know any dragons?"],
		                ["You're my favourite character.", "I'll read you my story when it's done.", "You're the best grown-up. Mostly."]],
		        rewards: [["m|feather", 3], ["d|cloth|lavender", 1], ["m|gem", 1], ["f|corn_fritters", 2], ["m|pixie_dust", 1]]},
		poupry: {name: "Poupry Meadowlark", title: "of Meadowlark Farm", race: "Human", body: "female", seed: 7011, shop: "animals",
		        loves: ["a|egg", "w|herb", "f|carrot_soup"], likes: ["a|", "p|", "w|"], dislikes: ["m|coal"], hates: ["m|bone", "m|troll_hide"],
		        lines: [["Milk, wool, eggs! Fresh every morning!", "The chickens know my voice. They come running.", "Welcome to Meadowlark Farm!"],
		                ["Sanji cooks, I farm, Tauriel paints. It works.", "Wren and Pip are good hands. Lazy before nine, though.", "Animals know a kind heart."],
		                ["You're family to us now.", "Take some eggs. No, take more.", "The farm's never been happier than since you came."]],
		        rewards: [["a|egg", 6], ["a|milk", 3], ["d|cloth|yellow", 1], ["m|wool", 5], ["d|cloth|pink", 1]]},
		sanji:  {name: "Sanji Meadowlark", title: "the Tavern Cook", race: "Human", body: "male", seed: 7012,
		        loves: ["x|salmon", "f|fiery_chilli", "p|tomato"], likes: ["f|", "x|", "p|"], dislikes: ["m|stone"], hates: ["m|bone", "w|toadstool"],
		        lines: [["A kitchen is a battlefield. I always win.", "Never waste food. Never.", "You look hungry. You always look hungry."],
		                ["Bring me good fish and I'll make you a feast.", "Poupry's eggs make the best omelettes in the world.", "Cooking is love you can taste."],
		                ["For you, the chef's special. Every day.", "You eat like you mean it. I like that.", "My kitchen's door is always open to you."]],
		        rewards: [["f|grilled_perch", 2], ["f|fiery_chilli", 2], ["d|cloth|red", 1], ["f|moonfin_soup", 1], ["d|cloth|charcoal", 1]]},
		tauriel:{name: "Tauriel Meadowlark", title: "the Artist", race: "Human", body: "female", seed: 7013,
		        loves: ["m|gem", "m|frost_crystal", "w|herb"], likes: ["m|", "w|", "f|"], dislikes: ["m|coal"], hates: ["m|bone", "m|troll_hide"],
		        lines: [["Hold still. The light on you is lovely.", "I paint the bay every morning. It's never the same twice.", "Hello! Mind the wet paint."],
		                ["Mum wants me to milk cows. I want to paint them.", "Colours are everywhere if you look.", "I sold a painting in Downtown! Just one."],
		                ["I painted you. It's my best one.", "You see the world the way I do.", "Will you sit for me again? I'll never tire of it."]],
		        rewards: [["d|cloth|teal", 1], ["m|gem", 1], ["d|cloth|purple", 1], ["m|frost_crystal", 1], ["m|moonsilk", 1]]},
		garth:  {name: "Garth Oakhart", title: "of the Lumber Mill", race: "Orc", body: "male", seed: 7014, shop: "carpentry",
		        loves: ["m|wood", "m|iron", "f|veg_stew"], likes: ["m|", "f|"], dislikes: ["p|tomato"], hates: ["m|silk", "m|feather"],
		        lines: [["Wood for sale. Barns built. Coops too.", "The mill turns all day. So do I.", "Need lumber? I've got lumber."],
		                ["Dad fells them, I mill them, Mum designs the houses.", "A good barn lasts a hundred years.", "Strong arms, simple life."],
		                ["I'd build you anything. Just ask.", "You work as hard as any orc I know.", "Stay for supper. Mum's stew is famous."]],
		        rewards: [["m|wood", 30], ["m|iron", 3], ["d|cloth|walnut", 1], ["m|steel", 2], ["d|cloth|forest", 1]]},
		zenya:  {name: "Zenya Kassar", title: "of the Tool Store", race: "Human", body: "female", seed: 7015,
		        loves: ["m|steel", "m|ember_core", "f|fiery_chilli"], likes: ["m|", "f|"], dislikes: ["w|herb", "m|silk"], hates: ["p|", "a|milk"],
		        lines: [["What? I'm working. Buy something or don't.", "Mara's alright. For a boss.", "Rules are for people with no imagination."],
		                ["You're not as dull as the rest of them.", "I fixed a hoe nobody could fix. Don't tell Mara.", "Ayla dances. I fight. We're a good pair."],
		                ["Fine. You're my favourite. Happy?", "Let's get out of this town one night. Just us.", "You actually get me. That's rare."]],
		        rewards: [["m|iron", 5], ["d|cloth|charcoal", 1], ["m|steel", 2], ["d|cloth|red", 1], ["m|ember_core", 1]]},
		ayla:   {name: "Ayla Kassar", title: "the Dancer", race: "Human", body: "female", seed: 7016,
		        loves: ["m|silk", "m|moonsilk", "f|gourd_pie"], likes: ["m|", "f|", "w|"], dislikes: ["m|coal"], hates: ["m|bone", "m|troll_hide"],
		        lines: [["Come to the tavern on the weekend! I dance!", "Zenya's all bark. Mostly.", "Hello, sweetie."],
		                ["Dancing is just walking with joy.", "The market's the best place for people-watching.", "My feet hurt. Worth it."],
		                ["I'll dance a song just for you.", "You're like family now.", "Look after my sister. She won't ask, but she needs it."]],
		        rewards: [["m|silk", 2], ["d|cloth|rose", 1], ["f|gourd_pie", 2], ["d|cloth|gold", 1], ["m|moonsilk", 1]]},
		mira:   {name: "Mira Larkspun", title: "Nell's daughter", race: "Human", body: "female", seed: 7017,
		        loves: ["m|wool", "m|cotton", "m|linen"], likes: ["m|", "f|"], dislikes: ["m|coal"], hates: ["m|bone", "m|ember_core"],
		        lines: [["Mum weaves, I sew. Between us, Dahya's dressed.", "That shirt's seen better days.", "Hello! Need mending?"],
		                ["I'm designing a new coat. It's going to be wonderful.", "The pines here smell lovely after rain.", "Bryn's leather and our cloth - the best in town."],
		                ["I made this for you. Try it on!", "You make everything feel cosier.", "Come by any time. I'll put the kettle on."]],
		        rewards: [["m|wool", 5], ["d|cloth|green", 1], ["m|linen", 3], ["d|cloth|sky", 1], ["m|moonsilk", 1]]},
		dikhaj: {name: "Dikhaj Tawil", title: "Bryn's sister", race: "Beastkin", body: "female", seed: 7018,
		        loves: ["x|salmon", "m|fur", "f|forest_stew"], likes: ["x|", "m|", "f|"], dislikes: ["p|corn"], hates: ["m|silk", "w|toadstool"],
		        lines: [["Bryn tans the hides. I find them.", "The market's loud. I like loud.", "Sniff. You smell like hay."],
		                ["I run the stalls at Wing Hill some days.", "Bryn worries about me. He shouldn't.", "Ever chased a deer barefoot? You should."],
		                ["You're pack now.", "I'll show you the secret trails in the woods.", "Brought you a fish. Fresh. Very fresh."]],
		        rewards: [["m|fur", 3], ["x|perch", 3], ["d|cloth|brown", 1], ["m|leather", 3], ["d|cloth|forest", 1]]},
		sylva:  {name: "Sylva Silverbough", title: "the Elf's daughter", race: "Elf", body: "female", seed: 7019,
		        loves: ["w|herb", "m|pixie_dust", "f|stuffed_artichoke"], likes: ["w|", "p|", "m|gem"], dislikes: ["m|coal"], hates: ["m|ember_core", "f|fiery_chilli"],
		        lines: [["The woods are listening. Speak softly.", "Mother brews, Father hunts, I wander.", "Good day, farmer."],
		                ["I know every herb in Whispering Woods.", "Elves live long. We learn to be patient.", "The river sings at dawn."],
		                ["A century from now I'll still remember you.", "Walk the woods with me at dusk.", "You have an old soul. I like it."]],
		        rewards: [["w|herb", 5], ["d|cloth|forest", 1], ["m|pixie_dust", 1], ["d|cloth|green", 1], ["m|frost_crystal", 1]]},
		soren:  {name: "Soren Night", title: "of the Night Farm", race: "Human", body: "male", seed: 7020, shop: "seeds",
		        loves: ["p|gourd", "p|corn", "f|veg_stew"], likes: ["p|", "f|", "s|"], dislikes: ["m|coal"], hates: ["m|troll_hide", "m|bone"],
		        lines: [["Seeds and honey. The best in the valley.", "Your grandmother taught me to farm, you know.", "Morning, cousin."],
		                ["Our farm has everything. We only sell the seeds.", "Jul kept us up all night. Worth it.", "Mother still treats me like I'm ten."],
		                ["Family's family. Whatever you need.", "Here, the good seeds. Don't tell the customers.", "You've made Grandmother's farm proud."]],
		        rewards: [["s|corn", 10], ["s|gourd", 5], ["d|cloth|green", 1], ["f|veg_stew", 2], ["d|cloth|walnut", 1]]},
		sera:   {name: "Sera Night", title: "the Baker", race: "Human", body: "female", seed: 7021, shop: "bakery",
		        loves: ["p|corn", "f|corn_fritters", "f|gourd_pie"], likes: ["p|", "a|", "f|"], dislikes: ["m|stone"], hates: ["m|coal", "f|fiery_chilli"],
		        lines: [["Bread's up at dawn and so am I.", "Flour everywhere. Always.", "Fresh loaves on Verdun Street!"],
		                ["Jul's first word was 'bun'. I'm so proud.", "Soren eats half my stock. Every day.", "The secret's a long rise."],
		                ["Take a pie. No charge for family.", "You're always welcome at our table.", "You've got flour on your nose. Hold still."]],
		        rewards: [["f|corn_fritters", 3], ["f|gourd_pie", 2], ["d|cloth|yellow", 1], ["a|egg", 5], ["d|cloth|pink", 1]]},
		jul:    {name: "Jul Night", title: "the Baby", race: "Human", body: "child", seed: 7022, kid: true,
		        loves: ["a|milk", "f|corn_fritters", "m|feather"], likes: ["f|", "a|"], dislikes: ["m|stone"], hates: ["f|fiery_chilli", "m|bone"],
		        lines: [["Ba!", "Goo.", "*giggles*"], ["*reaches for you*", "Fa-mer!", "*claps*"], ["*hugs your leg*", "*sleepy smile*", "Fa-mer! Fa-mer!"]],
		        rewards: [["m|feather", 1], ["a|milk", 1], ["m|feather", 2], ["a|milk", 2], ["m|gem", 1]]},
		alban:  {name: "Dr. Alban Frere", title: "the Doctor", race: "Halfling", body: "male", seed: 7023, shop: "hospital",
		        loves: ["w|herb", "f|antidote", "m|frost_crystal"], likes: ["w|", "f|"], dislikes: ["m|coal"], hates: ["m|bone", "w|toadstool"],
		        lines: [["Rest, water, and a good night's sleep. That's half of medicine.", "The hospital's open if you're poorly.", "Don't overdo it in that mine."],
		                ["Marigold's herbs fix more than my tonics do.", "You've a strong constitution. Look after it.", "Posy's the light of our lives."],
		                ["Come by any time. Doctor's orders.", "You keep this town healthy, you know. Good food does that.", "I trust you with my daughter's heart."]],
		        rewards: [["f|antidote", 2], ["w|herb", 5], ["d|cloth|sky", 1], ["m|frost_crystal", 1], ["d|cloth|navy", 1]]},
		marigold:{name: "Marigold Frere", title: "the Herbalist", race: "Halfling", body: "female", seed: 7024,
		        loves: ["w|herb", "w|mushroom", "f|forest_stew"], likes: ["w|", "p|"], dislikes: ["m|coal"], hates: ["m|ember_core", "m|bone"],
		        lines: [["Chamomile for sleep. Mint for the belly. Patience for everything.", "Alban's medicine, my herbs. We make a good pair.", "Hello, dear."],
		                ["Whispering Woods has herbs you won't find anywhere else.", "Posy gets her green thumb from me.", "Every weed is a herb nobody's met yet."],
		                ["Here, a tea for your tired bones.", "You're one of the family now, dear.", "I've a jar of my best salve set aside for you."]],
		        rewards: [["w|herb", 5], ["w|mushroom", 3], ["d|cloth|green", 1], ["f|forest_stew", 1], ["d|cloth|green", 1]]},
		alaric: {name: "Sir Alaric Ward", title: "the Knight", race: "Human", body: "male", seed: 7025, shop: "guild_melee",
		        loves: ["m|steel", "m|mithril", "f|veg_stew"], likes: ["m|", "f|"], dislikes: ["m|silk"], hates: ["m|pixie_dust", "w|toadstool"],
		        lines: [["A blade for a blade. The Guild has what you need.", "Father prays. I guard. Between us, the town's safe.", "Stand straight, farmer."],
		                ["I patrol the hills at night. Strange things in the woods.", "I have regrets. Every knight does.", "Train hard. The mine doesn't forgive."],
		                ["I'd stand beside you in any fight.", "There's something I've never told anyone. Maybe one day, you.", "You have a knight's heart."]],
		        rewards: [["m|iron", 5], ["m|steel", 3], ["d|metal|bronze", 1], ["d|cloth|navy", 1], ["m|mithril", 1]]},
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
	if(v[$ "look"] == "brom") return villager_look_brom();
	if(v[$ "look"] == "mara") return villager_look_mara();
	if(v[$ "look"] == "aldous") return villager_look_aldous();
	if(v[$ "look"] == "mayor") return villager_look_mayor();
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

/// @description Brom: a stout dwarf smith in an apron.
function villager_look_brom(){
	var look = character_empty_look("Dwarf", "male");
	var p = look.parts;
	p.body.pal  = character_find_palette("body", "bronze");
	p.head      = {item: character_find_item("head", "Human Male Plump"), pal: -1};
	p.hair      = {item: character_find_item("hair", "Balding"),          pal: character_find_palette("hair", "dark_gray")};
	p.beard     = {item: character_find_item("beard", "Winter Beard"),    pal: character_find_palette("hair", "dark_gray")};
	p.shirt     = {item: character_find_item("shirt", "Longsleeve"),      pal: character_find_palette("cloth", "charcoal")};
	p.vest      = {item: character_find_item("vest", "Apron"),            pal: character_find_palette("cloth", "leather")};
	p.pants     = {item: character_find_item("pants", "Pants"),           pal: character_find_palette("cloth", "brown")};
	p.shoes     = {item: character_find_item("shoes", "Basic Boots"),     pal: character_find_palette("cloth", "black")};
	p.belt      = {item: character_find_item("belt", "Leather Belt"),     pal: -1};
	p.held      = {item: character_find_item("held", "Hammer"),           pal: -1};
	return look;
}

/// @description Father Aldous: a grey-haired priest in a white robe.
/// @description The Mayor: a formal shirt, a waistcoat and a tie, grey at the temples, a moustache.
function villager_look_mayor(){
	var look = character_empty_look("Human", "male");
	var p = look.parts;
	p.body.pal  = character_find_palette("body", "olive");
	if(p.body.pal == -1) p.body.pal = character_find_palette("body", "light");
	p.head      = {item: character_find_item("head", "Human Male Plump"), pal: -1};
	p.hair      = {item: character_find_item("hair", "Balding"),          pal: character_find_palette("hair", "dark gray")};
	p.beard     = {item: character_find_item("beard", "Mustache"),        pal: character_find_palette("hair", "dark gray")};
	p.shirt     = {item: character_find_item("shirt", "Collared/Formal Longsleeve"), pal: character_find_palette("cloth", "white")};
	p.vest      = {item: character_find_item("vest", "Vest"),             pal: character_find_palette("cloth", "navy")};
	p.neck      = {item: character_find_item("neck", "Necktie"),          pal: character_find_palette("cloth", "maroon")};
	p.pants     = {item: character_find_item("pants", "Formal Pants"),    pal: character_find_palette("cloth", "charcoal")};
	p.shoes     = {item: character_find_item("shoes", "Basic Shoes"),     pal: character_find_palette("cloth", "black")};
	character_validate(look);
	return look;
}

function villager_look_aldous(){
	var look = character_empty_look("Human", "male");
	var p = look.parts;
	p.body.pal  = character_find_palette("body", "light");
	p.head      = {item: character_find_item("head", "Human Male Plump"), pal: -1};
	p.hair      = {item: character_find_item("hair", "Balding"),          pal: character_find_palette("hair", "gray")};
	p.beard     = {item: character_find_item("beard", "Winter Beard"),    pal: character_find_palette("hair", "gray")};
	p.shirt     = {item: character_find_item("shirt", "Robe"),            pal: character_find_palette("cloth", "white")};
	p.belt      = {item: character_find_item("belt", "Robe Belt"),       pal: character_find_palette("cloth", "yellow")};
	p.shoes     = {item: character_find_item("shoes", "Basic Shoes"),     pal: character_find_palette("cloth", "brown")};
	character_validate(look);
	return look;
}

/// @description Mara: a halfling shopkeeper in a green shirt, apron and yellow bandana.
function villager_look_mara(){
	var look = character_empty_look("Halfling", "teen");
	var p = look.parts;
	p.body.pal  = character_find_palette("body", "amber");
	p.head      = {item: character_find_item("head", "Human Female Small"), pal: -1};
	p.hair      = {item: character_find_item("hair", "Ponytail"),           pal: character_find_palette("hair", "ginger")};
	p.shirt     = {item: character_find_item("shirt", "Longsleeve"),        pal: character_find_palette("cloth", "green")};
	p.vest      = {item: character_find_item("vest", "Apron"),              pal: character_find_palette("cloth", "tan")};
	p.pants     = {item: character_find_item("pants", "Pants"),             pal: character_find_palette("cloth", "brown")};
	p.shoes     = {item: character_find_item("shoes", "Basic Shoes"),       pal: character_find_palette("cloth", "brown")};
	p.hat       = {item: character_find_item("hat", "Bandana"),             pal: character_find_palette("cloth", "yellow")};
	character_validate(look);
	return look;
}

/// @description What they say when you talk: a line for how well they know you, varying by day.
function villager_line(_key){
	var v = villager_def(_key);
	var h = people_hearts(_key);
	var tier = (h >= 6) ? 2 : ((h >= 2) ? 1 : 0);
	var lines = v.lines[tier];
	var line = lines[(day_index() + string_length(_key)) mod array_length(lines)];
	// the Mayor talks land and your standing (scripts/pshops)
	if(_key == "mayor") return pshop_mayor_line();
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
	if(_stack.id == "m|blue_feather") return marriage_propose(_key, _stack);   // the proposal (scripts/marriage)
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
	if(key == "aldous" && curse_active()){ priest_offer(_npc); return; }
	var reward = people_talk(key);
	// your employee, in your shop: their report, and the takings (scripts/pshops)
	var pid = pshop_staff_plot(key);
	if(pid != "" && room_get_name(room) == "rm_pshop_" + pid){
		var st = pshop_staff_talk(key);
		instance_create_depth(0, 0, -9000, obj_dialogue, {who: key, npc: _npc, text: st[0], note: (reward != "") ? reward + "  " + st[1] : st[1]});
		return;
	}
	instance_create_depth(0, 0, -9000, obj_dialogue, {who: key, npc: _npc, text: villager_line(key), note: reward});
}

/// @description T in a shopkeeper's dialogue: their shop.
function people_trade(_key){
	var v = villager_def(_key);
	var inv = instance_create_depth(0, 0, -9000, obj_inventory);
	inv.shop = true;
	switch(v.shop){
		case "smith": inv.smith = true; break;   // Brom: buys ore, sells ingots, upgrades tools
		case "animals":   // Poupry's farm: animals, and the milk, wool and eggs (the Night farm keeps theirs)
			inv.shopStock = array_concat(animal_stock(), shop_produce_stock());
			inv.shopTitle = "Meadowlark Farm - animals and produce"; break;
		case "carpentry": inv.shopStock = shop_carpentry_stock(); inv.shopTitle = "Oakhart Lumber Mill"; break;
		case "seeds":     // the Night farm: seeds for the season, and honey
			inv.shopStock = array_concat(item_seed_stock(), shop_honey_stock());
			inv.shopTitle = "Night Farm - " + season_name(global.clock.season) + " seeds and honey"; break;
		case "inn":       inv.shopStock = shop_inn_stock(); inv.shopTitle = "The Tavern - today's menu"; break;
		case "outfitter": inv.shopStock = shop_outfitter_stock(); inv.shopTitle = "Larkspun Clothes"; break;
		case "apothecary":inv.shopStock = shop_apothecary_stock(); inv.shopTitle = "Silverbough Potions"; break;
		case "tools":     inv.shopStock = shop_tools_stock(); inv.shopTitle = "Whitlow Tools"; break;
		case "guild_ranged": inv.shopStock = shop_list([["m|arrow", 5], ["c|held|Slingshot", 300], ["c|held|Bow", 800], ["c|held|Boomerang", 900], ["c|held|Recurve Bow", 1800], ["c|held|Crossbow", 2400], ["c|held|Great Bow", 3500]]); inv.shopTitle = "Adventurers' Guild - Hask's bows and slings"; break;
		case "guild_melee":  inv.shopStock = shop_list([["c|held|Dagger", 250], ["c|held|Club", 300], ["c|held|Arming Sword", 700], ["c|held|Spear", 800], ["c|held|Saber", 1400], ["c|held|Mace", 1600]]); inv.shopTitle = "Adventurers' Guild - Sir Alaric's blades"; break;
		case "explosives":   inv.shopStock = shop_list([["m|copper_ore", 0], ["m|iron_ore", 0], ["m|coal", 0], ["m|silver_ore", 0]]); inv.shopTitle = "Fen's Mine Stall - ore (explosives coming soon)"; break;
		case "fish":      inv.shopStock = shop_list([["x|sardine", 0], ["x|perch", 0], ["x|seabass", 0]]); inv.shopTitle = "Marlo's Fish Shack"; break;
		case "bakery":    inv.shopStock = shop_list([["f|corn_fritters", 0], ["f|gourd_pie", 0], ["f|hash_browns", 0]]); inv.shopTitle = "Night's Bakery"; break;
		case "flowers":   inv.shopStock = shop_list([["w|herb", 0], ["w|mushroom", 0], ["m|pixie_dust", 0]]); inv.shopTitle = "Posy's Flowers"; break;
		case "furniture": inv.shopStock = shop_furniture_stock(); inv.shopTitle = "Oakhart Furniture - house plans"; break;
		case "hospital":  inv.shopStock = shop_list([["f|antidote", 120], ["w|herb", 0]]); inv.shopTitle = "Uptown Hospital"; break;
		case "olive":     inv.shopStock = shop_list([["m|olive_oil", 0]]); inv.shopTitle = "Saba Olive Press - olive oil"; break;
		case "tinker":    inv.shopStock = shop_list([["m|gear", 0], ["o|sprinkler", 0]]); inv.shopTitle = "Brassbolt's Tinker Workshop (the rail cart is coming)"; break;
		case "boatyard":  inv.shopStock = shop_list([["m|rope", 0], ["m|wood", 0]]); inv.shopTitle = "Saltwhistle Boatyard (boats are coming)"; break;
		case "glassworks":inv.shopStock = shop_list([["m|glass", 0], ["m|glass_jar", 0]]); inv.shopTitle = "Fairglass Glassworks"; break;
		case "land":      inv.shopStock = pshop_land_stock(); inv.shopTitle = "City Hall - land for sale (standing " + string(pshop_standing().total) + ")"; break;   // the Mayor (scripts/pshops)
		case "stables":   inv.shopStock = shop_list([["m|horse_feed", 0], ["m|saddle", 0]]); inv.shopTitle = "Hayward Stables (horses are coming)"; break;
	}
}

/// @description A stock list from [[id, price]...]: price 0 means half again what it's worth.
function shop_list(_pairs){
	var out = [];
	for(var i = 0; i < array_length(_pairs); i++){
		var d = item_def(_pairs[i][0]);
		if(d == undefined) continue;
		array_push(out, {id: _pairs[i][0], price: (_pairs[i][1] > 0) ? _pairs[i][1] : max(2, round(d.price * 1.5))});
	}
	return out;
}

/// @description Poupry's milk, wool and eggs.
function shop_produce_stock(){ return shop_list([["a|milk", 0], ["a|egg", 0], ["m|wool", 0]]); }

/// @description The Night farm's honey (the farm's own beehives) - a sweet food until honey is an item of its own.
function shop_honey_stock(){ return shop_list([["a|honey", 0], ["f|gourd_pie", 0]]); }

// ---------------------------------------------------------------- Brindlemoor's shops

/// @description Thorne's timber yard: wood, stone and fibre for building and crafting, at twice their value.
function shop_carpentry_stock(){
	static ids = ["m|wood", "m|stone", "m|fibre"];
	var out = [];
	for(var i = 0; i < array_length(ids); i++) array_push(out, {id: ids[i], price: max(2, item_def(ids[i]).price * 2)});
	return out;
}

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
	              ["w|herb", 0], ["w|mushroom", 0], ["w|toadstool", 0], ["m|pixie_dust", 0], ["f|forest_stew", 0], ["f|moonfin_soup", 0], ["f|antidote", 120]];
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
	return instance_exists(obj_inventory) || dialogue_open() || mine_menu_open() || instance_exists(obj_fishing) || instance_exists(obj_world_map)
	       || (instance_exists(obj_quest_board) && obj_quest_board.open) || transit_menu_open() || plot_menu_open();
}
