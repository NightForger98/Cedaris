/// @description E or Esc: goodbye. G: give what you're holding. T: trade (Brom and Mara).
if(justOpened){ justOpened = false; exit; }
var v = villager_def(who);
if(input_pressed(ord("E")) || input_pressed(vk_escape)){
	global.talkCooldown = current_time + 300; // so the same E doesn't start talking again
	game.resumeLock = 2;
	instance_destroy();
	exit;
}
if(input_pressed(ord("T")) && (v[$ "shop"] ?? "") != ""){
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
