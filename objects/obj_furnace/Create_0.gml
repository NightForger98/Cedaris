/// @description Brom's furnace: press E nearby to smelt ore into bars
// Art: the forge from [LPC] Blacksmith (spr_forge).
// Collision footprint at the stove's base (spr_collision_check is 16x16 centred). Set before event_inherited().
mask_index = spr_collision_check;
image_xscale = 3.5;
image_yscale = 1;
event_inherited();
near = false;
sorted = false;
