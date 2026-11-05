/// @description Fly; stop at walls; hit the first monster it reaches. A boomerang (weapon.returns) flies out to its
/// range or a wall, then back to its owner, hitting every monster it passes once on the way out and once on the way back.
if(instance_exists(obj_inventory) || instance_exists(obj_menu)) exit;
var boomer = weapon[$ "returns"] ?? false;
if(boomer && back){
	// Home in on the thrower; caught when it reaches them
	if(!instance_exists(owner)){ instance_destroy(); exit; }
	var tx = owner.x, ty = owner.y - 20, sp = point_distance(0, 0, dx, dy);
	if(point_distance(x, y, tx, ty) <= sp + 4){ instance_destroy(); exit; }
	var dir = point_direction(x, y, tx, ty);
	dx = lengthdir_x(sp, dir);
	dy = lengthdir_y(sp, dir);
}
x += dx;
y += dy;
spin += 24;
var gy = y + 20;
// Walls and buildings stop it; rocks and trees don't (it flies over them). A boomerang flies back through them.
var wall = false;
if(!(boomer && back)){
	wall = collision_point(x, gy, obj_col_box, false, true) != noone && collision_point(x, gy, obj_resource, false, true) == noone;
	if(variable_global_exists("mineWalls") && global.mineWalls != -1 && tilemap_get_at_pixel(global.mineWalls, x, gy) > 0) wall = true;
}
if(boomer){
	if(!back && (--life <= 0 || wall)){ back = true; hits = []; }
	with(obj_monster){
		if(dying || array_get_index(other.hits, id) != -1) continue;
		if(point_distance(other.x, gy, x, y - 4) < 18){ monster_damage(id, other.weapon, other.ang); array_push(other.hits, id); }
	}
	exit;
}
if(--life <= 0 || wall){ instance_destroy(); exit; }
var m = instance_nearest(x, gy, obj_monster);
if(m != noone && !m.dying && point_distance(x, gy, m.x, m.y - 4) < 16){
	monster_damage(m, weapon, ang);
	instance_destroy();
}
