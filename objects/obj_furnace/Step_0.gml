/// @description Open the smelting list when the player presses E nearby
if(!sorted){ depth_sort(); sorted = true; }
// Only the closest thing you can use answers E (Brom stands beside it)
var d = instance_exists(obj_plyr) ? point_distance(x, y, obj_plyr.x, obj_plyr.y) : 9999;
near = d < 56 && (!instance_exists(obj_npc_blacksmith) || d < point_distance(obj_npc_blacksmith.x, obj_npc_blacksmith.y, obj_plyr.x, obj_plyr.y));
if(near && input_pressed(ord("E")) && !instance_exists(obj_inventory) && !instance_exists(obj_menu)){
	var inv = instance_create_depth(0, 0, -9000, obj_inventory);
	inv.craft = true;
	inv.filter = "furnace";
	inv.fixedFilter = true;
}
