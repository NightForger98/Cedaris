/// @description K or Esc closes it
if(justOpened){ justOpened = false; exit; }
if(messageTime > 0) messageTime--;
if(input_pressed(key_of("skills")) || input_pressed(vk_escape)){
	game.resumeLock = 2;
	global.talkCooldown = current_time + 250;
	instance_destroy();
}
