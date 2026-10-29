/// @description Amble about the meadow; E beside it pets it and collects what's ready
if(ui_blocking() || instance_exists(obj_menu) || game.doTransition) exit;
if(heartT > 0) heartT--;
near = interact_near(40);
if(near && input_pressed(key_of("interact")) && interact_ready()){
	farm_message(animal_tend(data));
	heartT = 50;
	moveX = 0;
	moveY = 0;
	wanderT = 90;
}
if(--wanderT <= 0){
	wanderT = irandom_range(60, 200);
	var w = choose(-1, -1, 0, 1, 2, 3);
	moveX = 0;
	moveY = 0;
	if(w >= 0){ dirIdx = w; moveX = [0, -1, 0, 1][w] * def.speed; moveY = [-1, 0, 1, 0][w] * def.speed; }
}
// Stay in the meadow, and out of the way of walls and people
var p = animal_pasture();
var nx = clamp(x + moveX, p[0], p[2]), ny = clamp(y + moveY, p[1], p[3]);
if(collision_point(nx, ny, obj_col_box, false, true) == noone){ x = nx; y = ny; } else { moveX = 0; moveY = 0; }
if(moveX != 0 || moveY != 0) frame += 0.08;
depth_sort();
