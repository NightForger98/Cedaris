/// Festivals (milestone 11, docs/MILESTONES.md): one a season, on a fixed day, in the village.
///
/// On a festival day the village is decorated (obj_festival_decor), everyone comes (the whole valley spends the day
/// in the crowd: see villager_stops), talking counts double, and the notice board has a Festival page with the day's event.
/// global.world.festivals = {<key>_<year>: true} once you've taken part that year.

/// @description The festivals. kind: "shop" (a one-day stall), "lanterns" (light one for luck and friendship) or
/// "contest" (your best produce is judged).
function festival_table(){
	static t = [
		{key: "seedling", name: "Seedling Fair",    season: 0, day: 13, kind: "shop",
		 desc: "Mara's cousins come over the hills with seeds from every season, and the village swaps cuttings and gossip."},
		{key: "lantern",  name: "Lantern Night",    season: 1, day: 20, kind: "lanterns",
		 desc: "At dusk the village floats paper lanterns down the river, one wish each. Light one for luck - and for friends."},
		{key: "weighin",  name: "Harvest Weigh-in", season: 2, day: 16, kind: "contest",
		 desc: "Bring your best crop: the judges weigh it, sniff it, and award prizes to the finest in the valley."},
		{key: "frost",    name: "Frost Market",     season: 3, day: 25, kind: "shop",
		 desc: "Traders from far away set up stalls in the snow, selling things you'll find nowhere else all year."},
	];
	return t;
}

/// @description Today's festival, or undefined.
function festival_today(){
	if(!world_time_ready()) return undefined;
	var t = festival_table();
	for(var i = 0; i < array_length(t); i++) if(t[i].season == global.clock.season mod 4 && t[i].day == global.clock.day) return t[i];
	return undefined;
}

/// @description Have you already taken part in this year's festival?
function festival_done(_f){
	if(!is_struct(global.world[$ "festivals"])) global.world.festivals = {};
	return global.world.festivals[$ _f.key + "_" + string(global.clock.year)] ?? false;
}

function festival_mark(_f){
	festival_done(_f);
	global.world.festivals[$ _f.key + "_" + string(global.clock.year)] = true;
}

/// @description A festival's stall: the Seedling Fair has every season's seeds at a discount; the Frost Market has
/// rare and legendary materials and a few dyes.
function festival_stock(_f){
	var out = [];
	if(_f.key == "seedling"){
		var c = crop_table();
		for(var i = 0; i < array_length(c); i++) array_push(out, {id: "s|" + c[i].key, price: round(c[i].seed * 0.75)});
		array_push(out, {id: "d|cloth|pink", price: 60}, {id: "d|cloth|sky", price: 60}, {id: "d|cloth|yellow", price: 60});
	} else {
		array_push(out, {id: "m|moonsilk", price: 450}, {id: "m|pixie_dust", price: 400}, {id: "m|frost_crystal", price: 350},
		                {id: "m|dragon_scale", price: 2400}, {id: "m|phoenix_feather", price: 2400}, {id: "m|unicorn_hair", price: 2200},
		                {id: "m|void_pearl", price: 2600}, {id: "d|cloth|white", price: 80}, {id: "d|metal|silver", price: 120},
		                {id: "k|heal", price: 900});
	}
	return out;
}

/// @description Lantern Night: light a lantern (50 gold). Today's luck rises and every villager likes you more.
function festival_light_lantern(_f){
	if(festival_done(_f)) return "Your lantern is already drifting down the river.";
	if(!inv_is_free()){
		if(global.inv.gold < 50) return "A lantern costs 50 gold";
		global.inv.gold -= 50;
	}
	festival_mark(_f);
	global.clock.luck = (global.clock[$ "luck"] ?? 0) + 0.05;
	var names = variable_struct_get_names(villager_table());
	for(var i = 0; i < array_length(names); i++) people_add(names[i], 30);
	return "Your lantern floats away, glowing. You feel lucky - and the whole village smiles at you.";
}

/// @description Harvest Weigh-in: your best crop (the most valuable produce in your bag) is judged. Returns a message.
function festival_weigh_in(_f){
	if(festival_done(_f)) return "You've already entered this year. The judges are still talking about it.";
	var best = undefined, score2 = 0;
	for(var i = 0; i < INV_SIZE; i++){
		var st = global.inv.slots[i];
		if(st == undefined || item_def(st.id).type != "produce") continue;
		var v = item_sell_price(st.id);
		if(v > score2){ score2 = v; best = st.id; }
	}
	if(best == undefined) return "Bring a crop to enter - anything you've grown.";
	festival_mark(_f);
	var place, prize, extra;
	if(score2 >= 200){ place = "First prize"; prize = 1000; extra = ["d|metal|gold", 1]; }
	else if(score2 >= 90){ place = "Second prize"; prize = 400; extra = ["d|cloth|purple", 1]; }
	else { place = "A ribbon for trying"; prize = 100; extra = ["m|silk", 1]; }
	if(!inv_is_free()) global.inv.gold += prize;
	inv_add(item_stack(extra[0], extra[1]));
	people_add("mara", 60);
	return "The judges weigh your " + item_def(best).name + "... " + place + "!  +" + string(prize) + " gold, " + item_def(extra[0]).name;
}

/// @description On a festival day the village is decorated; everyone spends the day in its crowd (their schedule
/// for the day, see villager_stops), so they come in like anyone else.
function festival_room_start(){
	if(festival_today() == undefined || room != rm_2) return;
	instance_create_depth(0, 0, 0, obj_festival_decor);
}
