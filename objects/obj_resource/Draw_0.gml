/// @description Draw the art from the terrain tileset with its ground point on the cell; veins get ore specks
var a = def.art;
var sc = def[$ "scale"] ?? 1;
var wob = (shake > 0) ? sin(shake * 1.7) * shake * 0.25 : 0;
var x1 = round(x - def.anchor[0] * sc + wob), y1 = round(y - def.anchor[1] * sc);
draw_sprite_part_ext(spr_tile_terrain, 0, a[0], a[1], a[2], a[3], x1, y1, sc, sc, def[$ "tint"] ?? c_white, 1);
if(variable_struct_exists(def, "ore")){
	// Specks of ore on the rock face, placed from the cell so they don't move between visits
	var dark = merge_colour(def.ore, c_black, 0.5);
	for(var i = 0; i < 6; i++){
		var h = (data.gx * 73 + data.gy * 151 + i * 97) mod 1000;
		var sx = x1 + round((12 + (h mod 31)) * sc), sy = y1 + round((12 + ((h div 31) mod 22)) * sc);
		draw_set_colour(dark);
		draw_rectangle(sx - 1, sy - 1, sx + 2, sy + 2, false);
		draw_set_colour(def.ore);
		draw_rectangle(sx, sy, sx + 1, sy + 1, false);
	}
	draw_set_colour(c_white);
}
