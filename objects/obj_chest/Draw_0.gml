/// @description The chest (the one from spr_tile_interior, like the shipping bin) with a glint, and the prompt
draw_sprite_part(spr_tile_interior, 0, 608, 606, 64, 36, x - 32, y - 26);
if((current_time div 400) mod 4 == 0){
	draw_set_colour(c_white);
	draw_circle(x + 18, y - 22, 2, false);
}
if(near){
	draw_set_font(fnt_eq);
	draw_set_halign(fa_center);
	draw_set_valign(fa_bottom);
	draw_text_transformed_colour(x, y - 28, "[E] Open", 0.3, 0.3, 0, c_yellow, c_yellow, c_yellow, c_yellow, 1);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
}
