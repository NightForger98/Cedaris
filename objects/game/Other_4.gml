/// @description Insert description here
// You can write your code in this editor

roomWidth = room_width;
roomHeight = room_height;
 
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











