/// @description E nearby opens the inventory with the bin
if(!sorted){ depth_sort(); sorted = true; }
near = instance_exists(obj_plyr) && point_distance(x, y, obj_plyr.x, obj_plyr.y) < 60;
if(near && keyboard_check_pressed(ord("E")) && !instance_exists(obj_inventory) && !instance_exists(obj_menu)){
	var inv = instance_create_depth(0, 0, -9000, obj_inventory);
	inv.ship = true;
}
