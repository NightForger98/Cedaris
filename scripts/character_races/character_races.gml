/// Playable races for the character creator. Edit this table to add or change races.
///
/// Each race:
///   name, desc   - shown in the creator
///   bodies       - body types the race can have
///   skins        - skin palette names (lpc body palettes)
///   only         - per slot, the only items allowed (by catalog name); slots not listed allow anything
///   none         - slots the race can never use
///   require      - slots that must always have an item
///   chance       - per slot, chance of being empty when randomising (overrides the slot default)
///   weight       - how often the race appears among random villagers
function character_races(){
	static races = undefined;
	if(races != undefined) return races;

	var natural = ["light", "amber", "olive", "taupe", "bronze", "brown", "black"];
	var greens  = ["green", "dark_green", "bright_green", "pale_green"];
	var fur     = ["fur_brown", "fur_tan", "fur_grey", "fur_copper", "fur_gold", "fur_white", "fur_black"]; // first one is the default
	var humanHeads = ["Human Male", "Human Female", "Human Male Small", "Human Female Small", "Human Male Gaunt",
	                  "Human Male Plump", "Human Male Elderly", "Human Female Elderly", "Human Elderly Small", "Human Child"];
	var elfEars = ["Elven ears", "Medium Elven Ears", "Downward Elven Ears", "Hanging Elven Ears"];
	var beastFace = ["ears", "nose", "beard", "eyebrows"]; // beast heads already have their own

	races = [
		{name: "Human", desc: "Hardy, adaptable folk found in every valley.",
		 bodies: ["male", "female", "muscular", "teen", "pregnant", "child"], skins: natural,
		 only: {head: humanHeads, ears: ["Big ears"], eyes: []}, none: [], require: [], chance: {ears: 0.9}, weight: 40},
		{name: "Elf", desc: "Long-lived and graceful, with pointed ears and no patience for beards.",
		 bodies: ["male", "female", "teen", "pregnant", "child"], skins: array_concat(natural, ["lavender", "pale_green"]),
		 only: {head: ["Human Male", "Human Female", "Human Male Small", "Human Female Small", "Human Male Gaunt", "Human Child"],
		        ears: elfEars, nose: ["Straight nose", "Button nose"], eyes: []},
		 none: ["beard"], require: ["ears"], chance: {}, weight: 12},
		{name: "Dwarf", desc: "Broad, stubborn and proud of their beards.",
		 // Muscular bodies have no shirts in the LPC art, so the regular bodies come first
		 bodies: ["male", "female", "muscular", "child"], skins: natural,
		 only: {head: ["Human Male Plump", "Human Male Elderly", "Human Female Elderly", "Human Elderly Small", "Human Male", "Human Female", "Human Child"],
		        ears: ["Big ears"], eyes: []},
		 none: [], require: [], chance: {beard: 0.1, ears: 0.7}, weight: 10},
		{name: "Halfling", desc: "Small, cheerful and always hungry.",
		 // Teen is LPC's small adult: full wardrobe and tools. Child is for halfling kids (very few clothes, no tools)
		 bodies: ["teen", "child"], skins: natural,
		 only: {head: ["Human Male Small", "Human Female Small", "Human Child"], ears: ["Big ears", "Long ears"], eyes: []},
		 none: [], require: [], chance: {ears: 0.4}, weight: 6},
		{name: "Beastkin", desc: "Human in face, with the ears of a cat, wolf or bird.",
		 bodies: ["male", "female", "teen", "pregnant", "child"], skins: natural,
		 only: {head: humanHeads, ears: ["Side Cat Ears", "Side Wolf Ears", "Feather Ears"], eyes: []},
		 none: [], require: ["ears"], chance: {}, weight: 6},
		{name: "Orc", desc: "Strong-tusked farmers of the hill country.",
		 bodies: ["male", "female", "muscular", "pregnant", "child"], skins: array_concat(greens, ["olive"]),
		 only: {head: ["Orc male", "Orc female", "Orc child"], eyes: []}, none: beastFace, require: [], chance: {}, weight: 8},
		{name: "Goblin", desc: "Small, sly and surprisingly good with turnips.",
		 // Small: teen body by default (full wardrobe and tools), child body for goblin kids
		 bodies: ["teen", "child"], skins: array_concat(greens, ["olive"]),
		 only: {head: ["Goblin", "Goblin child"], eyes: []}, none: beastFace, require: [], chance: {}, weight: 6},
		{name: "Troll", desc: "Huge and slow, with skin like river stone.",
		 bodies: ["muscular", "child"], skins: ["blue", "lavender", "green", "dark_green", "zombie_green"],
		 only: {head: ["Troll", "Troll child"]}, none: beastFace, require: [], chance: {eyes: 0.8}, weight: 3},
		{name: "Wolfkin", desc: "Loyal pack folk with keen noses.",
		 bodies: ["male", "female", "muscular", "teen", "pregnant", "child"], skins: fur,
		 only: {head: ["Wolf male", "Wolf female", "Wolf child"], eyes: []}, none: beastFace, require: [], chance: {}, weight: 4},
		{name: "Minotaur", desc: "Horned giants who plough a field in an afternoon.",
		 bodies: ["male", "female", "muscular", "child"], skins: fur,
		 only: {head: ["Minotaur", "Minotaur female", "Wartotaur", "Minotaur child"], eyes: []}, none: beastFace, require: [], chance: {}, weight: 3},
		{name: "Boarfolk", desc: "Tough, tusked and fond of mud.",
		 bodies: ["male", "female", "muscular", "teen", "pregnant", "child"], skins: array_concat(["light"], fur),
		 only: {head: ["Boarman", "Pig", "Boarman child", "Pig child"], eyes: []}, none: beastFace, require: [], chance: {}, weight: 3},
		{name: "Ratfolk", desc: "Quick, clever, and never far from the grain store.",
		 bodies: ["male", "female", "teen", "pregnant", "child"], skins: fur,
		 only: {head: ["Rat", "Mouse", "Rat child", "Mouse child"], eyes: []}, none: beastFace, require: [], chance: {}, weight: 3},
		{name: "Rabbitfolk", desc: "Fast diggers with an eye for carrots.",
		 bodies: ["male", "female", "teen", "pregnant", "child"], skins: fur,
		 only: {head: ["Rabbit", "Rabbit child"], eyes: []}, none: beastFace, require: [], chance: {}, weight: 3},
		{name: "Sheepfolk", desc: "Gentle, woolly and very warm in winter.",
		 bodies: ["male", "female", "teen", "pregnant", "child"], skins: fur,
		 only: {head: ["Sheep", "Sheep child"], eyes: []}, none: beastFace, require: [], chance: {}, weight: 2},
		{name: "Lizardfolk", desc: "Scaled swamp-dwellers who love the hot sun.",
		 bodies: ["male", "female", "muscular", "teen", "pregnant", "child"], skins: array_concat(greens, ["blue", "lavender"]),
		 only: {head: ["Lizard male", "Lizard female", "Lizard child"], ears: ["Dragon Ears"], eyes: []},
		 none: ["nose", "beard", "eyebrows"], require: [], chance: {ears: 0.7}, weight: 4},
		{name: "Vampire", desc: "Pale night-farmers. Avoid the garlic patch.",
		 bodies: ["male", "female", "muscular", "teen"], skins: ["light", "taupe", "lavender"],
		 only: {head: ["Vampire"], ears: elfEars, eyes: []}, none: ["nose", "beard"], require: [], chance: {ears: 0.6}, weight: 2},
		{name: "Undead", desc: "Back from the grave and still working the land.",
		 bodies: ["male", "female", "muscular", "teen"], skins: ["zombie", "zombie_green", "pale_green"],
		 only: {head: ["Zombie", "Frankenstein", "Skeleton"], eyes: []}, none: beastFace, require: [], chance: {}, weight: 2},
		{name: "Pumpkinhead", desc: "A scarecrow that woke up one harvest night.",
		 bodies: ["male", "female", "muscular", "teen"], skins: natural,
		 only: {head: ["Jack O Lantern"], eyes: []}, none: beastFace, require: [], chance: {}, weight: 1},
		{name: "Visitor", desc: "Nobody knows where they came from.",
		 bodies: ["male", "female", "teen"], skins: ["green", "pale_green", "blue", "lavender"],
		 only: {head: ["Alien"]}, none: beastFace, require: [], chance: {eyes: 0.6}, weight: 1},
	];
	return races;
}

/// @description The race struct called _name (Human if unknown).
function character_race(_name){
	var races = character_races();
	for(var i = 0; i < array_length(races); i++){
		if(races[i].name == _name) return races[i];
	}
	return races[0];
}

/// @description A random race name, weighted by each race's weight.
function character_random_race(){
	var races = character_races();
	var total = 0;
	for(var i = 0; i < array_length(races); i++) total += races[i].weight;
	var r = random(total);
	for(var i = 0; i < array_length(races); i++){
		r -= races[i].weight;
		if(r < 0) return races[i].name;
	}
	return races[0].name;
}

/// Story mode's farmer: a human man or woman. The gender is the first choice in the creator, sets the body type
/// (look.body), is kept in look.gender (saved with the look) and decides which heads, hair and beards are offered.
/// Free mode ignores this table.
///   genders - the choices, each also its body type (no teen, child, pregnant or muscular bodies in story mode)
///   keys    - the creator rows (the rest of the look is the worn outfit; clothes are earned in the world)
///   only    - per gender, per slot, the only items allowed (the first is the default for a required slot)
///   never   - per gender, per slot, items never allowed
///   none    - per gender, slots that are always empty
function character_story_rules(){
	static rules = undefined;
	if(rules != undefined) return rules;
	rules = {
		race: "Human",
		genders: ["male", "female"],
		keys: ["body", "head", "eyes", "ears", "nose", "eyebrows", "hair", "beard"],
		// Adult human heads of the right sex only: no child heads, no unisex "Human Elderly Small"
		only: {
			male:   {head: ["Human Male", "Human Male Small", "Human Male Gaunt", "Human Male Plump", "Human Male Elderly"]},
			female: {head: ["Human Female", "Human Female Small", "Human Female Elderly"]},
		},
		// ("not" is a GML keyword, even as a struct key)
		never: {
			male:   {hair: ["Princess", "Pigtails", "Pigtails bangs", "Bunches", "Bangs bun"]},
			female: {hair: ["Balding"]},
		},
		none: {male: [], female: ["beard"]},
	};
	return rules;
}
