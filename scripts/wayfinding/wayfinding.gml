/// Finding your way: a signpost by every way from one outdoor place to another, naming where it leads. Nothing is
/// placed by hand - they follow the room's exits (obj_transition), so a new road gets its sign by itself.

/// @description Room Start, outdoors: a signpost just inside each exit to another outdoor place, beside the way
/// (not on it), on the side of the room the exit is on.
function signposts_place(){
	if(!room_is_outdoors()) return;
	var made = [];
	with(obj_transition){
		if(targetRoom == -1 || !room_is_outdoors(targetRoom)) continue;
		var side = (bbox_top < 64) ? "n" : ((bbox_bottom > room_height - 64) ? "s" : ((bbox_left < 64) ? "w" : ((bbox_right > room_width - 64) ? "e" : "")));
		if(side == "") continue;   // a way out in the middle of a room (none yet)
		var sx, sy;
		switch(side){
			case "n": sx = bbox_right + 28; sy = bbox_bottom + 44; break;
			case "s": sx = bbox_right + 28; sy = bbox_top - 20;    break;
			case "w": sx = bbox_right + 44; sy = bbox_top - 22;    break;
			case "e": sx = bbox_left - 44;  sy = bbox_top - 22;    break;
		}
		sx = clamp(sx, 24, room_width - 24);
		sy = clamp(sy, 40, room_height - 8);
		// One sign per way out, even where an exit is split into pieces
		var dup = false;
		for(var i = 0; i < array_length(made); i++) if(made[i][0] == targetRoom && point_distance(made[i][1], made[i][2], sx, sy) < 200) dup = true;
		if(dup) continue;
		array_push(made, [targetRoom, sx, sy]);
		instance_create_layer(sx, sy, "Instances", obj_signpost, {text: save_room_name(room_get_name(targetRoom)), side: side});
	}
}
