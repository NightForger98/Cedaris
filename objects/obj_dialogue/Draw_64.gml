/// @description The dialogue box: portrait, name, hearts, what they say, and the keys
var c = ui_colours();
var v = villager_def(who);
var x1 = 120, y1 = guiH - 260, x2 = guiW - 120, y2 = guiH - 24;
draw_set_font(fnt_eq);
draw_set_alpha(0.94);
draw_set_colour(c.panel);
draw_roundrect_ext(x1, y1, x2, y2, 16, 16, false);
draw_set_alpha(1);

// Portrait: their look, large, in a frame
var px = x1 + 18, py = y1 + 18, ps = y2 - y1 - 36;
draw_set_colour(merge_colour(c.panel, c_black, 0.35));
draw_roundrect_ext(px, py, px + ps, py + ps, 12, 12, false);
if(instance_exists(npc)) character_draw(npc.look, 0, 10, px + ps / 2 - 96, py + ps / 2 - 120, 3);

// Name, title and hearts
var tx = px + ps + 24;
ui_text(tx, y1 + 32, v.name + ((v.title != "") ? "  " + v.title : ""), 0.75, c.accent, fa_left);
var h = people_hearts(who);
for(var i = 0; i < HEARTS_MAX; i++){
	var hx = tx + i * 24 + 8, hy = y1 + 66;
	draw_set_colour((i < h) ? make_colour_rgb(230, 80, 110) : merge_colour(c.panel, c_white, 0.15));
	draw_circle(hx - 4, hy - 3, 5, false);
	draw_circle(hx + 4, hy - 3, 5, false);
	draw_triangle(hx - 9, hy - 1, hx + 9, hy - 1, hx, hy + 9, false);
}

// What they say
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_colour(c_white);
draw_text_ext_transformed(tx, y1 + 90, text, 34, (x2 - tx - 30) / 0.6, 0.6, 0.6, 0);
if(note != "") ui_text(tx, y2 - 66, note, 0.55, make_colour_rgb(255, 200, 120), fa_left);

// Keys (a heart event has its own: next, a choice, or done)
if(event != undefined){
	var ek = key_label("interact") + " Next";
	if(eventDone) ek = key_label("interact") + " Done";
	else if(line >= array_length(event.lines) - 1 && variable_struct_exists(event, "choice")){
		ui_text(tx, y2 - 66, event.choice.ask, 0.5, make_colour_rgb(255, 200, 120), fa_left);
		ek = "[1] " + event.choice.options[0][0] + "     [2] " + event.choice.options[1][0];
	}
	ui_text(tx, y2 - 28, ek, 0.45, c.dim, fa_left);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_colour(c_white);
	exit;
}
// Keys
var held = inv_held_stack();
var keys = key_label("interact") + " Bye";
if(held != undefined && people_state(who).gifted != day_index() && item_def(held.id).type != "held" && item_def(held.id).type != "clothing")
	keys += "     [G] Give " + item_def(held.id).name;
if((v[$ "shop"] ?? "") != "") keys += villager_shop_open(who) ? "     [T] Trade" : "     [T] Hours";
ui_text(tx, y2 - 28, keys, 0.5, c.dim, fa_left);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_colour(c_white);
