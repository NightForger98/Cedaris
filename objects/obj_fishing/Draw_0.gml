/// @description The bobber on the water: it bobs while waiting, and dips when something bites
var dip = (state == "bite") ? 3 + sin(current_time / 60) * 2 : sin(current_time / 300) * 1.5;
draw_set_colour(c_white);
draw_set_alpha(0.5);
draw_ellipse(bobX - 7, bobY - 2 + dip, bobX + 7, bobY + 3 + dip, true);
draw_set_alpha(1);
draw_set_colour(make_colour_rgb(220, 50, 40));
draw_circle(bobX, bobY - 3 + dip, 3, false);
draw_set_colour(c_white);
draw_circle(bobX, bobY - 5 + dip, 1.5, false);
if(instance_exists(obj_plyr)){
	draw_set_alpha(0.6);
	draw_line(obj_plyr.x, obj_plyr.y - 50, bobX, bobY - 4 + dip);
	draw_set_alpha(1);
}
