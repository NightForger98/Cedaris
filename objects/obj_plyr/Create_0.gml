/// @description Insert description here
// You can write your code in this editor
w_spd= 1;
n_spd= 2;
r_spd= 3;
spd = n_spd;
x_frame =0;
y_frame =0;
moveX=0;
moveY=0;

// Appearance: the look picked in the character creator, or the default look
// (body parts, clothes and palettes - see character_default_look in character_look)
look = (variable_global_exists("look") && is_struct(global.look)) ? global.look : character_default_look();


///////

x_offset = sprite_get_xoffset(mask_index);
y_offset = sprite_get_yoffset(mask_index);
facing = 0;
act = undefined;     // the action being played (see the actions script), or undefined
actStep = 0;         // current step of it
actDir = 2;          // facing while acting: 0 north, 1 west, 2 south, 3 east
actHit = false;      // the hit step has fired
baseDepth = depth; // depth of the room layer the player was placed on, used by depth_sort()
iframes = 0;        // frames of invulnerability after a monster hits (see player_hurt)
