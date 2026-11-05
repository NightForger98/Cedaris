/// Items: definitions, materials, crafting recipes, stats, icons and the blacksmith's stock.
///
/// Item ids are strings:
///   "c|<slot>|<catalog name>"  clothing or held item from the LPC catalog, e.g. "c|shirt|Longsleeve", "c|held|Hoe"
///   "m|<material>"             crafting material, e.g. "m|linen", "m|dragon_scale"
///   "d|<palette material>|<colour>"  dye that recolours equipment, e.g. "d|cloth|red", "d|metal|gold"
///   "s|<crop>", "p|<crop>|<quality>"  seeds and produce (see farming); "f|<dish>" cooked food (see food)
///   "k|<spell>"                spell scroll (see magic)
///   "w|<forage>"               something wild from the woods (see forest)
///   "o|<kind>"                 something you place, like a sprinkler (see placeables)
///   "x|<fish>"                 a fish (see fishing)
///   "n|<animal>", "a|<product>"  a crate of livestock, eggs and milk (see animals)
/// A stack is {id, count, pal} - pal is an optional palette name giving clothing its own colour.
///
/// Stats: clothing gets its stats from the materials in its recipe (item_stats), and everything
/// equipped adds up (inv_stats). Speed changes walking speed and Charm lowers shop prices;
/// the rest are ready for future systems (combat, seasons, crops, magic).

#macro STAT_KEYS ["defense", "warmth", "speed", "stamina", "luck", "charm", "magic"]

/// @description Display names for stats.
function item_stat_name(_key){
	switch(_key){
		case "defense": return "Defence";
		case "warmth":  return "Warmth";
		case "speed":   return "Speed";
		case "stamina": return "Stamina";
		case "luck":    return "Luck";
		case "charm":   return "Charm";
		case "magic":   return "Magic";
	}
	return _key;
}

/// @description Rarity names and colours (tier 0-3).
function item_tier_name(_t){ static n = ["Common", "Uncommon", "Rare", "Legendary"]; return n[clamp(_t, 0, 3)]; }
function item_tier_colour(_t){
	static c = [c_white, make_colour_rgb(120, 220, 120), make_colour_rgb(110, 170, 255), make_colour_rgb(255, 170, 60)];
	return c[clamp(_t, 0, 3)];
}

/// @description Crafting materials. Stats are per unit used in a recipe; shape picks the icon.
/// Common and uncommon ones can be bought (Brom sells the metal bars); rare and legendary ones are
/// meant as quest and event rewards.
function item_materials(){
	static m = [
		// Common
		{key: "linen",   name: "Linen",       tier: 0, shape: "cloth",   colour: make_colour_rgb(225, 214, 180), price: 4,  stats: {stamina: 0.5},             desc: "Light, breathable cloth."},
		{key: "cotton",  name: "Cotton",      tier: 0, shape: "cloth",   colour: make_colour_rgb(250, 250, 245), price: 4,  stats: {stamina: 0.5, charm: 0.25}, desc: "Soft cloth for everyday wear."},
		{key: "wool",    name: "Wool",        tier: 0, shape: "cloth",   colour: make_colour_rgb(235, 228, 210), price: 5,  stats: {warmth: 1.5},              desc: "Warm, thick cloth for coats and hats."},
		{key: "leather", name: "Leather",     tier: 0, shape: "hide",    colour: make_colour_rgb(140, 90, 50),   price: 6,  stats: {defense: 1, warmth: 0.5},  desc: "Tough hide for belts, boots and vests."},
		{key: "fur",     name: "Fur",         tier: 0, shape: "hide",    colour: make_colour_rgb(175, 135, 95),  price: 8,  stats: {warmth: 2.5},              desc: "Keeps the winter out."},
		// Marriage (scripts/marriage): the proposal token, and the plans for the next farmhouse upgrade (built overnight)
		{key: "blue_feather", name: "Blue Feather", tier: 0, shape: "feather", colour: make_colour_rgb(80, 140, 235), price: 1000, stats: {}, desc: "A token of love. Give it to the one you want to marry."},
		{key: "house_plans", name: "House Plans", tier: 0, shape: "fibre", colour: make_colour_rgb(230, 220, 190), price: 1000, stats: {}, desc: "Rowan's plans for your farmhouse. Her crew builds it overnight."},
		// The new families' workshops (2026-11-06): olive oil, glass, rope, gears, horse things
		{key: "olive_oil", name: "Olive Oil",  tier: 0, shape: "orb",   colour: make_colour_rgb(190, 180, 60),  price: 40,  stats: {}, desc: "Pressed at the Saba olive press in Olive Bay."},
		{key: "glass",     name: "Glass",      tier: 0, shape: "gem",   colour: make_colour_rgb(190, 230, 240), price: 20,  stats: {}, desc: "Clear glass from the Fairglass glassworks."},
		{key: "glass_jar", name: "Glass Jar",  tier: 0, shape: "orb",   colour: make_colour_rgb(210, 240, 245), price: 30,  stats: {}, desc: "For jams and pickles, one day."},
		{key: "rope",      name: "Rope",       tier: 0, shape: "fibre", colour: make_colour_rgb(185, 150, 95),  price: 15,  stats: {}, desc: "Boatyard rope, tarred against the sea."},
		{key: "gear",      name: "Gear",       tier: 0, shape: "bar",   colour: make_colour_rgb(200, 165, 70),  price: 35,  stats: {}, desc: "A brass gear from the Brassbolt workshop."},
		{key: "horse_feed",name: "Horse Feed", tier: 0, shape: "fibre", colour: make_colour_rgb(220, 195, 110), price: 12,  stats: {}, desc: "Oats and hay from Hayward Stables."},
		{key: "saddle",    name: "Saddle",     tier: 0, shape: "hide",  colour: make_colour_rgb(120, 75, 40),   price: 600, stats: {}, desc: "For the horse you'll have one day."},
		{key: "feather", name: "Feather",     tier: 0, shape: "feather", colour: make_colour_rgb(240, 240, 250), price: 5,  stats: {speed: 0.75},              desc: "Light as air. Plumes and trims."},
		{key: "bone",    name: "Bone",        tier: 0, shape: "bone",    colour: make_colour_rgb(232, 226, 200), price: 5,  stats: {defense: 0.75},            desc: "Horns, toggles and grim decorations."},
		{key: "copper",  name: "Copper Bar",  tier: 0, shape: "bar",     colour: make_colour_rgb(205, 120, 70),  price: 10, stats: {defense: 1},               icon: [3, 2], desc: "Soft metal for fittings and trims."},
		{key: "iron",    name: "Iron Bar",    tier: 0, shape: "bar",     colour: make_colour_rgb(150, 155, 165), price: 15, stats: {defense: 2, speed: -0.25}, icon: [1, 2], desc: "Chainmail, helmets and armour. Heavy."},
		// Gathered (phase 2): wood, stone and fibre from the land, ore and coal from rocks; ore is smelted into bars
		{key: "wood",       name: "Wood",        tier: 0, shape: "log",   colour: make_colour_rgb(150, 100, 55),  price: 2,  stats: {}, desc: "Chopped from trees and stumps."},
		{key: "stone",      name: "Stone",       tier: 0, shape: "rock",  colour: make_colour_rgb(140, 138, 145), price: 2,  stats: {}, desc: "Broken from rocks. Good for building."},
		{key: "fibre",      name: "Fibre",       tier: 0, shape: "fibre", colour: make_colour_rgb(120, 175, 70),  price: 1,  stats: {}, desc: "Cut from weeds and bushes. Weave it into linen or cotton at a crafting table."},
		{key: "coal",       name: "Coal",        tier: 0, shape: "rock",  colour: make_colour_rgb(40, 38, 44),    price: 4,  stats: {}, icon: [0, 0], desc: "Fuel for the furnace."},
		{key: "copper_ore", name: "Copper Ore",  tier: 0, shape: "ore",   colour: make_colour_rgb(225, 130, 70),  price: 2,  stats: {}, icon: [3, 0], desc: "Smelt 5 with a coal at Brom's furnace for a copper bar."},
		{key: "iron_ore",   name: "Iron Ore",    tier: 0, shape: "ore",   colour: make_colour_rgb(200, 175, 160), price: 3,  stats: {}, icon: [1, 0], desc: "Smelt 5 with a coal at Brom's furnace for an iron bar."},
		// Uncommon
		{key: "silk",    name: "Silk",        tier: 1, shape: "cloth",   colour: make_colour_rgb(230, 150, 200), price: 14, stats: {charm: 1.5},               desc: "Fine fabric for robes, dresses and capes."},
		{key: "silver_ore", name: "Silver Ore",  tier: 1, shape: "ore",   colour: make_colour_rgb(235, 240, 250), price: 6,  stats: {}, icon: [4, 0], desc: "Smelt 5 with a coal at Brom's furnace for a silver bar."},
		{key: "gold_ore",   name: "Gold Ore",    tier: 1, shape: "ore",   colour: make_colour_rgb(250, 210, 60),  price: 9,  stats: {}, icon: [5, 0], desc: "Smelt 5 with a coal at Brom's furnace for a gold bar."},
		{key: "silver",  name: "Silver Bar",  tier: 1, shape: "bar",     colour: make_colour_rgb(215, 220, 230), price: 30, stats: {charm: 1, magic: 0.5},     icon: [4, 2], desc: "Jewellery, lenses and fine fittings."},
		{key: "steel",   name: "Steel Bar",   tier: 1, shape: "bar",     colour: make_colour_rgb(115, 130, 150), price: 35, stats: {defense: 3, speed: -0.25}, icon: [7, 2], desc: "Refined iron for plate and great helms."},
		{key: "gold",    name: "Gold Bar",    tier: 1, shape: "bar",     colour: make_colour_rgb(245, 205, 60),  price: 45, stats: {charm: 2},                 icon: [5, 2], desc: "For crowns, rings and showing off."},
		{key: "gem",     name: "Gemstone",    tier: 1, shape: "gem",     colour: make_colour_rgb(90, 220, 230),  price: 40, stats: {luck: 1.5, charm: 1},      desc: "Sparkly. Jewellers love it."},
		// Rare
		{key: "troll_hide",    name: "Troll Hide",    tier: 2, shape: "hide",  colour: make_colour_rgb(105, 140, 90),  price: 90,  stats: {defense: 2, stamina: 2}, desc: "Thick, rubbery and it never quite stops healing."},
		{key: "frost_crystal", name: "Frost Crystal", tier: 2, shape: "gem",   colour: make_colour_rgb(175, 230, 255), price: 100, stats: {magic: 2, defense: 0.5}, desc: "Cold to the touch, even in summer."},
		{key: "ember_core",    name: "Ember Core",    tier: 2, shape: "orb",   colour: make_colour_rgb(255, 120, 40),  price: 100, stats: {warmth: 4},              desc: "A coal that never goes out."},
		{key: "moonsilk",      name: "Moonsilk",      tier: 2, shape: "cloth", colour: make_colour_rgb(185, 195, 255), price: 120, stats: {magic: 2.5, charm: 1},   desc: "Spun by moths under a full moon."},
		{key: "pixie_dust",    name: "Pixie Dust",    tier: 2, shape: "dust",  colour: make_colour_rgb(255, 170, 240), price: 120, stats: {luck: 2.5, speed: 1},    desc: "Sneeze-inducing and wildly lucky."},
		// Legendary
		{key: "mithril_ore",     name: "Mithril Ore",     tier: 3, shape: "ore",     colour: make_colour_rgb(180, 240, 255), price: 60,  stats: {},                            icon: [2, 0], desc: "From the deepest rock. Smelt 5 with 2 coal for a mithril bar."},
		{key: "mithril",         name: "Mithril Bar",     tier: 3, shape: "bar",     colour: make_colour_rgb(200, 235, 245), price: 300, stats: {defense: 3, speed: 0.25},      icon: [2, 2], desc: "Stronger than steel and light as linen."},
		{key: "dragon_scale",    name: "Dragon Scale",    tier: 3, shape: "scale",   colour: make_colour_rgb(205, 50, 40),   price: 350, stats: {defense: 4, warmth: 2},        desc: "Shed by a dragon. Shrugs off flame."},
		{key: "phoenix_feather", name: "Phoenix Feather", tier: 3, shape: "feather", colour: make_colour_rgb(255, 140, 30),  price: 350, stats: {magic: 2, warmth: 2, speed: 1}, desc: "Warm, and it glows at night."},
		{key: "unicorn_hair",    name: "Unicorn Hair",    tier: 3, shape: "feather", colour: make_colour_rgb(250, 235, 255), price: 350, stats: {luck: 3, magic: 2, charm: 1}, desc: "A single silvery strand. Utterly charming."},
		{key: "void_pearl",      name: "Void Pearl",      tier: 3, shape: "orb",     colour: make_colour_rgb(95, 40, 145),   price: 400, stats: {magic: 4, luck: 1},           desc: "Darker than night. Hums quietly."},
	];
	return m;
}

function item_material(_key){
	var m = item_materials();
	for(var i = 0; i < array_length(m); i++) if(m[i].key == _key) return m[i];
	return undefined;
}

/// @description Definition of an item id: {id, type, name, desc, max, price, tier, stats, ...}. Cached.
function item_def(_id){
	static cache = {};
	var d = cache[$ _id];
	if(d != undefined) return d;
	var p = string_split(_id, "|");
	switch(p[0]){
		case "c":
			var idx = character_find_item(p[1], p[2]);
			var held = (p[1] == "held");
			d = {id: _id, type: held ? "held" : "clothing", slot: p[1], name: p[2], cat: idx, max: 1, tier: 0, stats: {},
			     price: held ? item_shop_price(_id) : 20,
			     desc: held ? "Select it on the hotbar to hold it." : "Equip in the " + item_slot_label(p[1]) + " slot."};
			if(idx != -1) d.material = lpc_catalog().items[idx].material;
			if(!held && idx != -1){
				// Stats, rarity and value follow the recipe's materials
				var cost = item_recipe_cost(p[1], d.material, p[2]);
				d.stats = item_stats_from_cost(cost);
				d.tier = item_cost_tier(cost);
				d.price = item_cost_value(cost);
			}
			break;
		case "m":
			var mt = item_material(p[1]);
			if(mt != undefined){
				d = {id: _id, type: "material", name: mt.name, desc: mt.desc, max: 99, price: mt.price, colour: mt.colour,
				     shape: mt.shape, tier: mt.tier, stats: {}, icon: mt[$ "icon"]};   // icon: [column, row] on spr_ore_icons, if it has art
			}
			break;
		case "s":
			var ci = crop_index(p[1]);
			if(ci != -1){
				var ct = crop_table()[ci];
				d = {id: _id, type: "seed", crop: ci, name: ct.name + " Seeds", max: 99, price: ct.seed, tier: 0, stats: {},
				     desc: "Plant on tilled soil in " + crop_seasons_text(ci) + ". Ripe after " + string(crop_days_to_ripe(ci)) + " watered days"
				           + ((ct.regrow > 0) ? ", then every " + string(ct.regrow) + "." : ".")};
			}
			break;
		case "p":
			var ci = crop_index(p[1]);
			if(ci != -1){
				var q = real(p[2]);
				var ct = crop_table()[ci];
				d = {id: _id, type: "produce", crop: ci, quality: q, max: 99, price: produce_price(ci, q) * 2, tier: q, stats: {},
				     name: ["", "Silver ", "Gold "][q] + ct.name,
				     desc: "Ship it, or hold it and use it to eat (+" + string(round(ct.energy * (1 + q * 0.4))) + " energy)."};
			}
			break;
		case "n":
			var ak = animal_def(p[1]);
			if(ak != undefined){
				d = {id: _id, type: "crate", kind: p[1], name: ak.name + " (crate)", max: 1, price: ak.price, tier: 1, stats: {},
				     desc: "Hold it on your farm and use it to let your new " + string_lower(ak.name) + " out into the meadow."};
			}
			break;
		case "a":
			var ap = animal_products()[$ p[1]];
			if(ap != undefined){
				d = {id: _id, type: "animalproduct", product: p[1], name: ap.name, max: 99, price: ap.sell * 2, tier: 0, stats: {}, colour: ap.colour,
				     desc: ap.desc + " Cook with it, or hold it and use it (+" + string(ap.energy) + " energy)."};
			}
			break;
		case "x":
			var fd = fish_def(p[1]);
			if(fd != undefined){
				d = {id: _id, type: "fish", fish: p[1], name: fd.name, max: 99, price: fd.sell * 2, tier: (fd.hard >= 0.5) ? 1 : 0, stats: {},
				     desc: (fd[$ "junk"] ?? false) ? "Someone lost this a long time ago." : "Sell it, cook it, or hold it and use it to eat it raw (+" + string(fd.energy) + " energy)."};
			}
			break;
		case "o":
			var pl = placeable_def(p[1]);
			if(pl != undefined){
				d = {id: _id, type: "placeable", kind: p[1], name: pl.name, max: 20, price: item_cost_value(pl.cost), tier: 1, stats: {},
				     desc: pl.desc + " Hold it and use it to place it in front of you; a pickaxe picks it back up."};
			}
			break;
		case "w":
			var fg = forage_table()[$ p[1]];
			if(fg != undefined){
				d = {id: _id, type: "forage", forage: p[1], name: fg.name, max: 99, price: fg.sell * 2, tier: 0, stats: {}, art: fg.art,
				     desc: fg.desc + ((fg.energy > 0) ? " Hold it and use it to eat (+" + string(fg.energy) + " energy)." : "")};
			}
			break;
		case "k":
			var sp = spell_def(p[1]);
			if(sp != undefined){
				d = {id: _id, type: "scroll", spell: sp.key, name: "Scroll of " + sp.name, max: 9, price: 200, tier: 2, stats: {}, colour: sp.colour,
				     desc: sp.desc + " Hold it and use it to learn the spell (" + string(sp.mana) + " mana)."};
			}
			break;
		case "f":
			var dt = dish_def(p[1]);
			if(dt != undefined){
				d = {id: _id, type: "food", dish: dt, name: dt.name, max: 99, price: dish_price(dt), tier: 1, stats: {}, colour: dt.colour,
				     desc: "Hold it and use it to eat: +" + string(dt.energy) + " energy, " + dish_buff_text(dt) + "."};
			}
			break;
		case "d":
			var colour = string_replace_all(p[2], "_", " ");
			var nice = string_upper(string_char_at(colour, 1)) + string_delete(colour, 1, 1);
			d = {id: _id, type: "dye", material: p[1], colour: p[2], max: 30, price: 15, tier: 1, stats: {},
			     pal: character_find_palette(p[1], p[2]),
			     name: nice + ((p[1] == "metal") ? " Polish" : " Dye"),
			     desc: (p[1] == "metal") ? "Put it in a dye slot to recolour metal gear." : "Put it in a dye slot to recolour cloth and leather."};
			break;
	}
	if(d == undefined) d = {id: _id, type: "unknown", name: _id, desc: "", max: 1, price: 0, tier: 0, stats: {}};
	cache[$ _id] = d;
	return d;
}

function item_stack(_id, _count = 1, _pal = ""){ return {id: _id, count: _count, pal: _pal}; }

/// @description Equipment slots shown in the inventory, in two columns of eight.
function item_equip_slots(){
	static s = ["hat", "face", "earrings", "neck", "shirt", "vest", "coat", "cape",
	            "belt", "pants", "shoes", "shoulders", "bauldron", "wrist", "gloves", "back"];
	return s;
}

function item_slot_label(_key){
	var slot = character_slot_by_key(_key);
	return (slot == undefined) ? _key : slot.label;
}

// ---------------------------------------------------------------- recipes

/// @description Recipes for particular items, by exact catalog name. These come first.
function item_recipe_named(){
	static r = {
		"Crown":                     {gold: 3, gem: 2, void_pearl: 1},
		"Tiara":                     {silver: 2, gem: 1, unicorn_hair: 1},
		"Celestial Wizard Hat":      {moonsilk: 3, pixie_dust: 2, frost_crystal: 1},
		"Celestial Wizard Moon Hat": {moonsilk: 3, pixie_dust: 2, void_pearl: 1},
		"Wizard Hat Base":           {moonsilk: 2, linen: 1},
		"Christmas Hat":             {wool: 2, fur: 1},
		"Plate":                     {steel: 4, dragon_scale: 1},
		"Leather":                   {leather: 3, troll_hide: 1},
		"Iverness cloak":            {wool: 3, ember_core: 1},
		"Sunglasses":                {silver: 1, frost_crystal: 1},
		"Shades":                    {silver: 1, frost_crystal: 1},
		"Bauldron":                  {iron: 2, dragon_scale: 1},
		"Gloves":                    {leather: 2, fur: 1},
		"Solid":                     {silk: 3},                 // the plain cape
		"Jetpack":                   {copper: 3, ember_core: 1},
		"Quiver":                    {leather: 2, feather: 2},
		"Basket":                    {linen: 2},
		"Tattered":                  {linen: 3},                // the tattered cape
		"Bandages":                  {linen: 1},
		"Hoofs":                     {iron: 2},                 // horseshoes, naturally
	};
	return r;
}

/// @description Keyword rules, checked in order against the item's name (lower case). slots: optional limit.
function item_recipe_rules(){
	static r = [
		{k: ["legion", "centurion", "maximus"],                     cost: {steel: 3, phoenix_feather: 1}},
		{k: ["xion", "xeon"],                                       cost: {mithril: 2, frost_crystal: 1}},
		{k: ["greathelm", "great helm", "sugarloaf", "closehelm", "close helm"], cost: {steel: 3, troll_hide: 1}},
		{k: ["horn"],                                               cost: {iron: 3, bone: 2}},
		{k: ["viking", "barbarian"],                                cost: {iron: 2, fur: 2}},
		{k: ["armet", "bascinet", "barbuta", "visor", "grated"],    cost: {steel: 3, leather: 1}},
		{k: ["chain", "mail"],                                      cost: {iron: 4}},
		{k: ["helm", "nasal", "kettle", "morion", "norman", "pigface", "flattop", "pagan"], cost: {iron: 3, leather: 1}},
		{k: ["armour", "armor", "plate", "overarmor"],              cost: {iron: 4, leather: 2}},
		{k: ["pauldron"],                                           cost: {iron: 2, leather: 1}},
		{k: ["epaulet", "mantal", "mantle"],                        cost: {gold: 1, silk: 1}},
		{k: ["admiral", "commodore", "captain"],                    cost: {wool: 2, leather: 1, gold: 1}},
		{k: ["plume", "plumage", "crest", "feather", "cavalier", "bonnie"], cost: {wool: 2, feather: 2}},
		{k: ["tricorne", "bicorne", "pirate"],                      cost: {wool: 2, leather: 1}},
		{k: ["tophat", "bowler"],                                   cost: {wool: 2, silk: 1}},
		{k: ["formal", "collared"], slots: ["shirt", "pants"],      cost: {cotton: 2, silk: 1}},
		{k: ["santa", "winter", "fur"],                             cost: {wool: 2, fur: 2}},
		{k: ["skull"],                                              cost: {leather: 2, bone: 1}},
		{k: ["robe", "kimono", "dress", "blouse", "bodice", "corset", "sash", "obi", "silk"], cost: {silk: 2, cotton: 1}},
		{k: ["hood", "cloak", "trench", "frock", "coat", "jacket", "tabard"], cost: {wool: 3, leather: 1}},
		{k: ["glasses", "monocle"],                                 cost: {silver: 1, gem: 1}},
		{k: ["eyepatch", "mask"],                                   cost: {leather: 1}},
		{k: ["necklace", "pendant", "pearl", "gem", "charm"],       cost: {silver: 1, gem: 1}},
		{k: ["boots"],                                              cost: {leather: 3}},
		{k: ["sandals", "slippers", "ghillies"],                    cost: {leather: 1, linen: 1}},
		{k: ["bracer"],                                             cost: {leather: 2}},
		{k: ["cuffs"],                                              cost: {cotton: 1, silk: 1}},
		{k: ["apron", "overall", "suspender"],                      cost: {linen: 2, leather: 1}},
		{k: ["tshirt", "shirt", "sleeve", "tank", "scoop", "polo", "cardigan"], cost: {cotton: 3}},
		{k: ["skirt", "pants", "leggings", "shorts", "hose"],       cost: {linen: 3}},
		{k: ["bandana", "kerchief", "headband", "hijab", "cap"],    cost: {cotton: 2}},
	];
	return r;
}

/// @description What a clothing item costs to craft: named recipe, else keyword rule, else the slot default.
/// Metal pieces with no specific recipe are smithed from iron.
function item_recipe_cost(_slot, _material, _name){
	var named = item_recipe_named()[$ _name];
	if(named != undefined) return named;
	var low = string_lower(_name);
	var rules = item_recipe_rules();
	for(var i = 0; i < array_length(rules); i++){
		var rule = rules[i];
		if(variable_struct_exists(rule, "slots") && array_get_index(rule.slots, _slot) == -1) continue;
		for(var k = 0; k < array_length(rule.k); k++){
			if(string_pos(rule.k[k], low) > 0) return rule.cost;
		}
	}
	var cost;
	switch(_slot){
		case "hat":       cost = {wool: 2}; break;
		case "face":      cost = {copper: 1, gem: 1}; break;
		case "earrings":  cost = {gold: 1, gem: 1}; break;
		case "neck":      cost = {silver: 1}; break;
		case "shirt":     cost = {linen: 3}; break;
		case "vest":      cost = {leather: 2, linen: 1}; break;
		case "coat":      cost = {wool: 4}; break;
		case "cape":      cost = {silk: 3}; break;
		case "belt":      cost = {leather: 2}; break;
		case "pants":     cost = {linen: 3}; break;
		case "shoes":     cost = {leather: 2}; break;
		case "shoulders": cost = {leather: 2}; break;
		case "bauldron":  cost = {iron: 2}; break;
		case "wrist":     cost = {leather: 1}; break;
		case "gloves":    cost = {leather: 2}; break;
		case "back":      cost = {leather: 3}; break;
		default:          cost = {linen: 1};
	}
	if(_material == "metal"){
		var n = 0, names = variable_struct_get_names(cost);
		for(var i = 0; i < array_length(names); i++) n += cost[$ names[i]];
		cost = {iron: n};
	}
	return cost;
}

/// @description Every clothing recipe: [{id, slot, cat, cost}], built from the catalog. Cached.
function item_recipes(){
	static list = undefined;
	if(list != undefined) return list;
	list = [];
	var slots = item_equip_slots();
	var cat = lpc_catalog().items;
	for(var i = 0; i < array_length(cat); i++){
		if(array_get_index(slots, cat[i].slot) == -1) continue;
		array_push(list, {id: "c|" + cat[i].slot + "|" + cat[i].name, slot: cat[i].slot, cat: i,
		                  cost: item_recipe_cost(cat[i].slot, cat[i].material, cat[i].name)});
	}
	return list;
}

/// @description Dye recipes, offered in free mode only (story mode dyes come from quests and events).
function item_dye_ids(){
	static ids = undefined;
	if(ids != undefined) return ids;
	ids = [];
	var p = lpc_catalog().palettes;
	for(var i = 0; i < array_length(p.cloth_names); i++) array_push(ids, "d|cloth|" + string_replace_all(p.cloth_names[i], " ", "_"));
	for(var i = 0; i < array_length(p.metal_names); i++) array_push(ids, "d|metal|" + string_replace_all(p.metal_names[i], " ", "_"));
	return ids;
}

// ---------------------------------------------------------------- stats

/// @description Stats from a recipe: each material's per-unit stats times how many are used, rounded.
function item_stats_from_cost(_cost){
	var out = {};
	var names = variable_struct_get_names(_cost);
	for(var i = 0; i < array_length(names); i++){
		var mt = item_material(names[i]);
		if(mt == undefined) continue;
		var sn = variable_struct_get_names(mt.stats);
		for(var s = 0; s < array_length(sn); s++){
			out[$ sn[s]] = (out[$ sn[s]] ?? 0) + mt.stats[$ sn[s]] * _cost[$ names[i]];
		}
	}
	var keys = variable_struct_get_names(out);
	for(var i = 0; i < array_length(keys); i++){
		out[$ keys[i]] = round(out[$ keys[i]]);
		if(out[$ keys[i]] == 0) variable_struct_remove(out, keys[i]);
	}
	return out;
}

/// @description Rarity of something made from these materials: its rarest ingredient.
function item_cost_tier(_cost){
	var t = 0, names = variable_struct_get_names(_cost);
	for(var i = 0; i < array_length(names); i++){
		var mt = item_material(names[i]);
		if(mt != undefined) t = max(t, mt.tier);
	}
	return t;
}

/// @description Value of a crafted item: what its materials are worth, plus a bit for the work.
function item_cost_value(_cost){
	var v = 0, names = variable_struct_get_names(_cost);
	for(var i = 0; i < array_length(names); i++){
		var mt = item_material(names[i]);
		if(mt != undefined) v += mt.price * _cost[$ names[i]];
	}
	return round(v * 1.25);
}

/// @description Stats line for tooltips, e.g. "+8 Defence, -1 Speed".
function item_stats_text(_stats){
	var parts = [], keys = STAT_KEYS;
	for(var i = 0; i < array_length(keys); i++){
		var v = _stats[$ keys[i]];
		if(v == undefined || v == 0) continue;
		array_push(parts, ((v > 0) ? "+" : "") + string(v) + " " + item_stat_name(keys[i]));
	}
	var s = "";
	for(var i = 0; i < array_length(parts); i++) s += ((i > 0) ? ", " : "") + parts[i];
	return s;
}

// ---------------------------------------------------------------- blacksmith

/// @description Brom's stock: farm tools, weapons, then metal bars. [{id, price}]
function item_shop_stock(){
	static s = undefined;
	if(s != undefined) return s;
	var held = [
		["Hoe", 40], ["Watering Can", 40], ["Axe", 60], ["Pickaxe", 60], ["Shovel", 50], ["Hammer", 50], ["Scythe", 90],
		["Dagger", 80], ["Arming Sword", 150], ["Saber", 180], ["Rapier", 200], ["Longsword", 250], ["Glowsword", 600],
		["Mace", 160], ["Flail", 190], ["Waraxe", 220], ["Spear", 120], ["Halberd", 260], ["Cane", 30],
		["Simple staff", 120], ["Gnarled staff", 180], ["Loop staff", 220], ["S staff", 240], ["Diamond staff", 400],
		["Slingshot", 70], ["Crossbow", 300], ["Fishing Rod", 60], ["Club", 60], ["Boomerang", 90], ["Katana", 320],
		["Scimitar", 240], ["Longsword alt", 280], ["Long spear", 200], ["Trident", 280], ["Dragon spear", 450],
	];
	s = [];
	for(var i = 0; i < array_length(held); i++) array_push(s, {id: "c|held|" + held[i][0], price: held[i][1]});
	var bars = ["copper", "iron", "steel", "silver", "gold"];
	for(var i = 0; i < array_length(bars); i++) array_push(s, {id: "m|" + bars[i], price: item_material(bars[i]).price});
	array_push(s, {id: "m|coal", price: 8}); // for the furnace, until you find your own
	array_push(s, {id: "k|light", price: 250}); // for the mine's dark
	return s;
}

function item_shop_price(_id){
	var s = item_shop_stock();
	for(var i = 0; i < array_length(s); i++) if(s[i].id == _id) return s[i].price;
	return 50;
}

/// @description What a stack sells for, per item (shops and the shipping bin). Charm adds 1% per point, up to 20%.
function item_sell_price(_id){
	var d = item_def(_id);
	var base = (d.type == "produce") ? produce_price(d.crop, d.quality) : max(1, floor(d.price / 2));
	return max(1, round(base * (1 + clamp(stat("charm") * 0.01, 0, 0.2))));
}

// ---------------------------------------------------------------- icons

/// @description Draw a stack's icon centred in a box at (_x, _y) of size _size. _body picks which art to show.
function item_draw_icon(_stack, _x, _y, _size, _body = "male"){
	var d = item_def(_stack.id);
	var cx = _x + _size / 2, cy = _y + _size / 2;
	switch(d.type){
		case "clothing":
		case "held":
			if(d.cat == -1) break;
			var pal = (_stack.pal != "") ? asset_get_index(_stack.pal) : -1;
			var it = lpc_catalog().items[d.cat];
			if(variable_struct_exists(it, "icon")){
				// Tools and weapons: the frame where the item is largest, cropped tight (measured by tools/lpc/icons.ps1)
				var ic = it.icon;
				var sc = (_size - 6) / max(ic.crop[2], ic.crop[3]);
				character_draw_item(d.cat, _body, pal, ic.col, ic.row, ic.crop,
				                    cx - ic.crop[2] * sc / 2, cy - ic.crop[3] * sc / 2, sc, ic.act);
				// Upgraded tools: a dot in the colour of their metal
				var tt = (d.type == "held") ? tool_tier(d.name) : 0;
				if(curse_locked(_stack)) tt = TOOL_CURSED;   // a cursed weapon gets the purple dot too
				if(tt > 0){
					draw_set_colour(c_black);
					draw_circle(_x + 9, _y + _size - 9, 6, false);
					draw_set_colour(tool_tier_colour(tt));
					draw_circle(_x + 9, _y + _size - 9, 5, false);
				}
				break;
			}
			// Clothing: zoom into the part of the 64x64 frame where this slot's art sits
			var r = item_icon_crop(d.slot);
			var sc = _size / max(r[2], r[3]);
			character_draw_item(d.cat, _body, pal, 0, 10, r, cx - r[2] * sc / 2, cy - r[3] * sc / 2, sc);
			break;
		case "material":
			// Ores, coal and bars: [LPC] Ore and Forge by bluecarrot16 (spr_ore_icons, 32 x 32 cells); the rest drawn
			if(d.icon != undefined){ var isz = _size * 0.85; draw_sprite_part_ext(spr_ore_icons, 0, d.icon[0] * 32, d.icon[1] * 32, 32, 32, cx - isz / 2, cy - isz / 2, isz / 32, isz / 32, c_white, 1); }
			else item_draw_material(d.shape, d.colour, cx, cy, _size * 0.34);
			break;
		case "produce":
			draw_sprite_stretched(spr_crops_picked, d.crop, cx - _size * 0.4, cy - _size * 0.4, _size * 0.8, _size * 0.8);
			if(d.quality > 0){
				// Quality star: silver or gold
				draw_set_colour(d.quality == 2 ? make_colour_rgb(250, 200, 50) : make_colour_rgb(200, 205, 215));
				draw_circle(_x + 9, _y + _size - 9, 5, false);
			}
			break;
		case "seed":
			// Seed packet with the crop on it
			draw_set_colour(make_colour_rgb(190, 160, 110));
			draw_roundrect_ext(cx - _size * 0.3, cy - _size * 0.36, cx + _size * 0.3, cy + _size * 0.36, 6, 6, false);
			draw_set_colour(make_colour_rgb(120, 90, 55));
			draw_roundrect_ext(cx - _size * 0.3, cy - _size * 0.36, cx + _size * 0.3, cy + _size * 0.36, 6, 6, true);
			draw_sprite_stretched(spr_crops_picked, d.crop, cx - _size * 0.24, cy - _size * 0.26, _size * 0.48, _size * 0.48);
			break;
		case "placeable":
			placeable_draw(d.kind, cx, cy + _size * 0.2, _size / 30);
			break;
		case "fish":
			fish_draw_icon(d.fish, cx, cy, _size * 0.36);
			break;
		case "crate":
			// A slatted crate with the animal peeking out (its facing-down frame)
			var ad = animal_def(d.kind), as = (_size * 0.7) / ((ad.fw > 64) ? ad.fw * 0.6 : ad.fw);
			draw_set_colour(make_colour_rgb(120, 85, 50));
			draw_rectangle(cx - _size * 0.38, cy - _size * 0.1, cx + _size * 0.38, cy + _size * 0.36, false);
			draw_sprite_part_ext(ad.spr, 0, 0, 2 * ad.fw, ad.fw, ad.fw, cx - ad.fw * as / 2, cy - ad.fw * as * 0.75, as, as, c_white, 1);
			draw_set_colour(make_colour_rgb(160, 120, 70));
			for(var l = 0; l < 3; l++) draw_rectangle(cx - _size * 0.38, cy + l * _size * 0.12, cx + _size * 0.38, cy + l * _size * 0.12 + 3, false);
			break;
		case "animalproduct":
			if(d.product == "egg"){
				draw_set_colour(merge_colour(d.colour, c_black, 0.3));
				draw_ellipse(cx - _size * 0.24, cy - _size * 0.32, cx + _size * 0.24, cy + _size * 0.3, false);
				draw_set_colour(d.colour);
				draw_ellipse(cx - _size * 0.2, cy - _size * 0.28, cx + _size * 0.2, cy + _size * 0.26, false);
			} else {
				// A milk bottle
				draw_set_colour(make_colour_rgb(150, 170, 190));
				draw_roundrect_ext(cx - _size * 0.2, cy - _size * 0.2, cx + _size * 0.2, cy + _size * 0.36, 6, 6, false);
				draw_rectangle(cx - _size * 0.1, cy - _size * 0.36, cx + _size * 0.1, cy - _size * 0.2, false);
				draw_set_colour(d.colour);
				draw_roundrect_ext(cx - _size * 0.16, cy - _size * 0.08, cx + _size * 0.16, cy + _size * 0.32, 5, 5, false);
			}
			draw_set_colour(c_white);
			break;
		case "forage":
			// The plant itself, from the terrain tileset
			var fa = d.art, fs = (_size * 0.8) / max(fa[2], fa[3]);
			draw_sprite_part_ext(spr_tile_terrain, 0, fa[0], fa[1], fa[2], fa[3], cx - fa[2] * fs / 2, cy - fa[3] * fs / 2, fs, fs, c_white, 1);
			break;
		case "scroll":
			// A rolled parchment tied with a ribbon in the spell's colour
			var sw = _size * 0.3, sh = _size * 0.38;
			draw_set_colour(make_colour_rgb(120, 95, 60));
			draw_roundrect_ext(cx - sw - 2, cy - sh - 2, cx + sw + 2, cy + sh + 2, 6, 6, false);
			draw_set_colour(make_colour_rgb(235, 220, 180));
			draw_roundrect_ext(cx - sw, cy - sh, cx + sw, cy + sh, 5, 5, false);
			draw_set_colour(make_colour_rgb(200, 180, 140));
			for(var l = -2; l <= 2; l++) draw_line(cx - sw * 0.6, cy + l * sh * 0.3, cx + sw * 0.6, cy + l * sh * 0.3);
			draw_set_colour(d.colour);
			draw_rectangle(cx - sw - 2, cy - 3, cx + sw + 2, cy + 3, false);
			break;
		case "food":
			// A bowl of it, steaming
			var bw = _size * 0.36;
			draw_set_colour(merge_colour(d.colour, c_white, 0.6));
			draw_line_width(cx - bw * 0.3, cy - _size * 0.12, cx - bw * 0.15, cy - _size * 0.32, 2);
			draw_line_width(cx + bw * 0.2, cy - _size * 0.12, cx + bw * 0.35, cy - _size * 0.3, 2);
			draw_set_colour(make_colour_rgb(110, 75, 45));
			draw_ellipse(cx - bw, cy - _size * 0.08, cx + bw, cy + _size * 0.3, false);
			draw_set_colour(d.colour);
			draw_ellipse(cx - bw * 0.85, cy - _size * 0.1, cx + bw * 0.85, cy + _size * 0.08, false);
			draw_set_colour(merge_colour(d.colour, c_white, 0.35));
			draw_ellipse(cx - bw * 0.5, cy - _size * 0.07, cx - bw * 0.05, cy + _size * 0.0, false);
			break;
		case "dye":
			// A little bottle filled with the palette's colours
			var bw = _size * 0.36, bh = _size * 0.46;
			draw_set_colour(c_black);
			draw_roundrect_ext(cx - bw / 2 - 2, cy - bh / 2 + 2, cx + bw / 2 + 2, cy + bh / 2 + 6, 8, 8, false);
			if(d.pal != -1) draw_sprite_stretched(d.pal, 0, cx - bw / 2, cy - bh / 2 + 4, bw, bh);
			draw_set_colour(make_colour_rgb(150, 110, 70));
			draw_rectangle(cx - bw / 5, cy - bh / 2 - 6, cx + bw / 5, cy - bh / 2 + 4, false);
			break;
	}
	if(_stack.count > 1){
		draw_set_halign(fa_right);
		draw_set_valign(fa_bottom);
		draw_text_transformed_colour(_x + _size - 3, _y + _size, string(_stack.count), 0.5, 0.5, 0, c_white, c_white, c_white, c_white, 1);
	}
}

/// @description Simple drawn icons for materials without art (ores and bars have spr_ore_icons), centred on (_cx, _cy).
function item_draw_material(_shape, _col, _cx, _cy, _r){
	var light = merge_colour(_col, c_white, 0.5), dark = merge_colour(_col, c_black, 0.45);
	switch(_shape){
		case "bar":     // ingot
			draw_set_colour(dark);
			draw_triangle(_cx - _r, _cy + _r * 0.5, _cx + _r, _cy + _r * 0.5, _cx + _r * 0.7, _cy - _r * 0.4, false);
			draw_triangle(_cx - _r, _cy + _r * 0.5, _cx - _r * 0.7, _cy - _r * 0.4, _cx + _r * 0.7, _cy - _r * 0.4, false);
			draw_set_colour(_col);
			draw_rectangle(_cx - _r * 0.6, _cy - _r * 0.35, _cx + _r * 0.6, _cy + _r * 0.1, false);
			draw_set_colour(light);
			draw_line_width(_cx - _r * 0.5, _cy - _r * 0.25, _cx + _r * 0.3, _cy - _r * 0.25, 2);
			break;
		case "gem":     // cut stone
			draw_set_colour(dark);
			draw_triangle(_cx - _r, _cy - _r * 0.2, _cx + _r, _cy - _r * 0.2, _cx, _cy + _r, false);
			draw_set_colour(_col);
			draw_triangle(_cx - _r * 0.6, _cy - _r * 0.7, _cx + _r * 0.6, _cy - _r * 0.7, _cx + _r, _cy - _r * 0.2, false);
			draw_triangle(_cx - _r * 0.6, _cy - _r * 0.7, _cx - _r, _cy - _r * 0.2, _cx + _r, _cy - _r * 0.2, false);
			draw_set_colour(light);
			draw_triangle(_cx - _r * 0.3, _cy - _r * 0.6, _cx + _r * 0.1, _cy - _r * 0.6, _cx - _r * 0.2, _cy - _r * 0.25, false);
			break;
		case "orb":
			draw_set_colour(dark);
			draw_circle(_cx, _cy, _r, false);
			draw_set_colour(_col);
			draw_circle(_cx, _cy, _r * 0.8, false);
			draw_set_colour(light);
			draw_circle(_cx - _r * 0.3, _cy - _r * 0.3, _r * 0.25, false);
			break;
		case "dust":    // a small heap of sparkles
			draw_set_colour(dark);
			draw_ellipse(_cx - _r, _cy, _cx + _r, _cy + _r * 0.7, false);
			draw_set_colour(_col);
			draw_ellipse(_cx - _r * 0.8, _cy - _r * 0.3, _cx + _r * 0.8, _cy + _r * 0.5, false);
			draw_set_colour(c_white);
			draw_circle(_cx - _r * 0.6, _cy - _r * 0.8, 2, false);
			draw_circle(_cx + _r * 0.5, _cy - _r * 0.6, 2, false);
			draw_circle(_cx, _cy - _r, 1.5, false);
			break;
		case "scale":
			draw_set_colour(dark);
			draw_ellipse(_cx - _r * 0.9, _cy - _r, _cx + _r * 0.9, _cy + _r, false);
			draw_set_colour(_col);
			draw_ellipse(_cx - _r * 0.7, _cy - _r * 0.85, _cx + _r * 0.7, _cy + _r * 0.7, false);
			draw_set_colour(light);
			draw_line_width(_cx, _cy - _r * 0.6, _cx, _cy + _r * 0.5, 2);
			break;
		case "feather":
			draw_set_colour(dark);
			draw_line_width(_cx - _r * 0.8, _cy + _r, _cx + _r * 0.6, _cy - _r, 2);
			draw_set_colour(_col);
			draw_ellipse(_cx - _r * 0.5, _cy - _r * 0.9, _cx + _r * 0.7, _cy + _r * 0.4, false);
			draw_set_colour(light);
			draw_line_width(_cx - _r * 0.5, _cy + _r * 0.6, _cx + _r * 0.5, _cy - _r * 0.8, 1);
			break;
		case "bone":
			draw_set_colour(dark);
			draw_line_width(_cx - _r * 0.7, _cy + _r * 0.7, _cx + _r * 0.7, _cy - _r * 0.7, _r * 0.45);
			draw_set_colour(_col);
			draw_circle(_cx - _r * 0.75, _cy + _r * 0.55, _r * 0.28, false);
			draw_circle(_cx - _r * 0.55, _cy + _r * 0.8, _r * 0.28, false);
			draw_circle(_cx + _r * 0.75, _cy - _r * 0.55, _r * 0.28, false);
			draw_circle(_cx + _r * 0.55, _cy - _r * 0.8, _r * 0.28, false);
			draw_line_width(_cx - _r * 0.6, _cy + _r * 0.6, _cx + _r * 0.6, _cy - _r * 0.6, _r * 0.3);
			break;
		case "hide":
			draw_set_colour(dark);
			draw_roundrect_ext(_cx - _r, _cy - _r * 0.8, _cx + _r, _cy + _r * 0.8, _r, _r * 0.6, false);
			draw_set_colour(_col);
			draw_roundrect_ext(_cx - _r * 0.8, _cy - _r * 0.6, _cx + _r * 0.8, _cy + _r * 0.6, _r * 0.8, _r * 0.5, false);
			draw_set_colour(light);
			draw_line_width(_cx - _r * 0.4, _cy - _r * 0.2, _cx + _r * 0.3, _cy - _r * 0.2, 1);
			break;
		case "log":     // a short log, end on
			draw_set_colour(dark);
			draw_roundrect_ext(_cx - _r, _cy - _r * 0.45, _cx + _r * 0.7, _cy + _r * 0.45, 4, 4, false);
			draw_set_colour(_col);
			draw_roundrect_ext(_cx - _r + 2, _cy - _r * 0.45 + 2, _cx + _r * 0.7 - 2, _cy + _r * 0.45 - 2, 3, 3, false);
			draw_set_colour(merge_colour(_col, make_colour_rgb(240, 210, 150), 0.6));
			draw_ellipse(_cx + _r * 0.45, _cy - _r * 0.45, _cx + _r, _cy + _r * 0.45, false);
			draw_set_colour(dark);
			draw_ellipse(_cx + _r * 0.62, _cy - _r * 0.2, _cx + _r * 0.83, _cy + _r * 0.2, true);
			break;
		case "rock":    // a lump of stone (or coal)
		case "ore":     // grey stone with specks of the ore's colour
			var base = (_shape == "ore") ? make_colour_rgb(125, 120, 128) : _col;
			draw_set_colour(merge_colour(base, c_black, 0.45));
			draw_roundrect_ext(_cx - _r, _cy - _r * 0.6, _cx + _r, _cy + _r * 0.8, _r * 0.8, _r * 0.8, false);
			draw_set_colour(base);
			draw_roundrect_ext(_cx - _r * 0.85, _cy - _r * 0.7, _cx + _r * 0.75, _cy + _r * 0.55, _r * 0.7, _r * 0.7, false);
			draw_set_colour(merge_colour(base, c_white, 0.35));
			draw_circle(_cx - _r * 0.35, _cy - _r * 0.3, _r * 0.18, false);
			if(_shape == "ore"){
				draw_set_colour(_col);
				draw_rectangle(_cx - _r * 0.1, _cy - _r * 0.4, _cx + _r * 0.2, _cy - _r * 0.1, false);
				draw_rectangle(_cx + _r * 0.3, _cy + _r * 0.05, _cx + _r * 0.55, _cy + _r * 0.3, false);
				draw_rectangle(_cx - _r * 0.55, _cy + _r * 0.1, _cx - _r * 0.3, _cy + _r * 0.35, false);
			}
			break;
		case "fibre":   // a bundle of green stalks
			draw_set_colour(dark);
			for(var i = -2; i <= 2; i++) draw_line_width(_cx + i * _r * 0.18, _cy + _r * 0.9, _cx + i * _r * 0.4, _cy - _r * 0.9, 3);
			draw_set_colour(_col);
			for(var i = -2; i <= 2; i++) draw_line_width(_cx + i * _r * 0.18, _cy + _r * 0.9, _cx + i * _r * 0.4, _cy - _r * 0.9, 1.5);
			draw_set_colour(make_colour_rgb(190, 150, 90));
			draw_rectangle(_cx - _r * 0.4, _cy + _r * 0.15, _cx + _r * 0.4, _cy + _r * 0.35, false);
			break;
		default:        // folded cloth
			draw_set_colour(dark);
			draw_roundrect_ext(_cx - _r - 2, _cy - _r - 2, _cx + _r + 2, _cy + _r + 2, 6, 6, false);
			draw_set_colour(_col);
			draw_roundrect_ext(_cx - _r, _cy - _r, _cx + _r, _cy + _r, 6, 6, false);
			draw_set_colour(dark);
			draw_line_width(_cx - _r, _cy, _cx + _r, _cy, 1);
			draw_set_colour(light);
			draw_roundrect_ext(_cx - _r + 3, _cy - _r + 3, _cx - 2, _cy - 3, 3, 3, false);
	}
}

/// @description Region of the 64x64 frame (x, y, w, h) where a slot's art sits, for icons.
function item_icon_crop(_slot){
	switch(_slot){
		case "hat":                    return [12, 0, 40, 34];
		case "face": case "earrings":  return [16, 10, 32, 26];
		case "neck":                   return [18, 22, 28, 22];
		case "belt":                   return [16, 34, 32, 18];
		case "pants":                  return [16, 34, 32, 30];
		case "shoes":                  return [18, 46, 28, 18];
		case "wrist": case "gloves":   return [10, 28, 44, 26];
		case "held":                   return [0, 0, 64, 64];
		default:                       return [12, 18, 40, 38]; // torso pieces
	}
}
