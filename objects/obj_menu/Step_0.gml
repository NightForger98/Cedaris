/// @description Back key, parade, timers
if(justOpened){ justOpened = false; exit; }
if(messageTime > 0) messageTime--;

// Controls: the next key pressed becomes the action's key (Esc cancels; a key in use swaps with this one)
if(rebinding != ""){
	if(keyboard_check_pressed(vk_anykey)){
		var k = keyboard_lastkey;
		if(k == vk_escape) rebinding = "";
		else if(key_reserved(k)) showMessage(key_name(k) + " is kept for the pause menu, the hotbar or debug mode");
		else {
			var keys = global.settings.keys, nm = variable_struct_get_names(keys);
			for(var i = 0; i < array_length(nm); i++) if(keys[$ nm[i]] == k && nm[i] != rebinding) keys[$ nm[i]] = keys[$ rebinding];
			keys[$ rebinding] = k;
			settings_save();
			showMessage(key_name(k) + " set");
			rebinding = "";
		}
	}
	exit;
}

// Esc: back out of a sub-screen, or resume from the pause screen
if(keyboard_check_pressed(vk_escape)){
	if(screen == "pause"){
		game_unpause();
		exit;
	}
	if(screen != "main") openScreen(isPause ? "pause" : "main");
}

// Credits scroll by themselves; the mouse wheel speeds them along
if(screen == "credits"){
	creditsScroll += 0.6 + (mouse_wheel_down() - mouse_wheel_up()) * 40;
	creditsScroll = max(0, creditsScroll);
}

// Parade walks right and wraps around with a fresh villager
if(!isPause){
	for(var i = 0; i < array_length(parade); i++){
		var p = parade[i];
		p.x += p.spd;
		p.frame += p.spd * 8 / 60;
		if(p.frame >= 9) p.frame = 1;
		if(p.x > guiW + 100){
			p.x = -200;
			p.look = character_random_look();
			p.spd = random_range(0.6, 1.4);
		}
	}
}
