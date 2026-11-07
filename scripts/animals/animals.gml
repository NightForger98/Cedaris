/// Farm animals (milestone 11, docs/MILESTONES.md): chickens, cows and sheep in the farm's meadow.
///
/// Thorne sells them in crates (items "n|<kind>"); hold a crate on the farm and use it to let the animal out.
/// global.world.animals = [{kind, name, love, petted, days, ready}] - love 0-1000 (petting once a day); days since
/// its last product; ready: a product is waiting. E beside an animal pets it and collects what's ready.
/// Products are items "a|<product>" (eggs, milk) or wool ("m|wool"); eggs and milk can be eaten or cooked.
/// Art: "LPC style farm animals" by Daniel Eddeland (CC-BY 3.0 / GPL 2.0) - 4 walking frames in rows up/left/down/right.

#macro ANIMALS_MAX 8

/// @description Kinds: price (a crate at Thorne's), sheet frame size and where its feet are in a frame, walking
/// speed, product and how many days it takes.
function animal_table(){
	static t = {
		chicken: {name: "Chicken", spr: spr_animal_chicken, fw: 32,  feet: [16, 29],  speed: 0.5,  price: 400,
		          product: "a|egg", every: 1, sound: "Cluck!"},
		sheep:   {name: "Sheep",   spr: spr_animal_sheep,   fw: 128, feet: [64, 100], speed: 0.35, price: 1200,
		          product: "m|wool", every: 3, sound: "Baa!"},
		cow:     {name: "Cow",     spr: spr_animal_cow,     fw: 128, feet: [64, 108], speed: 0.3,  price: 1500,
		          product: "a|milk", every: 1, sound: "Moo!"},
	};
	return t;
}

function animal_def(_kind){ return animal_table()[$ _kind]; }

/// @description Eggs and milk: energy when eaten, and what they sell for.
function animal_products(){
	static t = {
		egg:  {name: "Egg",  energy: 25, sell: 30, colour: make_colour_rgb(245, 235, 210), desc: "Fresh from the coop."},
		milk: {name: "Milk", energy: 35, sell: 60, colour: make_colour_rgb(250, 250, 255), desc: "Creamy, still warm."},
		// No animal makes honey: the Night farm sells it, from its hives (Saint Thereza)
		honey: {name: "Honey", energy: 30, sell: 50, colour: make_colour_rgb(235, 170, 50), desc: "From the Night farm's hives."},
	};
	return t;
}

function animals_list(){
	if(!is_array(global.world[$ "animals"])) global.world.animals = [];
	return global.world.animals;
}

/// @description Where animals roam on the farm: the fenced pasture (room pixels, from the farm's layout).
function animal_pasture(){ static p = layout_area("rm_1", "pasture"); return p; }

/// @description Poupry's livestock (Meadowlark Farm): a crate of each kind.
function animal_stock(){
	var out = [], names = ["chicken", "sheep", "cow"];
	for(var i = 0; i < 3; i++) array_push(out, {id: "n|" + names[i], price: animal_def(names[i]).price});
	return out;
}

/// @description Use a crate on the farm: the animal joins the herd. Returns true if it did.
function animal_release(_stack){
	if(room != rm_1){ farm_message("Let it out on your farm"); return false; }
	var list = animals_list();
	var kind = string_split(_stack.id, "|")[1];
	// the barn holds cows and sheep, the coop chickens (more as they grow: scripts/farm_buildings)
	if(farm_animal_count(kind) >= farm_animal_room(kind)){
		farm_message("Your " + string_lower(farm_building_name((kind == "chicken") ? "coop" : "barn")) + " is full (" + string(farm_animal_room(kind)) + "); Rowan can build a bigger one");
		return false;
	}
	static names = ["Daisy", "Clover", "Pepper", "Maple", "Biscuit", "Hazel", "Juniper", "Turnip", "Bramble", "Poppy", "Nutmeg", "Willow"];
	var a = {kind: kind, name: names[irandom(array_length(names) - 1)], love: 0, petted: -1, days: 0, ready: false};
	array_push(list, a);
	var p = animal_pasture();
	instance_create_depth(irandom_range(p[0], p[2]), irandom_range(p[1], p[3]), 0, obj_animal, {data: a});
	_stack.count--;
	if(_stack.count <= 0) global.inv.slots[global.inv.hotbar] = undefined;
	farm_message("Welcome, " + a.name + " the " + string_lower(animal_def(kind).name) + "!");
	return true;
}

/// @description Whether the animals are in their barn and coop: in the evening and at night (6 pm to 7 am), in rain,
/// storms and snow, and all winter.
function animals_indoors(){
	if(!world_time_ready()) return false;
	var h = (global.clock.minutes div 60) mod 24, w = weather_now();
	return h >= 18 || h < 7 || w == "rain" || w == "storm" || w == "snow" || (global.clock.season mod 4) == 3;
}

/// @description The room an animal sleeps in: the coop for chickens, the barn for the rest.
function animal_home(_kind){ return (_kind == "chicken") ? rm_coop : rm_barn; }

/// @description Where animals wander in this room (room pixels): the pasture on the farm, the pen in the barn or coop.
function animal_bounds(){
	if(room == rm_1) return animal_pasture();
	static pens = {};
	var n = room_get_name(room);
	if(pens[$ n] == undefined) pens[$ n] = layout_area(n, "pen");
	return pens[$ n];
}

/// @description Room Start: the herd in the meadow by day; at night, in bad weather and in winter, in the barn and coop.
function animals_room_start(){
	var inside = animals_indoors();
	if(room == rm_1 && inside) return;
	if(room != rm_1 && room != rm_barn && room != rm_coop) return;
	if(room != rm_1 && !inside) return;
	var list = animals_list(), p = animal_bounds();
	for(var i = 0; i < array_length(list); i++){
		if(room != rm_1 && animal_home(list[i].kind) != room) continue;
		instance_create_depth(irandom_range(p[0], p[2]), irandom_range(p[1], p[3]), 0, obj_animal, {data: list[i]});
	}
}

/// @description E beside an animal: pet it (once a day: +15 love) and take what it has for you. Returns a message.
function animal_tend(_a){
	var d = animal_def(_a.kind), msg = "";
	if(_a.petted != day_index()){
		_a.petted = day_index();
		_a.love = min(1000, _a.love + 15);
		msg = _a.name + ": " + d.sound;
	}
	if(_a.ready){
		// Well-loved animals sometimes give two
		var n = (random(1000) < _a.love * 0.4) ? 2 : 1;
		if(inv_add(item_stack(d.product, n)) > 0) return "Your bag is full";
		_a.ready = false;
		_a.days = 0;
		skill_add_xp("farming", 5);   // scripts/skills
		msg += ((msg == "") ? "" : "  ") + "+" + string(n) + " " + item_def(d.product).name;
	}
	return (msg == "") ? _a.name + " is happy to see you" : msg;
}

/// @description New-day part: products come along; animals nobody petted get a little lonely.
function animals_new_day(){
	var list = animals_list(), yesterday = day_index() - 1;
	for(var i = 0; i < array_length(list); i++){
		var a = list[i];
		if(a.petted < yesterday) a.love = max(0, a.love - farm_silo_love_loss());
		a.days += 1;
		if(a.days >= farm_silo_every(animal_def(a.kind).every)) a.ready = true;
	}
}

/// @description Eat an egg or milk from the hotbar.
function animal_product_eat(_stack){
	var pk = string_split(_stack.id, "|")[1];
	var pr = animal_products()[$ pk];
	if(pr == undefined) return;
	global.vitals.energy = min(vitals_max_energy(), global.vitals.energy + pr.energy);
	_stack.count--;
	if(_stack.count <= 0) global.inv.slots[global.inv.hotbar] = undefined;
	farm_message("Had some " + string_lower(pr.name) + "  (+" + string(pr.energy) + " energy)");
}
