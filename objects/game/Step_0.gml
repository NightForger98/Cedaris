/// @description Insert description here
// You can write your code in this editor
if(keyboard_check_pressed(vk_insert)) {debug = !debug}
if(keyboard_check_pressed(vk_home)) {game_restart();}
if(game_is_playing_room() && !instance_exists(obj_menu)){
	playtime += delta_time / 1000000;
	var invOpen = instance_exists(obj_inventory);
	if(resumeLock > 0) {resumeLock--;}
	else if(!invOpen && keyboard_check_pressed(vk_escape)) {game_pause();}
	else if(!invOpen && keyboard_check_pressed(ord("I")) && instance_exists(obj_plyr)) {instance_create_depth(0, 0, -9000, obj_inventory);}
	
	// Hotbar: 1-9 and 0 pick the held item
	for(var k = 0; k < INV_HOTBAR; k++){
		if(keyboard_check_pressed(ord(string((k + 1) mod 10)))){
			global.inv.hotbar = k;
			inv_apply_look(global.look);
		}
	}
}











