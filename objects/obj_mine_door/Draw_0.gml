/// @description The lift car (in the mine) and the prompt
if(inMine){
	// A timber frame against the rock, an iron gate and the cable going up into the dark
	var wood = make_colour_rgb(92, 62, 36), dark = make_colour_rgb(34, 28, 26), iron = make_colour_rgb(150, 150, 160);
	draw_set_colour(dark);
	draw_rectangle(x - 14, y - 44, x + 14, y + 4, false);
	draw_set_colour(iron);
	draw_line(x, y - 46, x, y - 76);
	for(var i = -9; i <= 9; i += 6) draw_line(x + i, y - 42, x + i, y + 2);
	draw_set_colour(wood);
	draw_rectangle(x - 17, y - 48, x - 13, y + 6, false);
	draw_rectangle(x + 13, y - 48, x + 17, y + 6, false);
	draw_rectangle(x - 17, y - 50, x + 17, y - 44, false);
	draw_rectangle(x - 17, y + 2, x + 17, y + 6, false);
	draw_set_colour(c_white);
}
if(!near || menuOpen) exit;
draw_set_font(fnt_eq);
draw_set_halign(fa_center);
draw_set_valign(fa_bottom);
var t = inMine ? "[E] Lift" : ((mine_lift_top() > 1) ? "[E] Take the lift" : "[E] Enter the mine");
draw_text_transformed_colour(x, y - (inMine ? 54 : 18), t, 0.3, 0.3, 0, c_yellow, c_yellow, c_yellow, c_yellow, 1);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
