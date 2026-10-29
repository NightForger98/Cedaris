/// @description Open the cooking list when the player presses E in front of the hearth
near = interact_near(44);
if(near && input_pressed(key_of("interact")) && interact_ready()){
	var inv = instance_create_depth(0, 0, -9000, obj_inventory);
	inv.craft = true;
	inv.filter = "cook";
	inv.fixedFilter = true;
}
