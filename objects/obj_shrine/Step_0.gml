/// @description Depth among the trees; E nearby says what it wants
if(!sorted){ depth_sort(); sorted = true; }
near = interact_near(48);
if(near && input_pressed(key_of("interact")) && interact_ready()){
	if(project_done("shrine")) farm_message("The shrine glows softly. Somewhere, pixies are dancing.");
	else farm_message("An old shrine, cold and dark. Elda will know what it needs - see Projects on the notice board.");
}
