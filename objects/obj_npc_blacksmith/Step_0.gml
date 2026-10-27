/// @description Stand still; open the shop when the player presses E nearby
event_inherited();
// Only the closest thing you can use answers E (the crafting table stands nearby)
near = instance_exists(obj_plyr) && point_distance(x, y, obj_plyr.x, obj_plyr.y) < 80
       && (!instance_exists(obj_crafting_table) || point_distance(x, y, obj_plyr.x, obj_plyr.y) < point_distance(obj_crafting_table.x, obj_crafting_table.y, obj_plyr.x, obj_plyr.y));
if(near && keyboard_check_pressed(ord("E")) && !instance_exists(obj_inventory) && !instance_exists(obj_menu)){
	var inv = instance_create_depth(0, 0, -9000, obj_inventory);
	inv.shop = true;
}
