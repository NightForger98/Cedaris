/// @description Insert description here
// You can write your code in this editor


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
////

if(moveY != 0){
	if(place_meeting(x,y+moveY,obj_col_box)){
		repeat(abs(moveY)){
			if(!place_meeting(x,y+sign(moveY),obj_col_box)){
			y += sign(moveY); }
			else { break; }
	} moveY = 0;
}
}

x += moveX;
y += moveY;

	
