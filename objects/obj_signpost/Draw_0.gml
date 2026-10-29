/// @description The sign (pointing out of the room to the west or east, a plain board for north and south), and
/// where it leads once you're close
if(side == "w") draw_sprite_part(spr_tile_terrain, 0, 11 * 32, 24 * 32, 32, 32, x - 16, y - 30);
else if(side == "e") draw_sprite_general(spr_tile_terrain, 0, 11 * 32, 24 * 32, 32, 32, x + 16, y - 30, -1, 1, 0, c_white, c_white, c_white, c_white, 1); // mirrored: points east
else draw_sprite_part(spr_tile_terrain, 0, 11 * 32, 25 * 32, 32, 32, x - 16, y - 30);
if(!instance_exists(obj_plyr)) exit;
var d = point_distance(x, y, obj_plyr.x, obj_plyr.y);
if(d > 140) exit;
draw_set_font(fnt_eq);
draw_set_halign(fa_center);
draw_set_valign(fa_bottom);
var a = clamp((140 - d) / 40, 0, 1);
draw_text_transformed_colour(x + 1, y - 33, "To " + text, 0.32, 0.32, 0, c_black, c_black, c_black, c_black, a * 0.7);
draw_text_transformed_colour(x, y - 34, "To " + text, 0.32, 0.32, 0, c_white, c_white, c_white, c_white, a);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
