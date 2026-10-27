/// @description Respawn the farm's crops from the world store
loadPending = false;
if(room == rm_1){
	ds_crops_instances = ds_grid_create(room_width div cellSize, room_height div cellSize);
	ds_grid_clear(ds_crops_instances, 0);
	// Tilled/watered soil drawn right above the field's tile layer
	var soilLayer = layer_get_id("T_Soil");
	if(soilLayer != -1 && !instance_exists(obj_farm_soil)) instance_create_depth(0, 0, layer_get_depth(soilLayer) - 1, obj_farm_soil);
	if(world_time_ready()){
		var list = world_room("rm_1").crops;
		for(var i = 0; i < array_length(list); i++) respawn_crop(list[i].gx, list[i].gy, list[i].type, list[i].days);
	}
}
