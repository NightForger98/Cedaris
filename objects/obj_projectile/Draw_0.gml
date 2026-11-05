/// @description A stone, a bolt or arrow, or a spinning boomerang, with a shadow on the ground
draw_set_alpha(0.3);
draw_set_colour(c_black);
draw_ellipse(x - 3, y + 18, x + 3, y + 22, false);
draw_set_alpha(1);
draw_set_colour(make_colour_rgb(200, 195, 185));
if(weapon[$ "returns"] ?? false){
	draw_set_colour(c_white);
	var s = projectile_boomerang_surface();
	draw_surface_ext(s, x + lengthdir_x(12, spin + 135) * 1.414, y + lengthdir_y(12, spin + 135) * 1.414, 1, 1, spin, c_white, 1);
	exit;
}
if(weapon[$ "fire"] ?? false){
	draw_set_colour(make_colour_rgb(255, 120, 40));
	draw_circle(x, y, 5, false);
	draw_set_colour(make_colour_rgb(255, 230, 120));
	draw_circle(x, y, 2.5, false);
}
else if(weapon.ammo == "m|stone") draw_circle(x, y, 3, false);
else draw_line_width(x - dx * 1.2, y - dy * 1.2, x + dx * 0.4, y + dy * 0.4, 2);
draw_set_colour(c_white);
