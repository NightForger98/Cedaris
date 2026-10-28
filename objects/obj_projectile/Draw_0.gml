/// @description A stone or bolt, with a shadow on the ground
draw_set_alpha(0.3);
draw_set_colour(c_black);
draw_ellipse(x - 3, y + 18, x + 3, y + 22, false);
draw_set_alpha(1);
draw_set_colour(make_colour_rgb(200, 195, 185));
if(weapon.ammo == "m|stone") draw_circle(x, y, 3, false);
else draw_line_width(x - dx * 1.2, y - dy * 1.2, x + dx * 0.4, y + dy * 0.4, 2);
draw_set_colour(c_white);
