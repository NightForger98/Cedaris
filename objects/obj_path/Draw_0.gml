/// @description The bridge (broken or mended) or a signpost back; and the prompt
if(target == "forest"){
	// The wooden bridge from the terrain tileset, running off east; broken, only its first planks remain
	var mended = project_done("bridge");
	draw_sprite_part_ext(spr_tile_terrain, 0, 13 * 32, 16 * 32, mended ? 96 : 40, 48, x - 8, y - 30, 0.8, 0.8, mended ? c_white : make_colour_rgb(150, 130, 120), 1);
} else {
	// A post with a sign pointing home
	draw_set_colour(make_colour_rgb(90, 60, 35));
	draw_rectangle(x - 2, y - 30, x + 2, y + 4, false);
	draw_set_colour(make_colour_rgb(160, 120, 70));
	draw_triangle(x - 16, y - 26, x - 8, y - 32, x - 8, y - 20, false);
	draw_rectangle(x - 8, y - 32, x + 14, y - 20, false);
}
if(near){
	draw_set_font(fnt_eq);
	draw_set_halign(fa_center);
	draw_set_valign(fa_bottom);
	var t = (target == "village") ? "[E] Back to the village" : (project_done("bridge") ? "[E] To Whisperwood" : "[E] The bridge is out");
	draw_text_transformed_colour(x, y - 36, t, 0.3, 0.3, 0, c_yellow, c_yellow, c_yellow, c_yellow, 1);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
}
draw_set_colour(c_white);
