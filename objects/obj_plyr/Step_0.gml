/// @description Insert description here
// You can write your code in this editor
// Stand still while a window is open (inventory, dialogue, notice board, lift); blink for a moment after being hit
if(iframes > 0) iframes--;
if(ui_blocking() || game.dying){ moveX = 0; moveY = 0; facing = -1; exit; }
// A hit's freeze (scripts/combat_feel): everything holds for a few frames
if(combat_hitstopped()){ global.hitStop--; exit; }
afterimages_fade();
// a knock back that eases off
if(abs(knX) + abs(knY) > 0.3){
	var ksol = collision_solids(false);
	if(!place_meeting(x + knX, y, ksol)) x += knX;
	if(!place_meeting(x, y + knY, ksol)) y += knY;
	knX *= 0.75; knY *= 0.75;
} else { knX = 0; knY = 0; }
if(dodgeCool > 0) dodgeCool--;
if(bufAttack > 0) bufAttack--;
if(comboT > 0) comboT--;
// mid-dodge: nothing else
if(dodgeT > 0){ dodge_step(); exit; }
// Dancing (scripts/skills): you stand and dance until it's done
if(danceT > 0){ danceT--; moveX = 0; moveY = 0; facing = -1; exit; }
if(input_pressed(key_of("skills")) && !instance_exists(obj_character)){ instance_create_depth(0, 0, -9000, obj_character); exit; }
if(input_pressed(key_of("dance")) && act == undefined && charge == undefined){ dance_start(); exit; }
// Dodge (Z): a dash, or a hop back; it cancels a swing, a charge or the guard (scripts/combat_feel)
if(input_pressed(key_of("dodge")) && dodgeCool <= 0 && castSpell == "" && dodge_start()) exit;
// Guard (V, or hold the right mouse button): it cancels a swing; a parry if a hit lands just as it goes up
if(input_held(key_of("block")) || mouse_check_button(mb_right)){
	if(!blocking){ blockT = 0; if(act != undefined && castSpell == ""){ act = undefined; motion = undefined; aimAng = -1; } charge = undefined; }
	blocking = true;
	blockT++;
} else { blocking = false; blockT = 0; }

// Charging: the swing waits on its wind-up while the button is held, a level every CHARGE_LEVEL_TIME; letting go plays
// it with that level (see the charging script). You can still walk, slowly, without turning.
if(charge != undefined){
	if(charge.flash > 0) charge.flash--;
	if(charge_held()){
		charge.t += 1 / game_get_speed(gamespeed_fps);
		var lv = min(charge.max, floor(charge.t / CHARGE_LEVEL_TIME));
		if(lv > charge.level){ charge.level = lv; charge.flash = 10; }
	} else {
		actCharge = charge.level;
		// A charged spin or big swing plays out its own way (charge_release_motion)
		motion = charge_release_motion(charge, actDir);
		if(motion == undefined && comboN == 2){ var fa = (aimAng == -1) ? [90, 180, 270, 0][actDir] : aimAng; motion = {type: "lunge", dx: lengthdir_x(2, fa), dy: lengthdir_y(2, fa), left: 8}; }   // the combo's finisher steps in
		if(motion != undefined && motion.type == "swing") act.fps *= 0.8;
		// Weapons are free to swing, but a charged move costs 2 energy a level
		if(actCharge > 0 && !item_is_tool(charge.item) && world_time_ready()) global.vitals.energy = max(0, global.vitals.energy - 2 * actCharge);
		charge = undefined;
	}
}
// Using the held item: play the action through, firing its effect once on the hit step
if(act != undefined && charge == undefined){
	if(mouse_check_button_pressed(mb_left) || input_pressed(key_of("use"))) bufAttack = 15;   // queued for when this one ends
	// A spin holds the swing's hit frame while it turns, landing a third of the way round
	var spinning = (motion != undefined && motion.type == "spin");
	if(spinning){ motion.t++; actStep = (motion.t >= motion.hitAt) ? act.hit : 0; }
	else actStep += act.fps / game_get_speed(gamespeed_fps);
	// A spear's lunge carries you forward (not through walls)
	if(motion != undefined && motion.type == "lunge" && motion.left > 0){
		var solids = collision_solids(!place_meeting(x, y, obj_npc_parent));
		repeat(min(6, motion.left)){
			if(place_meeting(x + motion.dx, y + motion.dy, solids)){ motion.left = 0; break; }
			x += motion.dx; y += motion.dy; motion.left--;
		}
	}
	if(!actHit && actStep >= act.hit){
		actHit = true;
		var itemName = lpc_catalog().items[look.parts.held.item].name;
		if(castSpell != ""){ spell_effect(id, castSpell, actDir, itemName); castSpell = ""; }  // a spell costs mana, not energy
		else {
			// A charged swing costs a tap's energy for every level, plus the tap
			if(item_is_tool(itemName) && world_time_ready()) global.vitals.energy = max(0, global.vitals.energy - tool_energy_cost(itemName) * (1 + actCharge));
			else if(world_time_ready() && curse_item() == "c|held|" + itemName) global.vitals.energy = max(0, global.vitals.energy - 1);
			action_hit(id, itemName, actDir, actCharge);
		}
	}
	// A dagger's flurry stabs again
	if(!spinning && actStep >= act.frames && motion != undefined && motion.type == "flurry" && motion.left > 0){
		motion.left--;
		actStep = 0;
		actHit = false;
	}
	if(spinning ? motion.t >= motion.total : actStep >= act.frames){
		if(spinning) y_frame = 8 + motion.start; // back facing the way you started
		act = undefined;
		motion = undefined;
		aimAng = -1;
		comboT = 30;   // half a second to keep the combo going
	}
	moveX = 0; moveY = 0;
	exit;
}
// Magic: Q picks the next spell you know; F casts it with a staff in hand
var busy = (charge != undefined);
if(!busy && input_pressed(key_of("spell")) && array_length(spells_known()) > 0){ spell_cycle(); farm_message("Spell: " + spell_def(spell_selected()).name); }
if(!busy && input_pressed(key_of("cast")) && look.parts.held.item != -1){
	var cast = spell_begin(look, lpc_catalog().items[look.parts.held.item].name);
	if(variable_struct_exists(cast, "act")){
		act = cast.act;
		actCharge = 0;
		motion = undefined;
		castSpell = cast.spell;
		actStep = 0;
		actHit = false;
		actDir = clamp(y_frame - 8, 0, 3);
		moveX = 0; moveY = 0;
		exit;
	}
	if(cast.why != "") farm_message(cast.why);
}
furniture_mouse_track();
var planting = instance_exists(crops) && crops.planting;
if(!busy && !planting && !blocking && (mouse_check_button_pressed(mb_left) || input_pressed(key_of("use")) || bufAttack > 0)){
	bufAttack = 0;
	var faceDir = clamp(y_frame - 8, 0, 3);
	var cell = instance_exists(crops) ? farm_front_cell(id, faceDir) : [0, 0];
	var cropHere = instance_exists(crops) ? farm_crop_at(cell[0], cell[1]) : noone;
	var held = inv_held_stack();
	var heldType = (held == undefined) ? "" : item_def(held.id).type;
	// A ripe crop in front: harvest it, whatever you're holding
	if(cropHere != noone && cropHere.growthStage >= cropHere.maxGrowthStage){ farm_harvest(cropHere); exit; }
	// Seeds: plant; produce: eat
	if(heldType == "seed"){
		if(farm_plant(cell[0], cell[1], item_def(held.id).crop)){
			held.count--;
			if(held.count <= 0) global.inv.slots[global.inv.hotbar] = undefined;
		}
		exit;
	}
	if(heldType == "produce"){ farm_eat(held); exit; }
	if(heldType == "food"){ food_eat(held); exit; }
	if(heldType == "scroll"){ spell_learn(held); exit; }
	if(heldType == "lesson"){ dance_learn(held); exit; }   // a dance lesson (scripts/skills)
	if(heldType == "forage"){ forage_eat(held); exit; }
	if(heldType == "placeable"){ placeable_place(held, cell[0], cell[1]); exit; }
	if(heldType == "furniture"){ furniture_place(held); exit; }
	if(held == undefined && furniture_pick_up()) exit;   // an empty hand on a piece of furniture picks it up
	if(heldType == "fish"){ fish_eat(held); exit; }
	if(heldType == "crate"){ animal_release(held); exit; }
	if(heldType == "animalproduct"){ animal_product_eat(held); exit; }
	// a metal weapon too heavy for your Strength won't swing (scripts/skills)
	var heavy = (heldType == "held") ? gear_too_heavy(held) : "";
	if(heavy != ""){ farm_message(heavy); exit; }
	act = character_action_for(look);
	// Agility: weapons swing faster (tools don't)
	if(act != undefined && heldType == "held" && !item_is_tool(item_def(held.id).name)) act.fps *= attr_attack_speed();
	// Too tired to swing a tool (weapons still work)
	if(act != undefined && world_time_ready() && vitals_exhausted() && item_is_tool(lpc_catalog().items[look.parts.held.item].name)){
		act = undefined;
		game.hudMessage = "You're too tired. Get some sleep.";
		game.hudTime = game_get_speed(gamespeed_fps) * 2;
	}
	if(act != undefined){
		actStep = 0;
		actHit = false;
		motion = undefined;
		actCharge = 0;
		actDir = clamp(y_frame - 8, 0, 3); // walk rows 8-11 are n, w, s, e
		// A weapon: toward the mouse (8 ways, a little aim help), the third swing in a row a finisher (scripts/combat_feel)
		if(heldType == "held" && !item_is_tool(item_def(held.id).name)){
			comboN = (comboT > 0) ? (comboN + 1) mod 3 : 0;
			aimAng = combat_aim_angle(id);
			y_frame = combat_row_for_angle(aimAng);
			actDir = clamp(y_frame - 8, 0, 3);
			if(comboN == 2) motion = {type: "lunge", dx: lengthdir_x(2, aimAng), dy: lengthdir_y(2, aimAng), left: 8};
		} else { comboN = 0; aimAng = -1; }
		// Chargeable: hold on the wind-up until the button's let go
		var heldName = lpc_catalog().items[look.parts.held.item].name;
		if(charge_max(heldName) > 0) charge = {item: heldName, t: 0, level: 0, max: charge_max(heldName), flash: 0};
		moveX = 0; moveY = 0;
		exit;
	}
}
var in_left = input_held(key_of("left"));   // keys from Options > Controls
var in_right = input_held(key_of("right"));
var in_up = input_held(key_of("up"));
var in_down = input_held(key_of("down"));
// the debug free camera (C) has the keys: you stand still
if(instance_exists(camera) && camera.move_cam){ in_left = 0; in_right = 0; in_up = 0; in_down = 0; }
var in_walk = input_held(key_of("walk"));
var in_run = input_held(key_of("run"));
if(input_pressed(key_of("autorun")) && !ui_blocking()) always_run_toggle();
if(input_pressed(key_of("flip")) && !ui_blocking()) furniture_flip();   // mirror the held piece of furniture, or the one in front
sprinting = in_run;   // drawn with the run cycle while moving (Draw)
// Your pace: running, or walking with always run off (R); Shift sprints, Ctrl walks
if(in_run) spd = r_spd;
else if(in_walk || !always_run()) spd = w_spd;
else spd = n_spd;
// Equipment Speed stat (feathers and pixie dust help, heavy metal slows you down)
spd *= inv_speed_multiplier();
// Roads (cobbles) speed you up, on foot or running (world_is_road: the road cells of the outdoor rooms)
if(world_is_road(room_get_name(room), floor(x / 32), floor(y / 32))) spd *= ROAD_BOOST;
if(world_time_ready() && vitals_exhausted()) spd *= 0.6; // exhausted: slow
if(busy) spd *= 0.5; // charging: a slow shuffle, still facing the same way
if(blocking) spd *= 0.5; // on guard: a careful step
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
var solids = collision_solids(!place_meeting(x,y,obj_npc_parent)); // in the mine, its rock too

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
// A door or road out takes you through when you walk into it: stepping onto it from any side, or walking on in its
// direction (PlayerFacingBefore; diagonals count, and -1 means any way) while you stand on it. Standing still never
// does, and a door you arrive on only works once you walk on through it or step off and back, so you don't bounce
// straight back. Transitions never given a target room are skipped.
var wantX = in_right - in_left, wantY = in_down - in_up, into = false;
if(inst != noone && inst.targetRoom != -1 && (wantX != 0 || wantY != 0)){
	var fb = inst.PlayerFacingBefore;
	var pushing = fb == -1 || (fb == dir.up && wantY < 0) || (fb == dir.down && wantY > 0)
	           || (fb == dir.left && wantX < 0) || (fb == dir.right && wantX > 0);
	into = pushing || (doorPrev != undefined && inst != doorPrev);
}
doorPrev = inst;
// Homes and shops lock at night and out of hours (door_lock_reason)
var locked = into ? door_lock_reason(room_get_name(inst.targetRoom)) : "";
if(locked != "" && game.hudTime <= 0){
	farm_message(locked);
	hint("locked", "Homes and shops keep hours. Talk to a shopkeeper and press T to hear theirs.");
}
if (into and locked == "" and !busy){
	
	with(game){
		spawnRoom= inst.targetRoom;
		spawnX = inst.targetX;
		spawnY = inst.targetY;
		spawnPlayerFacing = inst.PlayerFacingAfter;
		doTransition = true;

}}

	
