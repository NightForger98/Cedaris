/// @description The sign: pointing out of the room to the west or east, a plain board for north and south (its words: Draw End)
if(side == "w") draw_sprite_part(spr_tile_terrain, 0, 11 * 32, 24 * 32, 32, 32, x - 16, y - 30);
else if(side == "e") draw_sprite_general(spr_tile_terrain, 0, 11 * 32, 24 * 32, 32, 32, x + 16, y - 30, -1, 1, 0, c_white, c_white, c_white, c_white, 1); // mirrored: points east
else draw_sprite_part(spr_tile_terrain, 0, 11 * 32, 25 * 32, 32, 32, x - 16, y - 30);
