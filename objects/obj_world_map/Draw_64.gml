/// @description The map, scaled to fit the screen: room names, you, and a label for the building under the mouse
var c = ui_colours(), m = world_map();
var s = min((guiW - 160) / m.w, (guiH - 190) / m.h);
var mx = (guiW - m.w * s) / 2, my = 90 + (guiH - 190 - m.h * s) / 2;

draw_set_alpha(0.7);
draw_set_colour(c_black);
draw_rectangle(0, 0, guiW, guiH, false);
draw_set_alpha(0.96);
draw_set_colour(c.panel);
draw_roundrect_ext(mx - 24, my - 64, mx + m.w * s + 24, my + m.h * s + 56, 18, 18, false);
draw_set_alpha(1);
draw_set_font(fnt_eq);
ui_text(guiW / 2, my - 34, "World Map", 0.8, c.accent);
draw_sprite_ext(spr_world_map, 0, mx, my, s, s, 0, c_white, 1);
forest_draw_on_map(mx, my, s); // the real Whisperwood (the map tool only has a stand-in)

// Each place's name over its top edge
var names = variable_struct_get_names(m.rooms);
for(var i = 0; i < array_length(names); i++){
	var r = m.rooms[$ names[i]];
	var tx = mx + (r[0] + r[2] / 2) * s, ty = my + r[1] * s + 18;
	ui_text(tx + 2, ty + 2, save_room_name(names[i]), 0.6, c_black);
	ui_text(tx, ty, save_room_name(names[i]), 0.6, c_white);
}
var cave = m.inside.rm_mine;
ui_text(mx + cave[0] * s + 2, my + cave[1] * s + 16, "The Mine", 0.45, c_black);   // under the cave, clear of the farm's name
ui_text(mx + cave[0] * s, my + cave[1] * s + 14, "The Mine", 0.45, make_colour_rgb(255, 220, 150));

// You: where you stand outdoors, or the door of the building you're in
var here = room_get_name(room), you = undefined;
var rr = m.rooms[$ here];
if(rr != undefined && instance_exists(obj_plyr)) you = [rr[0] + obj_plyr.x * m.scale, rr[1] + obj_plyr.y * m.scale];
else if(m.inside[$ here] != undefined) you = m.inside[$ here];
if(you != undefined){
	var px = mx + you[0] * s, py = my + you[1] * s, pulse = 7 + 2 * sin(current_time / 200);
	draw_set_colour(c_white);
	draw_circle(px, py, pulse + 3, false);
	draw_set_colour(make_colour_rgb(220, 50, 60));
	draw_circle(px, py, pulse, false);
	ui_text(px + 1, py - 22, "You", 0.5, c_black);
	ui_text(px, py - 23, "You", 0.5, c_white);
}

// The building under the mouse: outlined, with who lives (or works) there beside it
var gx = device_mouse_x_to_gui(0), gy = device_mouse_y_to_gui(0);
for(var b = 0; b < array_length(m.buildings); b++){
	var bd = m.buildings[b], q = bd.rect;
	var x1 = mx + q[0] * s, y1 = my + q[1] * s, x2 = x1 + q[2] * s, y2 = y1 + q[3] * s;
	if(testHover == bd.room){ gx = (x1 + x2) / 2; gy = (y1 + y2) / 2; }
	if(!point_in_rectangle(gx, gy, x1, y1, x2, y2)) continue;
	draw_set_colour(c.accent);
	draw_rectangle(x1, y1, x2, y2, true);
	draw_rectangle(x1 + 1, y1 + 1, x2 - 1, y2 - 1, true);
	var label = building_label(bd.room);
	var tw = string_width(label) * 0.5 + 28, th = 40;
	var bx = min(gx + 18, guiW - tw - 8), by = max(gy - th - 8, 8);
	draw_set_alpha(0.95);
	draw_set_colour(merge_colour(c.panel, c_black, 0.3));
	draw_roundrect_ext(bx, by, bx + tw, by + th, 10, 10, false);
	draw_set_alpha(1);
	draw_set_colour(c.accent);
	draw_roundrect_ext(bx, by, bx + tw, by + th, 10, 10, true);
	ui_text(bx + 14, by + th / 2, label, 0.5, c_white, fa_left);
	break;
}

ui_text(guiW / 2, my + m.h * s + 30, key_label("map") + " Close     Point at a building to see whose it is", 0.5, c.dim);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
