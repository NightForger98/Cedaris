/// @description Open the cooking list when the player presses E in front of the hearth
// Only the closest thing you can use answers E (the bed is nearby)
var d = instance_exists(obj_plyr) ? point_distance(x, y, obj_plyr.x, obj_plyr.y) : 9999;
near = d < 44 && (!instance_exists(obj_bed) || d < point_distance(obj_bed.x, obj_bed.y, obj_plyr.x, obj_plyr.y));
if(near && input_pressed(ord("E")) && !instance_exists(obj_inventory) && !instance_exists(obj_menu)){
	var inv = instance_create_depth(0, 0, -9000, obj_inventory);
	inv.craft = true;
	inv.filter = "cook";
	inv.fixedFilter = true;
}
