/// @description Each kind of shot its own way, with a shadow on the ground
draw_set_alpha(0.3);
draw_set_colour(c_black);
draw_ellipse(x - 3, y + 18, x + 3, y + 22, false);
draw_set_alpha(1);
switch(kind){
	case "slime":
		// The slime-spit sheet from [LPC] Monsters: 4 frames of 16 x 16
		draw_sprite_part(spr_mon_slime_shot, 0, (floor(spin) mod 4) * 16, 0, 16, 16, x - 8, y - 8);
		break;
	case "spear":
		draw_set_colour(make_colour_rgb(140, 100, 60));
		draw_line_width(x - dx * 3, y - dy * 3, x + dx, y + dy, 2);
		draw_set_colour(make_colour_rgb(200, 205, 215));
		draw_line_width(x + dx * 0.4, y + dy * 0.4, x + dx * 1.4, y + dy * 1.4, 3);
		break;
	case "ice":
		draw_set_colour(make_colour_rgb(170, 220, 255));
		draw_circle(x, y, 6, false);
		draw_set_colour(c_white);
		draw_circle(x - 1, y - 1, 2.5, false);
		break;
	case "fire":
		draw_set_colour(make_colour_rgb(255, 110, 30));
		draw_circle(x, y, 7, false);
		draw_set_colour(make_colour_rgb(255, 220, 110));
		draw_circle(x, y, 3.5, false);
		break;
	case "poison":
	case "curse":
		// A witch's bolt: a glowing orb with a fading trail - green (poison) or black with a purple rim (curse)
		var core = (kind == "poison") ? make_colour_rgb(120, 230, 90) : make_colour_rgb(20, 10, 30);
		var rim = (kind == "poison") ? make_colour_rgb(40, 120, 30) : make_colour_rgb(170, 80, 230);
		for(var t = 4; t >= 1; t--){
			draw_set_alpha(0.15 * (5 - t));
			draw_set_colour(rim);
			draw_circle(x - dx * t * 2, y - dy * t * 2, 5 - t * 0.8, false);
		}
		draw_set_alpha(1);
		draw_set_colour(rim);
		draw_circle(x, y, 6 + sin(spin) * 0.8, false);
		draw_set_colour(core);
		draw_circle(x, y, 4, false);
		break;
	default: // a watcher's bolt
		draw_set_colour(make_colour_rgb(200, 120, 255));
		draw_circle(x, y, 4.5, false);
		draw_set_colour(c_white);
		draw_circle(x, y, 2, false);
}
draw_set_colour(c_white);
