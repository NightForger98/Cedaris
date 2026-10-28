/// @description The lift: a button for floor 1 and every 5th floor you've reached
if(!menuOpen) exit;
var c = ui_colours();
var floors = mine_lift_floors();
var gw = display_get_gui_width(), gh = display_get_gui_height();
var bw = 150, bh = 44, cols = min(4, array_length(floors)), rows = ceil(array_length(floors) / 4);
var pw = cols * (bw + 12) + 36, ph = rows * (bh + 12) + 110;
var px = (gw - pw) / 2, py = (gh - ph) / 2;
draw_set_font(fnt_eq);
draw_set_alpha(0.92);
draw_set_colour(c.panel);
draw_roundrect_ext(px, py, px + pw, py + ph, 14, 14, false);
draw_set_alpha(1);
ui_text(gw / 2, py + 30, "The Lift", 0.8, c.accent);
for(var i = 0; i < array_length(floors); i++){
	var bx = px + 24 + (i mod 4) * (bw + 12), by = py + 60 + (i div 4) * (bh + 12);
	if(ui_button(bx, by, bx + bw, by + bh, "Floor " + string(floors[i]), true, 0.55)){ menuOpen = false; mine_goto(floors[i]); }
}
ui_text(gw / 2, py + ph - 22, "Esc to close", 0.45, c.dim);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
