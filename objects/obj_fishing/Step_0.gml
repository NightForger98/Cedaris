/// @description Wait for the bite; then Space while the marker's in the zone lands it; Esc reels in
if(justOpened){ justOpened = false; exit; }
if(input_pressed(vk_escape)){ game.resumeLock = 2; instance_destroy(); exit; }
if(state == "wait"){
	if(--waitT <= 0) state = "bite";
	else if(input_pressed(vk_space)){ farm_message("Too soon - nothing's biting yet"); instance_destroy(); }
	exit;
}
// The bite: the marker sweeps back and forth; the fish gives up after a few seconds
marker += markerDir * markerSpeed;
if(marker >= 1 || marker <= 0){ markerDir = -markerDir; marker = clamp(marker, 0, 1); }
if(++biteT > 300){ farm_message("It got away"); instance_destroy(); exit; }
if(input_pressed(vk_space) || mouse_check_button_pressed(mb_left)){
	if(marker >= zoneAt && marker <= zoneAt + zone) fishing_catch(fish);
	else farm_message("It slipped off the hook");
	global.talkCooldown = current_time + 300; // this Space doesn't swing the rod again
	instance_destroy();
}
