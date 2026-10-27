/// @description respawn_crop: create a crop on the farm grid (planting, or rebuilding the farm from the world store)
/// @arg grid_x
/// @arg grid_y
/// @arg crop_type
/// @arg days_old  watered days it has grown
function respawn_crop(){
	var cs = crops.cellSize;
	var inst = instance_create_depth(argument0 * cs + cs / 2, argument1 * cs + cs / 2, 0, obj_crop);
	with(inst){ depth_sort(); }
	crops.ds_crops_instances[# argument0, argument1] = inst;
	// Give the crop its characteristics; its stage follows from its age (crop_stage in the farming script)
	with(inst){
		cropType = argument2;
		daysOld = argument3;
		growthStageDuration = crop_table()[cropType].stageDays;
		growthStage = crop_stage(cropType, daysOld);
		if(growthStage == maxGrowthStage){
			fullyGrown = true;
			alarm[1] = 1;
		}
	}
	return inst;
}
