/// @description Stand still and hammer; E nearby talks to him (the parent handles it; T in the dialogue trades)
event_inherited();
if(act != undefined){
	actStep += act.fps / game_get_speed(gamespeed_fps);
	if(actStep >= act.frames){ act = undefined; hammerTimer = irandom_range(90, 240); }
} else if(--hammerTimer <= 0){
	act = character_action_for(look);
	actStep = 0;
}
