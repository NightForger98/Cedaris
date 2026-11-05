/// Character looks, built from the LPC item catalog (lpc_catalog script) and the race
/// rules (character_races script). Used by obj_plyr, obj_npc_parent and obj_char_creator.
///
/// A look is { race: "Human", body: "male", parts: { <slot key>: {item, pal} } }
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
		character_slot("Race",      "race",      false, 0),
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

/// @description The slot struct with key _key.
function character_slot_by_key(_key){
	var slots = character_slots();
	for(var i = 0; i < array_length(slots); i++){
		if(slots[i].key == _key) return slots[i];
	}
	return undefined;
}

/// @description True if catalog item _i has art for body type _body.
function character_item_fits(_i, _body){
	var layers = lpc_catalog().items[_i].layers;
	for(var l = 0; l < array_length(layers); l++){
		if(variable_struct_exists(layers[l], _body)) return true;
	}
	return false;
}

/// @description True if the look's race allows catalog item _i in slot _key.
function character_race_allows(_race, _key, _i){
	if(array_get_index(_race.none, _key) != -1) return false;
	var only = _race.only[$ _key];
	if(only == undefined) return true;
	return array_get_index(only, lpc_catalog().items[_i].name) != -1;
}

/// @description True if the slot must always have an item for this race.
function character_slot_required(_slot, _race){
	return !_slot.canBeEmpty || array_get_index(_race.require, _slot.key) != -1;
}

/// @description The slot's items that fit the look's body type and race.
function character_slot_options(_slot, _look){
	var race = character_race(_look.race);
	var out = [];
	for(var i = 0; i < array_length(_slot.items); i++){
		var it = _slot.items[i];
		if(character_item_fits_any(it, _look.body) && character_race_allows(race, _slot.key, it)) array_push(out, it);
	}
	return out;
}

/// @description Colour choices for a slot's current item: {pals, names}, empty when it has fixed colours.
function character_palettes_for(_slotKey, _item, _look){
	var p = lpc_catalog().palettes;
	if(_slotKey == "body"){
		// Skin tones the race allows
		var skins = character_race(_look.race).skins;
		var pals = [];
		var names = [];
		for(var i = 0; i < array_length(skins); i++){
			var pal = character_find_palette("body", skins[i]);
			if(pal != -1){ array_push(pals, pal); array_push(names, string_replace_all(skins[i], "_", " ")); }
		}
		return {pals: pals, names: names};
	}
	var m = "";
	if(_slotKey == "eyes") m = "eye";
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
	var i = array_get_index(p[$ _material + "_names"], string_replace_all(_name, "_", " "));
	return (i == -1) ? -1 : p[$ _material][i];
}

function character_empty_look(_race, _body){
	var look = {race: _race, body: _body, parts: {}};
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
	var look = character_empty_look("Human", "male");
	var parts = look.parts;
	parts.head  = {item: character_find_item("head", "Human Male"),     pal: -1};
	parts.hair  = {item: character_find_item("hair", "Plain"),          pal: character_find_palette("hair", "chestnut")};
	parts.shirt = {item: character_find_item("shirt", "Longsleeve"),    pal: character_find_palette("cloth", "blue")};
	parts.pants = {item: character_find_item("pants", "Pants"),         pal: character_find_palette("cloth", "brown")};
	parts.shoes = {item: character_find_item("shoes", "Basic Shoes"),   pal: character_find_palette("cloth", "black")};
	parts.belt  = {item: character_find_item("belt", "Leather Belt"),   pal: -1};
	return look;
}

/// @description Best default for a required slot: heads that match the body (Female heads on female bodies...).
function character_pick_default(_slot, _opts, _look){
	if(_slot.key != "head") return _opts[0];
	var fem = (_look.body == "female" || _look.body == "pregnant");
	for(var o = 0; o < array_length(_opts); o++){
		var n = lpc_catalog().items[_opts[o]].name;
		if(fem == (string_pos("emale", n) > 0)) return _opts[o];
	}
	return _opts[0];
}

/// @description Make a look obey its race and body type: allowed body, skin and items, required slots filled.
function character_validate(_look){
	var race = character_race(_look.race);
	if(array_get_index(race.bodies, _look.body) == -1) _look.body = race.bodies[0];

	var skins = character_palettes_for("body", -1, _look).pals;
	if(array_get_index(skins, _look.parts.body.pal) == -1) _look.parts.body.pal = skins[0];

	var slots = character_slots();
	for(var i = 0; i < array_length(slots); i++){
		var s = slots[i];
		if(s.key == "race" || s.key == "body") continue;
		var part = _look.parts[$ s.key];
		var opts = character_slot_options(s, _look);
		// want = what was last picked for this slot, restored whenever the race and body allow it
		if(!variable_struct_exists(part, "want")) part.want = part.item;
		if(part.want == -1) part.item = -1;
		else if(array_get_index(opts, part.want) != -1) part.item = part.want;
		else part.item = character_closest_item(part.want, opts); // most similar item that is allowed
		if(part.item == -1 && character_slot_required(s, race) && array_length(opts) > 0){
			part.item = character_pick_default(s, opts, _look);
		}
	}
}

/// @description The option whose name shares the most words with item _old (e.g. "Child shirts" -> a shirt), or -1 if none.
function character_closest_item(_old, _opts){
	if(array_length(_opts) == 0) return -1;
	var words = string_split(string_lower(lpc_catalog().items[_old].name), " ");
	var best = _opts[0], bestHits = -1;
	for(var o = 0; o < array_length(_opts); o++){
		var n = string_lower(lpc_catalog().items[_opts[o]].name);
		var hits = 0;
		for(var w = 0; w < array_length(words); w++){
			if(string_length(words[w]) > 2 && string_pos(words[w], n) > 0) hits++;
		}
		if(hits > bestHits){ bestHits = hits; best = _opts[o]; }
	}
	return best;
}

/// @description Change race, then fix up body, skin and parts to suit it.
function character_set_race(_look, _race){
	_look.race = _race;
	character_validate(_look);
}

/// @description Change body type, swapping out parts that have no art for the new body.
function character_set_body(_look, _body){
	_look.body = _body;
	character_validate(_look);
}

// ---------------------------------------------------------------- gender (story mode)
// Story mode's farmer is a man or a woman (character_story_rules in character_races). The choice is kept in
// look.gender and saved with the look; looks without it (free mode, villagers, old saves) get one worked out from
// the body and head. Read it with character_gender(look), or player_gender() for the player.

/// @description "male" or "female": the look's chosen gender, else worked out from its body type and head.
function character_gender(_look){
	var g = _look[$ "gender"];
	if(g == "male" || g == "female") return g;
	if(_look.body == "female" || _look.body == "pregnant") return "female";
	if(_look.body == "male") return "male";
	// Teen, muscular and child bodies are shared: the head says ("Human Female", "Orc female", "Minotaur female"...)
	var h = _look.parts.head.item;
	if(h != -1 && string_pos("female", string_lower(lpc_catalog().items[h].name)) > 0) return "female";
	return "male";
}

/// @description The player's gender, "male" or "female".
function player_gender(){
	if(!variable_global_exists("look") || !is_struct(global.look)) return "male";
	return character_gender(global.look);
}

/// @description A slot's options in story mode: what the body and race allow, narrowed to the look's gender.
function character_story_options(_slot, _look){
	var rules = character_story_rules();
	var g = character_gender(_look);
	if(array_get_index(rules.none[$ g], _slot.key) != -1) return [];
	var only = rules.only[$ g][$ _slot.key];
	var never = rules.never[$ g][$ _slot.key];
	var opts = character_slot_options(_slot, _look);
	var out = [];
	for(var i = 0; i < array_length(opts); i++){
		var n = lpc_catalog().items[opts[i]].name;
		if(only != undefined && array_get_index(only, n) == -1) continue;
		if(never != undefined && array_get_index(never, n) != -1) continue;
		array_push(out, opts[i]);
	}
	// Required slots (the head) default to the first item in the gender's list
	if(only != undefined && array_length(out) > 1){
		var first = character_find_item(_slot.key, only[0]);
		var at = array_get_index(out, first);
		if(at > 0){ array_delete(out, at, 1); array_insert(out, 0, first); }
	}
	return out;
}

/// @description Make a look fit story mode: human, a man's or a woman's body, and only parts of that gender.
/// Parts that don't fit are replaced (and forgotten, so a later free-mode validate can't bring them back).
function character_story_validate(_look){
	var rules = character_story_rules();
	var g = character_gender(_look);
	_look.gender = g;
	if(_look.race != rules.race || _look.body != g){
		_look.race = rules.race;
		_look.body = g;
		character_validate(_look);
	}
	var race = character_race(_look.race);
	for(var k = 0; k < array_length(rules.keys); k++){
		var key = rules.keys[k];
		if(key == "body") continue;
		var s = character_slot_by_key(key);
		var part = _look.parts[$ key];
		var opts = character_story_options(s, _look);
		if(part.item != -1 && array_get_index(opts, part.item) == -1){
			// e.g. a man's head on a woman's body (the closest allowed head), pigtails on a man (plain hair), a beard on a woman
			if(character_slot_required(s, race)) part.item = character_closest_item(part.item, opts);
			else if(key == "hair") part.item = character_find_item("hair", "Plain");
			else part.item = -1;
		}
		if(part.item == -1 && character_slot_required(s, race) && array_length(opts) > 0) part.item = opts[0];
		part.want = part.item;
		var cols = character_palettes_for(key, part.item, _look);
		if(key != "eyes" && part.pal != -1 && array_get_index(cols.pals, part.pal) == -1) part.pal = -1;
	}
}

/// @description Story mode: make the look a man ("male") or a woman ("female"), swapping parts that don't fit.
function character_story_set_gender(_look, _gender){
	if(array_get_index(character_story_rules().genders, _gender) == -1) return;
	_look.gender = _gender;
	_look.body = _gender;
	character_validate(_look);
	character_story_validate(_look);
}

/// @description Story mode's starting look for a gender (Reset in the creator).
function character_story_default_look(_gender){
	var look = character_default_look();
	if(_gender == "female"){
		look.parts.head.item = character_find_item("head", "Human Female");
		look.parts.hair.item = character_find_item("hair", "Long");
	}
	character_story_set_gender(look, _gender);
	return look;
}

/// @description Story mode: random head, face and hair for the look's gender (the gender stays).
function character_story_randomise(_look){
	var rules = character_story_rules();
	var g = character_gender(_look);
	var race = character_race(rules.race);
	for(var k = 0; k < array_length(rules.keys); k++){
		var s = character_slot_by_key(rules.keys[k]);
		var part = _look.parts[$ s.key];
		if(s.key != "body"){
			var opts = character_story_options(s, _look);
			var n = array_length(opts);
			var emptyChance = race.chance[$ s.key] ?? s.emptyChance;
			part.item = (n == 0 || (!character_slot_required(s, race) && random(1) < emptyChance)) ? -1 : opts[irandom(n - 1)];
			part.want = part.item;
		}
		var cols = character_palettes_for(s.key, part.item, _look);
		var np = array_length(cols.pals);
		part.pal = (np > 0) ? cols.pals[irandom(np - 1)] : -1;
	}
	_look.gender = g;
	character_story_validate(_look);
}

/// @description Story mode: step a creator row (Gender flips man / woman; the rest step through that gender's parts).
function character_story_cycle_item(_look, _slot, _dir){
	if(_slot.key == "body"){
		var gs = character_story_rules().genders;
		var n = array_length(gs);
		character_story_set_gender(_look, gs[(array_get_index(gs, character_gender(_look)) + _dir + n * 2) mod n]);
		return;
	}
	var part = _look.parts[$ _slot.key];
	var opts = character_story_options(_slot, _look);
	var n = array_length(opts);
	if(n == 0) return;
	var lo = character_slot_required(_slot, character_race(_look.race)) ? 0 : -1;
	var i = array_get_index(opts, part.item) + _dir;
	if(i > n - 1) i = lo;
	if(i < lo) i = n - 1;
	part.item = (i == -1) ? -1 : opts[i];
	part.want = part.item;
	var cols = character_palettes_for(_slot.key, part.item, _look);
	if(_slot.key != "eyes" && array_get_index(cols.pals, part.pal) == -1) part.pal = -1;
}

/// @description Test helper: every story-mode part of a look that doesn't fit its gender, or "ok".
function character_story_problems(_look){
	var rules = character_story_rules();
	var g = character_gender(_look);
	var out = "";
	if(_look.race != rules.race) out += " race " + _look.race;
	if(_look.body != g) out += " body " + _look.body + " for " + g;
	for(var k = 0; k < array_length(rules.keys); k++){
		var key = rules.keys[k];
		if(key == "body") continue;
		var it = _look.parts[$ key].item;
		if(it != -1 && array_get_index(character_story_options(character_slot_by_key(key), _look), it) == -1){
			out += " " + key + " " + lpc_catalog().items[it].name;
		}
	}
	return (out == "") ? "ok" : string_trim(out);
}

/// @description Draw one 64x64 frame of a look. _frame is the sheet column, _row the sheet row.
/// _action (optional) = {act, i, dir}: draw step i of an action (see the actions script) facing dir 0-3;
/// then _frame and _row are ignored.
/// _action: {act, i, dir} while acting, plus fx while charging (charge_fx: the tool moved, tilted and glowing, the
/// face blushing). _sil: a colour to draw the whole look flat in (the cursed outline), or -1.
function character_draw(_look, _frame, _row, _x, _y, _scale, _action = undefined, _sil = -1){
	var cat = lpc_catalog();
	var parts = _look.parts;
	var skin = parts.body.pal;
	var eyes = parts.eyes.pal;

	// Which 64x64 frame the body and clothes show
	var sx = _frame * 64, sy = _row * 64;
	var act = undefined;
	if(_action != undefined){
		act = _action.act;
		var step = min(_action.i, act.frames - 1);
		var bodyFrame = act.custom ? act.seq[_action.dir][step] : act.seq[step];
		sx = bodyFrame * 64;
		sy = (act.row + _action.dir) * 64;
	}

	// Gather every sprite layer of every part, then draw back to front by z
	var list = [];
	var slots = character_slots();
	for(var s = 0; s < array_length(slots); s++){
		var part = parts[$ slots[s].key];
		if(part.item == -1) continue;
		var it = cat.items[part.item];
		if(slots[s].key == "held" && it.name == "Boomerang" && boomerang_out()) continue;   // thrown: it's flying
		var pal = (part.pal == -1) ? it.defPal : part.pal;
		var layers = it.layers;
		var lsx = sx, lsy = sy, lsw = 64, ldx = _x, ldy = _y;
		// During a custom action the held item swaps to its oversized sheet, centred on the 64px body
		if(act != undefined && act.custom && slots[s].key == "held" && variable_struct_exists(it.actions, act.name)){
			layers = it.actions[$ act.name];
			lsw = act.fs;
			lsx = min(_action.i, act.frames - 1) * act.fs;
			lsy = _action.dir * act.fs;
			ldx = _x - (act.fs - 64) / 2 * _scale;
			ldy = _y - (act.fs - 64) / 2 * _scale;
		}
		// Walking (or standing) with a held item carried by an oversized walk (the bows, the long spears, the katana):
		// its walk_128 sheet, frame for frame with the body's walk (rows 8-11: n, w, s, e)
		else if(act == undefined && slots[s].key == "held" && _row >= 8 && _row < 12 && variable_struct_exists(it.actions, "walk_128")){
			var wfs = cat.anims[$ "walk_128"].fs;
			layers = it.actions[$ "walk_128"];
			lsw = wfs;
			lsx = _frame * wfs;
			lsy = (_row - 8) * wfs;
			ldx = _x - (wfs - 64) / 2 * _scale;
			ldy = _y - (wfs - 64) / 2 * _scale;
		}
		for(var l = 0; l < array_length(layers); l++){
			var subs = layers[l][$ _look.body];
			if(subs == undefined) continue;
			for(var k = 0; k < array_length(subs); k++){
				var kind = subs[k].k;
				var p = kind;                    // a fixed palette sprite
				if(kind == -1) p = pal;          // the part's chosen colour
				else if(kind == -2) p = skin;
				else if(kind == -3) p = eyes;
				// -4 = fixed colours, drawn without the palette shader
				array_push(list, {order: layers[l].z * 1000 + s * 10 + k, spr: subs[k].spr, pal: p,
				                  sx: lsx, sy: lsy, sw: lsw, dx: ldx, dy: ldy, slot: slots[s].key});
			}
		}
	}
	array_sort(list, function(a, b){ return a.order - b.order; });

	var fx = (_action != undefined) ? _action[$ "fx"] : undefined;
	if(_sil != -1) gpu_set_fog(true, _sil, 0, 1);
	for(var i = 0; i < array_length(list); i++){
		var e = list[i];
		var held = (fx != undefined && e.slot == "held");
		if(e.pal != -4 && _sil == -1) lorikeet_set(e.pal);
		if(held){
			// Its frame, coloured, onto a surface first (see character_held_surface), then turned with the surface
			var hs = character_held_surface(e);
			if(e.pal != -4 && _sil == -1) lorikeet_reset();
			character_draw_held(hs, e, _x, _y, _scale, fx, 1);
			// A charging tool glows (drawn again, added on top)
			if(fx.glow > 0){
				gpu_set_blendmode(bm_add);
				character_draw_held(hs, e, _x, _y, _scale, fx, fx.glow);
				gpu_set_blendmode(bm_normal);
			}
		}
		else{
			draw_sprite_part_ext(e.spr, 0, e.sx, e.sy, e.sw, e.sw, e.dx, e.dy, _scale, _scale, c_white, 1);
			if(e.pal != -4 && _sil == -1) lorikeet_reset();
		}
		// Straining: the head goes red (under the hair, which is drawn after it)
		if(fx != undefined && fx.blush > 0 && e.slot == "head" && _sil == -1){
			gpu_set_fog(true, make_colour_rgb(235, 40, 40), 0, 1);
			draw_sprite_part_ext(e.spr, 0, e.sx, e.sy, e.sw, e.sw, e.dx, e.dy, _scale, _scale, c_white, fx.blush);
			gpu_set_fog(false, c_white, 0, 1);
		}
	}
	if(_sil != -1) gpu_set_fog(false, c_white, 0, 1);
}

/// @description The held item's frame drawn (with the palette shader that's set) onto a surface of its own, cleared
/// first. Turning the frame straight from the sprite (draw_sprite_general) reads past the sprite's cropped edges on its
/// texture page and shows bits of other sprites (a "pole axe" behind the axe); a plain draw_sprite_part doesn't.
function character_held_surface(_e){
	static surfs = {};
	var key = string(_e.sw), s = surfs[$ key];
	if(s == undefined || !surface_exists(s)){ s = surface_create(_e.sw, _e.sw); surfs[$ key] = s; }
	surface_set_target(s);
	draw_clear_alpha(c_black, 0);
	draw_sprite_part(_e.spr, 0, _e.sx, _e.sy, _e.sw, _e.sw, 0, 0);
	surface_reset_target();
	return s;
}

/// @description The held item while charging (its frame on surface _s): shifted and turned about the hands by fx (dx,
/// dy, ang).
function character_draw_held(_s, _e, _x, _y, _scale, _fx, _alpha){
	var px = _x + 32 * _scale, py = _y + 38 * _scale;            // the hands
	var ox = _e.dx - px, oy = _e.dy - py, a = _fx.ang;
	var rx = ox * dcos(a) + oy * dsin(a), ry = -ox * dsin(a) + oy * dcos(a);
	draw_surface_ext(_s, px + rx + _fx.dx * _scale, py + ry + _fx.dy * _scale, _scale, _scale, a, c_white, _alpha);
}

/// @description Draw one catalog item on its own (inventory icons). _crop = [x, y, w, h] of the frame.
/// _act: "" for the item's normal sheets, or a custom action name to use its oversized sheet.
/// Uses _body's art, or the first body type the item has. _pal -1 = the item's default colour.
function character_draw_item(_i, _body, _pal, _frame, _row, _crop, _x, _y, _scale, _act = ""){
	var cat = lpc_catalog();
	var it = cat.items[_i];
	var layers = (_act == "") ? it.layers : it.actions[$ _act];
	var fs = (_act == "") ? 64 : cat.anims[$ _act].fs;
	if(array_length(layers) == 0) return;
	var has = false;
	for(var l = 0; l < array_length(layers); l++) if(variable_struct_exists(layers[l], _body)) has = true;
	if(!has){
		for(var b = 0; b < array_length(cat.bodies) && !has; b++){
			for(var l = 0; l < array_length(layers); l++){
				if(variable_struct_exists(layers[l], cat.bodies[b])){ _body = cat.bodies[b]; has = true; break; }
			}
		}
	}
	var pal = (_pal == -1) ? it.defPal : _pal;
	var skin = character_find_palette("body", "light");
	var eyes = character_find_palette("eye", "blue");
	for(var l = 0; l < array_length(layers); l++){
		var subs = layers[l][$ _body];
		if(subs == undefined) continue;
		for(var k = 0; k < array_length(subs); k++){
			var kind = subs[k].k;
			var p = kind;
			if(kind == -1) p = pal;
			else if(kind == -2) p = skin;
			else if(kind == -3) p = eyes;
			if(p != -4) lorikeet_set(p);
			draw_sprite_part_ext(subs[k].spr, 0, _frame * fs + _crop[0], _row * fs + _crop[1], _crop[2], _crop[3], _x, _y, _scale, _scale, c_white, 1);
			if(p != -4) lorikeet_reset();
		}
	}
}

/// @description Step a slot to its next/previous option. Race and Body rows step through races and body types.
function character_cycle_item(_look, _slot, _dir){
	if(_slot.key == "race"){
		var races = character_races();
		var n = array_length(races);
		var r = 0;
		for(var i = 0; i < n; i++) if(races[i].name == _look.race) r = i;
		character_set_race(_look, races[(r + _dir + n) mod n].name);
		return;
	}
	if(_slot.key == "body"){
		var bodies = character_race(_look.race).bodies;
		var n = array_length(bodies);
		var b = (array_get_index(bodies, _look.body) + _dir + n) mod n;
		character_set_body(_look, bodies[b]);
		return;
	}
	var part = _look.parts[$ _slot.key];
	var opts = character_slot_options(_slot, _look);
	var n = array_length(opts);
	if(n == 0) return;
	var lo = character_slot_required(_slot, character_race(_look.race)) ? 0 : -1;
	var i = array_get_index(opts, part.item) + _dir;
	if(i > n - 1) i = lo;
	if(i < lo) i = n - 1;
	part.item = (i == -1) ? -1 : opts[i];
	part.want = part.item;

	// Keep the colour if the new item can use it, else take the item's default
	var cols = character_palettes_for(_slot.key, part.item, _look);
	if(_slot.key != "eyes" && array_get_index(cols.pals, part.pal) == -1) part.pal = -1;
}

/// @description Step a slot to its next/previous colour (wrapping).
function character_cycle_palette(_look, _slot, _dir){
	var part = _look.parts[$ _slot.key];
	var cols = character_palettes_for(_slot.key, part.item, _look);
	var n = array_length(cols.pals);
	if(n == 0) return;
	var cur = (part.pal == -1 && part.item != -1) ? lpc_catalog().items[part.item].defPal : part.pal;
	var i = array_get_index(cols.pals, cur) + _dir;
	part.pal = cols.pals[(i + n) mod n];
}

/// @description Fill a look with random parts and colours. _race = "" picks a random race.
function character_randomise(_look, _race = ""){
	if(_race == "") _race = character_random_race();
	var race = character_race(_race);
	_look.race = _race;
	_look.body = race.bodies[irandom(array_length(race.bodies) - 1)];

	var slots = character_slots();
	for(var i = 0; i < array_length(slots); i++){
		var s = slots[i];
		if(s.key == "race") continue;
		var part = _look.parts[$ s.key];
		if(s.key == "body"){
			part.item = character_find_item("body", "Body Color");
		} else {
			var opts = character_slot_options(s, _look);
			var n = array_length(opts);
			var emptyChance = race.chance[$ s.key] ?? s.emptyChance;
			if(n == 0 || (!character_slot_required(s, race) && random(1) < emptyChance)){
				part.item = -1;
			} else {
				part.item = opts[irandom(n - 1)];
			}
			part.want = part.item;
		}
		var cols = character_palettes_for(s.key, part.item, _look);
		var np = array_length(cols.pals);
		part.pal = (np > 0) ? cols.pals[irandom(np - 1)] : -1;
	}
	character_validate(_look);
}

/// @description A new random look. _race = "" picks a race weighted by how common it is.
function character_random_look(_race = ""){
	var look = character_empty_look("Human", "male");
	character_randomise(look, _race);
	return look;
}

/// @description Test helper (tools/test/cases/creator_story.txt): drive the creator in rm_creator and report.
/// _what: "look" (the creator's look), "gender" g, "row" key dir, "options" key, "randoms" n, "reset", "done",
/// "player" (global.look). Returns "stage .. gender .. body .. head .. hair .. beard .. problems ..".
function autotest_creator(_what, _a = "", _b = ""){
	var out = "";
	if(_what == "player") return character_story_summary(global.look);
	if(!instance_exists(obj_char_creator)) return "no creator";
	with(obj_char_creator){
		switch(_what){
			case "gender": pickGender(_a); break;
			case "row":
				for(var i = 0; i < array_length(slots); i++) if(slots[i].key == _a) cycleRow(i, real(_b));
				break;
			case "options":
				var opts = character_story_options(character_slot_by_key(_a), look);
				out = "options " + _a + ":";
				for(var i = 0; i < array_length(opts); i++) out += " [" + lpc_catalog().items[opts[i]].name + "]";
				if(array_length(opts) == 0) out += " (none)";
				break;
			case "randoms":
				// Randomise n times; count the looks that came out with the wrong gender or parts
				var g = character_gender(look), bad = 0;
				for(var i = 0; i < real(_a); i++){
					act("random");
					if(character_gender(look) != g || character_story_problems(look) != "ok") bad++;
				}
				out = "random bad " + string(bad) + " / ";
				break;
			case "reset": act("reset"); break;
			case "done": act("done"); break;
		}
		if(_what != "options") out += "stage " + stage + " " + character_story_summary(look);
	}
	return out;
}

/// @description One line about a story look, for the tests.
function character_story_summary(_look){
	var p = _look.parts, cat = lpc_catalog().items;
	var nm = function(_it, _cat){ return (_it == -1) ? "none" : _cat[_it].name; };
	return "gender " + character_gender(_look) + " (saved " + string(_look[$ "gender"] ?? "-") + ") body " + _look.body
		+ " race " + _look.race + " head " + nm(p.head.item, cat) + " hair " + nm(p.hair.item, cat)
		+ " beard " + nm(p.beard.item, cat) + " problems " + character_story_problems(_look);
}
