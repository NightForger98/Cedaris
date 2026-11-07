/// @description Insert description here
// You can write your code in this editor

roomWidth = room_width;
roomHeight = room_height;

// Entering a play room without going through the creator (e.g. running a room directly): free-mode defaults
if(game_is_playing_room()){
	if(!variable_global_exists("look") || !is_struct(global.look)) global.look = character_default_look();
	if(!variable_global_exists("inv") || !is_struct(global.inv)) global.inv = inv_new_free(global.look);
	if(!world_time_ready()) world_time_new();
	inv_apply_look(global.look);
	with(obj_plyr) look = global.look;
	// The mine builds its floor (and puts you at the entrance); elsewhere trees, rocks and weeds from the world store,
	// plus any that are due to spawn
	if(room == rm_mine) mine_room_start();
	else { global.mineWalls = -1; resources_room_start(); placeables_room_start(); furniture_room_start(); animals_room_start(); festival_room_start(); woods_room_start(); }
	villagers_update(); // whoever's here at this hour
	signposts_place();  // a sign by each way to another place
	if(layer_exists("Buildings_preview")) layer_set_visible("Buildings_preview", false);   // (the editor's view of the buildings; the real ones are obj_building)
	// the buildings you've been into (the world map marks them)
	if(!room_is_outdoors() && room != rm_mine && variable_global_exists("world") && is_struct(global.world)){ if(!is_struct(global.world[$ "visited"])) global.world.visited = {}; global.world.visited[$ room_get_name(room)] = true; }
	ground_season_apply();   // the ground in this season's colours (scripts/ground)
}

// After sleeping: wake up beside the bed, facing down, then autosave. After being knocked out: no autosave,
// and the morning message says what it cost.
if(wakeAtBed){
	wakeAtBed = false;
	sleeping = false;
	dying = false;
	sleepDone = false;
	waking = true;
	autosavePending = !revived;
	if(revived){
		revived = false;
		hudMessage = deathReport;
		hudTime = game_get_speed(gamespeed_fps) * 7;
	}
	if(instance_exists(obj_bed) && instance_exists(obj_plyr)){
		obj_plyr.x = obj_bed.x;
		obj_plyr.y = obj_bed.y + 56;
		obj_plyr.y_frame = 10;
	}
	exit;
}

// Place the player where the transition or loaded save says, only in that room
if(spawnRoom == -1 || room != spawnRoom || !instance_exists(obj_plyr)) exit;
obj_plyr.x=spawnX;
obj_plyr.y=spawnY;
obj_plyr.facing = spawnPlayerFacing;
// A save from before a room was rebuilt can put you inside what stands there now: step out to the nearest free spot
with(obj_plyr){
	var solids = collision_solids(false);
	if(place_meeting(x, y, solids)){
		var x0 = x, y0 = y, found = false;
		for(var d = 1; d <= 30 && !found; d++) for(var k = 0; k < 8 * d && !found; k++){
			var a = k / (8 * d) * 2 * pi, tx = x0 + round(cos(a) * d * 16), ty = y0 + round(sin(a) * d * 16);
			if(tx < 16 || ty < 16 || tx > room_width - 16 || ty > room_height - 16) continue;
			if(!place_meeting(tx, ty, solids)){ x = tx; y = ty; found = true; }
		}
	}
}

with(obj_plyr){

switch(facing){
case  dir.left:		 y_frame = 9;break;
case  dir.right:	 y_frame = 11;break;
case  dir.up:		 y_frame = 8;break;
case  dir.down:		 y_frame = 10;break;
case  -1:			 x_frame = 0;break;
}}	











