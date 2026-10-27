/// @description Tilled soil darkens with furrows; watered soil darkens more
var tiles = farm_tiles();
var keys = variable_struct_get_names(tiles);
var cs = crops.cellSize;
for(var i = 0; i < array_length(keys); i++){
	var p = string_split(keys[i], "_");
	var x1 = real(p[0]) * cs, y1 = real(p[1]) * cs;
	draw_set_alpha(tiles[$ keys[i]].watered ? 0.55 : 0.35);
	draw_set_colour(tiles[$ keys[i]].watered ? make_colour_rgb(40, 22, 12) : make_colour_rgb(70, 40, 20));
	draw_roundrect_ext(x1 + 1, y1 + 1, x1 + cs - 2, y1 + cs - 2, 6, 6, false);
	draw_set_alpha(0.35);
	draw_set_colour(make_colour_rgb(30, 15, 8));
	for(var f = 1; f < 4; f++) draw_line(x1 + 4, y1 + f * cs / 4, x1 + cs - 5, y1 + f * cs / 4);
}
draw_set_alpha(1);
draw_set_colour(c_white);
