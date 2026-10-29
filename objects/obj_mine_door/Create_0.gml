/// @description The lift. At the cave mouth on North Road (E goes down to floor 1 while that's the only floor to
/// choose, then opens the lift), and as a lift car by the ladder up on every 5th mine floor (inMine, set on creation).
/// Story mode: any floor you've reached; free mode: any floor (mine_lift_top).
near = false;
menuOpen = false;
pick = 1;   // the floor chosen in the lift
if(!variable_instance_exists(id, "inMine")) inMine = false;
// In the mine the car stands behind the player and monsters, like the ladders
if(inMine) depth = instance_exists(obj_plyr) ? obj_plyr.baseDepth : 100;
