/// @description Insert description here
// You can write your code in this editor

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
	if(held != undefined) ui_text(hx, hy + hs + 16, item_def(held.id).name, 0.5, c_white, fa_left);
	ui_text(hx + INV_HOTBAR * (hs + hg) + 8, hy + hs / 2, global.inv.mode == "free" ? "I: inventory" : "Gold " + string(global.inv.gold) + "   I: inventory", 0.5, c.accent, fa_left);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
}
