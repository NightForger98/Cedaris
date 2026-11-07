/// @description Draw the workbench (its legs sit on the collision footprint) and the prompt
// spr_workbench: [LPC] Woodshop by bluecarrot16
draw_sprite(spr_workbench, 0, x - 38, y - 46);
if(near){
	draw_set_font(fnt_eq);
	draw_set_halign(fa_center);
	draw_set_valign(fa_bottom);
	draw_text_transformed_colour(x, y - 48, key_label("interact") + " Craft", 0.3 * wtx(), 0.3 * wtx(), 0, c_yellow, c_yellow, c_yellow, c_yellow, 1);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
}
