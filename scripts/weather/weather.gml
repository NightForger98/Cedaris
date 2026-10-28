/// Weather (milestone 10.1, docs/MILESTONES.md): sun, rain, summer storms and winter snow.
///
/// global.clock.weather is today's, global.clock.tomorrow is already decided (Aunt Hesta can tell you). Rain and
/// storms water every tilled tile in the valley; rain, storms and snow make it a point colder outdoors.
/// Drawn over outdoor rooms in the game object's Draw GUI (weather_draw); an icon sits by the clock.

/// @description Roll a day's weather for a season (0 spring .. 3 winter).
function weather_roll(_season){
	var r = random(1);
	switch(_season mod 4){
		case 0: return (r < 0.25) ? "rain" : "sun";
		case 1: return (r < 0.06) ? "storm" : ((r < 0.16) ? "rain" : "sun");
		case 2: return (r < 0.28) ? "rain" : "sun";
		case 3: return (r < 0.4) ? "snow" : "sun";
	}
	return "sun";
}

function weather_now(){ return world_time_ready() ? (global.clock[$ "weather"] ?? "sun") : "sun"; }

function weather_tomorrow(){
	if(!world_time_ready()) return "sun";
	if(!variable_struct_exists(global.clock, "tomorrow")) global.clock.tomorrow = weather_roll(global.clock.season);
	return global.clock.tomorrow;
}

function weather_name(_w){
	switch(_w){
		case "rain":  return "Rain";
		case "storm": return "Storm";
		case "snow":  return "Snow";
	}
	return "Sunny";
}

function weather_is_wet(){ var w = weather_now(); return w == "rain" || w == "storm"; }

/// @description New-day part (after the soil dries): today becomes yesterday's forecast, a new forecast is rolled
/// (for the day after, which may be a new season), and rain waters every tilled tile.
function weather_new_day(){
	var ck = global.clock;
	ck.weather = weather_tomorrow();
	// The first day of a season takes its own weather: no snow in spring because the forecast was made in winter
	if(ck.day == 1) ck.weather = weather_roll(ck.season);
	var nextSeason = (ck.day >= SEASON_DAYS) ? ck.season + 1 : ck.season;
	ck.tomorrow = weather_roll(nextSeason);
	if(weather_is_wet()) weather_water_all();
}

/// @description Rain: every tilled tile in every room is watered.
function weather_water_all(){
	var names = variable_struct_get_names(global.world.rooms);
	for(var i = 0; i < array_length(names); i++){
		var tiles = global.world.rooms[$ names[i]][$ "tiles"] ?? {};
		var keys = variable_struct_get_names(tiles);
		for(var k = 0; k < array_length(keys); k++) tiles[$ keys[k]].watered = true;
	}
}

/// @description Extra cold outdoors from the weather.
function weather_cold(){ return (weather_now() == "sun") ? 0 : 1; }

/// @description Aunt Hesta's way of saying tomorrow's weather.
function weather_forecast_line(){
	switch(weather_tomorrow()){
		case "rain":  return "My knee says rain tomorrow. You can leave the watering can be.";
		case "storm": return "Storm coming tomorrow, I can smell it. Stay in if you've any sense.";
		case "snow":  return "Snow tomorrow. Wrap up warm, dear.";
	}
	return "Clear skies tomorrow, by the look of the sunset.";
}

// ---------------------------------------------------------------- drawing

/// @description Rain, storm or snow over an outdoor room (GUI space). The drops are placed from the time, so no
/// particles need keeping; a storm flashes now and then.
function weather_draw(_w, _h){
	var w = weather_now();
	if(w == "sun" || !room_is_outdoors()) return;
	var t = current_time;
	if(w == "snow"){
		draw_set_colour(c_white);
		for(var i = 0; i < 140; i++){
			var sx = (i * 137 + t * 0.03 + sin(t / 900 + i) * 20) mod _w;
			var sy = (i * 71 + t * (0.05 + (i mod 5) * 0.01)) mod _h;
			draw_set_alpha(0.5 + (i mod 3) * 0.15);
			draw_circle(sx, sy, 1.5 + (i mod 3), false);
		}
		draw_set_alpha(1);
		return;
	}
	var storm = (w == "storm");
	draw_set_alpha(storm ? 0.25 : 0.15);
	draw_rectangle_colour(0, 0, _w, _h, $503020, $503020, $503020, $503020, false);
	draw_set_colour(make_colour_rgb(170, 190, 230));
	draw_set_alpha(0.55);
	var n = storm ? 260 : 160;
	for(var i = 0; i < n; i++){
		var rx = (i * 211 + t * 0.35) mod (_w + 60) - 30;
		var ry = (i * 89 + t * (1.1 + (i mod 4) * 0.12)) mod (_h + 40) - 20;
		draw_line_width(rx, ry, rx - 6, ry + 18, 1.5);
	}
	draw_set_alpha(1);
	// Lightning: a brief white flash every so often
	if(storm && (t div 120) mod 70 == 0){
		draw_set_alpha(0.5);
		draw_rectangle_colour(0, 0, _w, _h, c_white, c_white, c_white, c_white, false);
		draw_set_alpha(1);
	}
	draw_set_colour(c_white);
}

/// @description The weather icon (for the clock box), centred at (_x, _y).
function weather_icon(_x, _y, _w){
	switch(_w){
		case "sun":
			draw_set_colour(make_colour_rgb(250, 210, 80));
			for(var a = 0; a < 360; a += 45) draw_line_width(_x + lengthdir_x(8, a), _y + lengthdir_y(8, a), _x + lengthdir_x(12, a), _y + lengthdir_y(12, a), 2);
			draw_circle(_x, _y, 6, false);
			break;
		case "rain":
		case "storm":
			draw_set_colour(make_colour_rgb(200, 205, 215));
			draw_circle(_x - 5, _y - 2, 6, false);
			draw_circle(_x + 4, _y - 4, 7, false);
			draw_rectangle(_x - 10, _y - 1, _x + 10, _y + 4, false);
			draw_set_colour((_w == "storm") ? make_colour_rgb(250, 220, 80) : make_colour_rgb(110, 160, 255));
			for(var i = -1; i <= 1; i++) draw_line_width(_x + i * 6, _y + 7, _x + i * 6 - 2, _y + 13, 2);
			break;
		case "snow":
			draw_set_colour(c_white);
			for(var a = 0; a < 180; a += 60) draw_line_width(_x + lengthdir_x(9, a), _y + lengthdir_y(9, a), _x - lengthdir_x(9, a), _y - lengthdir_y(9, a), 2);
			break;
	}
	draw_set_colour(c_white);
}
