/// Schedules: where every villager is through the day, and walking them there (as in Stardew Valley and Harvest Moon).
///
/// Everyone has a home, and most have a job: where they work, its hours, and a day off each week, when they do
/// something else (Wren shops at Mara's on Tuesdays). A shop is open only while its keeper is behind the counter, in
/// hours. A day is a list of stops [hour, place]: at that hour they set off for the place and walk there at
/// WALK_SPEED, along a route through the rooms' doors (room_walk, generated from the built rooms), so someone who
/// opens at 9 leaves home at 8 and turns up around 9, depending on how far they live.
///
/// Where someone is comes from the clock alone, so nothing is saved, and people you can't see are always where
/// they'd be: when one walks into the room you're in, an obj_villager appears at the door (villagers_update).
/// On a festival day everyone spends the day in the festival crowd in Downtown instead.
///
/// Places are "room.point" (named points in tools/rooms/specs, reached through layout_point), or "home".

#macro WALK_SPEED 120  // room pixels per game minute (about 2 px a frame at the slower clock): the longest commute is about 75 minutes

/// @description Homes, jobs and days. work: {at, open, close, off} - hours, and the weekday off (0 Mon - 6 Sun);
/// they leave an hour before opening. after: their evening once work's done (default: home at closing time).
/// dayoff: their day off. routine: every day, for those without a job. kid: last on the map's house labels.
/// seasons: {spring | summer | fall | winter: {routine | work | after | dayoff}} - the parts of their week that change.
/// hammer: swings a hammer while working (Brom). rainproof: still goes out in the rain (Marlo fishes, Garrick keeps
/// watch, Pip minds the sheep, Hask hunts, and Elda loves it); everyone else stays in (villager_stops).
function villager_routines(){
	static t = {
		// The new world (design/world_plan.md): generated from a checked list, every place a named spot in the room specs
		yubaba:  {home: "rm_hotel.yubaba_bed", work: {at: "rm_hotel.yubaba_work", open: 7, close: 21, off: 6}, dayoff: [[9, "rm_wellshead.s2"], [12, "rm_town_inn.table_a"], [16, "rm_hotel.home"], [21, "home"]]},   // the hotel; Boh minds it on Sundays
		boh:     {home: "rm_hotel.boh_bed", work: {at: "rm_hotel.boh_work", open: 8, close: 18, off: 3}, after: [[18, "rm_wellshead.s3"], [20, "home"]], dayoff: [[9, "rm_manara.s2"], [12, "rm_starsand.s3"], [16, "rm_town_inn.table_b"], [20, "home"]]},
		coralie: {home: "rm_lighthouse.coralie_bed", rainproof: true, work: {at: "rm_lighthouse.coralie_work", open: 6, close: 14, off: 5}, after: [[14, "rm_manara.s3"], [18, "rm_lighthouse.home"], [22, "home"]], dayoff: [[9, "rm_starsand.s2"], [13, "rm_town_inn.table_c"], [17, "home"]]},
		// The five families added on 2026-11-06: the one who runs the workshop, and the one who helps
		rami:    {home: "rm_home_saba.rami_bed", work: {at: "rm_olive_press.rami_work", open: 8, close: 16, off: 0}, after: [[16, "rm_olivebay.mid"], [19, "rm_home_saba.table"], [22, "home"]], dayoff: [[9, "rm_olivebay.mid"], [13, "rm_redstreet.mid"], [17, "home"]]},
		noor:    {home: "rm_home_saba.noor_bed", routine: [[7, "rm_olivebay.mid"], [11, "rm_olive_press.noor_work"], [16, "rm_home_saba.home"], [20, "home"]]},
		ottilie: {home: "rm_home_brassbolt.ottilie_bed", work: {at: "rm_tinker.ottilie_work", open: 9, close: 18, off: 2}, after: [[18, "rm_hangar.mid"], [20, "home"]], dayoff: [[10, "rm_downtown.mid"], [14, "rm_starsand.mid"], [18, "home"]]},
		gus:     {home: "rm_home_brassbolt.gus_bed", kid: true, routine: [[9, "rm_hangar.mid"], [12, "rm_tinker.gus_work"], [16, "rm_starsand.mid"], [18, "home"]]},
		hal:     {home: "rm_home_saltwhistle.hal_bed", work: {at: "rm_boatyard.hal_work", open: 8, close: 16, off: 4}, after: [[16, "rm_southbeach.pier_b"], [19, "home"]], dayoff: [[7, "rm_southbeach.pier_end"], [12, "rm_whitesand.mid"], [17, "home"]]},
		marina:  {home: "rm_home_saltwhistle.marina_bed", routine: [[6, "rm_southbeach.pier_end"], [9, "rm_boatyard.marina_work"], [15, "rm_whitesand.mid"], [19, "home"]]},
		iris:    {home: "rm_home_fairglass.iris_bed", work: {at: "rm_glassworks.iris_work", open: 9, close: 17, off: 1}, after: [[17, "rm_wellshead.mid"], [20, "home"]], dayoff: [[10, "rm_hotel.guest_a"], [14, "rm_manara.mid"], [18, "home"]]},
		tomas:   {home: "rm_home_fairglass.tomas_bed", routine: [[7, "rm_wellshead.mid"], [10, "rm_glassworks.tomas_work"], [16, "rm_home_fairglass.home"], [20, "home"]]},
		bram:    {home: "rm_home_hayward.bram_bed", work: {at: "rm_stables.bram_work", open: 7, close: 15, off: 3}, after: [[15, "rm_frere.mid"], [19, "home"]], dayoff: [[9, "rm_sthereza.mid"], [13, "rm_abda.mid"], [17, "home"]]},
		della:   {home: "rm_home_hayward.della_bed", routine: [[7, "rm_stables.della_work"], [12, "rm_home_hayward.home"], [15, "rm_frere.mid"], [19, "home"]]},
		morga:   {home: "rm_witch_tower.morga_bed", rainproof: true, routine: [[8, "rm_witch_tower.morga_work"], [12, "rm_plummet.cliff_a"], [14, "rm_witch_tower.morga_work"], [21, "home"]]},
		rook:    {home: "rm_witch_tower.rook_bed", kid: true, routine: [[9, "rm_plummet.cliff_a"], [12, "rm_witch_tower.home"], [15, "rm_plummet.cliff_b"], [18, "home"]]},
		cassius: {home: "rm_home_goldcrest.cassius_bed", work: {at: "rm_bank.cassius_work", open: 9, close: 16, off: 6}, after: [[16, "rm_downtown.s2"], [18, "rm_town_inn.table_d"], [21, "home"]], dayoff: [[10, "rm_redstreet.s2"], [13, "rm_town_inn.table_d"], [16, "home"]]},
		liora:   {home: "rm_home_goldcrest.liora_bed", routine: [[9, "rm_redstreet.s3"], [11, "rm_downtown.s4"], [14, "rm_olivebay.s3"], [17, "rm_town_inn.table_e"], [20, "home"]]},
		lysa:    {home: "rm_town_inn.lysa_bed", work: {at: "rm_town_inn.lysa_work", open: 10, close: 22, off: 0}, dayoff: [[10, "rm_downtown.s3"], [13, "rm_verdun.s2"], [17, "rm_town_inn.bar_a"], [22, "home"]]},   // the tavern
		sanji:   {home: "rm_valley_ranch.shop_a", work: {at: "rm_town_inn.bar", open: 10, close: 21, off: 2}, dayoff: [[8, "rm_whitesand.pier_b"], [12, "rm_valley_ranch.ranch_table"], [16, "rm_ovenswindow.s2"], [20, "home"]]},   // the tavern's cook
		ida:     {home: "rm_town_home_se.ida_bed", work: {at: "rm_town_inn.ida_work", open: 11, close: 20, off: 1}, dayoff: [[9, "rm_beaconhill.s2"], [12, "rm_bakery.customer"], [15, "rm_town_home_se.ida_home"], [21, "home"]]},   // serves at the tavern
		ayla:    {home: "rm_home_kassar.ayla_bed", routine: [[9, "rm_winghill.s2"], [12, "rm_home_kassar.home"], [16, "rm_winghill.s5"], [18, "rm_town_inn.bar_b"], [22.5, "home"]]},   // dances at the tavern in the evenings
		mara:    {home: "rm_home_whitlow.mara_bed", work: {at: "rm_toolstore.mara_work", open: 9, close: 17, off: 2}, dayoff: [[9, "rm_verdun.s3"], [11, "rm_bakery.customer"], [14, "rm_home_whitlow.home"], [21, "home"]]},
		zenya:   {home: "rm_home_kassar.zenya_bed", work: {at: "rm_toolstore.zenya_work", open: 9, close: 17, off: 3}, after: [[17, "rm_winghill.s4"], [19, "rm_town_inn.table_f"], [22, "home"]], dayoff: [[10, "rm_starsand.s4"], [14, "rm_guild.customer"], [18, "rm_town_inn.table_f"], [22, "home"]]},
		clara:   {home: "rm_home_whitlow.clara_bed", routine: [[9, "rm_gracetower.s1"], [12, "rm_home_whitlow.home"], [15, "rm_downtown.s5"], [18, "home"]]},
		brom:    {home: "rm_village_smithy.brom_bed", hammer: true, work: {at: "rm_village_smithy.brom_work", open: 9, close: 17, off: 3}, after: [[17.5, "rm_gracetower.s2"], [19, "rm_town_inn.table_a"], [21.5, "home"]], dayoff: [[8, "rm_whitesand.pier_b"], [13, "rm_town_inn.table_a"], [18, "rm_gracetower.s2"], [20, "home"]]},
		kael:    {home: "rm_village_smithy.shop_b", work: {at: "rm_village_smithy.shop_a", open: 9, close: 17, off: 4}, after: [[17, "rm_gracetower.s4"], [19, "rm_town_inn.table_g"], [22, "home"]], dayoff: [[9, "rm_beaconhill.s3"], [13, "rm_guild.customer"], [17, "rm_town_inn.table_g"], [21, "home"]]},
		garrick: {home: "rm_town_home_se.ida_home", rainproof: true, work: {at: "rm_beaconhill.miner", open: 8, close: 18, off: 6}, dayoff: [[9, "rm_beaconhill.s4"], [13, "rm_village_smithy.shop_b"], [16, "rm_town_inn.table_c"], [22, "home"]]},   // mines (by the cave)
		fen:     {home: "rm_town_home_se.fen_bed", work: {at: "rm_beaconhill.stall", open: 8, close: 17, off: 0}, dayoff: [[9, "rm_victoryhill.s2"], [12, "rm_downtown.s1"], [16, "rm_town_home_se.fen_home"], [20.5, "home"]]},   // the mine stall: ore and explosives
		marlo:   {home: "rm_home_gullwater.marlo_bed", rainproof: true, seasons: {winter: {after: [[12, "rm_town_inn.door_table"], [20.5, "home"]]}}, work: {at: "rm_whitesand.pier_end", open: 6, close: 12, off: 6}, after: [[12, "rm_beach_hut.marlo_home"], [17, "rm_pigeonrocks.s2"], [19, "home"]], dayoff: [[9, "rm_pigeonrocks.s3"], [12, "rm_village_store.shop_c"], [14, "rm_home_gullwater.home"], [21, "home"]]},
		nerissa: {home: "rm_home_gullwater.nerissa_bed", routine: [[7, "rm_whitesand.pier_b"], [12, "rm_pigeonrocks.s4"], [16, "rm_beach_hut.marlo_home"], [19, "home"]]},
		sera:    {home: "rm_village_store.shop_c", work: {at: "rm_bakery.sera_work", open: 7, close: 15, off: 0}, after: [[15, "rm_village_hesta.hesta_home"], [20, "home"]], dayoff: [[9, "rm_sthereza.s2"], [12, "rm_village_hesta.hesta_home"], [20, "home"]]},   // the bakery
		posy:    {home: "rm_flowershop.browse", work: {at: "rm_flowershop.posy_work", open: 9, close: 17, off: 0}, dayoff: [[9, "rm_yarzeh.s2"], [14, "rm_frere.s2"], [17, "rm_town_inn.bar_a"], [21, "home"]]},
		rowan:   {home: "rm_village_rowan.rowan_bed", work: {at: "rm_furniture.rowan_work", open: 9, close: 17, off: 5}, after: [[17, "rm_victoryhill.s3"], [19, "home"]], dayoff: [[9, "rm_valley_carpentry.shop_a"], [11, "rm_ovenswindow.s3"], [15, "home"]]},   // the furniture shop
		alban:   {home: "rm_village_elda.elda_bed", work: {at: "rm_hospital.alban_work", open: 9, close: 17, off: 6}, dayoff: [[9, "rm_frere.s3"], [13, "rm_town_inn.table_h"], [17, "home"]]},
		marigold:{home: "rm_village_elda.elda_table", work: {at: "rm_hospital.marigold_work", open: 10, close: 16, off: 5}, dayoff: [[8, "rm_yarzeh.s3"], [13, "rm_resolve.s2"], [16, "home"]]},
		edwin:   {home: "rm_town_home_nw.edwin_bed", work: {at: "rm_library.edwin_work", open: 9, close: 17, off: 6}, dayoff: [[10, "rm_town_home_nw.edwin_desk"], [14, "rm_uptown.s2"], [17, "rm_town_inn.table_e"], [21, "home"]]},
		wynn:    {home: "rm_town_home_nw.edwin_desk", kid: true, routine: [[9, "rm_library.wynn_study"], [13, "rm_uptown.s3"], [16, "rm_ovenswindow.s4"], [19, "home"]]},
		poupry:  {home: "rm_valley_ranch.ranch_table", rainproof: true, work: {at: "rm_valley_ranch.wren_work", open: 7, close: 16, off: 1}, dayoff: [[9, "rm_sthereza.s3"], [12, "rm_bakery.customer"], [15, "rm_valley_ranch.ranch_table"], [21, "home"]]},   // Meadowlark Farm: animals, milk, wool, eggs
		tauriel: {home: "rm_valley_ranch.wren_work", routine: [[8, "rm_olivebay.s2"], [13, "rm_downtown.s6"], [17, "rm_ovenswindow.s1"], [20, "home"]]},   // paints the bay in the mornings
		wren:    {home: "rm_valley_ranch.wren_bed", rainproof: true, work: {at: "rm_ovenswindow.s5", open: 7, close: 16, off: 2}, after: [[16, "rm_winghill.s3"], [19, "home"]], dayoff: [[9, "rm_winghill.s3"], [13, "rm_whitesand.pier_b"], [17, "home"]]},   // a farmhand at Meadowlark Farm
		pip:     {home: "rm_valley_ranch.pip_bed", rainproof: true, work: {at: "rm_ovenswindow.s6", open: 7, close: 16, off: 6}, after: [[16, "rm_ovenswindow.s2"], [19, "home"]], dayoff: [[10, "rm_winghill.s1"], [13, "rm_whitesand.s2"], [17, "home"]]},
		thorne:  {home: "rm_village_rowan.rowan_home", rainproof: true, seasons: {summer: {after: [[16, "rm_whitesand.pier_b"], [19.5, "rm_town_inn.table_b"], [21.5, "home"]]}}, work: {at: "rm_victoryhill.s2", open: 7, close: 16, off: 5}, after: [[16, "rm_valley_carpentry.rowan_work"], [18.5, "rm_town_inn.table_b"], [21.5, "home"]], dayoff: [[8, "rm_yarzeh.s4"], [12, "rm_victoryhill.s4"], [15, "rm_village_smithy.shop_a"], [18, "rm_town_inn.table_b"], [21, "home"]]},   // fells the trees
		garth:   {home: "rm_valley_carpentry.thorne_bed", work: {at: "rm_valley_carpentry.thorne_work", open: 8, close: 17, off: 6}, after: [[17, "rm_victoryhill.s5"], [19, "rm_town_inn.table_h"], [22, "home"]], dayoff: [[9, "rm_victoryhill.s5"], [13, "rm_guild.customer"], [17, "rm_town_inn.table_h"], [21, "home"]]},   // the lumber mill: wood and building
		nell:    {home: "rm_town_home_e.nell_bed", work: {at: "rm_town_outfitter.bryn_work", open: 9, close: 17, off: 0}, dayoff: [[9, "rm_valley_ranch.shop_a"], [13, "rm_dahya.s2"], [16, "rm_town_home_e.nell_wheel"], [18, "home"]]},   // the clothes store
		mira:    {home: "rm_town_home_e.nell_wheel", work: {at: "rm_town_outfitter.shop_a", open: 10, close: 17, off: 3}, after: [[17, "rm_dahya.s4"], [19, "home"]], dayoff: [[10, "rm_winghill.s4"], [14, "rm_verdun.s4"], [18, "home"]]},
		bryn:    {home: "rm_home_tawil.bryn_bed", work: {at: "rm_town_outfitter.shop_b", open: 9, close: 16, off: 4}, after: [[16, "rm_dahya.s5"], [18, "rm_town_inn.table_g"], [21, "home"]], dayoff: [[9, "rm_yarzeh.s5"], [14, "rm_dahya.s5"], [18, "home"]]},
		dikhaj:  {home: "rm_home_tawil.dikhaj_bed", rainproof: true, routine: [[8, "rm_yarzeh.s2"], [11, "rm_winghill.stall"], [16, "rm_dahya.s3"], [19, "home"]]},   // runs the market stalls
		elda:    {home: "rm_town_apothecary.morga_bed", rainproof: true, work: {at: "rm_town_apothecary.morga_work", open: 10, close: 18, off: 4}, dayoff: [[8, "rm_yarzeh.s3"], [13, "rm_village_elda.elda_table"], [16, "rm_resolve.s3"], [19, "home"]]},   // the potion shop
		hask:    {home: "rm_town_home_sw.hask_bed", rainproof: true, work: {at: "rm_guild.hask_work", open: 9, close: 17, off: 3}, dayoff: [[7, "rm_yarzeh.s4"], [15, "rm_resolve.s4"], [19, "home"]]},   // ranged weapons at the Guild
		sylva:   {home: "rm_town_home_sw.hask_home", routine: [[8, "rm_yarzeh.s3"], [13, "rm_resolve.s2"], [16, "rm_town_apothecary.shop_a"], [19, "home"]]},
		soren:   {home: "rm_village_store.mara_bed", work: {at: "rm_village_store.mara_work", open: 8, close: 17, off: 6}, dayoff: [[9, "rm_sthereza.s4"], [12, "rm_bakery.customer"], [15, "rm_village_hesta.hesta_home"], [21, "home"]]},   // the Night farm: seeds and honey
		hesta:   {home: "rm_village_hesta.hesta_bed", seasons: {spring: {routine: [[7, "rm_village_hesta.hesta_home"], [9, "rm_village_store.shop_b"], [10.5, "rm_sthereza.s3"], [17.5, "rm_village_hesta.hesta_home"], [21, "home"]]}}, routine: [[7, "rm_village_hesta.hesta_home"], [10, "rm_sthereza.s2"], [12, "rm_village_hesta.hesta_home"], [15, "rm_sthereza.s4"], [18, "home"]]},
		tobin:   {home: "rm_village_hesta.tobin_bed", kid: true, seasons: {summer: {routine: [[8, "rm_village_hesta.tobin_home"], [10, "rm_southbeach.s2"], [16, "rm_village_hesta.tobin_home"], [21, "home"]]}}, routine: [[8, "rm_village_hesta.tobin_home"], [9, "rm_sthereza.s1"], [12, "rm_sthereza.s3"], [16.5, "rm_village_hesta.tobin_home"], [21, "home"]]},
		jul:     {home: "rm_village_hesta.hesta_home", kid: true, routine: [[21, "home"]]},   // the baby: stays home
		aldous:  {home: "rm_home_ward.aldous_bed", rainproof: true, work: {at: "rm_church.aldous_work", open: 8, close: 18, off: 1}, dayoff: [[9, "rm_abda.s2"], [12, "rm_frere.s3"], [16, "rm_church.pew_a"], [19, "home"]]},   // the old church
		alaric:  {home: "rm_home_ward.alaric_bed", work: {at: "rm_guild.alaric_work", open: 9, close: 17, off: 4}, after: [[17, "rm_abda.s3"], [20, "home"]], dayoff: [[8, "rm_beaconhill.mid"], [13, "rm_church.pew_b"], [17, "rm_town_inn.table_c"], [21, "home"]]},   // close-range weapons at the Guild
	};
	return t;
}

/// @description Every villager with a schedule, in a fixed order.
function villager_names(){
	static names = undefined;
	if(names == undefined){
		names = variable_struct_get_names(villager_routines());
		array_sort(names, true);
	}
	return names;
}

/// @description A villager's routine; once married, your spouse comes home to the farmhouse (scripts/marriage).
function villager_routine(_key){
	var r = villager_routines()[$ _key];
	if(r == undefined || !marriage_married() || marriage_spouse() != _key) return r;
	var m = {}, keys = variable_struct_get_names(r);
	for(var i = 0; i < array_length(keys); i++) m[$ keys[i]] = r[$ keys[i]];
	m.home = "rm_12.spouse";
	return m;
}

/// @description The room a villager lives in ("rm_village_store").
function villager_home_room(_key){
	var h = villager_routine(_key).home;
	return world_alias(string_copy(h, 1, string_pos(".", h) - 1));
}

/// @description A place as {room, x, y}: "room.point", "home", or already a struct.
function sched_place(_key, _place){
	if(is_struct(_place)) return _place;
	if(_place == "home") _place = villager_routine(_key).home;
	var dot = string_pos(".", _place);
	var rm = string_copy(_place, 1, dot - 1);
	var p = layout_point(rm, string_delete(_place, 1, dot));
	return {room: world_alias(rm), x: p[0], y: p[1]};
}

/// @description Today's stops for a villager: [[hour, place, "work"?], ...], starting at home.
function villager_stops(_key){
	var r = villager_routine(_key);
	if(festival_today() != undefined){
		// The whole day in the festival crowd in Downtown, six to a row from the crowd point (the festival's people come and stay)
		var k = array_get_index(villager_names(), _key), c = layout_point("rm_downtown", "crowd");
		return [[0, {room: "rm_downtown", x: c[0] + (k mod 6) * 64, y: c[1] + (k div 6) * 80}]];
	}
	// This season's changes to their week, if they have any
	static seasonKeys = ["spring", "summer", "fall", "winter"];
	var seasonal = r[$ "seasons"] ?? {};
	var sr = seasonal[$ seasonKeys[global.clock.season mod 4]];
	if(sr != undefined){
		var merged = {}, keys = variable_struct_get_names(r);
		for(var i = 0; i < array_length(keys); i++) merged[$ keys[i]] = r[$ keys[i]];
		keys = variable_struct_get_names(sr);
		for(var i = 0; i < array_length(keys); i++) merged[$ keys[i]] = sr[$ keys[i]];
		r = merged;
	}
	var stops = [[0, "home"]];
	var work = r[$ "work"];
	if(work == undefined) stops = array_concat(stops, r.routine);
	else if((global.clock.day - 1) mod 7 == work.off) stops = array_concat(stops, r.dayoff);
	else {
		array_push(stops, [work.open - 1, work.at, "work"]);
		var after = r[$ "after"];
		stops = array_concat(stops, (after != undefined) ? after : [[work.close, "home"]]);
	}
	// Winter evenings: nobody lingers outdoors after 5pm (it's dark and freezing)
	var outside = world_outdoors();
	if(global.clock.season mod 4 == 3){
		for(var i = 1; i < array_length(stops); i++){
			var pl = stops[i][1];
			if(stops[i][0] < 17 || is_struct(pl) || pl == "home" || array_length(stops[i]) > 2) continue;
			if(array_get_index(outside, world_alias(string_copy(pl, 1, string_pos(".", pl) - 1))) != -1) stops[i] = [stops[i][0], "home"];
		}
	}
	// Rain: anything outdoors becomes staying in (home), unless they're the kind to go out in it anyway
	if(weather_is_wet() && !(r[$ "rainproof"] ?? false)){
		var outdoors = world_outdoors();
		for(var i = 1; i < array_length(stops); i++){
			var pl = stops[i][1];
			if(is_struct(pl) || pl == "home") continue;
			if(array_get_index(outdoors, world_alias(string_copy(pl, 1, string_pos(".", pl) - 1))) != -1) stops[i] = [stops[i][0], "home"];
		}
	}
	return stops;
}

/// @description Today's plan for a villager (made once a day): where they start, and each walk {t0, t1, route, to,
/// work} in game minutes. A walk that can't start on time (still on the way to the last place) starts on arrival.
function villager_plan(_key){
	if(!variable_global_exists("schedPlans")) global.schedPlans = {};
	var d = day_index(), fest = festival_today() != undefined, wet = weather_is_wet();
	var p = global.schedPlans[$ _key];
	if(p != undefined && p.day == d && p.fest == fest && p.wet == wet) return p;
	var stops = villager_stops(_key);
	var at = sched_place(_key, stops[0][1]);
	var legs = [], free = 0;
	for(var i = 1; i < array_length(stops); i++){
		var to = sched_place(_key, stops[i][1]);
		var route = route_find(at, to), walkTime = route.len / WALK_SPEED;
		var t0 = max(stops[i][0] * 60, free);
		// Work (the stop an hour before opening): set off in time to be there 10 minutes early, however far it is
		if(array_length(stops[i]) > 2) t0 = max(free, min(t0, (stops[i][0] + 1) * 60 - walkTime - 10));
		var t1 = t0 + walkTime;
		array_push(legs, {t0: t0, t1: t1, route: route, to: to, work: array_length(stops[i]) > 2, open: (stops[i][0] + 1) * 60});
		at = to;
		free = t1;
	}
	p = {day: d, fest: fest, wet: wet, start: sched_place(_key, stops[0][1]), legs: legs};
	global.schedPlans[$ _key] = p;
	return p;
}

/// @description Where a villager is now: {room, x, y, moving, work} (work: at their job, ready for customers).
function villager_where(_key){
	var p = villager_plan(_key);
	var t = global.clock.minutes;
	var leg = undefined;
	for(var i = array_length(p.legs) - 1; i >= 0; i--) if(p.legs[i].t0 <= t){ leg = p.legs[i]; break; }
	if(leg == undefined) return {room: p.start.room, x: p.start.x, y: p.start.y, moving: false, work: false};
	if(t >= leg.t1) return {room: leg.to.room, x: leg.to.x, y: leg.to.y, moving: false, work: leg.work};
	// On the way: how far along the route, room by room
	var d = (t - leg.t0) * WALK_SPEED;
	var segs = leg.route.segs, n = array_length(segs);
	for(var s = 0; s < n; s++){
		var g = segs[s];
		if(d > g.len && s < n - 1){ d -= g.len; continue; }
		var pts = g.pts;
		for(var k = 0; k + 3 < array_length(pts); k += 2){
			var sl = point_distance(pts[k], pts[k + 1], pts[k + 2], pts[k + 3]);
			if(d <= sl || k + 4 >= array_length(pts)){
				var f = (sl > 0) ? clamp(d / sl, 0, 1) : 1;
				return {room: g.room, x: lerp(pts[k], pts[k + 2], f), y: lerp(pts[k + 1], pts[k + 3], f), moving: true, work: false};
			}
			d -= sl;
		}
		return {room: g.room, x: pts[0], y: pts[1], moving: true, work: false};
	}
	return {room: leg.to.room, x: leg.to.x, y: leg.to.y, moving: false, work: leg.work};
}

/// @description Is this villager's shop open? Only in hours, and only once they're behind the counter.
function villager_shop_open(_key){
	var work = villager_routine(_key)[$ "work"];
	if(work == undefined) return false;
	var h = global.clock.minutes / 60;
	return h >= work.open && h < work.close && villager_where(_key).work;
}

/// @description "9am", "10:30pm".
function hour_text(_h){
	var hh = floor(_h) mod 24, mm = round(frac(_h) * 60);
	var h12 = hh mod 12; if(h12 == 0) h12 = 12;
	return string(h12) + ((mm > 0) ? ":" + ((mm < 10) ? "0" : "") + string(mm) : "") + ((hh < 12) ? "am" : "pm");
}

/// @description A shop's hours, e.g. "Open 9am - 5pm, closed Thursdays".
function villager_hours_text(_key){
	static days = ["Mondays", "Tuesdays", "Wednesdays", "Thursdays", "Fridays", "Saturdays", "Sundays"];
	var w = villager_routine(_key).work;
	return "Open " + hour_text(w.open) + " - " + hour_text(w.close) + ", closed " + days[w.off];
}

// ---------------------------------------------------------------- routes

/// @description A room's walking grid {w, h, cost} (cost: an array, 0 = blocked), made once from room_walk.
function walk_grid(_room){
	if(!variable_global_exists("walkGrids")) global.walkGrids = {};
	var g = global.walkGrids[$ _room];
	if(g != undefined) return g;
	var r = room_walk()[$ _room];
	var n = r.w * r.h, cost = array_create(n, 0);
	for(var i = 0; i < n; i++) cost[i] = string_byte_at(r.grid, i + 1) - 48;
	g = {w: r.w, h: r.h, cost: cost};
	global.walkGrids[$ _room] = g;
	return g;
}

/// @description Which walkable part of a room a point is in: rooms can be cut in two (the coast by the vale's river),
/// so a door is only a way out from the part it's in. Parts are numbered once per room (a flood over the walk grid).
function walk_region(_room, _x, _y){
	if(!variable_global_exists("walkRegions")) global.walkRegions = {};
	var g = walk_grid(_room), lab = global.walkRegions[$ _room];
	if(lab == undefined){
		var n = g.w * g.h, next = 0;
		lab = array_create(n, -1);
		for(var i = 0; i < n; i++){
			if(g.cost[i] == 0 || lab[i] != -1) continue;
			var st = [i];
			lab[i] = next;
			while(array_length(st) > 0){
				var c = array_pop(st), cx = c mod g.w, cy = c div g.w;
				if(cx > 0 && g.cost[c - 1] > 0 && lab[c - 1] == -1){ lab[c - 1] = next; array_push(st, c - 1); }
				if(cx < g.w - 1 && g.cost[c + 1] > 0 && lab[c + 1] == -1){ lab[c + 1] = next; array_push(st, c + 1); }
				if(cy > 0 && g.cost[c - g.w] > 0 && lab[c - g.w] == -1){ lab[c - g.w] = next; array_push(st, c - g.w); }
				if(cy < g.h - 1 && g.cost[c + g.w] > 0 && lab[c + g.w] == -1){ lab[c + g.w] = next; array_push(st, c + g.w); }
			}
			next++;
		}
		global.walkRegions[$ _room] = lab;
	}
	var cell = walk_cell_near(g, _x, _y);
	return (cell == -1) ? -1 : lab[cell];
}

/// @description The walkable cell nearest a point (doors and spots can sit on a wall's edge), as cell index.
function walk_cell_near(_g, _x, _y){
	var cx = floor(_x / 32), cy = floor(_y / 32);
	var best = -1, bd = infinity;
	for(var r = 0; r <= 3 && best == -1; r++){
		for(var yy = cy - r; yy <= cy + r; yy++) for(var xx = cx - r; xx <= cx + r; xx++){
			if(xx < 0 || yy < 0 || xx >= _g.w || yy >= _g.h || _g.cost[yy * _g.w + xx] == 0) continue;
			var dd = point_distance(_x, _y, xx * 32 + 16, yy * 32 + 16);
			if(dd < bd){ bd = dd; best = yy * _g.w + xx; }
		}
	}
	return best;
}

/// @description A path across one room from a point to a point: {room, pts: [x, y, x, y...], len}. A* over the
/// room's cells (4 ways, so people walk like the player), preferring roads; corners only where it turns.
function path_seg(_room, _x1, _y1, _x2, _y2){
	var g = walk_grid(_room), W = g.w;
	var s = walk_cell_near(g, _x1, _y1), e = walk_cell_near(g, _x2, _y2);
	if(s == -1 || e == -1){
		sched_problem("no path in " + _room + " from " + string(_x1) + "," + string(_y1) + " to " + string(_x2) + "," + string(_y2));
		return {room: _room, pts: [_x1, _y1, _x2, _y2], len: point_distance(_x1, _y1, _x2, _y2)};
	}
	var n = W * g.h, best = array_create(n, infinity), from = array_create(n, -1);
	var open = ds_priority_create();
	best[s] = 0;
	ds_priority_add(open, s, 0);
	var ex = e mod W, ey = e div W;
	static dx = [1, -1, 0, 0], dy = [0, 0, 1, -1];
	while(!ds_priority_empty(open)){
		var c = ds_priority_delete_min(open);
		if(c == e) break;
		var cx = c mod W, cy = c div W;
		for(var k = 0; k < 4; k++){
			var nx = cx + dx[k], ny = cy + dy[k];
			if(nx < 0 || ny < 0 || nx >= W || ny >= g.h) continue;
			var ni = ny * W + nx, cost = g.cost[ni];
			if(cost == 0) continue;
			var nb = best[c] + cost;
			if(nb < best[ni]){
				best[ni] = nb;
				from[ni] = c;
				ds_priority_add(open, ni, nb + abs(nx - ex) + abs(ny - ey));
			}
		}
	}
	ds_priority_destroy(open);
	// Back from the end: cell centres where the way turns
	var cells = [];
	for(var c2 = e; c2 != -1; c2 = from[c2]){ array_insert(cells, 0, c2); if(c2 == s) break; }
	if(cells[0] != s) sched_problem("" + _room + " is cut in two between " + string(_x1) + "," + string(_y1) + " and " + string(_x2) + "," + string(_y2));
	var pts = [_x1, _y1];
	for(var i = 0; i < array_length(cells); i++){
		var keep = (i == 0 || i == array_length(cells) - 1);
		if(!keep){
			var a = cells[i - 1], b = cells[i], z = cells[i + 1];
			keep = (b - a) != (z - b);   // the step changes direction
		}
		if(keep) array_push(pts, (cells[i] mod W) * 32 + 16, (cells[i] div W) * 32 + 16);
	}
	array_push(pts, _x2, _y2);
	var len = 0;
	for(var j = 0; j + 3 < array_length(pts); j += 2) len += point_distance(pts[j], pts[j + 1], pts[j + 2], pts[j + 3]);
	return {room: _room, pts: pts, len: len};
}

/// @description A route that can't be walked (someone would cut across or jump): logged, and kept for the tests
/// (autotest_schedule_check).
function sched_problem(_msg){
	show_debug_message("schedules: " + _msg);
	if(!variable_global_exists("schedProblems")) global.schedProblems = [];
	if(array_get_index(global.schedProblems, _msg) == -1) array_push(global.schedProblems, _msg);
}

/// @description The way from one place to another ({room, x, y}), the shortest walk through the rooms' doors:
/// {segs, len}, one path per room, each ending at the door into the next. Kept once found.
function route_find(_a, _b){
	if(!variable_global_exists("schedRoutes")) global.schedRoutes = {};
	var key = _a.room + ":" + string(_a.x) + "," + string(_a.y) + ">" + _b.room + ":" + string(_b.x) + "," + string(_b.y);
	var r = global.schedRoutes[$ key];
	if(r != undefined) return r;
	var walk = room_walk(), segs = [];
	// Places are (room, the walkable part of it) - a door only leads on from the part it's in
	var startNode = _a.room + "#" + string(walk_region(_a.room, _a.x, _a.y));
	var endNode = _b.room + "#" + string(walk_region(_b.room, _b.x, _b.y));
	if(startNode == endNode) segs = [path_seg(_a.room, _a.x, _a.y, _b.x, _b.y)];
	else {
		// Through the doors, shortest first (distances door to door in a straight line - close enough to choose between
		// ways round, as Brindlemoor to the village by the Crossroads or by North Road): prev[node] = {node, room, door}
		var prev = {}, dist = {}, at = {}, open = [startNode];
		prev[$ startNode] = {node: "", room: "", door: -1};
		dist[$ startNode] = 0;
		at[$ startNode] = [_a.x, _a.y];
		while(array_length(open) > 0){
			var bi = 0;
			for(var o = 1; o < array_length(open); o++) if(dist[$ open[o]] < dist[$ open[bi]]) bi = o;
			var nd = open[bi];
			array_delete(open, bi, 1);
			if(nd == endNode) break;
			var rm = string_copy(nd, 1, string_pos("#", nd) - 1), rg = real(string_delete(nd, 1, string_pos("#", nd)));
			var doors = walk[$ rm].doors, here = at[$ nd];
			for(var i = 0; i < array_length(doors); i++){
				var nr = doors[i][2];
				if(walk[$ nr] == undefined || walk_region(rm, doors[i][0], doors[i][1]) != rg) continue;
				var nn = nr + "#" + string(walk_region(nr, doors[i][3], doors[i][4]));
				var nd2 = dist[$ nd] + point_distance(here[0], here[1], doors[i][0], doors[i][1]);
				if(dist[$ nn] != undefined && dist[$ nn] <= nd2) continue;
				if(dist[$ nn] == undefined) array_push(open, nn);
				dist[$ nn] = nd2;
				at[$ nn] = [doors[i][3], doors[i][4]];
				prev[$ nn] = {node: nd, room: rm, door: i};
			}
		}
		if(prev[$ endNode] == undefined){
			sched_problem("no way from " + _a.room + " to " + _b.room);
			segs = [{room: _b.room, pts: [_b.x, _b.y], len: 0}];
		} else {
			var chain = [], cur = endNode;
			while(cur != startNode){
				var pv = prev[$ cur];
				array_insert(chain, 0, walk[$ pv.room].doors[pv.door]);
				cur = pv.node;
			}
			var cr = _a.room, cx = _a.x, cy = _a.y;
			for(var c = 0; c < array_length(chain); c++){
				var dr = chain[c];
				array_push(segs, path_seg(cr, cx, cy, dr[0], dr[1]));
				cr = dr[2]; cx = dr[3]; cy = dr[4];
			}
			array_push(segs, path_seg(cr, cx, cy, _b.x, _b.y));
		}
	}
	var len = 0;
	for(var s = 0; s < array_length(segs); s++) len += segs[s].len;
	r = {segs: segs, len: len};
	global.schedRoutes[$ key] = r;
	return r;
}

// ---------------------------------------------------------------- in the room you're in

/// @description Every step: anyone who should be in this room and isn't yet comes in (an obj_villager; it leaves
/// by itself when its walk takes it out of the room).
function villagers_update(){
	if(!instance_exists(obj_plyr)) return;
	var here = room_get_name(room), names = villager_names();
	for(var i = 0; i < array_length(names); i++){
		var key = names[i];
		var w = villager_where(key);
		if(w.room != here) continue;
		var found = false;
		with(obj_villager) if(who == key) found = true;
		if(found) continue;
		// On the room's instance layer (the player isn't on one in every room: the farm makes it at runtime)
		if(layer_exists("Instances")) instance_create_layer(w.x, w.y, "Instances", obj_villager, {villagerKey: key});
		else instance_create_depth(w.x, w.y, obj_plyr.depth, obj_villager, {villagerKey: key});
	}
}

/// @description The map's name for a building (by the room inside): "Ida & Fen's House (Baker)", "Brom's Smithy
/// (Blacksmith)". A shop is its keeper's; a home is everyone who lives there, grown-ups first.
function building_label(_room){
	static nouns = {rm_12: "", rm_town_inn: "Inn", rm_town_outfitter: "Outfitters", rm_town_apothecary: "Apothecary",
	                rm_village_smithy: "Smithy", rm_village_store: "General Store", rm_valley_ranch: "Ranch",
	                rm_valley_carpentry: "Carpentry", rm_beach_hut: "Hut"};
	if(_room == "rm_12") return "Your House";
	var names = villager_names(), owners = [], kids = [];
	for(var i = 0; i < array_length(names); i++){
		var r = villager_routine(names[i]), v = villager_def(names[i]);
		var w = r[$ "work"];
		if((v[$ "shop"] ?? "") != "" && w != undefined && string_pos(_room + ".", w.at) == 1) return building_name([names[i]], nouns[$ _room] ?? "House");
	}
	for(var i = 0; i < array_length(names); i++){
		if(villager_home_room(names[i]) != _room) continue;
		array_push((villager_routine(names[i])[$ "kid"] ?? false) ? kids : owners, names[i]);
	}
	return building_name(array_concat(owners, kids), nouns[$ _room] ?? "House");
}

function building_name(_keys, _noun){
	if(array_length(_keys) == 0) return "Empty " + _noun;
	var s = "";
	for(var i = 0; i < array_length(_keys); i++) s += ((i > 0) ? " & " : "") + villager_def(_keys[i]).name;
	var title = villager_def(_keys[0]).title;
	if(string_pos("the ", title) == 1) title = string_delete(title, 1, 4);
	title = string_upper(string_char_at(title, 1)) + string_delete(title, 1, 1);
	return s + "'s " + _noun + ((title != "") ? " (" + title + ")" : "");
}

// ---------------------------------------------------------------- doors

/// @description Can you go into this room now? "" if so, else what the locked door tells you. A home is locked while
/// its people sleep (9pm - 8am); a shop outside its hours and on its day off. Friends (2 hearts with anyone who lives
/// or works there) are welcome any time. Outdoors, and rooms nobody lives or works in (your house, the mine), are never locked.
function door_lock_reason(_rm){
	if(!world_time_ready() || room_is_outdoors(asset_get_index(_rm))) return "";
	var names = villager_names(), keeper = "", people = [];
	for(var i = 0; i < array_length(names); i++){
		var k = names[i], w = villager_routine(k)[$ "work"];
		if(villager_home_room(k) == _rm) array_push(people, k);
		if(w != undefined && string_pos(_rm + ".", w.at) == 1){
			array_push(people, k);
			if((villager_def(k)[$ "shop"] ?? "") != "") keeper = k;
		}
	}
	if(array_length(people) == 0) return "";
	for(var i = 0; i < array_length(people); i++) if(people_hearts(people[i]) >= 2) return "";
	var h = global.clock.minutes / 60;
	if(keeper != ""){
		var w = villager_routine(keeper).work;
		if((global.clock.day - 1) mod 7 != w.off && h >= w.open && h < w.close) return "";
		return "It's locked. " + villager_hours_text(keeper) + ".";
	}
	if(h >= 8 && h < 21) return "";
	return "It's locked. Everyone's asleep - come back after 8am.";
}
