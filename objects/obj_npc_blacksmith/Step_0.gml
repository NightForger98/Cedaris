/// @description Stand still and hammer; open the shop when the player presses E nearby
event_inherited();
if(act != undefined){
	actStep += act.fps / game_get_speed(gamespeed_fps);
	if(actStep >= act.frames){ act = undefined; hammerTimer = irandom_range(90, 240); }
} else if(--hammerTimer <= 0){
	act = character_action_for(look);
	actStep = 0;
}
// Only the closest thing you can use answers E (the crafting table stands nearby)
near = instance_exists(obj_plyr) && point_distance(x, y, obj_plyr.x, obj_plyr.y) < 80
       && (!instance_exists(obj_crafting_table) || point_distance(x, y, obj_plyr.x, obj_plyr.y) < point_distance(obj_crafting_table.x, obj_crafting_table.y, obj_plyr.x, obj_plyr.y));
if(near && keyboard_check_pressed(ord("E")) && !instance_exists(obj_inventory) && !instance_exists(obj_menu)){
	var inv = instance_create_depth(0, 0, -9000, obj_inventory);
	inv.shop = true;
}
