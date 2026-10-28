/// @description The board: Requests (today's offers and the ones you've taken) and Projects (rebuilding the valley)
if(!open) exit;
var c = ui_colours();
var gw = display_get_gui_width(), gh = display_get_gui_height();
var x1 = gw / 2 - 470, y1 = 60, x2 = gw / 2 + 470, y2 = gh - 40;
draw_set_font(fnt_eq);
draw_set_alpha(0.55);
draw_rectangle_colour(0, 0, gw, gh, c_black, c_black, c_black, c_black, false);
draw_set_alpha(0.95);
draw_set_colour(c.panel);
draw_roundrect_ext(x1, y1, x2, y2, 16, 16, false);
draw_set_alpha(1);
ui_text(x1 + 30, y1 + 32, "Notice Board", 0.85, c.accent, fa_left);
// Tabs
if(ui_button(x2 - 330, y1 + 14, x2 - 180, y1 + 50, "Requests", page != "requests", 0.5)) page = "requests";
if(ui_button(x2 - 170, y1 + 14, x2 - 20, y1 + 50, "Projects", page != "projects", 0.5)) page = "projects";
// On a festival day: its page too
var fest = festival_today();
if(fest != undefined && ui_button(x2 - 490, y1 + 14, x2 - 340, y1 + 50, "Festival", page != "festival", 0.5)) page = "festival";
if(fest == undefined && page == "festival") page = "requests";

var st = quests_state();
var ry = y1 + 80;

if(page == "festival"){
	// Today's festival: what it is, and its event
	ui_text(x1 + 24, ry + 10, fest.name + "  -  " + season_name(fest.season) + " " + string(fest.day), 0.75, c.accent, fa_left);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_colour(c_white);
	draw_text_ext_transformed(x1 + 24, ry + 40, fest.desc, 34, (x2 - x1 - 48) / 0.55, 0.55, 0.55, 0);
	var label = "", done = festival_done(fest);
	switch(fest.kind){
		case "shop":     label = "Browse the stalls"; break;
		case "lanterns": label = done ? "Your lantern is lit" : "Light a lantern (50 gold)"; break;
		case "contest":  label = done ? "You've entered" : "Enter your best crop"; break;
	}
	if(ui_button((x1 + x2) / 2 - 170, ry + 150, (x1 + x2) / 2 + 170, ry + 200, label, fest.kind == "shop" || !done, 0.6)){
		if(fest.kind == "shop"){
			open = false;
			var shopInv = instance_create_depth(0, 0, -9000, obj_inventory);
			shopInv.shop = true;
			shopInv.shopStock = festival_stock(fest);
			shopInv.shopTitle = fest.name;
		} else {
			message = (fest.kind == "lanterns") ? festival_light_lantern(fest) : festival_weigh_in(fest);
			messageTime = 300;
		}
	}
} else if(page == "requests"){
	var rowH = 74;
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
} else {
	// Projects: each with its story, a progress bar, and what it still needs (Give hands in what you have)
	var t = project_table();
	for(var i = 0; i < array_length(t); i++){
		var d = t[i], p = project_state(d.key);
		var locked = (d.key == "shrine" && !project_done("bridge"));
		ui_text(x1 + 24, ry + 10, locked ? "???" : d.name + "  (" + villager_def(d.who).name + ")", 0.6, p.done ? make_colour_rgb(150, 230, 120) : c_white, fa_left);
		// Progress bar
		var bx = x2 - 220, bw = 196, f = project_progress(d.key);
		draw_set_colour(merge_colour(c.panel, c_black, 0.4));
		draw_rectangle(bx, ry + 4, bx + bw, ry + 16, false);
		draw_set_colour(p.done ? make_colour_rgb(150, 230, 120) : c.accent);
		if(f > 0) draw_rectangle(bx, ry + 4, bx + bw * f, ry + 16, false);
		if(locked){
			ui_text(x1 + 24, ry + 36, "Somewhere past the broken bridge...", 0.45, c.dim, fa_left);
			ry += 70;
			continue;
		}
		ui_text(x1 + 24, ry + 34, p.done ? "Done: " + d.reward + "." : d.desc, 0.42, c.dim, fa_left);
		if(!p.done){
			for(var k = 0; k < array_length(d.need); k++){
				var key = d.need[k][0], need = d.need[k][1], got = p.given[$ key] ?? 0;
				var cx = x1 + 24 + k * 180, cy = ry + 52;
				item_draw_icon(item_stack(project_item_id(key)), cx, cy, 34, global.look.body);
				ui_text(cx + 40, cy + 17, string(got) + "/" + string(need), 0.45, (got >= need) ? make_colour_rgb(150, 230, 120) : c_white, fa_left);
				if(got < need && ui_button(cx + 100, cy + 4, cx + 166, cy + 32, "Give", project_have(key) > 0 || inv_is_free(), 0.4)){
					message = project_give(d.key, key);
					messageTime = 200;
				}
			}
			ry += 40;
		}
		ry += 74;
	}
}

if(messageTime > 0) ui_text((x1 + x2) / 2, y2 - 54, message, 0.55, c_white);
ui_text((x1 + x2) / 2, y2 - 22, "E or Esc to close   -   " + string(st.done) + " requests done", 0.45, c.dim);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
