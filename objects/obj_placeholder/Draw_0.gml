/// @description A see-through box with a dashed-looking outline and its name: art still to come
var x1 = x, y1 = y - boxH, x2 = x + boxW - 1, y2 = y - 1;
draw_set_alpha(0.45);
draw_rectangle_colour(x1, y1, x2, y2, c_purple, c_purple, c_purple, c_purple, false);
draw_set_alpha(1);
draw_rectangle_colour(x1, y1, x2, y2, c_yellow, c_yellow, c_yellow, c_yellow, true);
draw_rectangle_colour(x1 + 1, y1 + 1, x2 - 1, y2 - 1, c_yellow, c_yellow, c_yellow, c_yellow, true);
draw_set_font(fnt_eq);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_text_transformed_colour((x1 + x2) / 2, (y1 + y2) / 2 - 6, label, 0.3, 0.3, 0, c_white, c_white, c_white, c_white, 1);
draw_text_transformed_colour((x1 + x2) / 2, (y1 + y2) / 2 + 8, "(placeholder)", 0.22, 0.22, 0, c_yellow, c_yellow, c_yellow, c_yellow, 1);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
