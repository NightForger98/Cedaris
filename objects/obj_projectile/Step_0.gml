/// @description Fly; stop at walls; hit the first monster it reaches
if(instance_exists(obj_inventory) || instance_exists(obj_menu)) exit;
x += dx;
y += dy;
var gy = y + 20;
// Walls and buildings stop it; rocks and trees don't (it flies over them)
var wall = collision_point(x, gy, obj_col_box, false, true) != noone && collision_point(x, gy, obj_resource, false, true) == noone;
if(variable_global_exists("mineWalls") && global.mineWalls != -1 && tilemap_get_at_pixel(global.mineWalls, x, gy) > 0) wall = true;
if(--life <= 0 || wall){ instance_destroy(); exit; }
var m = instance_nearest(x, gy, obj_monster);
if(m != noone && !m.dying && point_distance(x, gy, m.x, m.y - 4) < 16){
	monster_damage(m, weapon, ang);
	instance_destroy();
}
