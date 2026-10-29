/// @description The prompt by the board
if(!near || open) exit;
draw_set_font(fnt_eq);
draw_set_halign(fa_center);
draw_set_valign(fa_bottom);
draw_text_transformed_colour(x, y - 40, key_label("interact") + " Notice board", 0.3, 0.3, 0, c_yellow, c_yellow, c_yellow, c_yellow, 1);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
