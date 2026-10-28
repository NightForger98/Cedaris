/// @description E beside it: climb down to the next floor, or up and out to the farm
near = interact_near(34);
if(near && input_pressed(ord("E")) && interact_ready() && !game.doTransition){
	if(down) mine_goto(mine_state().floor + 1);
	else mine_leave();
}
