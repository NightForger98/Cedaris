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

// Villagers: their name, and a prompt when you're close (Brom and Mara draw their own)
if(who != "" && !variable_instance_exists(id, "npcName")){
	var v = villager_def(who);
	var top = y - y_offset + 10;
	draw_set_font(fnt_eq);
	draw_set_halign(fa_center);
	draw_set_valign(fa_bottom);
	draw_text_transformed_colour(x, top, v.name, 0.3 * wtx(), 0.3 * wtx(), 0, c_white, c_white, c_white, c_white, 1);
	if(near)
		draw_text_transformed_colour(x, top - 12, key_label("interact") + " Talk", 0.3 * wtx(), 0.3 * wtx(), 0, c_yellow, c_yellow, c_yellow, c_yellow, 1);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
}
