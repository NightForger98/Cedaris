/// Whispering Woods (rm_yarzeh, once Yarzeh Woods): the valley's deep wood. It used to lead on to Whisperwood, a
/// forest generated at runtime; that's gone (2026-11-06) and Whispering Woods is the wood itself now: thick with trees
/// (tools/world: dense), the best forage (world_resource_areas), the old shrine in a clearing, and at night pixies and
/// moths - the sources of pixie dust and moonsilk.

/// @description Room start in Whispering Woods: at night, pixies and moths flit about its clearings.
function woods_room_start(){
	if(room != rm_woods) return;
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
		mushroom:  {name: "Wild Mushroom", energy: 20, sell: 25, art: [862, 893, 43, 34], spr: "spr_res_mushroom", desc: "Earthy and good in a stew."},
		toadstool: {name: "Red Toadstool", energy: 0,  sell: 60, art: [830, 994, 32, 30], spr: "spr_res_toadstool", desc: "Pretty, but don't eat it. Elda might want it."},
		herb:      {name: "Wild Herb",     energy: 10, sell: 18, art: [416, 453, 30, 33], spr: "spr_res_herb", desc: "Fragrant leaves from the forest floor."},
		// Seasonal flowers (2026-11-07): pick them, sell them, give them, or put one in a vase (furniture)
		tulip:         {name: "Tulip",         energy: 0, sell: 30, art: [416, 453, 30, 33], spr: "spr_flower_tulip",         flower: true, desc: "A spring tulip. Lovely in a vase."},
		daffodil:      {name: "Daffodil",      energy: 0, sell: 30, art: [416, 453, 30, 33], spr: "spr_flower_daffodil",      flower: true, desc: "A cheerful spring daffodil. Lovely in a vase."},
		sunflower:     {name: "Sunflower",     energy: 0, sell: 45, art: [416, 453, 30, 33], spr: "spr_flower_sunflower",     flower: true, desc: "A tall summer sunflower. Lovely in a vase."},
		poppy:         {name: "Poppy",         energy: 0, sell: 35, art: [416, 453, 30, 33], spr: "spr_flower_poppy",         flower: true, desc: "A bright red summer poppy. Lovely in a vase."},
		aster:         {name: "Aster",         energy: 0, sell: 35, art: [416, 453, 30, 33], spr: "spr_flower_aster",         flower: true, desc: "A purple autumn aster. Lovely in a vase."},
		chrysanthemum: {name: "Chrysanthemum", energy: 0, sell: 40, art: [416, 453, 30, 33], spr: "spr_flower_chrysanthemum", flower: true, desc: "An orange autumn chrysanthemum. Lovely in a vase."},
		snowdrop:      {name: "Snowdrop",      energy: 0, sell: 45, art: [416, 453, 30, 33], spr: "spr_flower_snowdrop",      flower: true, desc: "A brave winter snowdrop. Lovely in a vase."},
		crocus:        {name: "Crocus",        energy: 0, sell: 45, art: [416, 453, 30, 33], spr: "spr_flower_crocus",        flower: true, desc: "A purple crocus in the snow. Lovely in a vase."},
		// The beach and the bushes
		seashell:  {name: "Seashell",      energy: 0,  sell: 30, art: [416, 453, 30, 33], spr: "spr_res_seashell", desc: "A pink spiral shell from the shore."},
		coral:     {name: "Coral",         energy: 0,  sell: 70, art: [416, 453, 30, 33], spr: "spr_res_coral", desc: "A branch of red coral, washed up on the beach."},
		berry:     {name: "Wild Berries",  energy: 15, sell: 12, art: [416, 453, 30, 33], spr: "spr_res_berry_bush", desc: "Sweet berries from a wild bush."},
	};
	return t;
}

/// @description Eat a forage item from the hotbar. Returns false if it isn't something you'd eat.
function forage_eat(_stack){
	var key = string_split(_stack.id, "|")[1];
	var f = forage_table()[$ key];
	if(f == undefined) return false;
	if(f[$ "flower"] ?? false){ if(!furniture_vase_fill(_stack)) farm_message("Put it in a vase - Rowan sells them"); return true; }   // (scripts/furniture)
	if(f.energy <= 0){ farm_message("You'd rather not eat that"); return false; }
	var en = f.energy * (skill_has("herbalist") ? 2 : 1);   // the Herbalist (scripts/skills)
	global.vitals.energy = min(vitals_max_energy(), global.vitals.energy + en);
	_stack.count--;
	if(_stack.count <= 0) global.inv.slots[global.inv.hotbar] = undefined;
	farm_message("Ate " + f.name + "  (+" + string(en) + " energy)");
	return true;
}

