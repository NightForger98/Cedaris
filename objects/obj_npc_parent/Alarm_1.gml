/// @description Insert description here
// You can write your code in this editor

// Stop, then maybe pick a new direction
moveX = 0;
moveY = 0;
var idle = choose(0,1);
if(idle== false){
	var pick = choose(1,2,3,4);
	switch(pick){
		case 1: moveX = +spd; break;
		case 2: moveX = -spd; break;
		case 3: moveY = +spd; break;
		case 4: moveY = -spd; break;
	}
}

alarm[1] = random_range(2.5,4)*game_get_speed(gamespeed_fps);











