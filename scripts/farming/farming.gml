/// Farming (roadmap phase 1): crops, tilling, watering, planting, daily growth, harvest, eating and shipping.
///
/// Farm tiles live in the world store: world_room(<room>).tiles["gx_gy"] = {watered}. A key existing
/// means the tile is tilled. Crops stay in world_room(<room>).crops; on the farm they are obj_crop instances.
/// Item ids: "s|<crop>" seeds, "p|<crop>|<quality 0-2>" produce.

/// @description Crop table, in the row order of spr_crops (and the frames of spr_crops_picked).
/// stageDays: days per growth stage (mature after 3 x stageDays watered days); regrow: days back to ripe after
/// harvest (0 = harvested once); seasons: 0 spring, 1 summer, 2 fall, 3 winter.
function crop_table(){
	static t = [
		{key: "tomato",    name: "Tomato",    seasons: [1],    stageDays: 3, regrow: 3, seed: 50,  sell: 60,  energy: 20},
		{key: "potato",    name: "Potato",    seasons: [0],    stageDays: 2, regrow: 0, seed: 50,  sell: 80,  energy: 25},
		{key: "carrot",    name: "Carrot",    seasons: [0],    stageDays: 1, regrow: 0, seed: 20,  sell: 35,  energy: 30},
		{key: "artichoke", name: "Artichoke", seasons: [2],    stageDays: 3, regrow: 0, seed: 30,  sell: 160, energy: 30},
		{key: "chilli",    name: "Chilli",    seasons: [1],    stageDays: 2, regrow: 2, seed: 40,  sell: 40,  energy: 15},
		{key: "gourd",     name: "Gourd",     seasons: [2],    stageDays: 3, regrow: 0, seed: 100, sell: 320, energy: 40},
		{key: "corn",      name: "Corn",      seasons: [1, 2], stageDays: 4, regrow: 3, seed: 150, sell: 50,  energy: 20},
	];
	return t;
}

function crop_index(_key){
	var t = crop_table();
	for(var i = 0; i < array_length(t); i++) if(t[i].key == _key) return i;
	return -1;
}

function crop_in_season(_type, _season){ return array_get_index(crop_table()[_type].seasons, _season) != -1; }

function crop_seasons_text(_type){
	var s = crop_table()[_type].seasons, out = "";
	for(var i = 0; i < array_length(s); i++) out += ((i > 0) ? " & " : "") + season_name(s[i]);
	return out;
}

/// @description Growth stage for days of growth (0 = seed, 4 = ripe; spr_crops has 5 stages).
function crop_stage(_type, _days){
	if(_days <= 0) return 0;
	return min(1 + (_days div crop_table()[_type].stageDays), 4);
}

function crop_days_to_ripe(_type){ return 3 * crop_table()[_type].stageDays; }

/// @description Price paid for produce: normal, silver (+25%) and gold (+50%) quality.
function produce_price(_type, _quality){ return round(crop_table()[_type].sell * [1, 1.25, 1.5][_quality]); }

// ---------------------------------------------------------------- tiles

function farm_key(_gx, _gy){ return string(_gx) + "_" + string(_gy); }

function farm_tiles(){
	var r = world_room(room_get_name(room));
	if(!variable_struct_exists(r, "tiles")) r.tiles = {};
	return r.tiles;
}

/// @description Grid cell in front of a character facing _dir (0 n, 1 w, 2 s, 3 e).
function farm_front_cell(_user, _dir){
	var cs = crops.cellSize;
	var fx = _user.x + [0, -22, 0, 22][_dir];
	var fy = _user.y + [-22, 0, 22, 0][_dir];
	return [fx div cs, fy div cs];
}

/// @description True if the cell is part of a field (painted on the T_Soil tile layer).
function farm_is_soil(_gx, _gy){
	var lay = layer_get_id("T_Soil");
	if(lay == -1) return false;
	var cs = crops.cellSize;
	return tilemap_get_at_pixel(layer_tilemap_get_id(lay), _gx * cs + cs / 2, _gy * cs + cs / 2) > 0;
}

function farm_crop_at(_gx, _gy){
	if(!ds_exists(crops.ds_crops_instances, ds_type_grid)) return noone;
	var g = crops.ds_crops_instances;
	if(_gx < 0 || _gy < 0 || _gx >= ds_grid_width(g) || _gy >= ds_grid_height(g)) return noone;
	var inst = g[# _gx, _gy];
	return (inst != 0 && instance_exists(inst)) ? inst : noone;
}

// ---------------------------------------------------------------- tool and item effects

function farm_message(_text){
	game.hudMessage = _text;
	game.hudTime = game_get_speed(gamespeed_fps) * 2;
}

/// @description Hoe: till a field cell.
function farm_till(_gx, _gy){
	if(!farm_is_soil(_gx, _gy)) return;
	var tiles = farm_tiles();
	var k = farm_key(_gx, _gy);
	if(!variable_struct_exists(tiles, k)) tiles[$ k] = {watered: false};
}

/// @description Watering can: refill at water, else water a tilled cell. Uses global.inv.water (40 uses, more
/// when upgraded). Returns "refill" if it was filled up.
function farm_water(_user, _gx, _gy){
	var inv = global.inv;
	if(!variable_struct_exists(inv, "water")) inv.water = tool_water_max();
	var cs = crops.cellSize;
	if(collision_point(_gx * cs + cs / 2, _gy * cs + cs / 2, obj_water_zone, false, true) != noone){
		inv.water = tool_water_max();
		farm_message("Watering can refilled");
		return "refill";
	}
	var tiles = farm_tiles();
	var k = farm_key(_gx, _gy);
	if(!variable_struct_exists(tiles, k)) return;
	if(inv.water <= 0){ farm_message("Your watering can is empty. Refill it at the pond."); return; }
	inv.water--;
	tiles[$ k].watered = true;
}

/// @description Seeds: plant on a tilled, empty cell if the crop is in season. Returns true if planted.
function farm_plant(_gx, _gy, _type){
	var tiles = farm_tiles();
	if(!variable_struct_exists(tiles, farm_key(_gx, _gy))){ farm_message("Till the soil with a hoe first"); return false; }
	if(farm_crop_at(_gx, _gy) != noone) return false;
	if(placed_at(_gx, _gy) != undefined) return false; // a sprinkler stands there
	if(!crop_in_season(_type, global.clock.season)){
		farm_message(crop_table()[_type].name + " only grows in " + crop_seasons_text(_type));
		return false;
	}
	respawn_crop(_gx, _gy, _type, 0);
	return true;
}

/// @description Harvest a ripe crop: produce with quality from Luck, regrowing crops go back a few days.
function farm_harvest(_inst){
	var type = _inst.cropType;
	var c = crop_table()[type];
	var luck = stat("luck") * 0.01 + (global.clock[$ "luck"] ?? 0);
	// Farming skill: +1% gold and +1.5% silver a level; the Green Thumb far more gold (scripts/skills)
	var fl = skill_level("farming"), gold = 0.02 + luck + fl * 0.01 + (skill_has("green_thumb") ? 0.15 : 0);
	var r = random(1);
	var q = (r < gold) ? 2 : ((r < 0.12 + luck * 2 + fl * 0.025) ? 1 : 0);
	if(inv_add(item_stack("p|" + c.key + "|" + string(q))) > 0){ farm_message("Your inventory is full"); return; }
	skill_add_xp("farming", max(1, round(16 * ln(0.018 * c.sell + 1))));   // Stardew's harvest experience
	farm_message("Harvested " + item_def("p|" + c.key + "|" + string(q)).name);
	if(c.regrow > 0){
		with(_inst){
			daysOld = crop_days_to_ripe(type) - c.regrow;
			growthStage = crop_stage(type, daysOld);
			fullyGrown = false;
			sparkle = -1;
		}
	} else {
		var cs = crops.cellSize;
		crops.ds_crops_instances[# _inst.x div cs, _inst.y div cs] = 0;
		instance_destroy(_inst);
	}
	crops_store();
}

/// @description Eat produce from the hotbar: restores energy (and some health), better quality restores more.
function farm_eat(_stack){
	var p = string_split(_stack.id, "|");
	var type = crop_index(p[1]);
	var q = real(p[2]);
	var e = crop_table()[type].energy * (1 + q * 0.4);
	global.vitals.energy = min(vitals_max_energy(), global.vitals.energy + e);
	global.vitals.health = min(vitals_max_health(), global.vitals.health + e * 0.45);
	_stack.count--;
	if(_stack.count <= 0) global.inv.slots[global.inv.hotbar] = undefined;
	farm_message("Ate " + item_def(_stack.id).name + "  (+" + string(round(e)) + " energy)");
}

// ---------------------------------------------------------------- the new day

/// @description Farm part of the new-day event: watered crops grow, out-of-season crops die, soil dries.
/// Returns how many crops died.
function farm_new_day(_season){
	var died = 0;
	var names = variable_struct_get_names(global.world.rooms);
	for(var i = 0; i < array_length(names); i++){
		var r = global.world.rooms[$ names[i]];
		var tiles = r[$ "tiles"] ?? {};
		var keep = [];
		for(var c = 0; c < array_length(r.crops); c++){
			var cr = r.crops[c];
			if(!crop_in_season(cr.type, _season)){ died++; continue; }
			var t = tiles[$ farm_key(cr.gx, cr.gy)];
			if(t != undefined && t.watered) cr.days += 1 + ((skill_has("agriculturist") && random(1) < 0.2) ? 1 : 0);   // scripts/skills
			array_push(keep, cr);
		}
		r.crops = keep;
		var tk = variable_struct_get_names(tiles);
		for(var k = 0; k < array_length(tk); k++) tiles[$ tk[k]].watered = false;
	}
	return died;
}

// ---------------------------------------------------------------- shipping

function shipping_list(){
	if(!variable_struct_exists(global.world, "shipping")) global.world.shipping = [];
	return global.world.shipping;
}

function shipping_value(){
	var s = shipping_list(), v = 0;
	for(var i = 0; i < array_length(s); i++) v += item_sell_price(s[i].id) * s[i].count;
	return inv_is_free() ? 0 : v;
}

/// @description Put _n of a stack in the shipping bin (paid overnight).
function shipping_add(_stack, _n){
	var s = shipping_list();
	for(var i = 0; i < array_length(s); i++){
		if(s[i].id == _stack.id){ s[i].count += _n; return; }
	}
	array_push(s, item_stack(_stack.id, _n));
}

/// @description Overnight: pay for everything shipped. Returns the gold paid.
function shipping_payout(){
	var v = shipping_value();
	if(!inv_is_free()) global.inv.gold += v;
	global.world.shipping = [];
	return v;
}

/// @description The seed seller's stock: seeds of crops in season this season, and the farm spell scrolls.
function item_seed_stock(){
	var out = [], t = crop_table();
	for(var i = 0; i < array_length(t); i++){
		if(crop_in_season(i, global.clock.season)) array_push(out, {id: "s|" + t[i].key, price: t[i].seed});
	}
	// And the farm spells, for anyone with a staff
	array_push(out, {id: "k|grow", price: 300});
	array_push(out, {id: "k|rain", price: 400});
	return out;
}
