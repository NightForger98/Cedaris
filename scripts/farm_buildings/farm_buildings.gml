/// The farm's buildings and their upgrades, the Stardew Valley way: each has three stages (the farmhouse has four,
/// scripts/marriage). Rowan sells the next stage's plans; her crew builds it overnight. The barn and the coop hold more
/// animals as they grow (Stardew: Barn / Big Barn / Deluxe Barn, Coop / Big Coop / Deluxe Coop - 4, 8, 12 animals);
/// the shed and the silo grow too (a workshop, a silo tower).
/// global.world.farm = {barn: 0-2, coop: 0-2, shed: 0-2, silo: 0-2}. Art: PixelLab, spr_prop_farm_<key>_<1-3>.

/// @description The buildings: each stage's name, the price of the next stage's plans, and what the stages hold.
function farm_building_table(){
	static t = {
		barn: {stages: ["Barn", "Big Barn", "Deluxe Barn"],     prices: [12000, 25000], holds: [4, 8, 12],
		       desc: "Room for cows and sheep: 4, then 8, then 12."},
		coop: {stages: ["Coop", "Big Coop", "Deluxe Coop"],     prices: [10000, 20000], holds: [4, 8, 12],
		       desc: "Room for chickens: 4, then 8, then 12."},
		shed: {stages: ["Shed", "Big Shed", "Workshop"],        prices: [8000, 18000],  holds: [0, 0, 0],
		       desc: "Your tool shed, then a big shed, then a workshop with a chimney."},
		silo: {stages: ["Silo", "Twin Silos", "Silo Tower"],    prices: [5000, 12000],  holds: [0, 0, 0],
		       desc: "Grain storage: one silo, two, then three on a stone base."},
	};
	return t;
}

/// @description A building's stage, 0-2.
function farm_building_level(_key){
	if(!is_struct(global.world[$ "farm"])) global.world.farm = {};
	return clamp(global.world.farm[$ _key] ?? 0, 0, 2);
}

/// @description Its name now ("Big Barn").
function farm_building_name(_key){ return farm_building_table()[$ _key].stages[farm_building_level(_key)]; }

/// @description How many animals of a kind your buildings hold (cows and sheep: the barn; chickens: the coop).
function farm_animal_room(_kind){
	var key = (_kind == "chicken") ? "coop" : "barn";
	return farm_building_table()[$ key].holds[farm_building_level(key)];
}

/// @description How many animals you have that live in the same building as _kind.
function farm_animal_count(_kind){
	var l = animals_list(), n = 0, coop = (_kind == "chicken");
	for(var i = 0; i < array_length(l); i++) if((l[i].kind == "chicken") == coop) n++;
	return n;
}

/// @description Rowan's shop: the next stage's plans of each building (one set at a time).
function farm_building_stock(){
	var out = [], t = farm_building_table(), keys = ["barn", "coop", "shed", "silo"];
	for(var i = 0; i < array_length(keys); i++){
		var k = keys[i], lv = farm_building_level(k);
		if(lv < 2 && inv_count("m|" + k + "_plans") == 0) array_push(out, {id: "m|" + k + "_plans", price: t[$ k].prices[lv]});
	}
	return out;
}

/// @description New-day part: plans in your bag get built overnight. Returns a note for the morning ("" if none).
function farm_buildings_new_day(){
	var note = "", keys = ["barn", "coop", "shed", "silo"];
	for(var i = 0; i < array_length(keys); i++){
		var k = keys[i];
		if(inv_count("m|" + k + "_plans") > 0 && farm_building_level(k) < 2){
			inv_take("m|" + k + "_plans", 1);
			global.world.farm[$ k] = farm_building_level(k) + 1;
			note += ((note != "") ? " " : "") + "Rowan's crew built your " + farm_building_name(k) + " overnight!";
		}
	}
	return note;
}

/// @description On the farm (an obj_building's creation code): show this building's stage standing on (_fx, _fy) -
/// its foot's middle - and make its foot solid (the bottom two rows of cells under it).
function farm_building_setup(_key, _fx, _fy){
	sprite_index = asset_get_index("spr_prop_farm_" + _key + "_" + string(farm_building_level(_key) + 1));
	if(sprite_index == -1){ visible = false; return; }
	x = _fx - sprite_get_width(sprite_index) div 2;
	y = _fy;
	var c1 = floor((x + 4) / 32), c2 = floor((x + sprite_get_width(sprite_index) - 5) / 32);
	for(var c = c1; c <= c2; c++){
		var b = instance_create_depth(c * 32 + 16, _fy - 32, 0, obj_col_box);
		b.image_xscale = 2; b.image_yscale = 4; b.visible = false;
	}
}

/// @description Test: set a building's stage.
function autotest_farm_building(_key, _lv){ if(!is_struct(global.world[$ "farm"])) global.world.farm = {}; global.world.farm[$ _key] = real(_lv); return farm_building_name(_key); }
