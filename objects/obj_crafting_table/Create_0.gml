/// @description Crafting table: blocks movement like other obstacles, press E nearby to craft
// Placeholder art: the workbench from spr_tile_interior (64x64 at 704,192) until there's a proper asset.
// Collision footprint along the table's legs: spr_collision_check is 16x16 centred, so scale it to 56x16.
// Set before event_inherited(), because obj_col_box reads the mask's offset.
mask_index = spr_collision_check;
image_xscale = 3.5;
image_yscale = 1;
event_inherited();
artX = 704;
artY = 192;
near = false;
sorted = false; // depth is set on the first step, once the player exists
