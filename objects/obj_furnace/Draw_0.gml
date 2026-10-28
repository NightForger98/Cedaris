/// @description Draw the stove (the lit firebox under the pipe) and the prompt
draw_sprite_part(spr_tile_interior, 0, 798, 160, 34, 96, x - 17, y - 120);
draw_sprite_part(spr_tile_interior, 0, 832, 256, 32, 30, x - 16, y - 26);
if(near){
	draw_set_font(fnt_eq);
	draw_set_halign(fa_center);
	draw_set_valign(fa_bottom);
	draw_text_transformed_colour(x, y - 122, "[E] Smelt", 0.3, 0.3, 0, c_yellow, c_yellow, c_yellow, c_yellow, 1);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
}
