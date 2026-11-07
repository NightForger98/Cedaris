/// @description The piece (mirrored if flipped)
if(sprite_index == -1) exit;
if(data[$ "flip"] ?? false) draw_sprite_ext(sprite_index, 0, drawX + sprite_get_width(sprite_index), drawY, -1, 1, 0, c_white, 1);
else draw_sprite(sprite_index, 0, drawX, drawY);
