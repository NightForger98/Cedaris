/// Actions: using the held item (tool, weapon or staff) plays an LPC animation.
///
/// Standard animations replay frames from the universal sheet rows (from the generator's own table):
/// thrust, slash, shoot and spellcast have their own rows; watering replays thrust frames 0,1,4,4,4,4,5.
/// Custom animations (tool_axe, slash_oversize...) come from lpc_catalog().anims: the body replays its
/// slash or thrust frames while the item is drawn from its own oversized sheet (see character_draw).
///
/// An action is {name, custom, row, seq, frames, fs, fps, hit}:
///   row  - first universal row of the body animation (+ direction 0-3 = n, w, s, e)
///   seq  - body frame for each step: one list for standard animations, per direction for custom ones
///   hit  - the step on which the action takes effect (chop, till, strike...)

/// @description Standard LPC animations: universal sheet row and frame order.
function action_rows(){
	static r = {
		spellcast: {row: 0,  seq: [0, 1, 2, 3, 4, 5, 6],                         fps: 12, hit: 4},
		thrust:    {row: 4,  seq: [0, 1, 2, 3, 4, 5, 6, 7],                      fps: 14, hit: 4},
		slash:     {row: 12, seq: [0, 1, 2, 3, 4, 5],                            fps: 14, hit: 3},
		shoot:     {row: 16, seq: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],    fps: 16, hit: 8},
		watering:  {row: 4,  seq: [0, 1, 4, 4, 4, 4, 5],                         fps: 8,  hit: 3},
	};
	return r;
}

/// @description Body types missing some LPC animations (the generator has no art for them).
function action_body_lacks(_body, _anim){
	switch(_body){
		case "muscular": return _anim == "shoot";
		case "child":    return _anim != "slash";
	}
	return false;
}

/// @description The action for the look's held item, or undefined if it has none for this body.
function character_action_for(_look){
	var held = _look.parts.held.item;
	if(held == -1 || !character_item_fits_any(held, _look.body)) return undefined;
	var cat = lpc_catalog();
	var it = cat.items[held];

	// Custom oversized animations first (axe, hammer, big swords, staffs)
	static customPref = ["tool_axe", "tool_hammer", "tool_rod", "tool_whip", "slash_oversize", "slash_128",
	                     "slash_reverse_oversize", "thrust_oversize", "thrust_128"];
	for(var i = 0; i < array_length(customPref); i++){
		var name = customPref[i];
		if(!variable_struct_exists(it.actions, name)) continue;
		var c = cat.anims[$ name];
		if(action_body_lacks(_look.body, c.base)) continue;
		var std = action_rows()[$ c.base];
		return {name: name, custom: true, row: std.row, seq: c.seq, frames: c.cols, fs: c.fs, fps: 14,
		        hit: floor(c.cols * 0.5)};
	}

	// Then the item's own LPC animations, best match first
	static rowPref = ["watering", "slash", "shoot", "thrust", "spellcast"];
	for(var i = 0; i < array_length(rowPref); i++){
		var name = rowPref[i];
		var base = (name == "watering") ? "thrust" : name;
		if(array_get_index(it.anims, name) == -1 || action_body_lacks(_look.body, base)) continue;
		var r = action_rows()[$ name];
		return {name: name, custom: false, row: r.row, seq: r.seq, frames: array_length(r.seq), fs: 64, fps: r.fps, hit: r.hit};
	}
	return undefined;
}

/// @description True if catalog item _i has art for _body in its normal layers or any custom action.
function character_item_fits_any(_i, _body){
	if(character_item_fits(_i, _body)) return true;
	var acts = lpc_catalog().items[_i].actions;
	var names = variable_struct_get_names(acts);
	for(var a = 0; a < array_length(names); a++){
		var layers = acts[$ names[a]];
		for(var l = 0; l < array_length(layers); l++) if(variable_struct_exists(layers[l], _body)) return true;
	}
	return false;
}

/// @description Called once per action, on its hit step. Farming, gathering and combat hook in here.
/// _dir: 0 north, 1 west, 2 south, 3 east. The hoe tills and the watering can waters the cell in front.
function action_hit(_user, _item, _dir){
	if(!instance_exists(crops)) return;
	var cell = farm_front_cell(_user, _dir);
	switch(_item){
		case "Hoe":          farm_till(cell[0], cell[1]); break;
		case "Watering Can": farm_water(_user, cell[0], cell[1]); break;
		// Axe, pickaxe, scythe and weapons: gathering and combat phases
	}
}
