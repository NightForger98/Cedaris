/// @description E or Esc: goodbye. G: give what you're holding. T: trade (Brom and Mara).
if(justOpened){ justOpened = false; exit; }
// A heart event: E for the next line; a choice (1 or 2) at the end; E once more to finish
if(event != undefined){
	var hasChoice = variable_struct_exists(event, "choice");
	if(!eventDone && line >= array_length(event.lines) - 1 && hasChoice && chosen < 0){
		var pick = input_pressed(ord("1")) ? 0 : (input_pressed(ord("2")) ? 1 : -1);
		if(pick >= 0){ chosen = pick; text = event.choice.options[pick][2]; note = heart_event_finish(event, pick); eventDone = true; }
		exit;
	}
	if(input_pressed(key_of("interact"))){
		if(eventDone){ global.talkCooldown = current_time + 300; game.resumeLock = 2; instance_destroy(); exit; }
		line++;
		if(line < array_length(event.lines)) text = event.lines[line];
		else if(!hasChoice){ line = array_length(event.lines) - 1; note = heart_event_finish(event, -1); eventDone = true; } // one more E to close
	}
	exit;
}
var v = villager_def(who);
if(input_pressed(key_of("interact")) || input_pressed(vk_escape)){
	global.talkCooldown = current_time + 300; // so the same E doesn't start talking again
	game.resumeLock = 2;
	instance_destroy();
	exit;
}
if(input_pressed(ord("T")) && (v[$ "shop"] ?? "") != ""){
	// Only over the counter, in hours (see the schedules)
	if(!villager_shop_open(who)){ text = "Sorry, we're closed. " + villager_hours_text(who) + "."; exit; }
	instance_destroy();
	people_trade(who);
	exit;
}
if(input_pressed(ord("G"))){
	var held = inv_held_stack();
	if(held == undefined) text = "(You're not holding anything to give.)";
	else {
		text = people_gift(who, held);
		var r = people_reward(who);
		if(r != "") note = r;
		inv_apply_look(global.look);
		with(obj_plyr) look = global.look;
	}
}
