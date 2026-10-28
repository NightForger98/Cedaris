/// The player's inventory, equipment and dye slots (Terraria-style). Lives in global.inv:
///   mode    "story" or "free"
///   slots   40 stacks (undefined = empty); slots 0-9 are the hotbar
///   equip   {slot key: stack} worn clothing, one per equipment slot
///   dyes    {slot key: stack} dye recolouring the piece in that equipment slot
///   trash, gold, hotbar (selected hotbar slot 0-9)
/// A location in it is {area: "inv", index} | {area: "equip", key} | {area: "dye", key} | {area: "trash"}.

#macro INV_SIZE 40
#macro INV_HOTBAR 10

function inv_new(_mode){
	var inv = {mode: _mode, slots: array_create(INV_SIZE, undefined), equip: {}, dyes: {}, trash: undefined, gold: 0, hotbar: 0, tools: {}, water: 40};
	var keys = item_equip_slots();
	for(var i = 0; i < array_length(keys); i++){ inv.equip[$ keys[i]] = undefined; inv.dyes[$ keys[i]] = undefined; }
	return inv;
}

function inv_is_free(){ return variable_global_exists("inv") && is_struct(global.inv) && global.inv.mode == "free"; }

function inv_pal_name(_material, _colour){
	var p = character_find_palette(_material, _colour);
	return (p == -1) ? "" : sprite_get_name(p);
}

/// @description Story mode start: red shirt, blue pants, brown shoes, a little gold and some materials and dyes to try.
function inv_new_story(){
	var inv = inv_new("story");
	inv.equip.shirt = item_stack("c|shirt|Longsleeve", 1, inv_pal_name("cloth", "red"));
	inv.equip.pants = item_stack("c|pants|Pants", 1, inv_pal_name("cloth", "blue"));
	inv.equip.shoes = item_stack("c|shoes|Basic Shoes", 1, inv_pal_name("cloth", "brown"));
	inv.gold = 120;
	inv.water = 40;
	// Every farmer starts with the basic tools and some seeds (as in Stardew)
	inv.slots[0] = item_stack("c|held|Hoe");
	inv.slots[1] = item_stack("c|held|Watering Can");
	inv.slots[2] = item_stack("s|potato", 5);
	inv.slots[3] = item_stack("s|carrot", 10);
	inv.slots[4] = item_stack("c|held|Axe");
	inv.slots[5] = item_stack("c|held|Pickaxe");
	inv.slots[6] = item_stack("c|held|Scythe");
	global.inv = inv;
	inv_add(item_stack("m|linen", 6));
	inv_add(item_stack("m|leather", 4));
	inv_add(item_stack("m|wool", 2));
	inv_add(item_stack("m|cotton", 4));
	inv_add(item_stack("m|feather", 2));
	inv_add(item_stack("d|cloth|green", 1));
	inv_add(item_stack("d|cloth|yellow", 1));
	return inv;
}

/// @description Free mode start: everything from the character creator, worn; the held item goes on the hotbar.
function inv_new_free(_look){
	var inv = inv_new("free");
	inv.gold = 9999;
	var keys = item_equip_slots();
	var cat = lpc_catalog().items;
	for(var i = 0; i < array_length(keys); i++){
		var part = _look.parts[$ keys[i]];
		if(part == undefined || part.item == -1) continue;
		inv.equip[$ keys[i]] = item_stack("c|" + keys[i] + "|" + cat[part.item].name, 1, (part.pal == -1) ? "" : sprite_get_name(part.pal));
	}
	var held = _look.parts.held;
	inv.water = 40;
	inv.slots[0] = item_stack("c|held|Hoe");
	inv.slots[1] = item_stack("c|held|Watering Can");
	inv.slots[2] = item_stack("s|potato", 20);
	inv.slots[3] = item_stack("s|carrot", 20);
	inv.slots[4] = item_stack("c|held|Axe");
	inv.slots[5] = item_stack("c|held|Pickaxe");
	inv.slots[6] = item_stack("c|held|Scythe");
	var starters = ["Hoe", "Watering Can", "Axe", "Pickaxe", "Scythe"];
	if(held.item != -1 && array_get_index(starters, cat[held.item].name) == -1)
		inv.slots[7] = item_stack("c|held|" + cat[held.item].name, 1, (held.pal == -1) ? "" : sprite_get_name(held.pal));
	return inv;
}

/// @description Add a stack to the inventory (merging, hotbar first). Returns how many didn't fit.
function inv_add(_stack){
	var inv = global.inv;
	var d = item_def(_stack.id);
	var left = _stack.count;
	for(var i = 0; i < INV_SIZE && left > 0; i++){
		var s = inv.slots[i];
		if(s != undefined && s.id == _stack.id && s.pal == _stack.pal && s.count < d.max){
			var n = min(left, d.max - s.count);
			s.count += n;
			left -= n;
		}
	}
	for(var i = 0; i < INV_SIZE && left > 0; i++){
		if(inv.slots[i] == undefined){
			var n = min(left, d.max);
			inv.slots[i] = item_stack(_stack.id, n, _stack.pal);
			left -= n;
		}
	}
	return left;
}

function inv_count(_id){
	var n = 0;
	for(var i = 0; i < INV_SIZE; i++){
		var s = global.inv.slots[i];
		if(s != undefined && s.id == _id) n += s.count;
	}
	return n;
}

function inv_take(_id, _n){
	if(inv_count(_id) < _n) return false;
	for(var i = INV_SIZE - 1; i >= 0 && _n > 0; i--){
		var s = global.inv.slots[i];
		if(s == undefined || s.id != _id) continue;
		var t = min(_n, s.count);
		s.count -= t;
		_n -= t;
		if(s.count <= 0) global.inv.slots[i] = undefined;
	}
	return true;
}

function inv_get(_loc){
	var inv = global.inv;
	switch(_loc.area){
		case "inv":   return inv.slots[_loc.index];
		case "equip": return inv.equip[$ _loc.key];
		case "dye":   return inv.dyes[$ _loc.key];
		case "trash": return inv.trash;
	}
	return undefined;
}

function inv_set(_loc, _stack){
	var inv = global.inv;
	switch(_loc.area){
		case "inv":   inv.slots[_loc.index] = _stack; break;
		case "equip": inv.equip[$ _loc.key] = _stack; break;
		case "dye":   inv.dyes[$ _loc.key] = _stack; break;
		case "trash": inv.trash = _stack; break;
	}
}

function inv_same_loc(_a, _b){
	if(_a == undefined || _b == undefined || _a.area != _b.area) return false;
	if(_a.area == "inv") return _a.index == _b.index;
	if(_a.area == "trash") return true;
	return _a.key == _b.key;
}

/// @description Can _stack go in _loc? Returns "" if yes, else the reason.
function inv_can_place(_loc, _stack, _look){
	if(_stack == undefined) return "";
	var d = item_def(_stack.id);
	switch(_loc.area){
		case "equip":
			if(d.type != "clothing" || d.slot != _loc.key) return "That doesn't go in the " + item_slot_label(_loc.key) + " slot";
			if(!character_item_fits(d.cat, _look.body)) return "It doesn't come in your size";
			if(!character_race_allows(character_race(_look.race), d.slot, d.cat)) return "Your race can't wear that";
			return "";
		case "dye":
			if(d.type != "dye") return "Only dyes go in dye slots";
			return "";
	}
	return "";
}

/// @description The stack in the selected hotbar slot, or undefined.
function inv_held_stack(){ return global.inv.slots[global.inv.hotbar]; }

/// @description Dress a look in the equipped items, dyes and held item.
function inv_apply_look(_look){
	var inv = global.inv;
	var keys = item_equip_slots();
	for(var i = 0; i < array_length(keys); i++){
		var part = _look.parts[$ keys[i]];
		var st = inv.equip[$ keys[i]];
		part.item = -1;
		part.pal = -1;
		if(st != undefined){
			var d = item_def(st.id);
			part.item = d.cat;
			if(st.pal != "") part.pal = asset_get_index(st.pal);
			// A dye wins over the piece's own colour when it suits the material
			var dye = inv.dyes[$ keys[i]];
			if(dye != undefined){
				var dd = item_def(dye.id);
				if(dd.material == d.material && dd.pal != -1) part.pal = dd.pal;
			}
		}
		part.want = part.item;
	}
	var h = inv_held_stack();
	var hd = (h == undefined) ? undefined : item_def(h.id);
	_look.parts.held.item = (hd != undefined && hd.type == "held") ? hd.cat : -1;
	_look.parts.held.pal = (hd != undefined && hd.type == "held" && h.pal != "") ? asset_get_index(h.pal) : -1;
	_look.parts.held.want = _look.parts.held.item;
	inv.stats = inv_stats();
}

/// @description Total stats of everything equipped (they stack).
function inv_stats(){
	var total = {};
	var keys = STAT_KEYS;
	for(var i = 0; i < array_length(keys); i++) total[$ keys[i]] = 0;
	var slots = item_equip_slots();
	for(var i = 0; i < array_length(slots); i++){
		var st = global.inv.equip[$ slots[i]];
		if(st == undefined) continue;
		var s = item_def(st.id).stats;
		for(var k = 0; k < array_length(keys); k++) total[$ keys[k]] += s[$ keys[k]] ?? 0;
	}
	return total;
}

/// @description Walking speed multiplier from the Speed stat: +5% per point, between -30% and +40%.
function inv_speed_multiplier(){
	if(!variable_global_exists("inv") || !is_struct(global.inv)) return 1;
	return 1 + clamp(stat("speed") * 0.05, -0.3, 0.4);
}

/// @description A shop price after the Charm discount: 1% off per point, up to 30%.
function inv_charmed_price(_price){
	if(inv_is_free()) return 0;
	var charm = stat("charm");
	return max(1, round(_price * (1 - clamp(charm * 0.01, 0, 0.3))));
}

/// @description Recipes the player can see: in story mode only what fits them; free mode shows everything.
function inv_recipe_ok(_r, _look){
	return character_item_fits(_r.cat, _look.body) && character_race_allows(character_race(_look.race), _r.slot, _r.cat);
}

/// @description True if the player has the materials, or produce for cooking (always true in free mode).
function inv_can_afford(_cost){
	if(inv_is_free()) return true;
	var names = variable_struct_get_names(_cost);
	for(var i = 0; i < array_length(names); i++){
		if(cost_count(names[i]) < _cost[$ names[i]]) return false;
	}
	return true;
}

/// @description Craft: spend the materials (story mode) and add the item. Returns "" or the reason it failed.
function inv_craft(_id, _cost){
	if(!inv_can_afford(_cost)) return "Not enough materials";
	if(!inv_is_free()){
		var names = variable_struct_get_names(_cost);
		for(var i = 0; i < array_length(names); i++) cost_take(names[i], _cost[$ names[i]]);
	}
	if(inv_add(item_stack(_id, 1)) > 0) return "Your inventory is full";
	return "";
}

// ---------------------------------------------------------------- saving

function inv_stack_to_save(_s){ return (_s == undefined) ? undefined : {id: _s.id, count: _s.count, pal: _s.pal}; }

function inv_to_save(){
	var inv = global.inv;
	var out = {mode: inv.mode, gold: inv.gold, hotbar: inv.hotbar, slots: [], equip: {}, dyes: {}, trash: inv_stack_to_save(inv.trash),
	           tools: inv.tools, water: inv.water, spells: inv[$ "spells"] ?? [], spell: inv[$ "spell"] ?? "",
	           cursed: inv[$ "cursed"] ?? "", cursePending: inv[$ "cursePending"] ?? false};
	for(var i = 0; i < INV_SIZE; i++) array_push(out.slots, inv_stack_to_save(inv.slots[i]));
	var keys = item_equip_slots();
	for(var i = 0; i < array_length(keys); i++){
		out.equip[$ keys[i]] = inv_stack_to_save(inv.equip[$ keys[i]]);
		out.dyes[$ keys[i]] = inv_stack_to_save(inv.dyes[$ keys[i]]);
	}
	return out;
}

// JSON null can come back as something other than undefined, so only structs count as stacks
function inv_stack_from_save(_s){ return is_struct(_s) ? item_stack(_s.id, _s.count, _s.pal) : undefined; }

function inv_from_save(_data){
	var inv = inv_new(_data.mode);
	inv.gold = _data.gold;
	inv.hotbar = _data.hotbar;
	inv.trash = inv_stack_from_save(_data.trash);
	// Tool tiers and the watering can came with save version 3
	inv.tools = is_struct(_data[$ "tools"]) ? _data.tools : {};
	inv.water = _data[$ "water"] ?? 40;
	inv.cursed = _data[$ "cursed"] ?? "";              // the witch's curse (status script)
	inv.cursePending = _data[$ "cursePending"] ?? false;
	// Spells came with save version 5
	inv.spells = is_array(_data[$ "spells"]) ? _data.spells : [];
	inv.spell = _data[$ "spell"] ?? "";
	for(var i = 0; i < min(INV_SIZE, array_length(_data.slots)); i++) inv.slots[i] = inv_stack_from_save(_data.slots[i]);
	var keys = item_equip_slots();
	for(var i = 0; i < array_length(keys); i++){
		inv.equip[$ keys[i]] = inv_stack_from_save(_data.equip[$ keys[i]]);
		inv.dyes[$ keys[i]] = inv_stack_from_save(_data.dyes[$ keys[i]]);
	}
	return inv;
}
