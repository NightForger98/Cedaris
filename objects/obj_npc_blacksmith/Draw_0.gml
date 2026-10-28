/// @description Draw Brom (hammering or standing), his name, and a prompt when the player is close
if(act != undefined) character_draw(look, 0, 0, round(x - x_offset), round(y - y_offset), 1, {act: act, i: floor(actStep), dir: 2});
else event_inherited();
draw_set_font(fnt_eq);
draw_set_halign(fa_center);
draw_set_valign(fa_bottom);
var top = y - y_offset + 10;
draw_text_transformed_colour(x, top, npcName + " the Blacksmith", 0.3, 0.3, 0, c_white, c_white, c_white, c_white, 1);
if(near) draw_text_transformed_colour(x, top - 12, "[E] Talk", 0.3, 0.3, 0, c_yellow, c_yellow, c_yellow, c_yellow, 1);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
