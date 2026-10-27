/// @description Inventory screen setup
// Opened with I, with E at the blacksmith (shop = true), or with E at a crafting table (craft = true). The world keeps running but the player can't move.
// Mouse: drag an item to move it, or click to pick it up and click again to put it down.
// Shift-click equips/unequips, right-click splits one off a stack (or sells it when the shop is open).
shop = false;   // set by Brom: the left panel is his shop
craft = false;  // set by a crafting table: the left panel is the crafting list
justOpened = true;  // ignore the key press that opened us
guiW = display_get_gui_width();
guiH = display_get_gui_height();
S = 52;           // slot size
G = 6;            // gap between slots
invX = 24; invY = 44;
trashX = invX + 9 * (S + G); trashY = invY + 4 * (S + G) + 8;
panelX1 = 24; panelY1 = 350; panelX2 = invX + 10 * (S + G) - G; panelY2 = guiH - 24;
previewX1 = 640; previewY1 = 44; previewX2 = 930; previewY2 = 420;
eqX = [980, 1210];  // left edge of each equipment column (dye slot, then item slot)
eqY = 44;
dyeS = 42;

cursor = undefined;   // stack carried by the mouse
origin = undefined;   // where it was picked up from
dragging = false;     // true while the button is held after picking up
message = "";
messageTime = 0;
filter = "";          // crafting filter: an equipment slot key, "dye", or "" for all
scroll = 0;
frame = 1;

showMessage = function(_t){ message = _t; messageTime = game_get_speed(gamespeed_fps) * 2.5; };

slotRect = function(_loc){
	switch(_loc.area){
		case "inv":
			var x1 = invX + (_loc.index mod 10) * (S + G), y1 = invY + (_loc.index div 10) * (S + G) + ((_loc.index >= INV_HOTBAR) ? 8 : 0);
			return [x1, y1, x1 + S, y1 + S];
		case "trash": return [trashX, trashY, trashX + S, trashY + S];
		case "equip":
		case "dye":
			var i = array_get_index(item_equip_slots(), _loc.key);
			var col = i div 8, row = i mod 8;
			var y1 = eqY + row * (S + 10);
			if(_loc.area == "dye") return [eqX[col], y1 + (S - dyeS) / 2, eqX[col] + dyeS, y1 + (S - dyeS) / 2 + dyeS];
			return [eqX[col] + dyeS + 8, y1, eqX[col] + dyeS + 8 + S, y1 + S];
	}
};

allLocs = [];
for(var i = 0; i < INV_SIZE; i++) array_push(allLocs, {area: "inv", index: i});
var keys = item_equip_slots();
for(var i = 0; i < array_length(keys); i++){
	array_push(allLocs, {area: "equip", key: keys[i]});
	array_push(allLocs, {area: "dye", key: keys[i]});
}
array_push(allLocs, {area: "trash"});

slotAt = function(_mx, _my){
	for(var i = 0; i < array_length(allLocs); i++){
		var r = slotRect(allLocs[i]);
		if(_mx >= r[0] && _mx < r[2] && _my >= r[1] && _my < r[3]) return allLocs[i];
	}
	return undefined;
};

/// The player's look, kept in sync with the equipment
changed = function(){
	inv_apply_look(global.look);
	if(instance_exists(obj_plyr)) obj_plyr.look = global.look;
};

/// Put the carried stack into a slot: place, merge, or swap. Returns false if it isn't allowed there.
place = function(_loc){
	var why = inv_can_place(_loc, cursor, global.look);
	if(why != ""){ showMessage(why); return false; }
	var target = inv_get(_loc);
	if(_loc.area == "trash"){ inv_set(_loc, cursor); cursor = undefined; }
	else if(target == undefined){ inv_set(_loc, cursor); cursor = undefined; }
	else if(target.id == cursor.id && target.pal == cursor.pal && target.count < item_def(target.id).max){
		var n = min(cursor.count, item_def(target.id).max - target.count);
		target.count += n;
		cursor.count -= n;
		if(cursor.count <= 0) cursor = undefined;
	} else {
		// Swapping out of an equipment slot: the incoming item must fit there (checked above)
		inv_set(_loc, cursor);
		cursor = target;
	}
	if(cursor == undefined) origin = undefined;
	changed();
	return true;
};

/// A drag that ends nowhere useful puts the item back where it came from
snapBack = function(){
	if(cursor != undefined && origin != undefined && inv_get(origin) == undefined){
		inv_set(origin, cursor);
		cursor = undefined;
		origin = undefined;
		changed();
	}
};

/// Shift-click: equip from the inventory, or take off into the inventory
quickMove = function(_loc){
	var st = inv_get(_loc);
	if(st == undefined) return;
	var d = item_def(st.id);
	if(_loc.area == "inv"){
		var dest = undefined;
		if(d.type == "clothing") dest = {area: "equip", key: d.slot};
		else if(d.type == "dye"){
			// First dye slot whose piece takes this dye, else the first empty one
			var keys = item_equip_slots();
			for(var i = 0; i < array_length(keys) && dest == undefined; i++){
				var eq = global.inv.equip[$ keys[i]];
				if(global.inv.dyes[$ keys[i]] == undefined && eq != undefined && item_def(eq.id).material == d.material) dest = {area: "dye", key: keys[i]};
			}
		}
		if(dest == undefined){ showMessage("Nowhere to put that"); return; }
		var why = inv_can_place(dest, st, global.look);
		if(why != ""){ showMessage(why); return; }
		var old = inv_get(dest);
		inv_set(dest, item_stack(st.id, 1, st.pal));
		st.count--;
		if(st.count <= 0) inv_set(_loc, old);
		else if(old != undefined && inv_add(old) > 0) inv_set(dest, old);
	} else {
		if(inv_add(st) > 0){ showMessage("Your inventory is full"); return; }
		inv_set(_loc, undefined);
	}
	changed();
};

/// Closing: anything still on the mouse goes back into the bag
returnCursor = function(){
	if(cursor == undefined) return;
	var left = inv_add(cursor);
	if(left > 0 && origin != undefined && inv_get(origin) == undefined){ cursor.count = left; inv_set(origin, cursor); }
	cursor = undefined;
	origin = undefined;
	changed();
};

/// Crafting list for the current filter: free mode shows everything; story mode shows what you can make,
/// or with a filter, everything for that slot (dimmed if you lack materials) so you can see what to collect.
recipeList = function(){
	var out = [];
	if(filter == "dye" || (inv_is_free() && filter == "")){
		if(inv_is_free()){
			var dyes = item_dye_ids();
			for(var i = 0; i < array_length(dyes); i++) array_push(out, {id: dyes[i], cost: {}});
		}
		if(filter == "dye") return out;
	}
	var all_r = item_recipes();
	for(var i = 0; i < array_length(all_r); i++){
		var r = all_r[i];
		if(filter != "" && r.slot != filter) continue;
		if(!inv_recipe_ok(r, global.look)) continue;
		if(filter == "" && !inv_can_afford(r.cost)) continue;
		array_push(out, r);
	}
	return out;
};

changed();
