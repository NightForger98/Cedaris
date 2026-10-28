/// @description The line's status, and when a fish bites, the bar with its green zone and the sweeping marker
var c = ui_colours();
var gw = display_get_gui_width(), gh = display_get_gui_height();
var w = 420, h = 96, x1 = (gw - w) / 2, y1 = gh - h - 60;
draw_set_font(fnt_eq);
draw_set_alpha(0.9);
draw_set_colour(c.panel);
draw_roundrect_ext(x1, y1, x1 + w, y1 + h, 12, 12, false);
draw_set_alpha(1);
if(state == "wait"){
	ui_text(gw / 2, y1 + h / 2 - 10, "Waiting for a bite...", 0.6, c_white);
	ui_text(gw / 2, y1 + h / 2 + 20, "Esc to reel in", 0.42, c.dim);
} else {
	ui_text(gw / 2, y1 + 22, "A bite!  Space when the marker's in the green", 0.5, c.accent);
	var bx = x1 + 24, bw = w - 48, by = y1 + 46;
	draw_set_colour(merge_colour(c.panel, c_black, 0.5));
	draw_rectangle(bx, by, bx + bw, by + 28, false);
	draw_set_colour(make_colour_rgb(110, 200, 90));
	draw_rectangle(bx + bw * zoneAt, by, bx + bw * (zoneAt + zone), by + 28, false);
	draw_set_colour(c_white);
	draw_rectangle(bx + bw * marker - 2, by - 6, bx + bw * marker + 2, by + 34, false);
}
draw_set_halign(fa_left);
draw_set_valign(fa_top);
