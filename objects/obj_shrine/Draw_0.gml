/// @description The stone pedestal from the terrain tileset; lit once the shrine project is done; the prompt
var lit = project_done("shrine");
if(lit){
	draw_set_alpha(0.25 + sin(current_time / 400) * 0.08);
	draw_set_colour(make_colour_rgb(255, 200, 250));
	draw_circle(x, y - 30, 30, false);
	draw_set_alpha(1);
}
draw_sprite_part_ext(spr_tile_terrain, 0, 544, 392, 34, 64, x - 17, y - 60, 1, 1, lit ? c_white : make_colour_rgb(150, 150, 160), 1);
if(lit){
	draw_set_colour(make_colour_rgb(255, 230, 255));
	draw_circle(x, y - 46, 3 + sin(current_time / 200), false);
}
if(near){
	draw_set_font(fnt_eq);
	draw_set_halign(fa_center);
	draw_set_valign(fa_bottom);
	draw_text_transformed_colour(x, y - 64, "[E] The old shrine", 0.3, 0.3, 0, c_yellow, c_yellow, c_yellow, c_yellow, 1);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
}
draw_set_colour(c_white);
