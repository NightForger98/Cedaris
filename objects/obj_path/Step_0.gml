/// @description E nearby: cross (once the bridge is mended), or head back
near = interact_near(48);
if(near && input_pressed(key_of("interact")) && interact_ready() && !game.doTransition){
	if(target == "village") forest_leave();
	else if(project_done("bridge")) forest_goto();
	else farm_message("The bridge is out. Thorne's mending it - see Projects on the notice board.");
}
