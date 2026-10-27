/// @description Draw Mara, her name, and a prompt when the player is close
event_inherited();
draw_set_font(fnt_eq);
draw_set_halign(fa_center);
draw_set_valign(fa_bottom);
var top = y - y_offset + 10;
draw_text_transformed_colour(x, top, npcName + " the Seed Seller", 0.3, 0.3, 0, c_white, c_white, c_white, c_white, 1);
if(near) draw_text_transformed_colour(x, top - 12, "[E] Buy seeds", 0.3, 0.3, 0, c_yellow, c_yellow, c_yellow, c_yellow, 1);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
