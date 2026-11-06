/// The cable car (Phoenix Bay by Hangar 12 <-> the Mountain top) and the tram (its stops across Beirut, the Outskirts
/// and the Countryside). Each runs once its town project is done (the board in Downtown: "cablecar", "tram"); until
/// then its stations stand idle. Stations are obj_transit, placed by the world builder (tools/world2/areas_build.js)
/// in front of their art; world_transit() lists them all.

/// @description The project that gets a kind of station running.
function transit_project(_kind){ return (_kind == "cable") ? "cablecar" : "tram"; }

/// @description Whether a kind of station runs (its project is done; free mode: always).
function transit_runs(_kind){ return project_done(transit_project(_kind)) || (variable_global_exists("gameMode") && global.gameMode == "free"); }

/// @description The other stations of a kind, from the one named _from: [{kind, name, room, x, y}...]
function transit_others(_kind, _from){
	var t = world_transit(), out = [];
	for(var i = 0; i < array_length(t); i++) if(t[i].kind == _kind && t[i].name != _from) array_push(out, t[i]);
	return out;
}

/// @description The fare: the cable car 50 gold, the tram 20 (free mode: nothing).
function transit_fare(_kind){
	if(variable_global_exists("gameMode") && global.gameMode == "free") return 0;
	return (_kind == "cable") ? 50 : 20;
}

/// @description Ride to a station (pays the fare; fades out and in there). Returns a message.
function transit_ride(_st){
	var fare = transit_fare(_st.kind);
	if(global.inv.gold < fare) return "You need " + string(fare) + " gold for the fare";
	global.inv.gold -= fare;
	with(game){
		spawnRoom = asset_get_index(_st.room);
		spawnX = _st.x; spawnY = _st.y;
		spawnPlayerFacing = dir.down;
		restartRoom = (room == spawnRoom);
		doTransition = true;
	}
	return "";
}

/// @description Whether a station's menu (the tram's stops) is open.
function transit_menu_open(){
	var open = false;
	with(obj_transit) if(menuOpen) open = true;
	return open;
}
