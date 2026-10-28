/// @description The sprinkler; first thing in the morning it sprays its patch
placeable_draw(data.kind, x, y + 4, 1);
var d = placeable_def(data.kind);
if(world_time_ready() && global.clock.minutes < DAY_START + 40 && variable_struct_exists(d, "range")){
	draw_set_colour(make_colour_rgb(150, 200, 255));
	draw_set_alpha(0.6);
	var r = (d.range + 0.5) * RES_CELL;
	for(var i = 0; i < 16; i++){
		var a = i * 22.5 + current_time / 6, t = ((current_time / 400 + i * 0.37) mod 1);
		draw_circle(x + lengthdir_x(r * t, a), y - 12 + lengthdir_y(r * t, a) * 0.6 + t * 10, 1.5, false);
	}
	draw_set_alpha(1);
	draw_set_colour(c_white);
}
