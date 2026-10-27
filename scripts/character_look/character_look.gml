/// Character looks, built from the LPC item catalog (lpc_catalog script).
/// Used by obj_plyr, obj_npc_parent and obj_char_creator.
///
/// A look is { body: "male", parts: { <slot key>: {item, pal} } }
///   item - index into lpc_catalog().items, or -1 for none
///   pal  - palette sprite for the item's colour (-1 = the item's default)
/// parts.body.pal is the skin colour and parts.eyes.pal the eye colour; heads,
/// ears and noses follow them automatically.

/// @description The creator rows, in on-screen order.
function character_slots(){
	static slots = undefined;
	if(slots != undefined) return slots;
	// label, key, can be empty, chance of empty when randomising
	slots = [
		character_slot("Body",      "body",      false, 0),
		character_slot("Head",      "head",      false, 0),
		character_slot("Eyes",      "eyes",      true,  0.95),
		character_slot("Ears",      "ears",      true,  0.8),
		character_slot("Nose",      "nose",      true,  0.5),
		character_slot("Eyebrows",  "eyebrows",  true,  0.3),
		character_slot("Hair",      "hair",      true,  0.05),
		character_slot("Beard",     "beard",     true,  0.7),
		character_slot("Headwear",  "hat",       true,  0.6),
		character_slot("Face",      "face",      true,  0.85),
		character_slot("Earrings",  "earrings",  true,  0.85),
		character_slot("Neck",      "neck",      true,  0.75),
		character_slot("Shirt",     "shirt",     true,  0.05),
		character_slot("Vest",      "vest",      true,  0.7),
		character_slot("Coat",      "coat",      true,  0.8),
		character_slot("Belt",      "belt",      true,  0.5),
		character_slot("Legs",      "pants",     true,  0.02),
		character_slot("Shoes",     "shoes",     true,  0.1),
		character_slot("Shoulders", "shoulders", true,  0.85),
		character_slot("Bauldron",  "bauldron",  true,  0.9),
		character_slot("Wrists",    "wrist",     true,  0.8),
		character_slot("Gloves",    "gloves",    true,  0.8),
		character_slot("Cape",      "cape",      true,  0.85),
		character_slot("Back",      "back",      true,  0.85),
		character_slot("Held item", "held",      true,  0.5),
	];
	return slots;
}

function character_slot(_label, _key, _canBeEmpty, _emptyChance){
	var items = [];
	var allItems = lpc_catalog().items;
	for(var i = 0; i < array_length(allItems); i++){
		if(allItems[i].slot == _key) array_push(items, i);
	}
	return {label: _label, key: _key, items: items, canBeEmpty: _canBeEmpty, emptyChance: _emptyChance};
}

/// @description True if catalog item _i has art for body type _body.
function character_item_fits(_i, _body){
	var layers = lpc_catalog().items[_i].layers;
	for(var l = 0; l < array_length(layers); l++){
		if(variable_struct_exists(layers[l], _body)) return true;
	}
	return false;
}

/// @description The slot's items that fit a body type.
function character_slot_options(_slot, _body){
	var out = [];
	for(var i = 0; i < array_length(_slot.items); i++){
		if(character_item_fits(_slot.items[i], _body)) array_push(out, _slot.items[i]);
	}
	return out;
}

/// @description Colour choices for a slot's current item: {pals, names}, empty when it has fixed colours.
function character_palettes_for(_slotKey, _item){
	var p = lpc_catalog().palettes;
	var m = "";
	if(_slotKey == "body") m = "body";
	else if(_slotKey == "eyes") m = "eye";
	else if(_item != -1) m = lpc_catalog().items[_item].material;
	if(m == "") return {pals: [], names: []};
	return {pals: p[$ m], names: p[$ m + "_names"]};
}

/// @description Index of the item called _name in a slot, or -1.
function character_find_item(_slotKey, _name){
	var allItems = lpc_catalog().items;
	for(var i = 0; i < array_length(allItems); i++){
		if(allItems[i].slot == _slotKey && allItems[i].name == _name) return i;
	}
	return -1;
}

/// @description Palette sprite of a material by name (e.g. "cloth", "blue"), or -1.
function character_find_palette(_material, _name){
	var p = lpc_catalog().palettes;
	var i = array_get_index(p[$ _material + "_names"], _name);
	return (i == -1) ? -1 : p[$ _material][i];
}

function character_empty_look(_body){
	var look = {body: _body, parts: {}};
	var slots = character_slots();
	for(var i = 0; i < array_length(slots); i++){
		look.parts[$ slots[i].key] = {item: -1, pal: -1};
	}
	look.parts.body.item = character_find_item("body", "Body Color");
	look.parts.body.pal = character_find_palette("body", "light");
	look.parts.eyes.pal = character_find_palette("eye", "blue");
	return look;
}

/// @description The look the player starts with if the creator was skipped.
function character_default_look(){
	var look = character_empty_look("male");
	var parts = look.parts;
	parts.head  = {item: character_find_item("head", "Human Male"),     pal: -1};
	parts.hair  = {item: character_find_item("hair", "Plain"),          pal: character_find_palette("hair", "chestnut")};
	parts.shirt = {item: character_find_item("shirt", "Longsleeve"),    pal: character_find_palette("cloth", "blue")};
	parts.pants = {item: character_find_item("pants", "Pants"),         pal: character_find_palette("cloth", "brown")};
	parts.shoes = {item: character_find_item("shoes", "Basic Shoes"),   pal: character_find_palette("cloth", "black")};
	parts.belt  = {item: character_find_item("belt", "Leather Belt"),   pal: -1};
	return look;
}

/// @description Change body type, swapping out parts that have no art for the new body.
function character_set_body(_look, _body){
	_look.body = _body;
	var slots = character_slots();
	for(var i = 0; i < array_length(slots); i++){
		var s = slots[i];
		var part = _look.parts[$ s.key];
		if(part.item != -1 && character_item_fits(part.item, _body)) continue;
		if(s.canBeEmpty && part.item == -1) continue;
		var opts = character_slot_options(s, _body);
		part.item = -1;
		if(!s.canBeEmpty && array_length(opts) > 0){
			// Prefer a human head over beast heads
			part.item = opts[0];
			for(var o = 0; o < array_length(opts); o++){
				if(string_pos("Human", lpc_catalog().items[opts[o]].name) > 0){ part.item = opts[o]; break; }
			}
		}
	}
}

/// @description Draw one 64x64 frame of a look. _frame is the sheet column, _row the sheet row.
function character_draw(_look, _frame, _row, _x, _y, _scale){
	var cat = lpc_catalog();
	var parts = _look.parts;
	var skin = parts.body.pal;
	var eyes = parts.eyes.pal;

	// Gather every sprite layer of every part, then draw back to front by z
	var list = [];
	var slots = character_slots();
	for(var s = 0; s < array_length(slots); s++){
		var part = parts[$ slots[s].key];
		if(part.item == -1) continue;
		var it = cat.items[part.item];
		var pal = (part.pal == -1) ? it.defPal : part.pal;
		for(var l = 0; l < array_length(it.layers); l++){
			var subs = it.layers[l][$ _look.body];
			if(subs == undefined) continue;
			for(var k = 0; k < array_length(subs); k++){
				var kind = subs[k].k;
				var p = kind;                    // a fixed palette sprite
				if(kind == -1) p = pal;          // the part's chosen colour
				else if(kind == -2) p = skin;
				else if(kind == -3) p = eyes;
				// -4 = fixed colours, drawn without the palette shader
				array_push(list, {order: it.layers[l].z * 1000 + s * 10 + k, spr: subs[k].spr, pal: p});
			}
		}
	}
	array_sort(list, function(a, b){ return a.order - b.order; });

	var size = 64;
	for(var i = 0; i < array_length(list); i++){
		var e = list[i];
		if(e.pal != -4) lorikeet_set(e.pal);
		draw_sprite_part_ext(e.spr, 0, _frame * size, _row * size, size, size, _x, _y, _scale, _scale, c_white, 1);
		if(e.pal != -4) lorikeet_reset();
	}
}

/// @description Step a slot to its next/previous option. The Body row steps through body types.
function character_cycle_item(_look, _slot, _dir){
	if(_slot.key == "body"){
		var bodies = lpc_catalog().bodies;
		var n = array_length(bodies);
		var b = (array_get_index(bodies, _look.body) + _dir + n) mod n;
		character_set_body(_look, bodies[b]);
		return;
	}
	var part = _look.parts[$ _slot.key];
	var opts = character_slot_options(_slot, _look.body);
	var n = array_length(opts);
	if(n == 0) return;
	var lo = _slot.canBeEmpty ? -1 : 0;
	var i = array_get_index(opts, part.item) + _dir;
	if(i > n - 1) i = lo;
	if(i < lo) i = n - 1;
	part.item = (i == -1) ? -1 : opts[i];

	// Keep the colour if the new item can use it, else take the item's default
	var cols = character_palettes_for(_slot.key, part.item);
	if(_slot.key != "eyes" && array_get_index(cols.pals, part.pal) == -1) part.pal = -1;
}

/// @description Step a slot to its next/previous colour (wrapping).
function character_cycle_palette(_look, _slot, _dir){
	var part = _look.parts[$ _slot.key];
	var cols = character_palettes_for(_slot.key, part.item);
	var n = array_length(cols.pals);
	if(n == 0) return;
	var cur = (part.pal == -1) ? lpc_catalog().items[part.item].defPal : part.pal;
	var i = array_get_index(cols.pals, cur) + _dir;
	part.pal = cols.pals[(i + n) mod n];
}

/// @description Fill a look with random parts and colours. _body = "" picks a random body type.
function character_randomise(_look, _body = ""){
	var cat = lpc_catalog();
	if(_body == "") _body = cat.bodies[irandom(array_length(cat.bodies) - 1)];
	_look.body = _body;
	var slots = character_slots();
	for(var i = 0; i < array_length(slots); i++){
		var s = slots[i];
		var part = _look.parts[$ s.key];
		var opts = character_slot_options(s, _body);
		var n = array_length(opts);
		if(s.key == "body"){
			part.item = character_find_item("body", "Body Color");
		} else if(n == 0 || (s.canBeEmpty && random(1) < s.emptyChance)){
			part.item = -1;
		} else {
			part.item = opts[irandom(n - 1)];
		}
		var cols = character_palettes_for(s.key, part.item);
		var np = array_length(cols.pals);
		if(s.key == "body") np = min(np, 7); // natural skin tones are listed first
		part.pal = (np > 0) ? cols.pals[irandom(np - 1)] : -1;
	}
	// Mostly human heads
	if(random(1) < 0.8) character_set_body_head_human(_look);
}

function character_set_body_head_human(_look){
	var opts = character_slot_options(character_slots()[1], _look.body);
	var humans = [];
	for(var o = 0; o < array_length(opts); o++){
		if(string_pos("Human", lpc_catalog().items[opts[o]].name) > 0) array_push(humans, opts[o]);
	}
	if(array_length(humans) > 0) _look.parts.head.item = humans[irandom(array_length(humans) - 1)];
}

/// @description A new random look. _body = "" picks any body type.
function character_random_look(_body = ""){
	var look = character_empty_look("male");
	character_randomise(look, _body);
	return look;
}
