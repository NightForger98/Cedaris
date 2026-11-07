/// @description The building, standing on y
if(ambient_building_draw(id)) exit;   // a windmill's sails, a campfire's flames (scripts/ambient)
draw_sprite(sprite_index, 0, x, y - sprite_get_height(sprite_index));
