/// @description The tram's stops: one button each (click or Up / Down and Enter)
if(!menuOpen) exit;
var c = ui_colours();
var others = transit_others(kind, stop), n = array_length(others);
var gw = display_get_gui_width(), gh = display_get_gui_height();
var pw = 480, ph = 130 + n * 50;
var px = (gw - pw) / 2, py = (gh - ph) / 2, cx = gw / 2;
draw_set_font(fnt_eq);
draw_set_alpha(0.92);
draw_set_colour(c.panel);
draw_roundrect_ext(px, py, px + pw, py + ph, 14, 14, false);
draw_set_alpha(1);
ui_text(cx, py + 28, "The Tram  -  " + stop, 0.7, c.accent);
ui_text(cx, py + 56, "Fare " + string(transit_fare(kind)) + " gold   (you have " + string(global.inv.gold) + ")", 0.42, c.dim);
for(var i = 0; i < n; i++){
	var by = py + 78 + i * 50;
	if(ui_button(cx - 180, by, cx + 180, by + 40, ((i == pick) ? "[ " + others[i].name + " ]" : others[i].name), true, 0.55)){
		menuOpen = false;
		message = transit_ride(others[i]);
		messageTime = (message != "") ? 180 : 0;
	}
}
ui_text(cx, py + ph - 22, "Up / Down: choose    Enter: go    Esc: close", 0.38, c.dim);
