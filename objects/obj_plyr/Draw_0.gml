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

// The dash's afterimages, fading (scripts/combat_feel)
for(var i = 0; i < array_length(afterimages); i++){
	var ai = afterimages[i];
	character_draw(look, ai.frame, ai.row, round(ai.x - x_offset), round(ai.y - y_offset), 1, undefined, make_colour_rgb(150, 205, 255), ai.a);
}
// Dodging: a dash on the run cycle, or a hop back over its shadow
if(dodgeT > 0){
	var prog = 1 - dodgeT / dodgeTotal;
	if(dodgeHop){
		var hop = round(sin(prog * pi) * 14);
		draw_set_alpha(0.3); draw_set_colour(c_black);
		draw_ellipse(x - 10, y - 4, x + 10, y + 2, false);
		draw_set_alpha(1); draw_set_colour(c_white);
		character_draw(look, 1, y_frame, xx, yy - hop, 1);
	} else if(look.body != "child") character_draw(look, floor(prog * 8) mod 8, y_frame + 17, xx, yy, 1);
	else character_draw(look, 1 + floor(prog * 8) mod 8, y_frame, xx, yy, 1);
	exit;
}
// Blink while invulnerable after a hit
if(iframes > 0 && (iframes div 4) mod 2 == 0) exit;
// Dancing (scripts/skills): its steps in turn - a row of the sheet, a hop, a sway
if(danceT > 0 && danceKey != ""){
	var dd = dance_table()[$ danceKey], st = dd.steps, t = 150 - danceT, total = 0;
	for(var i = 0; i < array_length(st); i++) total += st[i][1] * 4;
	var tt = t mod total, k = 0;
	while(tt >= st[k][1] * 4){ tt -= st[k][1] * 4; k++; }
	var s = st[k], frac2 = tt / (s[1] * 4);
	var fr = (s[0] < 4) ? floor(frac2 * 7) : 1 + floor(frac2 * 8) mod 8;   // arms raised: frames 0-6; the walk: 1-8
	var hop = round(sin(frac2 * pi) * s[2]), sway = round(sin(frac2 * pi) * s[3]);
	character_draw(look, fr, s[0], xx + sway, yy - hop, 1);
	draw_set_font(fnt_eq);
	draw_set_halign(fa_center);
	draw_text_transformed_colour(x + 14, y - 74 - (t mod 30) / 3, "~", 0.5 * wtx(), 0.5 * wtx(), 0, make_colour_rgb(255, 180, 210), make_colour_rgb(255, 180, 210), make_colour_rgb(255, 180, 210), make_colour_rgb(255, 180, 210), 1 - (t mod 30) / 30);
	draw_set_halign(fa_left);
	exit;
}
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
// Sprinting (the run key, moving): the LPC run cycle, rows 25-28 (8 frames, n w s e), stepped by the walk counter;
// a child has no run art, so keeps the walk
else if(sprinting && facing != -1 && look.body != "child") character_draw(look, (max(1, floor(x_frame)) - 1) mod 8, y_frame + 17, xx, yy, 1);
else character_draw(look, floor(x_frame), y_frame, xx, yy, 1);
furniture_draw_preview();   // the held piece of furniture: where it would go
// On guard (scripts/combat_feel): a shield of light in front, bright while a parry is still possible
if(blocking){
	var ga = player_face_angle(), early = (blockT <= parry_window());
	draw_set_alpha(early ? 0.85 : 0.45);
	draw_set_colour(early ? make_colour_rgb(255, 240, 150) : make_colour_rgb(150, 200, 255));
	for(var k = -60; k < 60; k += 10){
		draw_line_width(x + lengthdir_x(22, ga + k), y - 16 + lengthdir_y(22, ga + k), x + lengthdir_x(22, ga + k + 10), y - 16 + lengthdir_y(22, ga + k + 10), 2);
	}
	draw_set_alpha(1);
	draw_set_colour(c_white);
}
