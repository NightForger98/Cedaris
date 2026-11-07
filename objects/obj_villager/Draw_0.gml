/// @description Draw them (mid-swing, or as any NPC with their name)
if(act != undefined){
	character_draw(look, 0, 0, round(x - x_offset), round(y - y_offset), 1, {act: act, i: floor(actStep), dir: 2});
	var top = y - y_offset + 10;
	draw_set_font(fnt_eq);
	draw_set_halign(fa_center);
	draw_set_valign(fa_bottom);
	draw_text_transformed_colour(x, top, villager_def(who).name, 0.3 * wtx(), 0.3 * wtx(), 0, c_white, c_white, c_white, c_white, 1);
	if(near) draw_text_transformed_colour(x, top - 12, key_label("interact") + " Talk", 0.3 * wtx(), 0.3 * wtx(), 0, c_yellow, c_yellow, c_yellow, c_yellow, 1);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
} else event_inherited();
