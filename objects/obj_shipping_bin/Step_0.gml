/// @description E nearby opens the inventory with the bin
if(!sorted){ depth_sort(); sorted = true; }
near = interact_near(60);
if(near && input_pressed(ord("E")) && interact_ready()){
	var inv = instance_create_depth(0, 0, -9000, obj_inventory);
	inv.ship = true;
}
