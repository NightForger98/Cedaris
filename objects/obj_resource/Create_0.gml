/// @description A tree, stump, rock, ore vein or weed (see the gathering script)
// data: the stored {key, gx, gy, hp, days, area} struct, passed in on creation; hits change it in place.
// Collision is a footprint at the base (spr_collision_check is 16x16 centred). Set before event_inherited(),
// because obj_col_box reads the mask's offset.
def = resource_def(data.key);
mask_index = spr_collision_check;
image_xscale = def.foot[0];
image_yscale = def.foot[1];
event_inherited();
shake = 0;    // frames of wobble after a hit
sorted = false;
