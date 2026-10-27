/// @description Stand still; open the seed shop when the player presses E nearby
event_inherited();
near = instance_exists(obj_plyr) && point_distance(x, y, obj_plyr.x, obj_plyr.y) < 70;
if(near && keyboard_check_pressed(ord("E")) && !instance_exists(obj_inventory) && !instance_exists(obj_menu)){
	var inv = instance_create_depth(0, 0, -9000, obj_inventory);
	inv.shop = true;
	inv.shopStock = item_seed_stock();
	inv.shopTitle = "Mara's Seeds - " + season_name(global.clock.season);
}
