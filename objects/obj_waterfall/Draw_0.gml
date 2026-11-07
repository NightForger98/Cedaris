/// @description This season's falling water, four frames
var s = (variable_global_exists("clock") && is_struct(global.clock)) ? clamp(global.clock.season, 0, 3) : 1;
var f = (current_time div 140) mod 4;
draw_sprite_part(spr, 0, (s * 4 + f) * fw, 0, fw, fh, x, y);
