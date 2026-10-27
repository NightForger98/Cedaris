/// Items: definitions, icons, crafting recipes and the blacksmith's stock.
///
/// Item ids are strings:
///   "c|<slot>|<catalog name>"  clothing or held item from the LPC catalog, e.g. "c|shirt|Longsleeve", "c|held|Hoe"
///   "m|<material>"             crafting material, e.g. "m|linen"
///   "d|<palette material>|<colour>"  dye that recolours equipment, e.g. "d|cloth|red", "d|metal|gold"
/// A stack is {id, count, pal} - pal is an optional palette name giving clothing its own colour.

/// @description The crafting materials. Quests and events hand these out; recipes consume them.
function item_materials(){
	static m = [
		{key: "linen",   name: "Linen",      desc: "Light cloth for shirts and trousers.", colour: make_colour_rgb(225, 214, 180), price: 4},
		{key: "wool",    name: "Wool",       desc: "Warm cloth for coats and hats.",       colour: make_colour_rgb(240, 240, 235), price: 5},
		{key: "leather", name: "Leather",    desc: "Tough hide for belts, boots and vests.", colour: make_colour_rgb(140, 90, 50), price: 6},
		{key: "silk",    name: "Silk",       desc: "Fine fabric for capes and finery.",    colour: make_colour_rgb(230, 150, 200), price: 12},
		{key: "iron",    name: "Iron Bar",   desc: "For armour and metal fittings.",       colour: make_colour_rgb(150, 155, 165), price: 10},
		{key: "gold",    name: "Gold Bar",   desc: "For jewellery and crowns.",            colour: make_colour_rgb(240, 200, 60),  price: 25},
		{key: "gem",     name: "Gemstone",   desc: "Sparkly. Jewellers love it.",          colour: make_colour_rgb(90, 220, 230),  price: 30},
	];
	return m;
}

/// @description Definition of an item id: {id, type, name, desc, max, price, ...}. Cached.
function item_def(_id){
	static cache = {};
	var d = cache[$ _id];
	if(d != undefined) return d;
	var p = string_split(_id, "|");
	switch(p[0]){
		case "c":
			var idx = character_find_item(p[1], p[2]);
			var held = (p[1] == "held");
			d = {id: _id, type: held ? "held" : "clothing", slot: p[1], name: p[2], cat: idx, max: 1,
			     price: held ? item_shop_price(p[2]) : 20,
			     desc: held ? "Select it on the hotbar to hold it." : "Equip in the " + item_slot_label(p[1]) + " slot."};
			if(idx != -1) d.material = lpc_catalog().items[idx].material;
			break;
		case "m":
			var mats = item_materials();
			for(var i = 0; i < array_length(mats); i++){
				if(mats[i].key == p[1]){
					d = {id: _id, type: "material", name: mats[i].name, desc: mats[i].desc, max: 99, price: mats[i].price, colour: mats[i].colour};
				}
			}
			break;
		case "d":
			var colour = string_replace_all(p[2], "_", " ");
			var nice = string_upper(string_char_at(colour, 1)) + string_delete(colour, 1, 1);
			d = {id: _id, type: "dye", material: p[1], colour: p[2], max: 30, price: 15,
			     pal: character_find_palette(p[1], p[2]),
			     name: nice + ((p[1] == "metal") ? " Polish" : " Dye"),
			     desc: (p[1] == "metal") ? "Put it in a dye slot to recolour metal gear." : "Put it in a dye slot to recolour cloth and leather."};
			break;
	}
	if(d == undefined) d = {id: _id, type: "unknown", name: _id, desc: "", max: 1, price: 0};
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

// ---------------------------------------------------------------- crafting

/// @description Materials a clothing item costs, as a struct {material: count}, by slot. Metal pieces use iron.
function item_recipe_cost(_slot, _material){
	var cost;
	switch(_slot){
		case "hat":       cost = {wool: 2}; break;
		case "face":      cost = {iron: 1, gem: 1}; break;
		case "earrings":  cost = {gold: 1, gem: 1}; break;
		case "neck":      cost = {gold: 1}; break;
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
	// Metal helmets, armour and fittings are smithed instead of sewn
	if(_material == "metal"){
		var n = 0, names = variable_struct_get_names(cost);
		for(var i = 0; i < array_length(names); i++) n += cost[$ names[i]];
		cost = {iron: n};
	}
	return cost;
}

/// @description Every clothing recipe: [{result id, cost struct}], built from the catalog. Cached.
function item_recipes(){
	static list = undefined;
	if(list != undefined) return list;
	list = [];
	var slots = item_equip_slots();
	var cat = lpc_catalog().items;
	for(var i = 0; i < array_length(cat); i++){
		if(array_get_index(slots, cat[i].slot) == -1) continue;
		array_push(list, {id: "c|" + cat[i].slot + "|" + cat[i].name, slot: cat[i].slot, cat: i,
		                  cost: item_recipe_cost(cat[i].slot, cat[i].material)});
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

// ---------------------------------------------------------------- blacksmith

/// @description Brom's stock: farm tools first, then weapons. [{name, price}]
function item_shop_stock(){
	static s = [
		{name: "Hoe", price: 40}, {name: "Watering Can", price: 40}, {name: "Axe", price: 60},
		{name: "Pickaxe", price: 60}, {name: "Shovel", price: 50}, {name: "Hammer", price: 50}, {name: "Scythe", price: 90},
		{name: "Dagger", price: 80}, {name: "Arming Sword", price: 150}, {name: "Saber", price: 180}, {name: "Rapier", price: 200},
		{name: "Longsword", price: 250}, {name: "Glowsword", price: 600}, {name: "Mace", price: 160}, {name: "Flail", price: 190},
		{name: "Waraxe", price: 220}, {name: "Spear", price: 120}, {name: "Halberd", price: 260}, {name: "Cane", price: 30},
		{name: "Simple staff", price: 120}, {name: "Gnarled staff", price: 180}, {name: "Loop staff", price: 220},
		{name: "S staff", price: 240}, {name: "Diamond staff", price: 400}, {name: "Slingshot", price: 70}, {name: "Crossbow", price: 300},
	];
	return s;
}

function item_shop_price(_name){
	var s = item_shop_stock();
	for(var i = 0; i < array_length(s); i++) if(s[i].name == _name) return s[i].price;
	return 50;
}

/// @description What a stack sells for, per item.
function item_sell_price(_id){ return max(1, floor(item_def(_id).price / 2)); }

// ---------------------------------------------------------------- icons

/// @description Draw a stack's icon centred in a box at (_x, _y) of size _size. _body picks which art to show.
function item_draw_icon(_stack, _x, _y, _size, _body = "male"){
	var d = item_def(_stack.id);
	var cx = _x + _size / 2, cy = _y + _size / 2;
	switch(d.type){
		case "clothing":
		case "held":
			if(d.cat == -1) break;
			// Zoom into the part of the 64x64 frame where this slot's art sits
			var r = item_icon_crop(d.slot);
			var sc = _size / max(r[2], r[3]);
			var pal = (_stack.pal != "") ? asset_get_index(_stack.pal) : -1;
			character_draw_item(d.cat, _body, pal, 0, 10, r, cx - r[2] * sc / 2, cy - r[3] * sc / 2, sc);
			break;
		case "material":
			var s = _size * 0.32;
			draw_set_colour(c_black);
			draw_roundrect_ext(cx - s - 2, cy - s - 2, cx + s + 2, cy + s + 2, 6, 6, false);
			draw_set_colour(d.colour);
			draw_roundrect_ext(cx - s, cy - s, cx + s, cy + s, 6, 6, false);
			draw_set_colour(merge_colour(d.colour, c_white, 0.5));
			draw_roundrect_ext(cx - s + 3, cy - s + 3, cx - 2, cy - 2, 3, 3, false);
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
