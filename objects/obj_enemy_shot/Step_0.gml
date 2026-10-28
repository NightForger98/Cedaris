/// @description Fly; stop at walls; hit the player
if(ui_blocking() || instance_exists(obj_menu) || game.doTransition) exit;
x += dx;
y += dy;
spin += 0.3;
var gy = y + 20;
var wall = variable_global_exists("mineWalls") && global.mineWalls != -1 && tilemap_get_at_pixel(global.mineWalls, x, gy) > 0;
if(--life <= 0 || wall){ instance_destroy(); exit; }
if(instance_exists(obj_plyr) && point_distance(x, gy, obj_plyr.x, obj_plyr.y - 6) < 14){
	var landed = obj_plyr.iframes <= 0;
	player_hurt(dmg, x - dx * 4, gy - dy * 4);
	// A witch's bolts: green poisons, black curses your tool (status script)
	if(landed && kind == "poison") status_poison(14);
	if(landed && kind == "curse") status_curse();
	instance_destroy();
}
