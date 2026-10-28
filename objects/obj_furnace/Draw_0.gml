/// @description Draw the forge (its fire flickering through three frames) and the prompt
// spr_forge: [LPC] Blacksmith by bluecarrot16 - frame 0 cold, 1-3 burning, 64 x 128 each, the base at the bottom
var f = 1 + (current_time div 160) mod 3;
draw_sprite_part(spr_forge, 0, f * 64, 0, 64, 128, x - 32, y - 122);
if(near){
	draw_set_font(fnt_eq);
	draw_set_halign(fa_center);
	draw_set_valign(fa_bottom);
	draw_text_transformed_colour(x, y - 124, "[E] Smelt", 0.3, 0.3, 0, c_yellow, c_yellow, c_yellow, c_yellow, 1);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
}
