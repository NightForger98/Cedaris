/// @description Bed: blocks movement; press E nearby to sleep and end the day
// Placeholder art: the double bed from spr_tile_interior (64x84 at 672,12) until there's a proper asset.
// Collision covers the bed (spr_collision_check is 16x16 centred). Set before event_inherited(): obj_col_box reads the mask.
mask_index = spr_collision_check;
image_xscale = 3.75;
image_yscale = 4.25;
event_inherited();
near = false;
art = true; // false where the room's tiles already show a bed (set in the room)
sorted = false;
