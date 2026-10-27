/// @description Insert description here
// You can write your code in this editor
// Stand still while the inventory is open
if(instance_exists(obj_inventory)){ moveX = 0; moveY = 0; facing = -1; exit; }

// Using the held item: play the action through, firing its effect once on the hit step
if(act != undefined){
	actStep += act.fps / game_get_speed(gamespeed_fps);
	if(!actHit && actStep >= act.hit){
		actHit = true;
		var itemName = lpc_catalog().items[look.parts.held.item].name;
		if(item_is_tool(itemName) && world_time_ready()) global.vitals.energy = max(0, global.vitals.energy - tool_energy_cost());
		action_hit(id, itemName, actDir);
	}
	if(actStep >= act.frames) act = undefined;
	moveX = 0; moveY = 0;
	exit;
}
var planting = instance_exists(crops) && crops.planting;
if(!planting && (mouse_check_button_pressed(mb_left) || keyboard_check_pressed(vk_space))){
	act = character_action_for(look);
	// Too tired to swing a tool (weapons still work)
	if(act != undefined && world_time_ready() && vitals_exhausted() && item_is_tool(lpc_catalog().items[look.parts.held.item].name)){
		act = undefined;
		game.hudMessage = "You're too tired. Get some sleep.";
		game.hudTime = game_get_speed(gamespeed_fps) * 2;
	}
	if(act != undefined){
		actStep = 0;
		actHit = false;
		actDir = clamp(y_frame - 8, 0, 3); // walk rows 8-11 are n, w, s, e
		moveX = 0; moveY = 0;
		exit;
	}
}
var in_left =keyboard_check(vk_left);
var in_right =keyboard_check(vk_right);
var in_up=keyboard_check(vk_up);
var in_down =keyboard_check(vk_down);
var in_walk=keyboard_check(vk_control);
var in_run=keyboard_check(vk_shift);
	//ALTERSPEED
if(in_walk || in_run){
	spd=abs((in_walk*w_spd)-(in_run*r_spd));
}else {
	spd=n_spd;
}
// Equipment Speed stat (feathers and pixie dust help, heavy metal slows you down)
spd *= inv_speed_multiplier();
if(world_time_ready() && vitals_exhausted()) spd *= 0.6; // exhausted: slow
//RESETVARIABLES

moveY= (in_down - in_up) * spd;
moveX =(in_right - in_left) * spd;
// Same speed on diagonals
if(moveX != 0 && moveY != 0){
	moveX *= 0.7071;
	moveY *= 0.7071;
}

//get direction player facing
if(moveX != 0){
switch(sign(moveX)){
case 1: facing = dir.right; break;
case -1: facing= dir.left; break;
}
}else if(moveY != 0){
switch(sign(moveY)){
case 1: facing = dir.down; break;
case -1: facing = dir.up; break;
}
}else{facing = -1;}



///collisions
// NPCs block too, unless already overlapping one (so the player can walk out)
var solids = place_meeting(x,y,obj_npc_parent) ? obj_col_box : [obj_col_box, obj_npc_parent];

if(moveX != 0){
	if(place_meeting(x+moveX,y,solids)){
		repeat(abs(moveX)){
			if(!place_meeting(x+sign(moveX),y,solids)){
			x += sign(moveX); }
			else { break; }
	} moveX = 0;
}
}
// Move horizontally before checking vertically, so diagonals can't clip corners
x += moveX;
////vertical

if(moveY != 0){
	if(place_meeting(x,y+moveY,solids)){
		repeat(abs(moveY)){
			if(!place_meeting(x,y+sign(moveY),solids)){
			y += sign(moveY); }
			else { break; }
	} moveY = 0;
}
}
y += moveY;

//objects
var inst = instance_place(x,y,obj_transition);
// Skip transitions that were never given a target room
if (inst != noone and inst.targetRoom != -1 and facing == inst.PlayerFacingBefore){
	
	with(game){
		spawnRoom= inst.targetRoom;
		spawnX = inst.targetX;
		spawnY = inst.targetY;
		spawnPlayerFacing = inst.PlayerFacingAfter;
		doTransition = true;

}}

	
