/// @description E: stock the shop
near = interact_near(48);
if(near && input_pressed(key_of("interact")) && interact_ready()){
	global.talkCooldown = current_time + 250;
	if(pshop_plot(plot).built) farm_message(pshop_stock_add(plot));
}
