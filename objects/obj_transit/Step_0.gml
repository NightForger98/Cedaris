/// @description E nearby: ride (the cable car), or open the tram's stops; idle until its project is done.
/// The tram's menu: Up / Down to choose, Enter or E to go, Esc to close.
if(messageTime > 0) messageTime--;
near = interact_near(56);
if(menuOpen){
	var others = transit_others(kind, stop), n = array_length(others);
	if(input_pressed(vk_up)) pick = (pick + n - 1) mod n;
	if(input_pressed(vk_down)) pick = (pick + 1) mod n;
	if(input_pressed(vk_enter) || input_pressed(key_of("interact"))){
		menuOpen = false;
		message = transit_ride(others[pick]);
		messageTime = (message != "") ? 180 : 0;
		global.talkCooldown = current_time + 250;
		exit;
	}
	if(input_pressed(vk_escape) || point_distance(x, y, obj_plyr.x, obj_plyr.y) > 80){
		menuOpen = false;
		game.resumeLock = 2;
		global.talkCooldown = current_time + 250;
	}
	exit;
}
if(near && input_pressed(key_of("interact")) && interact_ready() && !game.doTransition){
	global.talkCooldown = current_time + 250;
	if(!transit_runs(kind)){
		message = (kind == "cable") ? "The cable car hasn't run in years. (Projects, on the board in Downtown)"
		                            : "No tram has stopped here in years. (Projects, on the board in Downtown)";
		messageTime = 200;
	} else if(kind == "cable"){
		var o = transit_others(kind, stop);
		if(array_length(o) > 0){ message = transit_ride(o[0]); messageTime = (message != "") ? 180 : 0; }
	} else {
		menuOpen = true;
		pick = 0;
		message = ""; messageTime = 0;
	}
}
