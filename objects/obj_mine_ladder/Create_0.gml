/// @description A ladder in the mine. Set on creation: down (true: the hole to the next floor; false: the way out)
near = false;
// Behind the player and monsters (they all depth-sort in front of their layer)
depth = instance_exists(obj_plyr) ? obj_plyr.baseDepth : 100;
