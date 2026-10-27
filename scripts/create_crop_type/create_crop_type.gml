///@description create_crop_type
///@arg growth_stage_duration
///@arg cost

function create_crop_type(){
var argNum = argument_count;


if(!ds_exists(ds_crops_types, ds_type_grid)){

	//ds_crops_types = ds_grid_create(argNum,1);
	ds_crops_types = ds_grid_create(2,1);
	var height = 1;
} else {
	
	var height = ds_grid_height(ds_crops_types);
	var width = ds_grid_width(ds_crops_types);
	ds_grid_resize(ds_crops_types, argNum, height+1);
	height += 1;
	
}


var yy = height - 1;
//var i = 0; repeat(argNum){
	
	//ds_crops_type[# i, yy]= argument[i];
//	i+=1;
	ds_crops_types[# 0, yy] = argument0; // growthstage duration
	ds_crops_types[# 1, yy] = argument1; // cost 

//}

}