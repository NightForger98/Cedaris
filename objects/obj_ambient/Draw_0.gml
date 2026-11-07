/// @description The creatures, over the world (birds and butterflies; fireflies' light: game's Draw GUI)
for(var i = 0; i < array_length(butterflies); i++){
	var u = butterflies[i];
	draw_sprite(u.spr, anim_frame(u.spr, 10, i * 3), round(u.x), round(u.y));
}
for(var i = 0; i < array_length(flies); i++){
	var fl = flies[i];
	if(0.5 + 0.5 * sin(current_time / 300 + fl.ph) > 0.3) draw_sprite(spr_anim_firefly, anim_frame(spr_anim_firefly, 6, fl.ph), round(fl.x), round(fl.y));
}
for(var i = 0; i < array_length(birds); i++){
	var b = birds[i], w = sprite_get_width(b.spr);
	// facing the way it flies (the art faces right)
	if(b.dx < 0) draw_sprite_ext(b.spr, anim_frame(b.spr, 8, i), round(b.x) + w, round(b.y), -1, 1, 0, c_white, 1);
	else draw_sprite(b.spr, anim_frame(b.spr, 8, i), round(b.x), round(b.y));
}
