/// @description Bunting across the square; on Lantern Night, lanterns drifting down the river after dusk
if(fest == undefined) exit;
var cols = [make_colour_rgb(230, 80, 80), make_colour_rgb(250, 200, 70), make_colour_rgb(110, 190, 230), make_colour_rgb(150, 220, 110), make_colour_rgb(230, 140, 220)];
// Two strings across the square (its area in the village's layout), sagging in the middle
var sq = layout_area("rm_downtown", "square");
var x1 = sq[0], span = sq[2] - sq[0], flags = floor(span / 31);
for(var row = 0; row < 2; row++){
	var y0 = sq[1] + 64 + row * (sq[3] - sq[1]) * 0.45;
	draw_set_colour(make_colour_rgb(90, 70, 50));
	for(var bx = x1; bx < x1 + span; bx += 6) draw_point(bx, y0 + sin((bx - x1) / span * pi) * 18);
	for(var i = 0; i < flags; i++){
		var fx = x1 + 10 + i * 31, fy = y0 + sin((fx - x1) / span * pi) * 18;
		draw_set_colour(cols[(i + row) mod array_length(cols)]);
		draw_triangle(fx - 7, fy, fx + 7, fy, fx, fy + 12 + sin(current_time / 300 + i) * 1.5, false);
	}
}
if(fest.kind == "lanterns" && global.clock.minutes >= 1080){
	var river = layout_point("rm_downtown", "river");
	for(var i = 0; i < 9; i++){
		var t = ((current_time / 9000 + i / 9) mod 1);
		var lx = river[0] + sin(t * 6 + i) * 14, ly = river[1] + t * room_height;
		draw_set_alpha(0.35);
		draw_set_colour(make_colour_rgb(255, 190, 90));
		draw_circle(lx, ly, 10, false);
		draw_set_alpha(1);
		draw_set_colour(make_colour_rgb(250, 160, 70));
		draw_rectangle(lx - 3, ly - 4, lx + 3, ly + 3, false);
	}
}
draw_set_colour(c_white);
