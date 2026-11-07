/// @description The prompt over the station, and what it says when it doesn't run (or you can't pay)
if(!near && messageTime <= 0) exit;
if(menuOpen) exit;
draw_set_font(fnt_eq);
draw_set_halign(fa_center);
draw_set_valign(fa_bottom);
var t;
if(messageTime > 0) t = message;
else if(!transit_runs(kind)) t = key_label("interact") + " " + ((kind == "cable") ? "Cable car" : "Tram stop") + ": " + stop;
else if(kind == "cable") t = key_label("interact") + " Ride the cable car to " + transit_others(kind, stop)[0].name + " (" + string(transit_fare(kind)) + "g)";
else t = key_label("interact") + " Take the tram (" + string(transit_fare(kind)) + "g)";
var col = (messageTime > 0) ? c_white : c_yellow;
draw_text_transformed_colour(x + 1, y - 69, t, 0.3 * wtx(), 0.3 * wtx(), 0, c_black, c_black, c_black, c_black, 0.7);
draw_text_transformed_colour(x, y - 70, t, 0.3 * wtx(), 0.3 * wtx(), 0, col, col, col, col, 1);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
