/// @description Night tint, fades and the HUD (clock, energy, health, hotbar)
// Night falls over outdoor rooms (drawn first, so the HUD stays bright)
if(game_is_playing_room() && world_time_ready() && room_is_outdoors()){
	var night = night_amount();
	if(night > 0){
		draw_set_alpha(night);
		draw_rectangle_colour(0, 0, guiWidth, guiHeight, $401008, $401008, $401008, $401008, false);
		draw_set_alpha(1);
	}
}

// Pixies glow through the dark (their light is drawn again over the night tint)
with(obj_monster){
	if((def[$ "look"] ?? "") != "pixie" || dying) continue;
	var cam = view_camera[0];
	var gx = (x - camera_get_view_x(cam)) * other.guiWidth / camera_get_view_width(cam);
	var gy = (y - 26 - camera_get_view_y(cam)) * other.guiHeight / camera_get_view_height(cam);
	gpu_set_blendmode(bm_add);
	draw_set_alpha(0.3 * night_amount() + 0.1);
	draw_circle_colour(gx, gy, 26, make_colour_rgb(255, 150, 230), c_black, false);
	draw_set_alpha(1);
	gpu_set_blendmode(bm_normal);
}

// Rain, storms and snow over outdoor rooms
if(game_is_playing_room() && world_time_ready()) weather_draw(guiWidth, guiHeight);

// The mine is dark away from you: a dark layer with a soft circle of light cut out around the player
var dark = mine_darkness();
if(dark > 0 && instance_exists(obj_plyr)){
	if(!surface_exists(lightSurf)) lightSurf = surface_create(guiWidth, guiHeight);
	var cam = view_camera[0];
	var lx = (obj_plyr.x - camera_get_view_x(cam)) * guiWidth / camera_get_view_width(cam);
	var ly = (obj_plyr.y - 24 - camera_get_view_y(cam)) * guiHeight / camera_get_view_height(cam);
	var r = guiWidth * (spell_light_on() ? 0.5 : 0.3);
	surface_set_target(lightSurf);
	draw_clear_alpha(c_black, dark);
	gpu_set_blendmode(bm_subtract);
	draw_primitive_begin(pr_trianglefan);
	draw_vertex_colour(lx, ly, c_black, dark);
	for(var a = 0; a <= 360; a += 15) draw_vertex_colour(lx + lengthdir_x(r, a), ly + lengthdir_y(r, a), c_black, 0);
	draw_primitive_end();
	gpu_set_blendmode(bm_normal);
	surface_reset_target();
	draw_surface(lightSurf, 0, 0);
}

if(doTransition){
	//handle transition
	// restartRoom: going to the room you're in (the next mine floor) rebuilds it
	if(room != spawnRoom || restartRoom){
		blackAlpha += 0.1;
		if(blackAlpha >= 1){
			if(restartRoom){ restartRoom = false; room_restart(); }
			else room_goto(spawnRoom)}
			}else{blackAlpha -= 0.1;
				if(blackAlpha <= 0)
			doTransition=false;
			}
	
	
	
	//draw black fade
draw_set_alpha(blackAlpha);
draw_rectangle_colour(0,0,guiWidth,guiHeight,c_black,c_black,c_black,c_black,false);
draw_set_alpha(1);
}











// Frame rate (Options > Show FPS)
if(global.settings.showFps){
	draw_set_font(fnt_eq);
	draw_text_transformed_colour(8, 8, string(fps) + " fps", 0.6, 0.6, 0, c_yellow, c_yellow, c_yellow, c_yellow, 1);
}

// Hotbar (the inventory screen draws its own)
if(game_is_playing_room() && variable_global_exists("inv") && is_struct(global.inv)
   && !instance_exists(obj_inventory) && !instance_exists(obj_menu)){
	var c = ui_colours();
	var hs = 44, hg = 5, hx = 16, hy = 14;
	draw_set_font(fnt_eq);
	for(var i = 0; i < INV_HOTBAR; i++){
		var x1 = hx + i * (hs + hg);
		draw_set_alpha(0.8);
		draw_set_colour(c.panel);
		draw_roundrect_ext(x1, hy, x1 + hs, hy + hs, 8, 8, false);
		draw_set_alpha(1);
		if(i == global.inv.hotbar){ draw_set_colour(c.accent); draw_roundrect_ext(x1, hy, x1 + hs, hy + hs, 8, 8, true); }
		var st = global.inv.slots[i];
		if(st != undefined) item_draw_icon(st, x1, hy, hs, global.look.body);
		ui_text(x1 + 5, hy + 8, string((i + 1) mod 10), 0.35, c.dim, fa_left);
	}
	var held = inv_held_stack();
	if(held != undefined){
		var hd = item_def(held.id);
		var label = (hd.type == "held") ? tool_display_name(hd.name) : hd.name;
		if(held.id == "c|held|Watering Can") label += "  -  water " + string(global.inv[$ "water"] ?? 40) + "/" + string(tool_water_max());
		// A staff shows the spell it will cast
		if(hd.type == "held" && staff_power(hd.name) >= 0){
			var sk = spell_selected();
			label += (sk == "") ? "  -  no spells yet" : "  -  " + spell_def(sk).name + " (" + string(spell_def(sk).mana) + " mana)   F cast, Q change";
		}
		ui_text(hx, hy + hs + 16, label, 0.5, c_white, fa_left);
	}
	ui_text(hx + INV_HOTBAR * (hs + hg) + 8, hy + hs / 2, global.inv.mode == "free" ? "I: inventory" : "Gold " + string(global.inv.gold) + "   I: inventory", 0.5, c.accent, fa_left);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
}

// Sleeping / knocked out / waking fade
if(sleeping || dying || waking){
	draw_set_alpha(blackAlpha);
	draw_rectangle_colour(0, 0, guiWidth, guiHeight, c_black, c_black, c_black, c_black, false);
	draw_set_alpha(1);
}

// Clock and energy/health bars while playing
if(game_is_playing_room() && world_time_ready() && !instance_exists(obj_menu) && !sleeping && !dying){
	var c = ui_colours();
	draw_set_font(fnt_eq);
	// Clock box, top right
	var bx = guiWidth - 230, by = 14;
	draw_set_alpha(0.85);
	draw_set_colour(c.panel);
	draw_roundrect_ext(bx, by, guiWidth - 14, by + 78, 10, 10, false);
	draw_set_alpha(1);
	ui_text(bx + 14, by + 20, weekday_name(global.clock.day) + " " + string(global.clock.day) + "  " + season_name(global.clock.season) + "  Y" + string(global.clock.year), 0.55, c.accent, fa_left);
	ui_text(bx + 14, by + 54, clock_text(), 0.8, c_white, fa_left);
	weather_icon(guiWidth - 44, by + 52, weather_now());
	// In the mine: which floor and band, top centre
	if(room == rm_mine) ui_text(guiWidth / 2, 30, "Mine floor " + string(mine_state().floor) + "  -  " + mine_band(mine_state().floor).name, 0.6, c.accent);

	// Food buff under the clock: what it gives and how long it has left
	var buff = food_buff();
	if(buff != undefined){
		var left = max(0, buff.until - global.clock.minutes);
		draw_set_alpha(0.85);
		draw_set_colour(c.panel);
		draw_roundrect_ext(bx, by + 84, guiWidth - 14, by + 140, 10, 10, false);
		draw_set_alpha(1);
		ui_text(bx + 14, by + 101, dish_def(buff.dish).name, 0.48, make_colour_rgb(130, 200, 255), fa_left);
		ui_text(bx + 14, by + 124, item_stats_text(buff.stats) + "   " + string(left div 60) + "h " + string(floor(left) mod 60) + "m", 0.42, c_white, fa_left);
	}

	// Energy and health, bottom right (vertical bars like Stardew)
	var bars = [["E", global.vitals.energy / vitals_max_energy(), make_colour_rgb(110, 200, 90)],
	            ["H", global.vitals.health / vitals_max_health(), make_colour_rgb(220, 70, 60)]];
	// Mana, once you know a spell
	if(array_length(spells_known()) > 0) array_insert(bars, 0, ["M", mana() / mana_max(), make_colour_rgb(90, 140, 255)]);
	var nb = array_length(bars);
	for(var i = 0; i < nb; i++){
		var x1 = guiWidth - 86 - (nb - 2) * 38 + i * 38, y1 = guiHeight - 250, x2 = x1 + 28, y2 = guiHeight - 30;
		draw_set_alpha(0.85);
		draw_set_colour(c.panel);
		draw_roundrect_ext(x1 - 4, y1 - 4, x2 + 4, y2 + 4, 8, 8, false);
		draw_set_alpha(1);
		var f = clamp(bars[i][1], 0, 1);
		draw_set_colour(bars[i][2]);
		if(f > 0) draw_rectangle(x1, y2 - (y2 - y1) * f, x2, y2, false);
		ui_text((x1 + x2) / 2, y1 - 18, bars[i][0], 0.6, c_white);
	}
	if(vitals_exhausted()) ui_text(guiWidth - 64, guiHeight - 270, "Exhausted", 0.5, make_colour_rgb(230, 110, 90), fa_right);
	// Too cold for what you're wearing: energy drains (warmer clothes or a warming dish fix it)
	else if(climate_chill() > 0){
		var hot = climate_cold() < 0;
		ui_text(guiWidth - 100 - (nb - 2) * 38, guiHeight - 262, (hot ? "Hot - Warmth " + string(stat("warmth")) + " is too much" : "Cold " + string(climate_cold()) + "  Warmth " + string(stat("warmth"))),
		        0.5, hot ? make_colour_rgb(255, 150, 90) : make_colour_rgb(150, 200, 255), fa_right);
	}

	// Message line (day start, saves, warnings)
	if(hudTime > 0) ui_text(guiWidth / 2, 110, hudMessage, 0.7, c_white);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
}

// Debug (Insert): room, player position and controls, for placing things in rooms
if(debug && instance_exists(obj_plyr)){
	draw_set_font(fnt_eq);
	ui_text(16, guiHeight - 40, room_get_name(room) + "   player " + string(round(obj_plyr.x)) + ", " + string(round(obj_plyr.y))
	        + "   [PgUp/PgDn] rooms  [T] +1 hour  [G] grow crops", 0.5, c_yellow, fa_left);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
}
