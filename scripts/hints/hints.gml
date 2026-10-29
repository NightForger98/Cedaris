/// First-time hints: a short tip the first time you meet something (the farm's way out, a tool, the shipping bin, the
/// lift, a locked door, a late night). Each shows once per game - the keys seen are kept in global.world.hints, so
/// they're saved with the world. Shown one at a time at the bottom of the screen (game Draw GUI).
/// Test runs show none unless a test turns them on (call autotest_hints), so screenshots stay clean.

#macro HINT_FRAMES 480   // 8 seconds on screen

/// @description Show a hint once per game (queued behind any that are showing).
function hint(_key, _text){
	if(autotest_running() && !(variable_global_exists("hintsInTests") && global.hintsInTests)) return;
	if(!world_time_ready()) return;
	if(!is_array(global.world[$ "hints"])) global.world.hints = [];
	if(array_get_index(global.world.hints, _key) != -1) return;
	array_push(global.world.hints, _key);
	array_push(game.hintQueue, _text);
}

/// @description Game Step, while playing: notice the things that have a hint, a few times a second.
function hints_step(){
	if(game.hintTime > 0) game.hintTime--;
	if(game.hintTime <= 0 && array_length(game.hintQueue) > 0){
		game.hintText = game.hintQueue[0];
		array_delete(game.hintQueue, 0, 1);
		game.hintTime = HINT_FRAMES;
	}
	if(!instance_exists(obj_plyr) || ui_blocking() || (current_time div 250) == (current_time - delta_time / 1000) div 250) return;

	if(room == rm_1) hint("farm_exit", "Welcome to the farm! The path at the top leads north to Hollow Vale and the rest of the valley. Press " + key_name(key_of("map")) + " for the map, " + key_name(key_of("inventory")) + " for your inventory.");
	var held = inv_held_stack(), id_ = (held == undefined) ? "" : held.id;
	if(id_ == "c|held|Hoe") hint("hoe", "The hoe: click or press " + key_name(key_of("use")) + " facing the field's soil to till it, then plant seeds in it.");
	else if(id_ == "c|held|Watering Can") hint("can", "The watering can: water each crop every day. Use it on a pond or river to refill it.");
	else if(string_pos("s|", id_) == 1) hint("seeds", "Seeds: plant them in tilled soil and water them every day until they're grown.");
	with(obj_shipping_bin) if(point_distance(x, y, obj_plyr.x, obj_plyr.y) < 90)
		hint("bin", "The shipping bin: press " + key_name(key_of("interact")) + " to open it, then right-click what you want to sell. It's paid for overnight.");
	with(obj_mine_door) if(!inMine && point_distance(x, y, obj_plyr.x, obj_plyr.y) < 90 && mine_lift_top() > 1)
		hint("lift", mine_lift_free() ? "The lift: in free mode it goes to any floor of the mine." : "The lift: it takes you back down to any floor you've already reached.");
	if(global.clock.minutes >= 22 * 60) hint("late", "It's getting late. At 2 am you'll pass out wherever you are - get to bed before then.");
	if(global.vitals.energy < vitals_max_energy() * 0.25) hint("tired", "You're tired. Eat something, or sleep in your bed to start fresh in the morning.");
}

/// @description Game Draw GUI: the hint showing, in a panel above the bottom of the screen, fading in and out.
function hints_draw(_gw, _gh){
	if(game.hintTime <= 0) return;
	var c = ui_colours();
	var a = min(1, game.hintTime / 30, (HINT_FRAMES - game.hintTime) / 20);
	draw_set_font(fnt_eq);
	var sc = 0.5, wrap = 1500, w = min(string_width_ext(game.hintText, -1, wrap) * sc, 760) + 48;
	var h = string_height_ext(game.hintText, -1, wrap) * sc + 30;
	var x1 = (_gw - w) / 2, y1 = _gh - 150 - h;
	draw_set_alpha(0.9 * a);
	draw_set_colour(c.panel);
	draw_roundrect_ext(x1, y1, x1 + w, y1 + h, 14, 14, false);
	draw_set_alpha(a);
	draw_set_colour(c.accent);
	draw_roundrect_ext(x1, y1, x1 + w, y1 + h, 14, 14, true);
	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);
	draw_text_ext_transformed_colour(_gw / 2, y1 + h / 2, game.hintText, -1, wrap, sc, sc, 0, c_white, c_white, c_white, c_white, a);
	draw_set_alpha(1);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
}
