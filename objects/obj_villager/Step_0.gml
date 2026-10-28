/// @description Follow the schedule; stand still while talking; E nearby talks
if(instance_exists(obj_dialogue) && obj_dialogue.npc == id){ moveX = 0; moveY = 0; exit; }
var w = villager_where(who);
if(w.room != room_get_name(room)){ instance_destroy(); exit; }   // walked out through a door

// Face the way they're going (Draw animates while moveX / moveY aren't 0); stand facing down once there
var dx = w.x - x, dy = w.y - y;
if(w.moving && (dx != 0 || dy != 0)){
	moveX = (abs(dx) >= abs(dy)) ? sign(dx) : 0;
	moveY = (abs(dx) < abs(dy)) ? sign(dy) : 0;
} else {
	if(moveX != 0 || moveY != 0) y_frame = 10;
	moveX = 0;
	moveY = 0;
}
x = w.x;
y = w.y;
atWork = w.work;
talkRange = atWork ? 100 : 48;   // across a counter at work

near = interact_near(talkRange);
if(near && input_pressed(ord("E")) && interact_ready()) people_open(id);

// Brom at his anvil: a swing every few seconds
if(hammer){
	if(act != undefined){
		actStep += act.fps / game_get_speed(gamespeed_fps);
		if(actStep >= act.frames) act = undefined;
	} else if(atWork && --hammerTimer <= 0){
		act = character_action_for(look);
		actStep = 0;
		hammerTimer = irandom_range(90, 240);
	}
}
depth_sort();
