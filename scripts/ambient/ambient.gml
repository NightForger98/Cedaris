/// Life in the world (the user, 2026-11-07; SpriteCook animations, art/anim_spritecook): the windmill's sails turn,
/// campfires flicker, flags wave; outdoors, birds cross the sky now and then (seagulls by the sea), butterflies
/// flutter on fine spring and summer days, fireflies blink on summer nights. obj_ambient (one an outdoor room, made at
/// Room Start) runs the creatures; obj_building draws the moving parts of buildings and props.

/// @description An animation's frame at a speed (frames a second), from the clock - every copy in step.
function anim_frame(_spr, _fps, _offset = 0){ return floor(current_time / (1000 / _fps) + _offset) mod sprite_get_number(_spr); }

/// @description A building's or prop's moving parts, drawn by obj_building over (or instead of) its picture. Returns
/// true if it drew the whole thing itself.
function ambient_building_draw(_b){
	var spr = _b.sprite_index, top = _b.y - sprite_get_height(spr);
	if(spr == spr_house_windmill){
		// the tower, then its sails turning slowly clockwise round the hub (tower pixel 80, 68; the frames' hub 120, 112)
		draw_sprite(spr, 0, _b.x, top);
		var f = 7 - anim_frame(spr_anim_windmill_sails, 7);
		draw_sprite(spr_anim_windmill_sails, f, _b.x + 80 - 120, top + 68 - 112);
		return true;
	}
	if(spr == spr_anim_flag){ draw_sprite(spr, anim_frame(spr, 7, _b.x * 0.01), _b.x, top); return true; }
	if(spr == spr_prop_campfire){
		// the fire itself, flickering, on the camp's middle
		draw_sprite(spr, 0, _b.x, top);
		var cw = sprite_get_width(spr_anim_campfire);
		draw_sprite(spr_anim_campfire, anim_frame(spr_anim_campfire, 9, _b.x), _b.x + (sprite_get_width(spr) - cw) / 2, _b.y - sprite_get_height(spr_anim_campfire));
		return true;
	}
	return false;
}

/// @description Room Start: the creatures, outdoors.
function ambient_room_start(){
	if(room_is_outdoors() && !instance_exists(obj_ambient)) instance_create_depth(0, 0, -20, obj_ambient);
}

/// @description Whether it's fine weather by day (birds, butterflies) - not raining or snowing, and light.
function ambient_fine_day(){
	if(!world_time_ready()) return true;
	var w = weather_now(), h = global.clock.minutes / 60;
	return w != "rain" && w != "storm" && w != "snow" && h >= 6.5 && h < 19;
}

/// @description Fireflies' light, over the night tint (game's Draw GUI).
function ambient_draw_glow(){
	if(!instance_exists(obj_ambient) || array_length(obj_ambient.flies) == 0) return;
	var cam = view_camera[0], gw = display_get_gui_width(), gh = display_get_gui_height();
	var vx = camera_get_view_x(cam), vy = camera_get_view_y(cam), vw = camera_get_view_width(cam), vh = camera_get_view_height(cam);
	gpu_set_blendmode(bm_add);
	with(obj_ambient) for(var i = 0; i < array_length(flies); i++){
		var fl = flies[i], a = 0.5 + 0.5 * sin(current_time / 300 + fl.ph);
		if(a < 0.2) continue;
		var gx = (fl.x - vx) * gw / vw, gy = (fl.y - vy) * gh / vh;
		draw_set_alpha(a * 0.5 * night_amount());
		draw_circle_colour(gx, gy, 9, make_colour_rgb(200, 255, 120), c_black, false);
	}
	draw_set_alpha(1);
	gpu_set_blendmode(bm_normal);
}
