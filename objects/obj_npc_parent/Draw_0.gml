/// @description Draw the NPC's look
var anim_length=9;
var anim_speed = 6 * spd; // same pace as the player at this speed


if( moveX < 0){ y_frame = 9}
else if(moveX > 0){y_frame = 11}
else if(moveY < 0){y_frame = 8}
else if(moveY > 0){y_frame = 10}

//INCREMENT FRAME - frame 0 is standing, 1-8 are the walk cycle
if(moveX == 0 && moveY == 0){
	x_frame = 0;
} else {
	x_frame += anim_speed/60;
	if(x_frame >= anim_length) {x_frame = 1}
}

var xx = round(x-x_offset);
var yy = round(y- y_offset);

character_draw(look, floor(x_frame), y_frame, xx, yy, 1);
