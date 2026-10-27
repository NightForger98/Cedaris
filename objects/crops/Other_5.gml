/// @description Leaving the farm: keep its crops in the world store
// (unless a load or a new day already replaced the store, which sets loadPending)
if(room == rm_1){
	if(!loadPending && world_time_ready()) crops_store();
	ds_grid_destroy(ds_crops_instances);
	ds_crops_instances = -1;
}
