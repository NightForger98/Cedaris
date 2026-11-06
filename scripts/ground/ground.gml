/// The PixelLab ground (tools/map/ground_atlas.js, tools/rooms/build.js groundLayer): the outdoor rooms are built with
/// the summer ground tileset; the four seasons' tilesets are laid out the same, so entering a room shows the season
/// by swapping its ground layers' tileset.

/// @description The ground tileset for a season (0 spring, 1 summer, 2 fall, 3 winter).
function ground_tileset(_season){
	static sets = [TS_ground_spring, TS_ground_summer, TS_ground_autumn, TS_ground_winter];
	return sets[clamp(_season, 0, 3)];
}

/// @description Room Start: every ground layer in this room shows the current season.
function ground_season_apply(){
	if(!variable_global_exists("clock") || !is_struct(global.clock)) return;
	var want = ground_tileset(global.clock.season), lays = layer_get_all();
	for(var i = 0; i < array_length(lays); i++){
		var tm = layer_tilemap_get_id(lays[i]);
		if(tm == -1) continue;
		var cur = tilemap_get_tileset(tm);
		if(cur != want && (cur == TS_ground_spring || cur == TS_ground_summer || cur == TS_ground_autumn || cur == TS_ground_winter)) tilemap_tileset(tm, want);
	}
}

/// @description Test: which ground tileset this room shows ("none" if it has no PixelLab ground).
function autotest_ground(){
	var lays = layer_get_all();
	for(var i = 0; i < array_length(lays); i++){
		var tm = layer_tilemap_get_id(lays[i]);
		if(tm != -1){ var cur = tilemap_get_tileset(tm); for(var s = 0; s < 4; s++) if(cur == ground_tileset(s)) return ["spring", "summer", "fall", "winter"][s]; }
	}
	return "none";
}
