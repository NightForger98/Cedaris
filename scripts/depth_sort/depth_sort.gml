/// @description depth_sort
/// Sets depth from y so objects lower on screen draw in front.
/// Stays within the 100 depths above the player's layer, so tile layers
/// placed above the player (roofs, tree tops) still cover everything.
function depth_sort(){
	// Objects created before the player (room creation order) fall back to their own layer depth
	var base = (instance_exists(obj_plyr) && variable_instance_exists(obj_plyr, "baseDepth")) ? obj_plyr.baseDepth : depth;
	depth = base - 1 - floor(clamp(y, 0, room_height - 1) / room_height * 98);
}
