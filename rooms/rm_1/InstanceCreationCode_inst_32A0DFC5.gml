var _l = clamp(house_level(), 0, 3);
sprite_index = [spr_house_farmhouse_1, spr_house_farmhouse_2, spr_house_farmhouse_3, spr_house_farmhouse_4][_l];
x = 816 - [78, 78, 96, 62][_l];
var _c1 = floor(x / 32), _c2 = floor((x + sprite_get_width(sprite_index) - 8) / 32);
for(var _c = _c1; _c <= _c2; _c++) if(_c != 25){ var _b = instance_create_depth(_c * 32 + 16, 512, 0, obj_col_box); _b.image_xscale = 2; _b.image_yscale = 4; _b.visible = false; }
