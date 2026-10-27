/// @description Draw the player's look
var anim_length=9;
var anim_speed = 6 * spd; // walk 6, normal 12, run 18



switch(facing){
case  dir.left:		 y_frame = 9;break;
case  dir.right:	 y_frame = 11;break;
case  dir.up:		 y_frame = 8;break;
case  dir.down:		 y_frame = 10;break;
case  -1:			 x_frame = 0;break;
}



// Round so diagonal (fractional) positions don't shimmer
var xx = round(x-x_offset);
var yy = round(y- y_offset);

//INCREMENT FRAME - frame 0 is standing, 1-8 are the walk cycle
if(facing != -1){
	x_frame += anim_speed/60;
	if(x_frame >= anim_length) {x_frame = 1}
}

// All layers, palettes and draw order live in character_draw (character_look script)
if(act != undefined) character_draw(look, 0, 0, xx, yy, 1, {act: act, i: floor(actStep), dir: actDir});
else character_draw(look, floor(x_frame), y_frame, xx, yy, 1);
