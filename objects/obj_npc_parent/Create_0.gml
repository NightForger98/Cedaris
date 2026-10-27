/// @description NPC setup
w_spd= 1;
n_spd= 2;
r_spd= 3;
spd = w_spd;
x_frame =0;
y_frame =0;
moveX=0;
moveY=0;

// Appearance: a random villager, race weighted by how common it is (see character_races)
look = character_random_look();

///////
x_offset = sprite_get_xoffset(mask_index);
y_offset = sprite_get_yoffset(mask_index);

alarm[1] = 1;
