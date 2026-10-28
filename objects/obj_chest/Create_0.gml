/// @description A treasure chest on a mine lift floor, there the first time you reach it. Set on creation: chestFloor.
near = false;
// Behind the player and monsters
depth = instance_exists(obj_plyr) ? obj_plyr.baseDepth : 100;
