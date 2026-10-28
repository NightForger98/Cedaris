/// @description The board: today's requests (Accept) and the ones you've taken (Hand in when done)
if(!open) exit;
var c = ui_colours();
var gw = display_get_gui_width(), gh = display_get_gui_height();
var x1 = gw / 2 - 470, y1 = 70, x2 = gw / 2 + 470, y2 = gh - 60;
draw_set_font(fnt_eq);
draw_set_alpha(0.55);
draw_rectangle_colour(0, 0, gw, gh, c_black, c_black, c_black, c_black, false);
draw_set_alpha(0.95);
draw_set_colour(c.panel);
draw_roundrect_ext(x1, y1, x2, y2, 16, 16, false);
draw_set_alpha(1);
ui_text((x1 + x2) / 2, y1 + 32, "Notice Board", 0.85, c.accent);

var st = quests_state();
var rowH = 74, ry = y1 + 80;
var row = function(_q, _y, _x1, _x2, _c){
	var v = villager_def(_q.who);
	ui_text(_x1 + 24, _y + 14, v.name + ":  " + _q.text, 0.55, c_white, fa_left);
	ui_text(_x1 + 24, _y + 40, quest_goal_text(_q), 0.48, quest_ready(_q) ? make_colour_rgb(150, 230, 120) : _c.dim, fa_left);
	ui_text(_x2 - 170, _y + 40, quest_reward_text(_q), 0.45, _c.accent, fa_right);
};

ui_text(x1 + 24, ry, "Today's requests", 0.6, c.accent, fa_left);
ry += 24;
var offers = quests_offers();
if(array_length(offers) == 0){ ui_text(x1 + 24, ry + 20, "Nothing new today. Come back tomorrow.", 0.5, c.dim, fa_left); ry += 50; }
for(var i = 0; i < array_length(offers); i++){
	row(offers[i], ry, x1, x2, c);
	if(ui_button(x2 - 150, ry + 14, x2 - 24, ry + 52, "Accept", array_length(st.active) < QUESTS_ACTIVE_MAX, 0.5)){
		var why = quest_accept(i);
		message = (why == "") ? "Request taken" : why;
		messageTime = 150;
		break;
	}
	ry += rowH;
}

ry += 16;
ui_text(x1 + 24, ry, "Your requests  (" + string(array_length(st.active)) + "/" + string(QUESTS_ACTIVE_MAX) + ")", 0.6, c.accent, fa_left);
ry += 24;
if(array_length(st.active) == 0) ui_text(x1 + 24, ry + 20, "None yet.", 0.5, c.dim, fa_left);
for(var i = 0; i < array_length(st.active); i++){
	row(st.active[i], ry, x1, x2, c);
	if(ui_button(x2 - 150, ry + 14, x2 - 24, ry + 52, "Hand in", quest_ready(st.active[i]), 0.5)){
		message = quest_hand_in(i);
		messageTime = 200;
		break;
	}
	ry += rowH;
}

if(messageTime > 0) ui_text((x1 + x2) / 2, y2 - 54, message, 0.55, c_white);
ui_text((x1 + x2) / 2, y2 - 22, "E or Esc to close   -   " + string(st.done) + " requests done", 0.45, c.dim);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
