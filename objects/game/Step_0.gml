/// @description Insert description here
// You can write your code in this editor
if(keyboard_check_pressed(vk_insert)) {debug = !debug}
if(keyboard_check_pressed(vk_home)) {game_restart();}
if(game_is_playing_room() && !instance_exists(obj_menu)){
	playtime += delta_time / 1000000;
	if(resumeLock > 0) {resumeLock--;}
	else if(keyboard_check_pressed(vk_escape)) {game_pause();}
}











