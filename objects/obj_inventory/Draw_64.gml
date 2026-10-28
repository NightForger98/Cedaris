/// @description Draw the inventory, equipment, preview and crafting / shop panel
var c = ui_colours();
var mx = device_mouse_x_to_gui(0);
var my = device_mouse_y_to_gui(0);
var body = global.look.body;
var inv = global.inv;
var hover = slotAt(mx, my);
var tip = undefined;   // stack under the mouse, for the tooltip
var tipExtra = "";
draw_set_font(fnt_eq);

// Dim the world
draw_set_alpha(0.55);
draw_rectangle_colour(0, 0, guiW, guiH, c_black, c_black, c_black, c_black, false);
draw_set_alpha(1);

ui_text(invX, 22, "Inventory", 0.75, c.accent, fa_left);
ui_text(eqX[0], 22, "Equipment", 0.75, c.accent, fa_left);
ui_text(eqX[0], eqY + 8 * (S + 10) + 6, "Dye slots (left) recolour the piece beside them", 0.45, c.dim, fa_left);

// Every slot
for(var i = 0; i < array_length(allLocs); i++){
	var loc = allLocs[i];
	var r = slotRect(loc);
	var st = inv_get(loc);
	var isHover = (hover != undefined && inv_same_loc(hover, loc));
	var bg = c.panel;
	if(loc.area == "inv" && loc.index < INV_HOTBAR) bg = merge_colour(c.panel, c.button, 0.35);
	if(loc.area == "dye") bg = merge_colour(c.panel, make_colour_rgb(70, 40, 80), 0.6);
	if(loc.area == "trash") bg = merge_colour(c.panel, make_colour_rgb(90, 30, 30), 0.6);
	draw_set_colour(isHover ? c.hover : bg);
	draw_roundrect_ext(r[0], r[1], r[2], r[3], 8, 8, false);
	if(loc.area == "inv" && loc.index == inv.hotbar){
		draw_set_colour(c.accent);
		draw_roundrect_ext(r[0], r[1], r[2], r[3], 8, 8, true);
	}
	if(st != undefined){
		item_draw_icon(st, r[0], r[1], r[2] - r[0], body);
		if(isHover) tip = st;
	} else {
		// Faint label in empty slots
		var lab = "";
		if(loc.area == "equip") lab = item_slot_label(loc.key);
		if(loc.area == "dye") lab = "dye";
		if(loc.area == "trash") lab = "trash";
		if(lab != "") ui_text((r[0] + r[2]) / 2, (r[1] + r[3]) / 2, lab, 0.36, c.dim);
	}
	if(loc.area == "inv" && loc.index < INV_HOTBAR){
		ui_text(r[0] + 6, r[1] + 9, string((loc.index + 1) mod 10), 0.4, c.dim, fa_left);
	}
}
ui_text(invX, trashY + S / 2, "Gold: " + (inv_is_free() ? "unlimited" : string(inv.gold)), 0.7, c.accent, fa_left);
ui_text(trashX - 10, trashY + S / 2, (inv.mode == "story") ? "Story mode" : "Free mode", 0.5, c.dim, fa_right);

// Character preview
draw_set_colour(c.panel);
draw_roundrect_ext(previewX1, previewY1, previewX2, previewY2, 14, 14, false);
var pcx = (previewX1 + previewX2) / 2;
ui_text(pcx, previewY1 + 20, global.look.race + " " + global.look.body, 0.55, c.dim);
character_draw(global.look, floor(frame), 10, pcx - 128, previewY1 + 18, 4);
// Total stats of everything worn (they stack)
// Stats right now: what you wear plus your food buff (buffed stats in blue)
var keys = STAT_KEYS, buff = food_buff();
for(var i = 0; i < array_length(keys); i++){
	var col = i mod 4, row = i div 4;
	var sx = previewX1 + 16 + col * 68 + (row == 1 ? 34 : 0), sy = previewY2 - 52 + row * 26;
	var v = stat(keys[i]);
	var vc = (v > 0) ? c.accent : ((v < 0) ? make_colour_rgb(230, 110, 90) : c.dim);
	if(buff != undefined && (buff.stats[$ keys[i]] ?? 0) != 0) vc = make_colour_rgb(130, 200, 255);
	var abbr = ["DEF", "WRM", "SPD", "STA", "LCK", "CHA", "MAG"];
	ui_text(sx, sy, abbr[i] + " " + string(v), 0.45, vc, fa_left);
}
if(messageTime > 0) ui_text(pcx, previewY2 + 22, message, 0.6, c_white);

// Crafting or shop panel
draw_set_colour(c.panel);
draw_roundrect_ext(panelX1, panelY1, panelX2, panelY2, 14, 14, false);
var rowH = 50;
var listTop = panelY1 + 56;
var listBottom = panelY2 - 30;
var overPanel = (mx >= panelX1 && mx < panelX2 && my >= listTop && my < listBottom);

if(shop && upgrades){
	// Brom's tool upgrades: each tool you carry, its next tier and what it costs
	ui_text(panelX1 + 16, panelY1 + 26, "Tool Upgrades", 0.8, c.accent, fa_left);
	if(ui_button(panelX2 - 130, panelY1 + 10, panelX2 - 14, panelY1 + 42, "Shop", true, 0.5)){ upgrades = false; scroll = 0; }
	ui_text(panelX2 - 144, panelY1 + 26, "Faster work, less energy", 0.42, c.dim, fa_right);
	var tools = tool_upgrade_list();
	var tiers = tool_tiers();
	if(array_length(tools) == 0) ui_text((panelX1 + panelX2) / 2, (listTop + listBottom) / 2, "Bring a hoe, watering can, axe, pickaxe or scythe", 0.55, c.dim);
	for(var i = 0; i < array_length(tools); i++){
		var name = tools[i], cur = tool_tier(name);
		var y1 = listTop + i * rowH;
		item_draw_icon(item_stack("c|held|" + name), panelX1 + 14, y1 + 2, 44, body);
		if(cur >= TOOL_MITHRIL){
			ui_text(panelX1 + 70, y1 + rowH / 2, tool_display_name(name) + "  -  as good as it gets", 0.58, c.accent, fa_left);
			continue;
		}
		var nx = tiers[cur + 1];
		var haveBars = inv_is_free() || inv_count("m|" + nx.bar) >= nx.bars;
		var haveGold = inv_is_free() || inv.gold >= nx.gold;
		var over = overPanel && my >= y1 && my < y1 + rowH;
		if(over){ draw_set_colour(c.hover); draw_roundrect_ext(panelX1 + 8, y1, panelX2 - 8, y1 + rowH - 4, 8, 8, false); }
		ui_text(panelX1 + 70, y1 + rowH / 2 - 9, tool_display_name(name) + "  >  " + nx.name + " " + name, 0.56, (haveBars && haveGold) ? c_white : c.dim, fa_left);
		ui_text(panelX1 + 70, y1 + rowH / 2 + 12, tool_upgradable(name), 0.4, c.dim, fa_left);
		var red = make_colour_rgb(230, 110, 90);
		ui_text(panelX2 - 20, y1 + rowH / 2, inv_is_free() ? "free" : string(nx.gold) + " gold", 0.55, haveGold ? c.accent : red, fa_right);
		var cx2 = panelX2 - 130;
		ui_text(cx2, y1 + rowH / 2, string(nx.bars), 0.5, haveBars ? c_white : red, fa_right);
		item_draw_icon(item_stack("m|" + nx.bar), cx2 - 44, y1 + 8, 30, body);
		if(over && mouse_check_button_pressed(mb_left) && cursor == undefined){
			var why = tool_upgrade(name);
			showMessage((why == "") ? "Your " + string_lower(name) + " is now " + tool_display_name(name) : why);
			changed();
		}
	}
} else if(shop){
	ui_text(panelX1 + 16, panelY1 + 26, shopTitle, 0.8, c.accent, fa_left);
	var hdrRight = panelX2 - 16;
	if(smith){
		if(ui_button(panelX2 - 130, panelY1 + 10, panelX2 - 14, panelY1 + 42, "Upgrades", true, 0.5)){ upgrades = true; scroll = 0; }
		hdrRight = panelX2 - 144;
	}
	var charm = stat("charm");
	ui_text(hdrRight, panelY1 + 26, (charm > 0 && !inv_is_free()) ? "Charm discount " + string(min(30, charm)) + "%  -  right-click to sell" : "Right-click your items to sell", 0.45, c.dim, fa_right);
	var stock = shopStock;
	scroll = min(scroll, max(0, array_length(stock) * rowH - (listBottom - listTop)));
	for(var i = 0; i < array_length(stock); i++){
		var y1 = listTop + i * rowH - scroll;
		if(y1 < listTop - 1 || y1 + rowH > listBottom + 1) continue;
		var itemId = stock[i].id;
		var price = inv_charmed_price(stock[i].price);
		var afford = inv.gold >= price;
		var over = overPanel && my >= y1 && my < y1 + rowH;
		if(over){ draw_set_colour(c.hover); draw_roundrect_ext(panelX1 + 8, y1, panelX2 - 8, y1 + rowH - 4, 8, 8, false); tip = item_stack(itemId); }
		item_draw_icon(item_stack(itemId), panelX1 + 14, y1 + 2, 44, body);
		ui_text(panelX1 + 70, y1 + rowH / 2, item_def(itemId).name, 0.6, afford ? c_white : c.dim, fa_left);
		ui_text(panelX2 - 20, y1 + rowH / 2, (price == 0) ? "free" : string(price) + " gold", 0.55, afford ? c.accent : c.dim, fa_right);
		if(over && mouse_check_button_pressed(mb_left) && cursor == undefined){
			if(!afford) showMessage("Not enough gold");
			else if(inv_add(item_stack(itemId)) > 0) showMessage("Your inventory is full");
			else { inv.gold -= price; showMessage("Bought " + item_def(itemId).name); changed(); }
		}
	}
} else if(ship){
	// Shipping bin: what's in it and what it'll pay tomorrow morning
	ui_text(panelX1 + 16, panelY1 + 26, "Shipping Bin", 0.8, c.accent, fa_left);
	ui_text(panelX2 - 16, panelY1 + 26, "Right-click to ship one, Shift+right-click a stack", 0.42, c.dim, fa_right);
	var list = shipping_list();
	if(array_length(list) == 0) ui_text((panelX1 + panelX2) / 2, (listTop + listBottom) / 2, "Empty. Shipped items are paid for overnight.", 0.55, c.dim);
	for(var i = 0; i < array_length(list); i++){
		var y1 = listTop + i * 40;
		if(y1 + 40 > listBottom - 30) break;
		item_draw_icon(item_stack(list[i].id), panelX1 + 14, y1, 36, body);
		ui_text(panelX1 + 60, y1 + 18, item_def(list[i].id).name + "  x" + string(list[i].count), 0.55, c_white, fa_left);
		ui_text(panelX2 - 20, y1 + 18, string(item_sell_price(list[i].id) * list[i].count) + " gold", 0.55, c.accent, fa_right);
	}
	ui_text(panelX2 - 20, listBottom - 6, "Pays tomorrow: " + string(shipping_value()) + " gold", 0.6, c.accent, fa_right);
} else if(craft){
	var title = "Crafting Table";
	if(filter == "furnace") title = "Brom's Furnace";
	else if(filter == "cook") title = "Hearth - cooking";
	else if(filter == "weave") title += " - weaving";
	else if(filter == "build") title += " - building";
	else if(filter == "dye") title += " - dyes";
	else if(filter != "") title += " - " + item_slot_label(filter);
	ui_text(panelX1 + 16, panelY1 + 26, title, 0.8, c.accent, fa_left);
	if(fixedFilter){
		ui_text(panelX2 - 16, panelY1 + 26, (filter == "cook") ? "Click a dish to cook it. Any quality of produce will do" : "Click a bar to smelt it from ore and coal", 0.42, c.dim, fa_right);
	} else if(filter != ""){
		if(ui_button(panelX2 - 110, panelY1 + 10, panelX2 - 14, panelY1 + 42, "Show all", true, 0.5)){ filter = ""; scroll = 0; }
	} else {
		// Weaving: fibre into cloth; Build: sprinklers, once the Old Well is raised
		if(ui_button(panelX2 - 110, panelY1 + 10, panelX2 - 14, panelY1 + 42, "Weave", true, 0.5)){ filter = "weave"; scroll = 0; }
		var hintX = panelX2 - 124;
		if(project_done("well")){
			if(ui_button(panelX2 - 214, panelY1 + 10, panelX2 - 118, panelY1 + 42, "Build", true, 0.5)){ filter = "build"; scroll = 0; }
			hintX = panelX2 - 228;
		}
		ui_text(hintX, panelY1 + 26, "Click an equipment slot to see its recipes", 0.42, c.dim, fa_right);
	}
	var list = recipeList();
	scroll = min(scroll, max(0, array_length(list) * rowH - (listBottom - listTop)));
	if(array_length(list) == 0){
		ui_text((panelX1 + panelX2) / 2, (listTop + listBottom) / 2,
		        (filter == "dye") ? "Dyes are rewards from quests and events" : "Collect materials to unlock more clothing", 0.55, c.dim);
	}
	var mats = item_materials();
	for(var i = 0; i < array_length(list); i++){
		var y1 = listTop + i * rowH - scroll;
		if(y1 < listTop - 1 || y1 + rowH > listBottom + 1) continue;
		var rc = list[i];
		var ok = inv_can_afford(rc.cost);
		var over = overPanel && my >= y1 && my < y1 + rowH;
		if(over){ draw_set_colour(c.hover); draw_roundrect_ext(panelX1 + 8, y1, panelX2 - 8, y1 + rowH - 4, 8, 8, false); tip = item_stack(rc.id); }
		item_draw_icon(item_stack(rc.id), panelX1 + 14, y1 + 2, 44, body);
		ui_text(panelX1 + 70, y1 + rowH / 2, item_def(rc.id).name, 0.58, ok ? item_tier_colour(item_def(rc.id).tier) : c.dim, fa_left);
		// Cost as little material swatches with counts
		var cx2 = panelX2 - 20;
		for(var m = array_length(mats) - 1; m >= 0; m--){
			var need = rc.cost[$ mats[m].key];
			if(need == undefined) continue;
			var have = inv_count("m|" + mats[m].key);
			var col = (have >= need || inv_is_free()) ? c_white : make_colour_rgb(230, 110, 90);
			ui_text(cx2, y1 + rowH / 2, string(need), 0.5, col, fa_right);
			cx2 -= 22;
			draw_set_colour(mats[m].colour);
			draw_roundrect_ext(cx2 - 16, y1 + rowH / 2 - 9, cx2, y1 + rowH / 2 + 7, 4, 4, false);
			cx2 -= 26;
		}
		// Cooking ingredients: produce of any quality (shown as the crop) and forage
		var keys = variable_struct_get_names(rc.cost);
		array_sort(keys, false);
		for(var k = 0; k < array_length(keys); k++){
			if(string_pos("|", keys[k]) == 0) continue; // materials are the swatches above
			var need = rc.cost[$ keys[k]];
			var col = (cost_count(keys[k]) >= need || inv_is_free()) ? c_white : make_colour_rgb(230, 110, 90);
			ui_text(cx2, y1 + rowH / 2, string(need), 0.5, col, fa_right);
			cx2 -= 20;
			item_draw_icon(item_stack(cost_item_id(keys[k])), cx2 - 30, y1 + rowH / 2 - 15, 30, body);
			cx2 -= 40;
		}
		if(over && mouse_check_button_pressed(mb_left) && cursor == undefined){
			var why = inv_craft(rc.id, rc.cost);
			showMessage((why == "") ? "Made " + item_def(rc.id).name : why);
			changed();
		}
	}
} else {
	// Plain inventory: what you're carrying for crafting, and where to craft
	ui_text(panelX1 + 16, panelY1 + 26, "Materials", 0.8, c.accent, fa_left);
	var mats = item_materials();
	// Three columns, so the gathered materials fit too
	var colW = (panelX2 - panelX1) / 3;
	var perCol = ceil(array_length(mats) / 3);
	for(var m = 0; m < array_length(mats); m++){
		var x1 = panelX1 + (m div perCol) * colW, y1 = listTop - 14 + (m mod perCol) * 28;
		var have = inv_count("m|" + mats[m].key);
		item_draw_icon(item_stack("m|" + mats[m].key), x1 + 8, y1, 28, body);
		ui_text(x1 + 40, y1 + 14, mats[m].name, 0.4, (have > 0) ? item_tier_colour(mats[m].tier) : c.dim, fa_left);
		ui_text(x1 + colW - 10, y1 + 14, string(have), 0.45, (have > 0) ? c.accent : c.dim, fa_right);
		if(mx >= x1 && mx < x1 + colW && my >= y1 && my < y1 + 28) tip = item_stack("m|" + mats[m].key);
	}
	ui_text((panelX1 + panelX2) / 2, panelY2 - 18, "Use a crafting table [E] to make clothing and dyes", 0.45, c.dim);
}

// Tooltip (not while carrying something)
if(tip != undefined && cursor == undefined){
	var d = item_def(tip.id);
	var lines = [d.name];
	var tierLine = (d.type == "clothing" || d.type == "material") ? item_tier_name(d.tier) : "";
	switch(d.type){
		case "clothing":
			array_push(lines, item_slot_label(d.slot));
			if(!character_item_fits(d.cat, body)) array_push(lines, "Doesn't come in your size");
			else if(!character_race_allows(character_race(global.look.race), d.slot, d.cat)) array_push(lines, "Your race can't wear this");
			break;
		case "held":
			lines[0] = tool_display_name(d.name);
			array_push(lines, "Tool / weapon");
			if(tool_upgradable(d.name) != "" && tool_tier(d.name) < TOOL_MITHRIL)
				array_push(lines, "Brom can upgrade it: " + string_lower(tool_upgradable(d.name)));
			break;
		case "material": array_push(lines, "Material"); break;
		case "dye":      array_push(lines, "Dye"); break;
		case "scroll":   array_push(lines, "Spell scroll"); break;
		case "forage":   array_push(lines, "Forage"); break;
		case "placeable": array_push(lines, "Place it"); break;
		case "fish":     array_push(lines, "Fish"); break;
		case "crate":    array_push(lines, "Livestock"); break;
		case "animalproduct": array_push(lines, "Animal product"); break;
		case "food":     array_push(lines, "Food"); break;
	}
	if(tierLine != "") lines[1] = tierLine + " " + string_lower(lines[1]);
	var statLine = item_stats_text(d.stats);
	if(statLine != "") array_push(lines, statLine);
	if(d.type == "material"){
		var mt = item_material(string_split(tip.id, "|")[1]);
		var ms = item_stats_text(mt.stats);
		if(ms != "") array_push(lines, "Adds per unit: " + ms);
	}
	array_push(lines, d.desc);
	if(shop && d.type != "held") array_push(lines, "Sells for " + string(item_sell_price(tip.id)) + " gold");
	var tw = 0;
	for(var i = 0; i < array_length(lines); i++) tw = max(tw, string_width(lines[i]) * ((i == 0) ? 0.6 : 0.48));
	var tx = min(mx + 18, guiW - tw - 30), ty = min(my + 18, guiH - array_length(lines) * 24 - 24);
	draw_set_alpha(0.92);
	draw_set_colour(c_black);
	draw_roundrect_ext(tx, ty, tx + tw + 20, ty + array_length(lines) * 24 + 12, 8, 8, false);
	draw_set_alpha(1);
	for(var i = 0; i < array_length(lines); i++){
		var lc = (i == 0) ? item_tier_colour(d[$ "tier"] ?? 0) : c_white;
		if(i > 0 && string_pos("+", lines[i]) == 1) lc = c.accent;
		ui_text(tx + 10, ty + 18 + i * 24, lines[i], (i == 0) ? 0.6 : 0.48, lc, fa_left);
	}
}

// The carried stack follows the mouse
if(cursor != undefined) item_draw_icon(cursor, mx - S / 2, my - S / 2, S, body);

draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_colour(c_white);
