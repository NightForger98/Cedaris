/// @description The plot's edge (faint, while it's for sale) and its sign, with what it says when you're near
var p = pshop_plot(plot);
if(p.built || !ready) exit;
if(!p.owned){
	draw_set_alpha(0.18);
	draw_set_colour(make_colour_rgb(255, 240, 180));
	draw_rectangle(x + 2, y + 2, x + pw * 32 - 3, y + ph * 32 - 3, true);
	draw_rectangle(x + 3, y + 3, x + pw * 32 - 4, y + ph * 32 - 4, true);
	draw_set_alpha(1);
	draw_set_colour(c_white);
}
draw_sprite_part(spr_tile_terrain, 0, 11 * 32, 25 * 32, 32, 32, signX - 16, signY - 30);
var s = 0.28 * wtx();
var t = !p.owned ? "For Sale" : (p.building ? "Building tonight" : "Your plot");
draw_set_font(fnt_eq);
draw_set_halign(fa_center);
draw_set_valign(fa_bottom);
draw_text_transformed_colour(signX, signY - 30, t, s, s, 0, c_white, c_white, c_white, c_white, 1);
if(near && !menuOpen){
	var a = !p.owned ? "Claim with a Land Deed" : (p.building ? "" : "Choose a shop");
	if(a != "") draw_text_transformed_colour(signX, signY - 30 - 40 * s, key_label("interact") + " " + a, s, s, 0, c_yellow, c_yellow, c_yellow, c_yellow, 1);
}
draw_set_halign(fa_left);
draw_set_valign(fa_top);
