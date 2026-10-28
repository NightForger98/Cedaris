/// @description Something placed in the world (see the placeables script). Set on creation: data ({kind, gx, gy}, the
/// stored struct). Blocks like other obstacles: spr_collision_check is 16x16 centred; set before event_inherited().
mask_index = spr_collision_check;
image_xscale = 1.25;
image_yscale = 0.75;
event_inherited();
sorted = false;
