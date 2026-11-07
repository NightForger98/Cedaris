/// @description The sign's menu: the kind of shop, then the building (with a picture of the one chosen)
if(!menuOpen) exit;
var c = ui_colours();
var list = pshop_plot_menu_list(id), n = array_length(list), cols = (n > 10) ? 2 : 1, rows = ceil(n / cols);
var gw = display_get_gui_width(), gh = display_get_gui_height();
var colW = 330, pw2 = cols * colW + 60 + ((stage == 1) ? 260 : 0), ph2 = 150 + rows * 40;
var px = (gw - pw2) / 2, py = (gh - ph2) / 2;
draw_set_font(fnt_eq);
draw_set_alpha(0.92);
draw_set_colour(c.panel);
draw_roundrect_ext(px, py, px + pw2, py + ph2, 14, 14, false);
draw_set_alpha(1);
var title = (stage == 0) ? "What shop will it be?" : "Which building for the " + string_lower(pshop_kinds()[$ kindPick].name) + "?";
ui_text(px + pw2 / 2, py + 28, title, 0.62, c.accent);
ui_text(px + pw2 / 2, py + 56, "Rowan's crew: " + string(PSHOP_BUILD_GOLD) + " gold, " + string(PSHOP_BUILD_WOOD) + " wood, " + string(PSHOP_BUILD_STONE) + " stone - built overnight", 0.4, c.dim);
for(var i = 0; i < n; i++){
	var cc = i div rows, rr = i mod rows;
	var bx = px + 30 + cc * colW, by = py + 80 + rr * 40;
	if(ui_button(bx, by, bx + colW - 20, by + 34, (i == pick) ? "[ " + list[i] + " ]" : list[i], true, 0.48)){
		pick = i;
		pshop_plot_menu_choose(id, i);
		exit;
	}
}
if(stage == 1){
	var d = pshop_designs()[pick], sw = sprite_get_width(d.spr), sh = sprite_get_height(d.spr);
	var k = min(220 / sw, 220 / sh), cx2 = px + cols * colW + 40 + 120, cy2 = py + 80 + 120;
	draw_sprite_ext(d.spr, 0, cx2 - sw * k / 2, cy2 - sh * k / 2, k, k, 0, c_white, 1);
} else {
	var fk = pshop_free_kinds(), kk = fk[pick];   // (two lines: an accessor keyed by an indexed call crashes the compiler)
	var kd = pshop_kinds()[$ kk];
	ui_text(px + pw2 / 2, py + ph2 - 52, "Like " + kd.like + ": takes " + kd.goods + " materials; makes " + string(kd.make) + ", sells " + string(kd.sell) + " a day", 0.4, c_white);
}
ui_text(px + pw2 / 2, py + ph2 - 22, "Arrows: choose    Enter: pick    Esc: back", 0.38, c.dim);
