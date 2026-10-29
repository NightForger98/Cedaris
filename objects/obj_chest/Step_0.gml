/// @description E beside it: open it (its loot goes into the bag, and it never comes back)
near = interact_near(40);
if(near && input_pressed(key_of("interact")) && interact_ready()){
	farm_message(mine_chest_open(chestFloor));
	instance_destroy();
}
