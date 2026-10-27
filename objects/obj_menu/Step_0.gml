/// @description Back key, parade, timers
if(justOpened){ justOpened = false; exit; }
if(messageTime > 0) messageTime--;

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
