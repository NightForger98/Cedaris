/// @description Insert description here
// You can write your code in this editor
var in_left =keyboard_check(vk_left);
var in_right =keyboard_check(vk_right);
var in_up=keyboard_check(vk_up);
var in_down =keyboard_check(vk_down);
var in_walk=keyboard_check(vk_control);
var in_run=keyboard_check(vk_shift);
	//ALTERSPEED
if(in_walk || in_run){
	spd=abs((in_walk*w_spd)-(in_run*r_spd));
}else {
	spd=n_spd;
}
//RESETVARIABLES

moveY= (in_down - in_up) * spd;
moveX =(in_right - in_left) * spd; 

//get direction player facing
if(moveX != 0){
switch(sign(moveX)){
case 1: facing = dir.right; break;
case -1: facing= dir.left; break;
}
}else if(moveY != 0){
switch(sign(moveY)){
case 1: facing = dir.down; break;
case -1: facing = dir.up; break;
}
}else{facing = -1;}



///collisions
if(moveX != 0){
	if(place_meeting(x+moveX,y,obj_col_box)){ 
		repeat(abs(moveX)){
			if(!place_meeting(x+sign(moveX),y,obj_col_box)){
			x += sign(moveX); }
			else { break; }
	} moveX = 0;
}
}
////vertical

if(moveY != 0){
	if(place_meeting(x,y+moveY,obj_col_box)){
		repeat(abs(moveY)){
			if(!place_meeting(x,y+sign(moveY),obj_col_box)){
			y += sign(moveY); }
			else { break; }
	} moveY = 0;
}
}

//objects
var inst = instance_place(x,y,obj_transition);
if (inst != noone and facing == inst.PlayerFacingBefore){
	
	with(game){
		spawnRoom= inst.targetRoom;
		spawnX = inst.targetX;
		spawnY = inst.targetY;
		spawnPlayerFacing = inst.PlayerFacingAfter;
		doTransition = true;

}}


x += moveX;
y += moveY;

	
