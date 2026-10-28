/// @description Sleep when the player presses E beside the bed
if(!sorted){ depth_sort(); sorted = true; }
near = instance_exists(obj_plyr) && point_distance(x, y, obj_plyr.x, obj_plyr.y) < 72
       && (!instance_exists(obj_kitchen) || point_distance(x, y, obj_plyr.x, obj_plyr.y) <= point_distance(obj_kitchen.x, obj_kitchen.y, obj_plyr.x, obj_plyr.y));
if(near && input_pressed(ord("E")) && !instance_exists(obj_inventory) && !instance_exists(obj_menu)){
	sleep_now(false);
}
