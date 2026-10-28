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

if(doTransition){
	//handle transition
	if(room != spawnRoom){
		blackAlpha += 0.1;
		if(blackAlpha >= 1){
			room_goto(spawnRoom)}
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
		ui_text(hx, hy + hs + 16, label, 0.5, c_white, fa_left);
	}
	ui_text(hx + INV_HOTBAR * (hs + hg) + 8, hy + hs / 2, global.inv.mode == "free" ? "I: inventory" : "Gold " + string(global.inv.gold) + "   I: inventory", 0.5, c.accent, fa_left);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
}

// Sleeping / waking fade
if(sleeping || waking){
	draw_set_alpha(blackAlpha);
	draw_rectangle_colour(0, 0, guiWidth, guiHeight, c_black, c_black, c_black, c_black, false);
	draw_set_alpha(1);
}

// Clock and energy/health bars while playing
if(game_is_playing_room() && world_time_ready() && !instance_exists(obj_menu) && !sleeping){
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

	// Energy and health, bottom right (vertical bars like Stardew)
	var bars = [["E", global.vitals.energy / vitals_max_energy(), make_colour_rgb(110, 200, 90)],
	            ["H", global.vitals.health / vitals_max_health(), make_colour_rgb(220, 70, 60)]];
	for(var i = 0; i < 2; i++){
		var x1 = guiWidth - 86 + i * 38, y1 = guiHeight - 250, x2 = x1 + 28, y2 = guiHeight - 30;
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
