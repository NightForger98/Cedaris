/// @description An animated waterfall (LPC Revised, art/lpc_revised/cut: four frames for each season, frozen in winter).
/// Set on creation: dir ("down", "left": water arriving from the east spilling west over a cliff, "right"). x, y: the
/// top-left of its picture; it sorts by its foot.
if(!variable_instance_exists(id, "dir")) dir = "left";
spr = (dir == "down") ? spr_waterfall_down : ((dir == "right") ? spr_waterfall_right : spr_waterfall_left);
fw = (dir == "down") ? 96 : 64;
fh = sprite_get_height(spr);
foot = y + fh;
depth = instance_exists(obj_plyr) ? obj_plyr.baseDepth + 1 : depth;   // under the people and things that sort
