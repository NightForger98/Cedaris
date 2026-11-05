/// Whispering Woods (rm_yarzeh, once Yarzeh Woods): the valley's deep wood. It used to lead on to Whisperwood, a
/// forest generated at runtime; that's gone (2026-11-06) and Whispering Woods is the wood itself now: thick with trees
/// (tools/world: dense), the best forage (world_resource_areas), the old shrine in a clearing, and at night pixies and
/// moths - the sources of pixie dust and moonsilk.

/// @description Room start in Whispering Woods: at night, pixies and moths flit about its clearings.
function woods_room_start(){
	if(room != rm_yarzeh) return;
	if(global.clock.minutes < 1200 && global.clock.minutes >= DAY_START) return;
	var spots = [], names = ["nw", "ne", "sw", "se"];
	for(var i = 0; i < 4; i++){
		var a = layout_cells("rm_yarzeh", names[i]);
		if(a == undefined) continue;
		repeat(12){
			var cx = irandom_range(a[0], a[2]) * 32 + 16, cy = irandom_range(a[1], a[3]) * 32 + 16;
			if(!position_meeting(cx, cy, obj_col_box) && !position_meeting(cx, cy, obj_resource)) array_push(spots, [cx, cy]);
		}
	}
	repeat(min(array_length(spots), 7)){
		var k = irandom(array_length(spots) - 1), c = spots[k];
		array_delete(spots, k, 1);
		monster_spawn(choose("pixie", "pixie", "moth", "moth", "moth"), c[0], c[1], 1);
	}
}

// ---------------------------------------------------------------- foraging

/// @description Wild things to pick in the woods (Whispering Woods has the most): item ids "w|<key>". Eaten from the hotbar like produce (energy),
/// or sold. Art: a part of spr_tile_terrain, for the icon.
function forage_table(){
	static t = {
		mushroom:  {name: "Wild Mushroom", energy: 20, sell: 25, art: [862, 893, 43, 34], desc: "Earthy and good in a stew."},
		toadstool: {name: "Red Toadstool", energy: 0,  sell: 60, art: [830, 994, 32, 30], desc: "Pretty, but don't eat it. Elda might want it."},
		herb:      {name: "Wild Herb",     energy: 10, sell: 18, art: [416, 453, 30, 33], desc: "Fragrant leaves from the forest floor."},
	};
	return t;
}

/// @description Eat a forage item from the hotbar. Returns false if it isn't something you'd eat.
function forage_eat(_stack){
	var key = string_split(_stack.id, "|")[1];
	var f = forage_table()[$ key];
	if(f == undefined || f.energy <= 0){ farm_message("You'd rather not eat that"); return false; }
	global.vitals.energy = min(vitals_max_energy(), global.vitals.energy + f.energy);
	_stack.count--;
	if(_stack.count <= 0) global.inv.slots[global.inv.hotbar] = undefined;
	farm_message("Ate " + f.name + "  (+" + string(f.energy) + " energy)");
	return true;
}

