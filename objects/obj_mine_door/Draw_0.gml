/// @description The lift car (in the mine) and the prompt
if(inMine){
	// The lift cage (spr_mine_lift: LPC Base Assets' timber, gate and planks) with its cable going up into the dark
	draw_set_colour(make_colour_rgb(150, 150, 160));
	draw_line(x, y - 58, x, y - 90);
	draw_set_colour(c_white);
	draw_sprite(spr_mine_lift, 0, x - 24, y - 58);
}
if(!near || menuOpen) exit;
draw_set_font(fnt_eq);
draw_set_halign(fa_center);
draw_set_valign(fa_bottom);
var t = inMine ? key_label("interact") + " Lift" : ((mine_lift_top() > 1) ? key_label("interact") + " Take the lift" : key_label("interact") + " Enter the mine");
draw_text_transformed_colour(x, y - (inMine ? 62 : 18), t, 0.3 * wtx(), 0.3 * wtx(), 0, c_yellow, c_yellow, c_yellow, c_yellow, 1);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
