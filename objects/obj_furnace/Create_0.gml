/// @description Brom's furnace: press E nearby to smelt ore into bars
// Placeholder art: the iron stove and its pipe from spr_tile_interior until there's a proper asset.
// Collision footprint at the stove's base (spr_collision_check is 16x16 centred). Set before event_inherited().
mask_index = spr_collision_check;
image_xscale = 2;
image_yscale = 1;
event_inherited();
near = false;
sorted = false;
