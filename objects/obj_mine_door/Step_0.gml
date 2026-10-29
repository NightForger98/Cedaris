/// @description E nearby opens the lift (at the cave, straight down to floor 1 while that's the only floor).
/// In the lift: left / right one floor, up / down five, Enter or E to go, Esc to close.
near = interact_near(44);
if(menuOpen){
	var top = mine_lift_top();
	if(input_pressed(vk_left)) pick--;
	if(input_pressed(vk_right)) pick++;
	if(input_pressed(vk_up)) pick -= MINE_LIFT_EVERY;
	if(input_pressed(vk_down)) pick += MINE_LIFT_EVERY;
	pick = clamp(pick, 1, top);
	if((input_pressed(vk_enter) || input_pressed(key_of("interact"))) && !(inMine && pick == mine_state().floor)){
		menuOpen = false;
		mine_goto(pick);
		exit;
	}
	if(input_pressed(vk_escape) || point_distance(x, y, obj_plyr.x, obj_plyr.y) > 60){
		menuOpen = false;
		game.resumeLock = 2;                    // the same Esc doesn't also pause
		global.talkCooldown = current_time + 250; // nor does an E reopen something
	}
	exit;
}
if(near && input_pressed(key_of("interact")) && interact_ready() && !game.doTransition){
	if(!inMine && mine_lift_top() <= 1) mine_goto(1);
	else {
		menuOpen = true;
		pick = inMine ? mine_state().floor : clamp(mine_state().deepest, 1, mine_lift_top());
	}
}
