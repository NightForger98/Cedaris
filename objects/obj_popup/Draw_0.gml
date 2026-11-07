/// @description The text, fading out at the end
draw_set_font(fnt_eq);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_text_transformed_colour(x, y, text, 0.32 * wtx(), 0.32 * wtx(), 0, colour, colour, colour, colour, min(1, life / 15));
draw_set_halign(fa_left);
draw_set_valign(fa_top);
