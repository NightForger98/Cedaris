/// @description A hole with a ladder's top (down), or a ladder against the wall above (up); and the prompt
if(down){
	draw_set_colour(make_colour_rgb(70, 45, 30));
	draw_ellipse(x - 15, y - 11, x + 15, y + 11, false);
	draw_set_colour(make_colour_rgb(12, 8, 8));
	draw_ellipse(x - 12, y - 8, x + 12, y + 8, false);
	draw_sprite_part(spr_tile_terrain, 0, 9 * 32 + 6, 5 * 32, 20, 18, x - 10, y - 12);
	draw_set_colour(c_white);
} else {
	draw_sprite_part(spr_tile_terrain, 0, 9 * 32, 5 * 32, 32, 64, x - 16, y - 52);
}
if(near){
	draw_set_font(fnt_eq);
	draw_set_halign(fa_center);
	draw_set_valign(fa_bottom);
	var t = down ? key_label("interact") + " Climb down" : key_label("interact") + " Climb out";
	draw_text_transformed_colour(x, y - (down ? 16 : 56), t, 0.3 * wtx(), 0.3 * wtx(), 0, c_yellow, c_yellow, c_yellow, c_yellow, 1);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
}
