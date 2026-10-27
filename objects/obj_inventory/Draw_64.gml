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
character_draw(global.look, floor(frame), 10, pcx - 128, previewY1 + 30, 4);
ui_text(pcx, previewY2 - 34, global.look.race + " " + global.look.body, 0.6, c.dim);
if(messageTime > 0) ui_text(pcx, previewY2 + 22, message, 0.6, c_white);

// Crafting or shop panel
draw_set_colour(c.panel);
draw_roundrect_ext(panelX1, panelY1, panelX2, panelY2, 14, 14, false);
var rowH = 50;
var listTop = panelY1 + 56;
var listBottom = panelY2 - 30;
var overPanel = (mx >= panelX1 && mx < panelX2 && my >= listTop && my < listBottom);

if(shop){
	ui_text(panelX1 + 16, panelY1 + 26, "Brom's Smithy", 0.8, c.accent, fa_left);
	ui_text(panelX2 - 16, panelY1 + 26, "Right-click your items to sell", 0.45, c.dim, fa_right);
	var stock = item_shop_stock();
	scroll = min(scroll, max(0, array_length(stock) * rowH - (listBottom - listTop)));
	for(var i = 0; i < array_length(stock); i++){
		var y1 = listTop + i * rowH - scroll;
		if(y1 < listTop - 1 || y1 + rowH > listBottom + 1) continue;
		var itemId = "c|held|" + stock[i].name;
		var price = inv_is_free() ? 0 : stock[i].price;
		var afford = inv.gold >= price;
		var over = overPanel && my >= y1 && my < y1 + rowH;
		if(over){ draw_set_colour(c.hover); draw_roundrect_ext(panelX1 + 8, y1, panelX2 - 8, y1 + rowH - 4, 8, 8, false); tip = item_stack(itemId); }
		item_draw_icon(item_stack(itemId), panelX1 + 14, y1 + 2, 44, body);
		ui_text(panelX1 + 70, y1 + rowH / 2, stock[i].name, 0.6, afford ? c_white : c.dim, fa_left);
		ui_text(panelX2 - 20, y1 + rowH / 2, (price == 0) ? "free" : string(price) + " gold", 0.55, afford ? c.accent : c.dim, fa_right);
		if(over && mouse_check_button_pressed(mb_left) && cursor == undefined){
			if(!afford) showMessage("Not enough gold");
			else if(inv_add(item_stack(itemId)) > 0) showMessage("Your inventory is full");
			else { inv.gold -= price; showMessage("Bought " + stock[i].name); changed(); }
		}
	}
} else if(craft){
	var title = "Crafting Table";
	if(filter == "dye") title += " - dyes";
	else if(filter != "") title += " - " + item_slot_label(filter);
	ui_text(panelX1 + 16, panelY1 + 26, title, 0.8, c.accent, fa_left);
	if(filter != ""){
		if(ui_button(panelX2 - 110, panelY1 + 10, panelX2 - 14, panelY1 + 42, "Show all", true, 0.5)){ filter = ""; scroll = 0; }
	} else {
		ui_text(panelX2 - 16, panelY1 + 26, "Click an equipment slot to see its recipes", 0.42, c.dim, fa_right);
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
		ui_text(panelX1 + 70, y1 + rowH / 2, item_def(rc.id).name, 0.58, ok ? c_white : c.dim, fa_left);
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
	for(var m = 0; m < array_length(mats); m++){
		var y1 = listTop + m * 44;
		var st = item_stack("m|" + mats[m].key, inv_count("m|" + mats[m].key));
		item_draw_icon(item_stack(st.id), panelX1 + 14, y1, 40, body);
		ui_text(panelX1 + 68, y1 + 20, mats[m].name, 0.58, (st.count > 0) ? c_white : c.dim, fa_left);
		ui_text(panelX2 - 20, y1 + 20, string(st.count), 0.6, (st.count > 0) ? c.accent : c.dim, fa_right);
	}
	ui_text((panelX1 + panelX2) / 2, panelY2 - 30, "Use a crafting table [E] to make clothing and dyes", 0.5, c.dim);
}

// Tooltip (not while carrying something)
if(tip != undefined && cursor == undefined){
	var d = item_def(tip.id);
	var lines = [d.name];
	switch(d.type){
		case "clothing":
			array_push(lines, item_slot_label(d.slot));
			if(!character_item_fits(d.cat, body)) array_push(lines, "Doesn't come in your size");
			else if(!character_race_allows(character_race(global.look.race), d.slot, d.cat)) array_push(lines, "Your race can't wear this");
			break;
		case "held":     array_push(lines, "Tool / weapon"); break;
		case "material": array_push(lines, "Material"); break;
		case "dye":      array_push(lines, "Dye"); break;
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
		ui_text(tx + 10, ty + 18 + i * 24, lines[i], (i == 0) ? 0.6 : 0.48, (i == 0) ? c.accent : c_white, fa_left);
	}
}

// The carried stack follows the mouse
if(cursor != undefined) item_draw_icon(cursor, mx - S / 2, my - S / 2, S, body);

draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_colour(c_white);
