/// @description Its walking frame (scaled so a cow is cow-sized next to you), a heart after petting, and a little
/// sign when something's ready to collect
var sc = (def.fw > 64) ? 0.6 : 1;
var f = (moveX != 0 || moveY != 0) ? floor(frame) mod 4 : 0;
draw_sprite_part_ext(def.spr, 0, f * def.fw, dirIdx * def.fw, def.fw, def.fw,
                     round(x - def.feet[0] * sc), round(y - def.feet[1] * sc), sc, sc, c_white, 1);
var top = y - def.feet[1] * sc + ((def.fw > 64) ? 30 : 0);
if(data.ready){
	draw_set_colour(c_white);
	draw_circle(x, top - 8, 6, false);
	item_draw_icon(item_stack(def.product), x - 8, top - 16, 16, global.look.body);
}
if(heartT > 0){
	var hy = top - 14 - (50 - heartT) * 0.4;
	draw_set_alpha(min(1, heartT / 20));
	draw_set_colour(make_colour_rgb(230, 80, 110));
	draw_circle(x - 3, hy, 3.5, false);
	draw_circle(x + 3, hy, 3.5, false);
	draw_triangle(x - 6.5, hy + 1, x + 6.5, hy + 1, x, hy + 8, false);
	draw_set_alpha(1);
}
if(near){
	draw_set_font(fnt_eq);
	draw_set_halign(fa_center);
	draw_set_valign(fa_bottom);
	draw_text_transformed_colour(x, top - 24, data.name + "  [E]", 0.3, 0.3, 0, c_yellow, c_yellow, c_yellow, c_yellow, 1);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
}
draw_set_colour(c_white);
