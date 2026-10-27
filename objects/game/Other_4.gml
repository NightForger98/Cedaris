/// @description Insert description here
// You can write your code in this editor

roomWidth = room_width;
roomHeight = room_height;

// Entering a play room without going through the creator (e.g. running a room directly): free-mode defaults
if(game_is_playing_room()){
	if(!variable_global_exists("look") || !is_struct(global.look)) global.look = character_default_look();
	if(!variable_global_exists("inv") || !is_struct(global.inv)) global.inv = inv_new_free(global.look);
	inv_apply_look(global.look);
	with(obj_plyr) look = global.look;
}
 
// Place the player where the transition or loaded save says, only in that room
if(spawnRoom == -1 || room != spawnRoom || !instance_exists(obj_plyr)) exit;
obj_plyr.x=spawnX;
obj_plyr.y=spawnY;
obj_plyr.facing = spawnPlayerFacing; 

with(obj_plyr){

switch(facing){
case  dir.left:		 y_frame = 9;break;
case  dir.right:	 y_frame = 11;break;
case  dir.up:		 y_frame = 8;break;
case  dir.down:		 y_frame = 10;break;
case  -1:			 x_frame = 0;break;
}}	











