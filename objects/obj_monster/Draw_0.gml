/// @description A look (humanoids) or a sheet frame (creatures); flickers when hit and while beaten; health bar once hurt
if((flash > 0 || dying) && ((flash + deathT) div 2) mod 2 == 0) exit;
if(look != undefined){
	var xx = round(x - 32), yy = round(y - 58);
	if(attacking && act != undefined) character_draw(look, 0, 0, xx, yy, 1, {act: act, i: floor(step), dir: dirIdx});
	else character_draw(look, (moveX != 0 || moveY != 0) ? 1 + floor(frame) mod 8 : 0, 8 + dirIdx, xx, yy, 1);
} else {
	// [LPC] Monsters sheets: the attack row doubles as the idle loop (its first frames)
	var f = attacking ? min(floor(step), def.frames - 1) : floor(frame) mod 3;
	var bob = (def[$ "flies"] ?? false) ? sin(current_time / 150 + x * 0.1) * 3 : 0;
	draw_sprite_part(def.spr, 0, f * 64, dirIdx * 64, 64, 64, round(x - 32), round(y - 54 + bob));
}
if(hp < hpMax && !dying){
	var w = 28, bx = x - w / 2, by = y - 62;
	draw_set_colour(c_black);
	draw_rectangle(bx - 1, by - 1, bx + w + 1, by + 3, false);
	draw_set_colour(make_colour_rgb(220, 70, 60));
	draw_rectangle(bx, by, bx + w * max(0, hp) / hpMax, by + 2, false);
	draw_set_colour(c_white);
}
