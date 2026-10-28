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
// Step around you and each other. Where they are comes from the clock, so they curve round rather than stop: a nudge
// off to the side of where they're going (straight away when standing), eased in and out, and never into a wall
var ax = 0, ay = 0, me = id;
var bump = function(_fx, _fy, _wx, _wy, _dx, _dy, _moving){
	var d = point_distance(_fx, _fy, _wx, _wy);
	if(d >= 26) return [0, 0];
	var awx = (d >= 1) ? (_wx - _fx) / d : 1, awy = (d >= 1) ? (_wy - _fy) / d : 0; // right on top: step aside to the right
	if(!_moving) return [awx * (26 - d), awy * (26 - d)];
	var ml = max(point_distance(0, 0, _dx, _dy), 0.001), px = -_dy / ml, py = _dx / ml;
	var side = (awx * px + awy * py >= 0) ? 1 : -1;
	return [px * side * (26 - d) * 1.2, py * side * (26 - d) * 1.2];
};
if(instance_exists(obj_plyr)){ var b = bump(obj_plyr.x, obj_plyr.y, w.x, w.y, dx, dy, w.moving); ax += b[0]; ay += b[1]; }
with(obj_villager) if(id != me){ var b2 = bump(x, y, w.x, w.y, dx, dy, w.moving); ax += b2[0]; ay += b2[1]; }
sideX = lerp(sideX, ax, 0.15);
sideY = lerp(sideY, ay, 0.15);
var blockers = collision_solids(false);
if(place_meeting(w.x + sideX, w.y + sideY, blockers) && !place_meeting(w.x, w.y, blockers)){ sideX = 0; sideY = 0; }
x = w.x + sideX;
y = w.y + sideY;
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
