/// @description Draw the bin and the prompt
// spr_shipping_chest: a banded chest from [LPC] Containers by bluecarrot16 and others
draw_sprite(spr_shipping_chest, 0, x - 25, y - 38);
if(near){
	draw_set_font(fnt_eq);
	draw_set_halign(fa_center);
	draw_set_valign(fa_bottom);
	draw_text_transformed_colour(x, y - 40, "[E] Ship", 0.3, 0.3, 0, c_yellow, c_yellow, c_yellow, c_yellow, 1);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
}
