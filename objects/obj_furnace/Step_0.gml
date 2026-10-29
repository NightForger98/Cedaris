/// @description Open the smelting list when the player presses E nearby
if(!sorted){ depth_sort(); sorted = true; }
near = interact_near(56);
if(near && input_pressed(key_of("interact")) && interact_ready()){
	var inv = instance_create_depth(0, 0, -9000, obj_inventory);
	inv.craft = true;
	inv.filter = "furnace";
	inv.fixedFilter = true;
}
