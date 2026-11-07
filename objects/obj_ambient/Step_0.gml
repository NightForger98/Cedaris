/// @description Birds now and then; butterflies by fine spring and summer days; fireflies on summer nights
if(ui_blocking()) exit;
var cam = view_camera[0];
var vx = camera_get_view_x(cam), vy = camera_get_view_y(cam), vw = camera_get_view_width(cam), vh = camera_get_view_height(cam);
var season = world_time_ready() ? (global.clock.season mod 4) : 0, night = world_time_ready() ? night_amount() : 0;

// Birds: one crosses the view every few seconds by day (seagulls by the sea, sparrows inland)
if(ambient_fine_day() && --birdT <= 0){
	birdT = irandom_range(240, 600);
	var left = choose(true, false), spr = (sea && random(1) < 0.7) ? spr_anim_bird_seagull : spr_anim_bird_sparrow;
	var by = vy + random_range(0.1, 0.7) * vh;
	array_push(birds, {x: left ? vx - 30 : vx + vw + 30, y: by, dx: (left ? 1 : -1) * random_range(1.6, 2.4), dy: random_range(-0.3, 0.3), spr: spr});
}
for(var i = array_length(birds) - 1; i >= 0; i--){
	var b = birds[i];
	b.x += b.dx; b.y += b.dy;
	if(b.x < vx - 80 || b.x > vx + vw + 80) array_delete(birds, i, 1);
}

// Butterflies: a few about you on fine spring and summer days
var wantB = (ambient_fine_day() && (season == 0 || season == 1)) ? 4 : 0;
while(array_length(butterflies) < wantB)
	array_push(butterflies, {x: vx + random(vw), y: vy + random(vh), dx: 0, dy: 0, spr: choose(spr_anim_butterfly_blue, spr_anim_butterfly_orange), t: 0});
if(array_length(butterflies) > wantB) array_resize(butterflies, wantB);
for(var i = 0; i < array_length(butterflies); i++){
	var u = butterflies[i];
	if(--u.t <= 0){ u.t = irandom_range(20, 60); var a = random(360); u.dx = lengthdir_x(0.7, a); u.dy = lengthdir_y(0.7, a); }
	u.x += u.dx; u.y += u.dy + sin(current_time / 120 + i) * 0.3;
	// keep them in view
	if(u.x < vx || u.x > vx + vw || u.y < vy || u.y > vy + vh){ u.x = clamp(u.x, vx + 10, vx + vw - 10); u.y = clamp(u.y, vy + 10, vy + vh - 10); u.t = 0; }
}

// Fireflies: on summer (and late spring) nights, drifting low
var wantF = (night > 0.3 && (season == 1 || season == 0)) ? 14 : 0;
while(array_length(flies) < wantF) array_push(flies, {x: vx + random(vw), y: vy + random(vh), dx: 0, dy: 0, ph: random(10)});
if(array_length(flies) > wantF) array_resize(flies, wantF);
for(var i = 0; i < array_length(flies); i++){
	var fl = flies[i];
	fl.dx = clamp(fl.dx + random_range(-0.05, 0.05), -0.4, 0.4); fl.dy = clamp(fl.dy + random_range(-0.05, 0.05), -0.3, 0.3);
	fl.x += fl.dx; fl.y += fl.dy;
	if(fl.x < vx - 20 || fl.x > vx + vw + 20 || fl.y < vy - 20 || fl.y > vy + vh + 20){ fl.x = vx + random(vw); fl.y = vy + random(vh); }
}
