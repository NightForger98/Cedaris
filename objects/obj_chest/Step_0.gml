/// @description E beside it: open it (its loot goes into the bag, and it never comes back)
near = instance_exists(obj_plyr) && point_distance(x, y, obj_plyr.x, obj_plyr.y) < 40;
if(near && input_pressed(ord("E")) && !instance_exists(obj_inventory) && !instance_exists(obj_menu)){
	farm_message(mine_chest_open(chestFloor));
	instance_destroy();
}
