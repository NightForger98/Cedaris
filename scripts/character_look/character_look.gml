/// Character looks: the slots a character is built from, the default look,
/// and drawing a look with palette swaps. Used by obj_plyr and obj_char_creator.
///
/// A look is a struct of parts keyed by slot, e.g. look.hair = {spr: index_bs1_hair_short_mess3, pal: pal_hair_sandy}.
/// spr == -1 means the slot is empty. pal == -1 means "use the body's skin colour" (ears, nose).

/// @description The slots shown in the character creator, in on-screen order.
/// Option lists are built from sprite names, so new index_/pal_ sprites with a
/// matching prefix show up automatically.
function character_slots(){
	if(variable_global_exists("character_slot_list")) return global.character_slot_list;

	var skin  = ["pal_skin_"];
	var eyes  = ["pal_eyes_"];
	var hairp = ["pal_hair_"];
	var gear  = ["pal_clothes_", "pal_metal_"];
	var jewel = ["pal_metal_", "pal_clothes_"];
	var hatp  = ["pal_clothes_", "pal_hair_", "pal_metal_"];

	// label, key, sprite prefixes, prefixes stripped for display, palette prefixes (-1 = skin colour), can be empty, chance of empty when randomising
	global.character_slot_list = [
		character_slot("Body",      "body",      ["index_base0_"],                 ["index_base0_"],          skin,  false, 0),
		character_slot("Ears",      "ears",      ["index_base1__ears_"],           ["index_base1__ears_"],    -1,    true,  0.6),
		character_slot("Nose",      "nose",      ["index_base1__nose_"],           ["index_base1__nose_"],    -1,    false, 0),
		character_slot("Eyes",      "eyes",      ["index_base1_eyes"],             ["index_base1_"],          eyes,  false, 0),
		character_slot("Hair",      "hair",      ["index_bs1_hair_"],              ["index_bs1_hair_"],       hairp, true,  0.05),
		character_slot("Beard",     "beard",     ["index_bs1_beard_"],             ["index_bs1_beard_"],      hairp, true,  0.7),
		character_slot("Headwear",  "hat",       ["index_bs2_headtop_", "index_bs3_hat_", "index_bs3_headtop_", "index_bs3_helmet_"],
		                                         ["index_bs2_headtop_", "index_bs3_"],                        hatp,  true,  0.6),
		character_slot("Face",      "face",      ["index_bs2_face_"],              ["index_bs2_face_"],       jewel, true,  0.8),
		character_slot("Neck",      "neck",      ["index_bs2_neck_"],              ["index_bs2_neck_"],       jewel, true,  0.6),
		character_slot("Shirt",     "shirt",     ["index_bs3_torso_shirt_", "index_bs3_torso_bandages"],
		                                         ["index_bs3_torso_shirt_", "index_bs3_torso_"],              gear,  true,  0.05),
		character_slot("Vest",      "vest",      ["index_bs3_torso_vest_", "index_bs3_torso_chainmail", "index_bs3_torso_apron_", "index_bs3_torso_tabard"],
		                                         ["index_bs3_torso_"],                                        gear,  true,  0.6),
		character_slot("Coat",      "coat",      ["index_bs3_torso_coat_", "index_bs3_torso_jacket_", "index_bs3_torso_overarmor_", "index_bs3_torso_santacoat"],
		                                         ["index_bs3_torso_"],                                        gear,  true,  0.7),
		character_slot("Belt",      "belt",      ["index_bs3_torso_waist_"],       ["index_bs3_torso_waist_"], gear, true,  0.4),
		character_slot("Legs",      "pants",     ["index_bs3_leg_"],               ["index_bs3_leg_"],        gear,  false, 0),
		character_slot("Shoes",     "shoes",     ["index_bs3_shoes_"],             ["index_bs3_shoes_"],      gear,  true,  0.1),
		character_slot("Shoulders", "shoulders", ["index_bs2_shoulder_"],          ["index_bs2_shoulder_"],   gear,  true,  0.8),
		character_slot("Bauldron",  "bauldron",  ["index_bs2_body_"],              ["index_bs2_body_"],       gear,  true,  0.8),
		character_slot("Wrists",    "wrist",     ["index_bs3_arms_wrist_"],        ["index_bs3_arms_wrist_"], gear,  true,  0.7),
		character_slot("Gloves",    "gloves",    ["index_bs3_arms_hands_"],        ["index_bs3_arms_hands_"], gear,  true,  0.7),
		character_slot("Cape",      "cape",      ["index_bs3_cape_"],              ["index_bs3_cape_"],       gear,  true,  0.8),
	];
	return global.character_slot_list;
}

function character_slot(_label, _key, _sprPrefixes, _strip, _palPrefixes, _canBeEmpty, _emptyChance){
	var sprites = sprites_with_prefix(_sprPrefixes);
	var palettes = is_array(_palPrefixes) ? sprites_with_prefix(_palPrefixes) : [];

	var names = [];
	for(var i = 0; i < array_length(sprites); i++){
		array_push(names, character_option_name(sprites[i], _strip));
	}
	var palNames = [];
	for(var i = 0; i < array_length(palettes); i++){
		array_push(palNames, character_option_name(palettes[i], ["pal_"]));
	}

	return {
		label: _label,
		key: _key,
		sprites: sprites,
		names: names,
		palettes: palettes,
		palNames: palNames,
		canBeEmpty: _canBeEmpty,
		emptyChance: _emptyChance,
	};
}

/// @description All sprites whose name starts with one of the prefixes, grouped by prefix and sorted by name.
function sprites_with_prefix(_prefixes){
	var ids = asset_get_ids(asset_sprite);
	var out = [];
	for(var p = 0; p < array_length(_prefixes); p++){
		var found = [];
		for(var i = 0; i < array_length(ids); i++){
			if(string_starts_with(sprite_get_name(ids[i]), _prefixes[p])) array_push(found, ids[i]);
		}
		array_sort(found, function(a, b){ return sprite_get_name(a) < sprite_get_name(b) ? -1 : 1; });
		out = array_concat(out, found);
	}
	return out;
}

/// @description Readable name for a sprite: first matching prefix removed, underscores to spaces.
function character_option_name(_spr, _strip){
	var full = sprite_get_name(_spr);
	var n = full;
	for(var p = 0; p < array_length(_strip); p++){
		if(string_starts_with(n, _strip[p])){
			n = string_delete(n, 1, string_length(_strip[p]));
			break;
		}
	}
	// Prefix was the whole name (e.g. index_bs3_torso_tabard) - use its last word
	if(n == ""){ n = string_delete(full, 1, string_last_pos("_", full)); }
	return string_replace_all(n, "_", " ");
}

/// @description The look the player starts with if the creator was skipped.
function character_default_look(){
	return {
		body:      {spr: index_base0_male_norm,             pal: pal_skin_light},
		ears:      {spr: -1,                                pal: -1},
		nose:      {spr: index_base1__nose_straight,        pal: -1},
		eyes:      {spr: index_base1_eyes,                  pal: pal_eyes_blue},
		hair:      {spr: index_bs1_hair_short_mess3,        pal: pal_hair_sandy},
		beard:     {spr: index_bs1_beard_full,              pal: pal_hair_sandy},
		hat:       {spr: index_bs2_headtop_headcover_hijab, pal: pal_hair_black},
		face:      {spr: index_bs2_face_earing,             pal: pal_metal_silver},
		neck:      {spr: index_bs2_neck_necklace,           pal: pal_metal_silver},
		shirt:     {spr: index_bs3_torso_shirt_longsleeve,  pal: pal_clothes_purple},
		vest:      {spr: index_bs3_torso_chainmail,         pal: pal_clothes_forest},
		coat:      {spr: index_bs3_torso_overarmor_leather, pal: pal_clothes_navy},
		belt:      {spr: index_bs3_torso_waist_leatherbelt, pal: pal_clothes_leather},
		pants:     {spr: index_bs3_leg_pants,               pal: pal_clothes_blue},
		shoes:     {spr: index_bs3_shoes_shoes,             pal: pal_clothes_black},
		shoulders: {spr: index_bs2_shoulder_leather,        pal: pal_clothes_leather},
		bauldron:  {spr: index_bs2_body_bauldron,           pal: pal_clothes_leather},
		wrist:     {spr: index_bs3_arms_wrist_bracers,      pal: pal_clothes_blue},
		gloves:    {spr: index_bs3_arms_hands_gloves,       pal: pal_clothes_maroon},
		cape:      {spr: index_bs3_cape_tattered,           pal: pal_clothes_lavender},
	};
}

/// @description Draw one 64x64 frame of a look. _frame is the sheet column, _row the sheet row.
function character_draw(_look, _frame, _row, _x, _y, _scale){
	// Back to front - same order the player was drawn in before
	static order = ["body", "ears", "nose", "eyes", "hair", "face", "neck", "hat", "shirt", "pants", "shoes",
	                "vest", "coat", "bauldron", "belt", "shoulders", "wrist", "gloves", "cape", "beard"];
	var size = 64;
	for(var i = 0; i < array_length(order); i++){
		var part = _look[$ order[i]];
		if(part == undefined || part.spr == -1) continue;
		var pal = (part.pal == -1) ? _look.body.pal : part.pal;
		lorikeet_set(pal);
		draw_sprite_part_ext(part.spr, 0, _frame * size, _row * size, size, size, _x, _y, _scale, _scale, c_white, 1);
		lorikeet_reset();
	}
}

/// @description Step a slot to its next/previous option (wrapping, including "none" when allowed).
function character_cycle_sprite(_look, _slot, _dir){
	var part = _look[$ _slot.key];
	var n = array_length(_slot.sprites);
	if(n == 0) return;
	var lo = _slot.canBeEmpty ? -1 : 0;
	var i = array_get_index(_slot.sprites, part.spr) + _dir;
	if(i > n - 1) i = lo;
	if(i < lo) i = n - 1;
	part.spr = (i == -1) ? -1 : _slot.sprites[i];
}

/// @description Step a slot to its next/previous colour (wrapping).
function character_cycle_palette(_look, _slot, _dir){
	var n = array_length(_slot.palettes);
	if(n == 0) return;
	var part = _look[$ _slot.key];
	var i = array_get_index(_slot.palettes, part.pal) + _dir;
	part.pal = _slot.palettes[(i + n) mod n];
}

/// @description Random look, using each slot's chance of being empty.
function character_randomise(_look){
	var slots = character_slots();
	for(var i = 0; i < array_length(slots); i++){
		var s = slots[i];
		var part = _look[$ s.key];
		var n = array_length(s.sprites);
		if(n == 0 || (s.canBeEmpty && random(1) < s.emptyChance)){
			part.spr = -1;
		} else {
			part.spr = s.sprites[irandom(n - 1)];
		}
		var np = array_length(s.palettes);
		part.pal = (np > 0) ? s.palettes[irandom(np - 1)] : -1;
	}
}
