/// @description Sleep when the player presses E beside the bed
if(!sorted){ depth_sort(); sorted = true; }
near = instance_exists(obj_plyr) && point_distance(x, y, obj_plyr.x, obj_plyr.y) < 72;
if(near && keyboard_check_pressed(ord("E")) && !instance_exists(obj_inventory) && !instance_exists(obj_menu)){
	sleep_now(false);
}
