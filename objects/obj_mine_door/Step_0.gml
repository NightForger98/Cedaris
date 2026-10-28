/// @description E nearby: go down to floor 1, or pick a floor on the lift; Esc closes the lift
near = interact_near(44);
if(menuOpen){
	if(input_pressed(vk_escape) || point_distance(x, y, obj_plyr.x, obj_plyr.y) > 60) menuOpen = false;
	exit;
}
if(near && input_pressed(ord("E")) && interact_ready() && !game.doTransition){
	if(array_length(mine_lift_floors()) > 1) menuOpen = true;
	else mine_goto(1);
}
