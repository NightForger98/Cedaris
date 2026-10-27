/// @description Respawn the farm's crops from the world store
loadPending = false;
if(room == rm_1){
	ds_crops_instances = ds_grid_create(room_width div cellSize, room_height div cellSize);
	ds_grid_clear(ds_crops_instances, 0);
	if(world_time_ready()){
		var list = world_room("rm_1").crops;
		for(var i = 0; i < array_length(list); i++) respawn_crop(list[i].gx, list[i].gy, list[i].type, list[i].days);
	}
}
