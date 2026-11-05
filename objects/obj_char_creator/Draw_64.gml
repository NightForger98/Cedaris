/// @description Draw the creator
var mx = device_mouse_x_to_gui(0);
var my = device_mouse_y_to_gui(0);
var cPanel  = make_colour_rgb(46, 36, 26);
var cHover  = make_colour_rgb(78, 61, 42);
var cButton = make_colour_rgb(96, 74, 48);
var cAccent = make_colour_rgb(236, 196, 104);
var cDim    = make_colour_rgb(170, 160, 140);

draw_set_font(fnt_eq);
draw_set_valign(fa_middle);

// Title
draw_set_halign(fa_center);
draw_text_colour(guiW / 2, 44, story ? "Create your farmer - Story Mode" : "Create your farmer - Free Mode", cAccent, cAccent, cAccent, cAccent, 1);

// Story mode's first screen: man or woman
if(stage == "gender"){
	draw_text_transformed_colour(guiW / 2, cardY - 40, "Is your farmer a man or a woman?", 0.9, 0.9, 0, c_white, c_white, c_white, c_white, 1);
	var ps = 5;
	for(var i = 0; i < array_length(cards); i++){
		var cd = cards[i];
		var over = (i == hoverCard);
		draw_set_colour(over ? cHover : cPanel);
		draw_roundrect_ext(cd.x1, cd.y1, cd.x2, cd.y2, 16, 16, false);
		if(over){ draw_set_colour(cAccent); draw_roundrect_ext(cd.x1, cd.y1, cd.x2, cd.y2, 16, 16, true); }
		var ccx = (cd.x1 + cd.x2) / 2;
		character_draw(genderLooks[i], floor(frame), facingRows[0], ccx - 32 * ps, cd.y1 + 30, ps);
		var lc = over ? cAccent : c_white;
		draw_text_transformed_colour(ccx, cd.y2 - 50, genderNames[$ cd.gender], 1, 1, 0, lc, lc, lc, lc, 1);
	}
	// Back
	var b0 = buttons[0];
	var overB = (mx >= b0.x1 && mx < b0.x2 && my >= b0.y1 && my < b0.y2);
	draw_set_colour(overB ? cAccent : cButton);
	draw_roundrect_ext(b0.x1, b0.y1, b0.x2, b0.y2, 10, 10, false);
	var cb = overB ? cPanel : c_white;
	draw_text_transformed_colour((b0.x1 + b0.x2) / 2, (b0.y1 + b0.y2) / 2, b0.label, 0.8, 0.8, 0, cb, cb, cb, cb, 1);
	draw_text_transformed_colour(guiW / 2, guiH - 18, "Click one  -  M: male  -  F: female  -  Esc: back", 0.5, 0.5, 0, cDim, cDim, cDim, cDim, 1);
	draw_set_colour(c_white);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	exit;
}

// Preview
var pw = 64 * previewScale;
draw_set_colour(cPanel);
draw_roundrect_ext(previewCX - pw / 2 - 20, previewCY - pw / 2 - 20, previewCX + pw / 2 + 20, previewCY + pw / 2 + 20, 16, 16, false);
character_draw(look, floor(frame), facingRows[facing], previewCX - pw / 2, previewCY - pw / 2, previewScale);
draw_text_transformed_colour(previewCX, previewCY + 212, "Turn", textScale, textScale, 0, c_white, c_white, c_white, c_white, 1);

// Race name and description
var race = character_race(look.race);
draw_text_transformed_colour(previewCX, previewCY + 270, race.name, 0.9, 0.9, 0, cAccent, cAccent, cAccent, cAccent, 1);
draw_set_valign(fa_top);
draw_text_ext_transformed_colour(previewCX, previewCY + 292, race.desc, -1, (pw + 40) / 0.55, 0.55, 0.55, 0, cDim, cDim, cDim, cDim, 1);
draw_set_valign(fa_middle);

// Slot rows
var ts = textScale;
for(var i = 0; i < rowCount; i++){
	var s = slots[i];
	var part = look.parts[$ s.key];
	var y1 = top + i * rowH;
	var cy = y1 + rowH / 2;

	if(i == hoverRow){
		draw_set_colour(cHover);
		draw_roundrect_ext(colLabel - 10, y1, palX + palW + 10, y1 + rowH - 2, 8, 8, false);
	}

	// Label
	draw_set_halign(fa_left);
	draw_text_transformed_colour(colLabel, cy, s.label, ts, ts, 0, cAccent, cAccent, cAccent, cAccent, 1);

	// Item selector (the Race and Body rows pick the race and body type)
	var name;
	var picker = (s.key == "race" || s.key == "body");
	if(s.key == "race") name = story ? look.race + " (story)" : look.race;
	else if(s.key == "body") name = story ? genderNames[$ look.body] : look.body;
	else if(array_length(character_slot_options(s, look)) == 0) name = "-"; // nothing for this race and body
	else if(part.item == -1) name = (s.key == "eyes") ? "normal" : "none";
	else name = lpc_catalog().items[part.item].name;
	var cName = (part.item == -1 && !picker) ? cDim : c_white;
	draw_set_colour(cPanel);
	draw_roundrect_ext(optX, y1 + 2, optX + optW, y1 + rowH - 4, 6, 6, false);
	draw_set_halign(fa_center);
	draw_text_transformed_colour(optX + arrowW / 2, cy, "<", ts, ts, 0, cAccent, cAccent, cAccent, cAccent, 1);
	draw_text_transformed_colour(optX + optW - arrowW / 2, cy, ">", ts, ts, 0, cAccent, cAccent, cAccent, cAccent, 1);
	var nts = min(ts, (optW - arrowW * 2 - 8) / max(1, string_width(name))); // shrink long names to fit
	draw_text_transformed_colour(optX + optW / 2, cy, name, nts, nts, 0, cName, cName, cName, cName, 1);

	// Colour selector
	var cols = character_palettes_for(s.key, part.item, look);
	if(array_length(cols.pals) > 0){
		var cur = (part.pal == -1) ? lpc_catalog().items[part.item].defPal : part.pal;
		var palIdx = array_get_index(cols.pals, cur);
		draw_set_colour(cPanel);
		draw_roundrect_ext(palX, y1 + 2, palX + palW, y1 + rowH - 4, 6, 6, false);
		draw_text_transformed_colour(palX + arrowW / 2, cy, "<", ts, ts, 0, cAccent, cAccent, cAccent, cAccent, 1);
		draw_text_transformed_colour(palX + palW - arrowW / 2, cy, ">", ts, ts, 0, cAccent, cAccent, cAccent, cAccent, 1);
		if(palIdx != -1){
			// Swatch: the palette sprite stretched into a strip
			var sw = 56;
			var sx = palX + arrowW + 4;
			draw_sprite_stretched(cols.pals[palIdx], 0, sx, y1 + 6, sw, rowH - 12);
			draw_set_halign(fa_left);
			draw_text_transformed_colour(sx + sw + 8, cy, cols.names[palIdx], ts * 0.85, ts * 0.85, 0, c_white, c_white, c_white, c_white, 1);
		}
	} else if(part.item != -1){
		// Heads, ears and noses follow the skin colour; some items have fixed colours
		var note = (s.key == "head" || s.key == "ears" || s.key == "nose") ? "skin colour" : "fixed colours";
		draw_set_halign(fa_left);
		draw_text_transformed_colour(palX + 8, cy, note, ts * 0.85, ts * 0.85, 0, cDim, cDim, cDim, cDim, 1);
	}
}

// Story mode: the starter outfit is fixed
if(story){
	var ny = top + rowCount * rowH + 30;
	draw_set_halign(fa_left);
	draw_text_transformed_colour(colLabel, ny, "Clothing: red shirt, blue trousers, brown shoes", textScale, textScale, 0, cAccent, cAccent, cAccent, cAccent, 1);
	draw_text_transformed_colour(colLabel, ny + 34, "New clothes, colours and tools are earned in the world.", textScale * 0.85, textScale * 0.85, 0, cDim, cDim, cDim, cDim, 1);
}

// Buttons
draw_set_halign(fa_center);
for(var i = 0; i < array_length(buttons); i++){
	var b = buttons[i];
	var over = (mx >= b.x1 && mx < b.x2 && my >= b.y1 && my < b.y2);
	draw_set_colour(over ? cAccent : cButton);
	draw_roundrect_ext(b.x1, b.y1, b.x2, b.y2, 10, 10, false);
	var c = over ? cPanel : c_white;
	draw_text_transformed_colour((b.x1 + b.x2) / 2, (b.y1 + b.y2) / 2, b.label, 0.8, 0.8, 0, c, c, c, c, 1);
}

// Hint
draw_text_transformed_colour(guiW / 2, guiH - 18, "Click the arrows or scroll over an option  -  R: randomise  -  Enter: done", 0.5, 0.5, 0, cDim, cDim, cDim, cDim, 1);

draw_set_colour(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
