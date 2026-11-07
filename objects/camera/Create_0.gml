/// @description The view follows this (rooms' view 0); it trails the player (Step)
following = obj_plyr;
h_border = 60;
v_border = 30;
move_cam = false;   // the free camera (C, debug mode only)
offscreen = 0;      // frames the player has been off screen
bx = x; by = y;       // the trailing follow
lead_x = 0; lead_y = 0;   // the look-ahead (running, sprinting)
