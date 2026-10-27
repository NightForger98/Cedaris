/// @description Insert description here
// You can write your code in this editor


///collisions
// Other NPCs and the player block too, unless already overlapping one
var solids = place_meeting(x,y,[obj_npc_parent, obj_plyr]) ? obj_col_box : [obj_col_box, obj_npc_parent, obj_plyr];

if(moveX != 0){
	if(place_meeting(x+moveX,y,solids)){
		repeat(abs(moveX)){
			if(!place_meeting(x+sign(moveX),y,solids)){
			x += sign(moveX); }
			else { break; }
	} moveX = 0;
}
}
x += moveX;
////

if(moveY != 0){
	if(place_meeting(x,y+moveY,solids)){
		repeat(abs(moveY)){
			if(!place_meeting(x,y+sign(moveY),solids)){
			y += sign(moveY); }
			else { break; }
	} moveY = 0;
}
}
y += moveY;

depth_sort();

	
