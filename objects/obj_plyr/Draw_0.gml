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

// Blink while invulnerable after a hit
if(iframes > 0 && (iframes div 4) mod 2 == 0) exit;
// Charging: the cells the release will work, under your feet
if(charge != undefined) charge_draw_cells(id);
// All layers, palettes and draw order live in character_draw (character_look script)
if(charge != undefined){
	// Held on the wind-up: the tool pulled back and glowing, the strain on the face (charging script)
	var a = {act: act, i: charge_pose_step(act), dir: actDir, fx: charge_fx(charge, actDir)};
	charge_draw_behind(id, xx, yy, a);
	character_draw(look, 0, 0, xx, yy, 1, a);
	charge_draw_front(id, xx, yy, actDir);
}
// A charged release: the spin with its trail, or the big swing with its arc
else if(motion != undefined && motion.type == "spin" && act != undefined) charge_draw_spin(id, xx, yy);
else if(act != undefined){
	character_draw(look, 0, 0, xx, yy, 1, {act: act, i: floor(actStep), dir: actDir});
	if(motion != undefined && motion.type == "swing") charge_draw_swing(id);
	if(motion != undefined && motion.type == "slam") charge_draw_slam(id);
}
else character_draw(look, floor(x_frame), y_frame, xx, yy, 1);
