/// @description depth_sort
/// Sets depth from y so objects lower on screen draw in front.
/// Stays within the 100 depths above the player's layer, so tile layers
/// placed above the player (roofs, tree tops) still cover everything.
function depth_sort(){
	var base = instance_exists(obj_plyr) ? obj_plyr.baseDepth : 0;
	depth = base - 1 - floor(clamp(y, 0, room_height - 1) / room_height * 98);
}
