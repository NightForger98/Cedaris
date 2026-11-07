/// @description Skills on the left, attributes on the right
var c = ui_colours();
draw_set_font(fnt_eq);
draw_set_alpha(0.7);
draw_set_colour(c_black);
draw_rectangle(0, 0, guiW, guiH, false);
var px1 = guiW / 2 - 640, px2 = guiW / 2 + 640, py1 = 40, py2 = guiH - 40;
draw_set_alpha(0.96);
draw_set_colour(c.panel);
draw_roundrect_ext(px1, py1, px2, py2, 18, 18, false);
draw_set_alpha(1);
ui_text(guiW / 2, py1 + 32, "Character  -  level " + string(skill_total_level()), 0.8, c.accent);

// ---------------------------------------------------------------- skills
var sx = px1 + 30, sw = 700, k = skill_keys(), t = skill_table(), xpT = skill_xp_table();
ui_text(sx, py1 + 76, "Skills", 0.62, c.accent, fa_left);
var rowH = (py2 - py1 - 130) / 5;
for(var i = 0; i < array_length(k); i++){
	var key = k[i], d = t[$ key], s = skill_state(key), lv = skill_level(key);
	var y1 = py1 + 100 + i * rowH;
	draw_set_colour(merge_colour(c.panel, c_black, 0.25));
	draw_roundrect_ext(sx, y1, sx + sw, y1 + rowH - 10, 10, 10, false);
	ui_text(sx + 16, y1 + 20, d.name + "  " + string(lv) + " / 10", 0.58, c_white, fa_left);
	// the experience bar to the next level
	var lo = (lv == 0) ? 0 : xpT[lv - 1], hi = (lv >= 10) ? xpT[9] : xpT[lv];
	var f = (lv >= 10) ? 1 : clamp((s.xp - lo) / (hi - lo), 0, 1);
	var bx = sx + 250, bw = 300;
	draw_set_colour(c_black); draw_rectangle(bx, y1 + 12, bx + bw, y1 + 28, false);
	draw_set_colour(make_colour_rgb(110, 200, 120)); draw_rectangle(bx + 2, y1 + 14, bx + 2 + (bw - 4) * f, y1 + 26, false);
	ui_text(bx + bw + 12, y1 + 20, (lv >= 10) ? "max" : string(s.xp) + " / " + string(hi) + " xp", 0.4, c.dim, fa_left);
	ui_text(sx + 16, y1 + 46, d.how + "  -  " + d.perk, 0.4, c.dim, fa_left);
	// specialisations: chosen, or two buttons to choose from
	var tiers = [5, 10];
	for(var tt = 0; tt < 2; tt++){
		var tier = tiers[tt], have = (tier == 5) ? s.spec5 : s.spec10, opts = (tier == 5) ? d.spec5 : d.spec10;
		var ly = y1 + 72 + tt * 30;
		if(ly > y1 + rowH - 22) break;
		if(have != ""){
			var nm = "";
			for(var o = 0; o < 2; o++) if(opts[o][0] == have) nm = opts[o][1] + ": " + opts[o][2];
			ui_text(sx + 16, ly, "Lv " + string(tier) + "  " + nm, 0.4, c.accent, fa_left);
		} else if(lv >= tier){
			ui_text(sx + 16, ly, "Lv " + string(tier) + "  choose:", 0.4, c.accent, fa_left);
			for(var o = 0; o < 2; o++){
				var b1 = sx + 120 + o * 290;
				if(ui_button(b1, ly - 13, b1 + 280, ly + 13, opts[o][1], true, 0.4)){
					skill_choose(key, tier, opts[o][0]);
					message = opts[o][1] + ": " + opts[o][2];
					messageTime = 240;
				}
			}
		} else ui_text(sx + 16, ly, "Lv " + string(tier) + "  " + opts[0][1] + " or " + opts[1][1], 0.38, c.dim, fa_left);
	}
}

// ---------------------------------------------------------------- attributes
var ax = sx + sw + 30, aw = px2 - 30 - ax, at = attr_table(), ak = attr_keys();
ui_text(ax, py1 + 76, "Attributes  -  " + string(attr_points_free()) + " point" + ((attr_points_free() == 1) ? "" : "s") + " to spend", 0.62, c.accent, fa_left);
for(var i = 0; i < array_length(ak); i++){
	var y1 = py1 + 104 + i * 74, a = at[$ ak[i]];
	draw_set_colour(merge_colour(c.panel, c_black, 0.25));
	draw_roundrect_ext(ax, y1, ax + aw, y1 + 66, 10, 10, false);
	ui_text(ax + 16, y1 + 20, a.name + "  " + string(attr(ak[i])), 0.56, c_white, fa_left);
	ui_text(ax + 16, y1 + 46, a.desc, 0.36, c.dim, fa_left);
	if(ui_button(ax + aw - 60, y1 + 6, ax + aw - 12, y1 + 34, "+", attr_points_free() > 0, 0.6)){
		var why = attr_spend(ak[i]);
		if(why != ""){ message = why; messageTime = 180; }
	}
}
// what they come to
var yy = py1 + 104 + 6 * 74 + 10;
ui_text(ax, yy, "Health " + string(vitals_max_health()) + "   Energy " + string(vitals_max_energy()) + "   Melee x" + string_format(attr_melee_mult(), 1, 2)
                + "   Attack speed +" + string(round((attr_attack_speed() - 1) * 100)) + "%   Dodge " + string(round(attr_dodge() * 100)) + "%", 0.4, c_white, fa_left);
var dk = dance_known(), dl = "";
for(var i = 0; i < array_length(dk); i++) dl += ((dl != "") ? ", " : "") + dance_table()[$ dk[i]].name;
ui_text(ax, yy + 28, "Dances: " + ((dl == "") ? "none yet (Ayla teaches at the tavern, evenings)" : dl + "  (" + key_label("dance") + " to dance)"), 0.4, c_white, fa_left);
ui_text(ax, yy + 56, "Strength for metal gear: Copper 0, Iron 4, Steel 8, Silver 12, Gold 16, Mithril 22", 0.36, c.dim, fa_left);

if(messageTime > 0) ui_text(guiW / 2, py2 - 46, message, 0.5, c.accent);
ui_text(guiW / 2, py2 - 18, key_label("skills") + " / Esc  Close     Every skill level gives an attribute point", 0.42, c.dim);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
