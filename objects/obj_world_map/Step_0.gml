/// @description M or Esc closes it
if(justOpened){ justOpened = false; exit; }
if(input_pressed(key_of("map")) || input_pressed(vk_escape)){
	game.resumeLock = 2;   // so the same Esc doesn't pause the game
	instance_destroy();
}
