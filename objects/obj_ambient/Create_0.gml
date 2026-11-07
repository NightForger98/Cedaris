/// @description The room's creatures (scripts/ambient): birds crossing, butterflies, fireflies - all in view of the
/// camera, none solid
birds = [];        // {x, y, dx, dy, spr}
butterflies = [];  // {x, y, dx, dy, spr, t}
flies = [];        // {x, y, dx, dy, ph}
birdT = irandom_range(120, 400);   // frames to the next bird
sea = (world_water(room_get_name(room)) == "sea");
