/// The outdoor ground and its seasons: the rooms are built with the LPC Revised summer sheet (TS_lpcr_summer,
/// art/lpc_revised; tools/rooms/build.js lpcrGround); the four seasons' sheets share one layout, so entering a room shows
/// the season by swapping the tileset of every layer that uses one of them (ground, bridges, fences). The summer's
/// leaves and sprouts (layers "scatter_...") lie under the snow in winter. Waterfalls pick their season themselves.

/// @description The LPC Revised sheet for a season (0 spring, 1 summer, 2 fall, 3 winter).
function ground_tileset(_season){
	static sets = [TS_lpcr_spring, TS_lpcr_summer, TS_lpcr_autumn, TS_lpcr_winter];
	return sets[clamp(_season, 0, 3)];
}

/// @description Room Start: this room's LPC Revised layers show the current season.
function ground_season_apply(){
	if(!variable_global_exists("clock") || !is_struct(global.clock)) return;
	var want = ground_tileset(global.clock.season), lays = layer_get_all();
	static sheets = [TS_lpcr_spring, TS_lpcr_summer, TS_lpcr_autumn, TS_lpcr_winter];
	for(var i = 0; i < array_length(lays); i++){
		if(string_pos("scatter", layer_get_name(lays[i])) == 1) layer_set_visible(lays[i], global.clock.season != 3);
		var tm = layer_tilemap_get_id(lays[i]);
		if(tm == -1) continue;
		var cur = tilemap_get_tileset(tm);
		if(cur != want && array_get_index(sheets, cur) != -1) tilemap_tileset(tm, want);
		var roads = [TS_road_spring, TS_road_summer, TS_road_autumn, TS_road_winter], rw = roads[clamp(global.clock.season, 0, 3)];
		if(cur != rw && array_get_index(roads, cur) != -1) tilemap_tileset(tm, rw);   // the dark road's season
	}
}

/// @description Test: which season's ground this room shows ("none" if it has no LPC Revised ground).
function autotest_ground(){
	var lays = layer_get_all();
	for(var i = 0; i < array_length(lays); i++){
		if(layer_get_name(lays[i]) != "Ground") continue;
		var tm = layer_tilemap_get_id(lays[i]);
		if(tm != -1){ var cur = tilemap_get_tileset(tm); for(var s = 0; s < 4; s++) if(cur == ground_tileset(s)) return ["spring", "summer", "fall", "winter"][s]; }
	}
	return "none";
}

/// @description How much bigger to draw words in the world (signs, names, prompts) so they read the same at any zoom:
/// 1 at the close 375-wide view the farm and interiors use, 2 in the town (750), about 1.33 in the other outdoor areas.
function wtx(){ return camera_get_view_width(view_camera[0]) / 375; }
