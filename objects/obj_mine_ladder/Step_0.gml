/// @description E beside it: climb down to the next floor, or up and out to the farm
near = instance_exists(obj_plyr) && point_distance(x, y, obj_plyr.x, obj_plyr.y) < 34;
if(near && input_pressed(ord("E")) && !instance_exists(obj_inventory) && !instance_exists(obj_menu) && !game.doTransition){
	if(down) mine_goto(mine_state().floor + 1);
	else mine_leave();
}
