/// @description The lift: the floor picked (with its band, and a boss if one waits there), buttons to change it, go
/// and, in the mine, back to the surface
if(!menuOpen) exit;
var c = ui_colours();
var top = mine_lift_top(), here = inMine ? mine_state().floor : -1;
var gw = display_get_gui_width(), gh = display_get_gui_height();
var pw = 560, ph = 330;
var px = (gw - pw) / 2, py = (gh - ph) / 2, cx = gw / 2;
draw_set_font(fnt_eq);
draw_set_alpha(0.92);
draw_set_colour(c.panel);
draw_roundrect_ext(px, py, px + pw, py + ph, 14, 14, false);
draw_set_alpha(1);
ui_text(cx, py + 28, "The Lift", 0.8, c.accent);
ui_text(cx, py + 58, mine_lift_free() ? "Free mode: any floor" : ("Floors you've reached: 1 - " + string(top)), 0.45, c.dim);
ui_text(cx, py + 104, "Floor " + string(pick), 1.1, c_white);
var info = mine_band(pick).name;
if(mine_boss(pick) != "") info += "  -  a boss waits here";
if(pick == here) info += "  -  you are here";
ui_text(cx, py + 142, info, 0.45, c.dim);
// Up 5, up 1, down 1, down 5 (the font has no minus sign)
var steps = [-MINE_LIFT_EVERY, -1, 1, MINE_LIFT_EVERY], bw = 90, gap = 14;
var bx0 = cx - (4 * bw + 3 * gap) / 2;
for(var i = 0; i < 4; i++){
	var bx = bx0 + i * (bw + gap), s = steps[i];
	var lab = ((s > 0) ? "Down " : "Up ") + string(abs(s));
	if(ui_button(bx, py + 168, bx + bw, py + 204, lab, clamp(pick + s, 1, top) != pick, 0.5)) pick = clamp(pick + s, 1, top);
}
// Go, and the surface from inside the mine
var gwid = inMine ? 160 : 220;
if(inMine){
	if(ui_button(cx - gwid - 8, py + 222, cx - 8, py + 266, (pick < here) ? "Go up" : "Go down", pick != here, 0.6)){ menuOpen = false; mine_goto(pick); }
	if(ui_button(cx + 8, py + 222, cx + gwid + 8, py + 266, "Surface", true, 0.6)){ menuOpen = false; mine_leave(); }
} else if(ui_button(cx - gwid / 2, py + 222, cx + gwid / 2, py + 266, "Go down", true, 0.6)){ menuOpen = false; mine_goto(pick); }
ui_text(cx, py + ph - 26, "Left / Right: 1 floor    Up / Down: 5 floors    Enter: go    Esc: close", 0.38, c.dim);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
