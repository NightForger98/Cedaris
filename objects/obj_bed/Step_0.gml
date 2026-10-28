/// @description Sleep when the player presses E beside the bed
if(!sorted){ depth_sort(); sorted = true; }
near = interact_near(72);
if(near && input_pressed(ord("E")) && interact_ready()){
	sleep_now(false);
}
