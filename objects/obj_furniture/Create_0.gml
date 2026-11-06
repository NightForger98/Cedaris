/// @description A placed piece of furniture (scripts/furniture). Set on creation: data {kind, gx, gy} - its
/// bottom-left cell. Solid where it stands (rugs lie flat, under everything).
sprite_index = furniture_sprite(data.kind);
var sz = furniture_size(data.kind), flat = furniture_def(data.kind)[$ "flat"] ?? false;
var w = (sprite_index == -1) ? 32 : sprite_get_width(sprite_index), h = (sprite_index == -1) ? 32 : sprite_get_height(sprite_index);
x = data.gx * 32 + sz[0] * 16;   // its foot's middle
y = (data.gy + 1) * 32 - 2;
drawX = data.gx * 32 + (sz[0] * 32 - w) / 2;
drawY = (data.gy + 1) * 32 - h;
boxes = [];
if(flat) depth = instance_exists(obj_plyr) ? obj_plyr.baseDepth : depth;   // under everything that sorts
else {
	depth_sort();
	for(var c = 0; c < sz[0]; c++) for(var r = 0; r < sz[1]; r++){
		var b = instance_create_depth((data.gx + c) * 32 + 16, (data.gy - r) * 32 + 16, 0, obj_col_box);
		b.image_xscale = 2; b.image_yscale = 2; b.visible = false;
		array_push(boxes, b);
	}
}
