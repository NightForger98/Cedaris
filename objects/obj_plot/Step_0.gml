/// @description Set up once (the building, or the door shut), then the sign: E claims the plot or opens its menu
if(!ready){
	ready = true;
	var p0 = pshop_plot(plot);
	midX = x + (pw div 2) * 32 + 16;
	doorY = y + (ph - 1) * 32 + 16;
	signX = midX + 56;
	signY = y + ph * 32 + 4;
	if(p0.built) pshop_plot_raise(id);
	else with(obj_transition) if(point_distance(x, y, other.midX, other.doorY) < 12) instance_destroy();   // no shop yet: no way in
	depth = instance_exists(obj_plyr) ? obj_plyr.baseDepth : depth;
}
var p = pshop_plot(plot);
if(p.built) exit;
near = instance_exists(obj_plyr) && point_distance(signX, signY - 12, obj_plyr.x, obj_plyr.y) < 48;

if(menuOpen){
	var list = pshop_plot_menu_list(id), n = array_length(list), cols = (n > 10) ? 2 : 1, rows = ceil(n / cols);
	if(input_pressed(vk_up)) pick = (pick + n - 1) mod n;
	if(input_pressed(vk_down)) pick = (pick + 1) mod n;
	if(cols > 1 && (input_pressed(vk_left) || input_pressed(vk_right))) pick = (pick + rows) mod (rows * cols);
	pick = min(pick, n - 1);
	if(input_pressed(vk_enter) || input_pressed(key_of("interact"))){
		pshop_plot_menu_choose(id, pick);
		global.talkCooldown = current_time + 250;
		exit;
	}
	if(input_pressed(vk_escape) || !near){
		if(stage == 1 && near){ stage = 0; pick = 0; }
		else { menuOpen = false; game.resumeLock = 2; }
		global.talkCooldown = current_time + 250;
	}
	exit;
}

if(near && input_pressed(key_of("interact")) && interact_ready() && !game.doTransition){
	global.talkCooldown = current_time + 250;
	var held = inv_held_stack();
	if(!p.owned){
		if(held != undefined && held.id == "m|land_deed"){
			inv_take("m|land_deed", 1);
			p.owned = true;
			farm_message("This plot is yours! Use the sign again to choose a shop for it");
		} else farm_message("For sale. The Mayor sells plots at City Hall, by the square");
	} else if(p.building) farm_message("Rowan's crew builds your " + string_lower(pshop_kinds()[$ p.kind].name) + " here tonight");
	else if(array_length(pshop_free_kinds()) == 0) farm_message("You run one of every kind of shop already");
	else { menuOpen = true; stage = 0; pick = 0; }
}
