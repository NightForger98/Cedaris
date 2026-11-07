/// Plots and player-run shops (the user, 2026-11-07). The Mayor (City Hall, by Beirut's square) sells plots of land
/// once you have the Big Barn; how many you may own grows with your town standing (your farm's buildings, his
/// hearts, the town projects done). A plot's For Sale sign takes a Land Deed; then the sign lets you choose a shop
/// (one of each kind) and a building, and Rowan's crew builds it overnight. A villager with no work of their own runs
/// it: leave its raw materials in the stock crate, and each day they make some into goods (up to a day's limit) and
/// sell some (up to a day's limit), and take their wage. Talk to them to collect the takings; they keep adding up.
///
/// global.world.pshops = {<plot id>: {owned, kind, design, building, built, staff, stock: {<item id>: n},
///                        goods: {<item id>: n} (made, not sold yet), till, report}}
/// Plots: obj_plot (tools/world2/areas_build.js lays them out), their shops' insides rm_pshop_<id>.

#macro PSHOP_DEED_PRICE 5000      // the first plot; each one after costs this much more
#macro PSHOP_BUILD_GOLD 4000      // Rowan's crew, for the building
#macro PSHOP_BUILD_WOOD 200
#macro PSHOP_BUILD_STONE 100

/// @description The shops you can open, one of each, copying the town's own: what raw materials each takes (ids, or
/// prefixes ending in "|"), what it makes of them, how much a good is worth (x the raw material's price), how many
/// it makes and sells a day at most, and the employee's daily wage.
function pshop_kinds(){
	static t = {
		tailor:     {name: "Tailor",        like: "Larkspun Clothes",     raws: ["m|wool", "m|cotton", "m|linen", "m|silk"],      goods: "thread and cloth", mult: 2.2, make: 10, sell: 5,  wage: 30},
		smithy:     {name: "Smithy",        like: "Brom's forge",         raws: ["m|copper_ore", "m|iron_ore", "m|silver_ore", "m|gold_ore"], goods: "metal bars", mult: 2.4, make: 10, sell: 6, wage: 40},
		bakery:     {name: "Bakery",        like: "Night's Bakery",       raws: ["p|corn", "p|potato", "p|gourd", "a|egg", "a|milk"], goods: "bread and pies", mult: 2.0, make: 12, sell: 8, wage: 35},
		flowers:    {name: "Flower Shop",   like: "Posy's Flowers",       raws: ["w|"],                                             goods: "bouquets",        mult: 2.0, make: 10, sell: 6,  wage: 25},
		tavern:     {name: "Tavern",        like: "The Tavern",           raws: ["p|", "x|", "f|"],                                 goods: "meals",           mult: 1.8, make: 12, sell: 8,  wage: 40},
		apothecary: {name: "Apothecary",    like: "Silverbough Potions",  raws: ["w|", "m|pixie_dust", "m|frost_crystal", "m|ember_core"], goods: "potions",   mult: 2.2, make: 8,  sell: 4,  wage: 35},
		produce:    {name: "Produce Stand", like: "Meadowlark Farm",      raws: ["p|", "a|"],                                       goods: "fresh produce",   mult: 1.4, make: 20, sell: 12, wage: 25},
		fish:       {name: "Fish Market",   like: "Marlo's Fish Shack",   raws: ["x|"],                                             goods: "fish",            mult: 1.5, make: 15, sell: 10, wage: 30},
		lumber:     {name: "Lumber Yard",   like: "Oakhart Lumber Mill",  raws: ["m|wood", "m|stone"],                              goods: "planks and blocks", mult: 3.0, make: 40, sell: 25, wage: 30},
	};
	return t;
}

/// @description The kinds in the order the sign's menu lists them.
function pshop_kind_keys(){ static k = ["tailor", "smithy", "bakery", "flowers", "tavern", "apothecary", "produce", "fish", "lumber"]; return k; }

/// @description Who runs the shops: villagers with no work of their own, in the order they're taken on.
function pshop_staff_pool(){ static p = ["liora", "clara", "nerissa", "sylva", "tauriel", "ayla", "marina", "tomas", "della"]; return p; }

/// @description A plot's state (made the first time it's asked for).
function pshop_plot(_id){
	if(!is_struct(global.world[$ "pshops"])) global.world.pshops = {};
	var p = global.world.pshops[$ _id];
	if(!is_struct(p)){
		p = {owned: false, kind: "", design: "", building: false, built: false, staff: "", stock: {}, goods: {}, till: 0, report: ""};
		global.world.pshops[$ _id] = p;
	}
	return p;
}

function pshop_ids(){ return is_struct(global.world[$ "pshops"]) ? variable_struct_get_names(global.world.pshops) : []; }

// ---------------------------------------------------------------- standing and land

/// @description How many town projects are done.
function pshop_projects_done(){
	var t = project_table(), n = 0;
	for(var i = 0; i < array_length(t); i++) if(project_done(t[i].key)) n++;
	return n;
}

/// @description Your town standing: 1 a farm building stage and farmhouse upgrade, 1 a heart with the Mayor, 2 a town
/// project done. Returns {farm, hearts, projects, total}.
function pshop_standing(){
	var farm = farm_building_level("barn") + farm_building_level("coop") + farm_building_level("shed") + farm_building_level("silo") + clamp(house_level(), 0, 3);
	var hearts = people_hearts("mayor"), pr = pshop_projects_done() * 2;
	return {farm: farm, hearts: hearts, projects: pr, total: farm + hearts + pr};
}

/// @description The standing you need for each plot you own: the 1st, the 2nd...
function pshop_thresholds(){ static t = [8, 13, 18, 22, 26, 29, 31, 33]; return t; }

/// @description How many plots your standing allows.
function pshop_slots(){
	var t = pshop_thresholds(), s = pshop_standing().total, n = 0;
	for(var i = 0; i < array_length(t); i++) if(s >= t[i]) n++;
	return n;
}

/// @description How many plots you own, counting deeds in your bag not yet used.
function pshop_owned_count(){
	var ids = pshop_ids(), n = inv_count("m|land_deed");
	for(var i = 0; i < array_length(ids); i++) if(global.world.pshops[$ ids[i]].owned) n++;
	return n;
}

/// @description Whether the Mayor will sell you a plot now, and if not why ("" if he will).
function pshop_land_why_not(){
	if(farm_building_level("barn") < 1) return "The council only sells land to farmers who've built up their farm. Come back when you have a Big Barn.";
	var n = pshop_owned_count(), slots = pshop_slots(), t = pshop_thresholds();
	if(n >= array_length(t)) return "You own all the land the council can spare.";
	if(n >= slots) return "Your standing in town is " + string(pshop_standing().total) + ". The council will sell you another plot at " + string(t[n]) + ".";
	return "";
}

/// @description The Mayor's stock (people_trade, shop "land"): a Land Deed when he'll sell you one.
function pshop_land_stock(){
	if(pshop_land_why_not() != "") return [];
	return [{id: "m|land_deed", price: PSHOP_DEED_PRICE * (pshop_owned_count() + 1)}];
}

/// @description What the Mayor says about land and your standing.
function pshop_mayor_line(){
	var st = pshop_standing(), why = pshop_land_why_not();
	var s = "Your standing in town: " + string(st.total) + " (farm " + string(st.farm) + ", our friendship " + string(st.hearts) + ", town projects " + string(st.projects) + "). ";
	if(why != "") return s + why;
	return s + "There's land for sale - a deed is " + string(PSHOP_DEED_PRICE * (pshop_owned_count() + 1)) + " gold. Press T to see it, then take it to a For Sale sign.";
}

// ---------------------------------------------------------------- building

/// @description The buildings you can choose for a plot: {is, spr, w, h, ox, door, solid} (world_plot_designs, generated).
function pshop_designs(){ return world_plot_designs(); }

/// @description The kinds you can still open (one of each).
function pshop_free_kinds(){
	var out = [], k = pshop_kind_keys(), ids = pshop_ids();
	for(var i = 0; i < array_length(k); i++){
		var used = false;
		for(var j = 0; j < array_length(ids) && !used; j++) if(global.world.pshops[$ ids[j]].kind == k[i]) used = true;
		if(!used) array_push(out, k[i]);
	}
	return out;
}

/// @description Order a shop on an owned plot: pay Rowan's crew; it's built overnight. Returns a message.
function pshop_order(_id, _kind, _design){
	var p = pshop_plot(_id);
	if(!p.owned || p.building || p.built) return "";
	if(!inv_is_free()){
		var miss = "";
		if(global.inv.gold < PSHOP_BUILD_GOLD) miss += string(PSHOP_BUILD_GOLD) + " gold";
		if(cost_count("wood") < PSHOP_BUILD_WOOD) miss += ((miss != "") ? ", " : "") + string(PSHOP_BUILD_WOOD) + " wood";
		if(cost_count("stone") < PSHOP_BUILD_STONE) miss += ((miss != "") ? ", " : "") + string(PSHOP_BUILD_STONE) + " stone";
		if(miss != "") return "Rowan's crew needs " + miss + " to build it";
		global.inv.gold -= PSHOP_BUILD_GOLD;
		cost_take("wood", PSHOP_BUILD_WOOD);
		cost_take("stone", PSHOP_BUILD_STONE);
	}
	p.kind = _kind;
	p.design = _design;
	p.building = true;
	return "Rowan's crew will build your " + string_lower(pshop_kinds()[$ _kind].name) + " overnight";
}

/// @description Take a villager on for a shop: the first of the pool not working in one already.
function pshop_hire(){
	var pool = pshop_staff_pool(), ids = pshop_ids();
	for(var i = 0; i < array_length(pool); i++){
		var busy = false;
		for(var j = 0; j < array_length(ids) && !busy; j++) if(global.world.pshops[$ ids[j]].staff == pool[i]) busy = true;
		if(!busy) return pool[i];
	}
	return "";
}

/// @description The plot a villager runs a shop on ("" if none).
function pshop_staff_plot(_key){
	var ids = pshop_ids();
	for(var i = 0; i < array_length(ids); i++){
		var p = global.world.pshops[$ ids[i]];
		if(p.built && p.staff == _key) return ids[i];
	}
	return "";
}

/// @description A shop's employee's day (villager_routine uses it in place of their own): behind the counter 9 to 5,
/// Sundays off.
function pshop_staff_routine(_key, _r){
	var pid = pshop_staff_plot(_key);
	if(pid == "") return _r;
	return {home: _r.home, work: {at: "rm_pshop_" + pid + ".staff_work", open: 9, close: 17, off: 6},
	        after: [[17, "rm_beirut.square_c"], [19, "home"]], dayoff: [[10, "rm_beirut.park_2"], [14, "rm_beirut.cafe_b"], [18, "home"]]};
}

// ---------------------------------------------------------------- the shop's day

/// @description Whether a shop takes an item as raw material.
function pshop_accepts(_kind, _id){
	var r = pshop_kinds()[$ _kind].raws;
	for(var i = 0; i < array_length(r); i++){
		var k = r[i];
		if(string_char_at(k, string_length(k)) == "|"){ if(string_pos(k, _id) == 1) return true; }
		else if(_id == k || string_pos(k + "|", _id) == 1) return true;
	}
	return false;
}

/// @description How many items a {id: n} store holds.
function pshop_count(_store){
	var k = variable_struct_get_names(_store), n = 0;
	for(var i = 0; i < array_length(k); i++) n += _store[$ k[i]];
	return n;
}

/// @description Leave the held stack in a shop's stock crate. Returns a message.
function pshop_stock_add(_id){
	var p = pshop_plot(_id), held = inv_held_stack();
	var kd = pshop_kinds()[$ p.kind];
	if(held == undefined) return "In stock: " + string(pshop_count(p.stock)) + " raw, " + string(pshop_count(p.goods)) + " " + kd.goods + " ready to sell";
	if(!pshop_accepts(p.kind, held.id)) return "The " + string_lower(kd.name) + " doesn't use " + string_lower(item_def(held.id).name);
	var n = held.count, nm = item_def(held.id).name;
	p.stock[$ held.id] = (p.stock[$ held.id] ?? 0) + n;
	global.inv.slots[global.inv.hotbar] = undefined;
	return "Left " + string(n) + " " + nm + " for " + string_lower(kd.name) + " (" + string(pshop_count(p.stock)) + " in stock)";
}

/// @description A good's sale price: the raw material's worth times the shop's.
function pshop_good_price(_kind, _id){
	var d = item_def(_id);
	return max(1, round(((d == undefined) ? 1 : d.price) * pshop_kinds()[$ _kind].mult));
}

/// @description One shop's day: make up to its limit from the stock, sell up to its limit, pay the wage.
function pshop_day(_id){
	var p = pshop_plot(_id), kd = pshop_kinds()[$ p.kind];
	var made = 0, sold = 0, takings = 0;
	var ks = variable_struct_get_names(p.stock);
	for(var i = 0; i < array_length(ks) && made < kd.make; i++){
		var n = min(p.stock[$ ks[i]], kd.make - made);
		if(n <= 0) continue;
		p.stock[$ ks[i]] -= n;
		if(p.stock[$ ks[i]] <= 0) variable_struct_remove(p.stock, ks[i]);
		p.goods[$ ks[i]] = (p.goods[$ ks[i]] ?? 0) + n;
		made += n;
	}
	var gs = variable_struct_get_names(p.goods);
	for(var i = 0; i < array_length(gs) && sold < kd.sell; i++){
		var n = min(p.goods[$ gs[i]], kd.sell - sold);
		if(n <= 0) continue;
		p.goods[$ gs[i]] -= n;
		if(p.goods[$ gs[i]] <= 0) variable_struct_remove(p.goods, gs[i]);
		takings += n * pshop_good_price(p.kind, gs[i]);
		sold += n;
	}
	// the wage, on days there was work (an empty shop: they stay home, unpaid)
	var wage = (made > 0 || sold > 0) ? kd.wage : 0;
	p.till += takings - wage;
	p.report = "Yesterday: made " + string(made) + " " + kd.goods + ", sold " + string(sold) + " for " + string(takings) + " gold"
	         + ((wage > 0) ? ", my wage " + string(wage) : ", no work (the stock's empty)") + ".";
}

/// @description New-day part: shops ordered yesterday are built (and staffed), and every shop has its day. Returns a
/// note for the morning ("" if none).
function pshops_new_day(){
	var note = "", ids = pshop_ids();
	for(var i = 0; i < array_length(ids); i++){
		var p = global.world.pshops[$ ids[i]];
		if(p.built) pshop_day(ids[i]);
		else if(p.building){
			p.building = false;
			p.built = true;
			p.staff = pshop_hire();
			var who = (p.staff != "") ? villager_def(p.staff).name + " will run it." : "Nobody's free to run it yet.";
			note += ((note != "") ? " " : "") + "Rowan's crew built your " + string_lower(pshop_kinds()[$ p.kind].name) + "! " + who;
		}
	}
	return note;
}

/// @description Talking to your employee in the shop: their report, and the takings handed over. Returns [text, note].
function pshop_staff_talk(_key){
	var pid = pshop_staff_plot(_key);
	var p = pshop_plot(pid), kd = pshop_kinds()[$ p.kind];
	var text = (p.report != "") ? p.report : "Welcome to your " + string_lower(kd.name) + "! Leave " + kd.goods + " materials in the crate and I'll do the rest.";
	text += "  (stock: " + string(pshop_count(p.stock)) + " raw, " + string(pshop_count(p.goods)) + " " + kd.goods + "; I make " + string(kd.make) + " and sell " + string(kd.sell) + " a day)";
	var note = "";
	if(p.till > 0){ global.inv.gold += p.till; note = "+" + string(p.till) + " gold from the shop"; p.till = 0; }
	else if(p.till < 0){
		var pay = min(-p.till, global.inv.gold);
		global.inv.gold -= pay; p.till += pay;
		note = "Paid " + string(pay) + " gold in wages" + ((p.till < 0) ? " (still owed " + string(-p.till) + ")" : "");
	}
	p.report = "";
	return [text, note];
}

// ---------------------------------------------------------------- tests

/// @description Test: give yourself a deed and claim a plot.
function autotest_pshop_claim(_id){ var p = pshop_plot(_id); p.owned = true; return "owned " + _id; }

/// @description Test: order and finish a shop on a plot.
function autotest_pshop_build(_id, _kind){
	var p = pshop_plot(_id);
	p.owned = true;
	global.inv.gold += PSHOP_BUILD_GOLD;
	inv_add(item_stack("m|wood", PSHOP_BUILD_WOOD));
	inv_add(item_stack("m|stone", PSHOP_BUILD_STONE));
	var d = pshop_designs(), why = pshop_order(_id, _kind, d[0].is);
	if(!p.building) return why;
	return pshops_new_day();
}

/// @description Test: put n of an item in a shop's stock.
function autotest_pshop_stock(_id, _item, _n){ var p = pshop_plot(_id); p.stock[$ _item] = (p.stock[$ _item] ?? 0) + real(_n); return string(pshop_count(p.stock)); }

// ---------------------------------------------------------------- the plot's sign (obj_plot)

/// @description Whether a plot's menu is open (ui_blocking).
function plot_menu_open(){
	var open = false;
	with(obj_plot) if(menuOpen) open = true;
	return open;
}

/// @description The menu's lines: the kinds you can still open, or the buildings.
function pshop_plot_menu_list(_plot){
	var out = [];
	if(_plot.stage == 0){
		var k = pshop_free_kinds();
		for(var i = 0; i < array_length(k); i++) array_push(out, pshop_kinds()[$ k[i]].name);
	} else {
		var d = pshop_designs();
		for(var i = 0; i < array_length(d); i++) array_push(out, d[i].name);
	}
	return out;
}

/// @description A line chosen in the menu: a kind (on to the buildings), or a building (the order).
function pshop_plot_menu_choose(_plot, _i){
	with(_plot){
		if(stage == 0){
			kindPick = pshop_free_kinds()[_i];
			stage = 1;
			pick = 0;
		} else {
			var msg = pshop_order(plot, kindPick, pshop_designs()[_i].is);
			menuOpen = false;
			game.resumeLock = 2;
			farm_message(msg);
		}
	}
}

/// @description Put up a plot's building (obj_plot, at Room Start once it's built): the picture and its solid foot,
/// standing with its door on the plot's door.
function pshop_plot_raise(_plot){
	var p = pshop_plot(_plot.plot), d = undefined, ds = pshop_designs();
	for(var i = 0; i < array_length(ds); i++) if(ds[i].is == p.design) d = ds[i];
	if(d == undefined) d = ds[0];
	var c0 = (_plot.x div 32) + (_plot.pw div 2) - d.door[0], r0 = (_plot.y div 32) + (_plot.ph - 1) - d.door[1];
	var b = instance_create_depth(c0 * 32 + d.ox, (r0 + d.h) * 32, 0, obj_building);
	b.sprite_index = d.spr;
	for(var i = 0; i < array_length(d.solid); i++){
		var s = d.solid[i];
		var box = instance_create_depth((c0 + s[0]) * 32 + s[2] * 16, (r0 + s[1]) * 32 + s[3] * 16, 0, obj_col_box);
		box.image_xscale = s[2] * 2; box.image_yscale = s[3] * 2; box.visible = false;
	}
}

/// @description Test: a shop's numbers "stock goods till".
function autotest_pshop_state(_id){ var p = pshop_plot(_id); return string(pshop_count(p.stock)) + " " + string(pshop_count(p.goods)) + " " + string(p.till) + " " + p.staff; }
