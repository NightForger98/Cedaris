/// @description The piece (mirrored if flipped)
if(sprite_index == -1) exit;
if(data[$ "flip"] ?? false) draw_sprite_ext(sprite_index, 0, drawX + sprite_get_width(sprite_index), drawY, -1, 1, 0, c_white, 1);
else draw_sprite(sprite_index, 0, drawX, drawY);
// a vase's flower (scripts/furniture): its picture standing in the vase's neck
if(data.kind == "vase" && (data[$ "flower"] ?? "") != ""){
	var fs2 = asset_get_index("spr_flower_" + data.flower);
	if(fs2 != -1) draw_sprite_ext(fs2, 0, x - sprite_get_width(fs2) * 0.4, drawY - sprite_get_height(fs2) * 0.8 + 8, 0.8, 0.8, 0, c_white, 1);
}
