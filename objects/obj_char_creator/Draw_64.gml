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
draw_text_colour(guiW / 2, 44, "Create your farmer", cAccent, cAccent, cAccent, cAccent, 1);

// Preview
var pw = 64 * previewScale;
draw_set_colour(cPanel);
draw_roundrect_ext(previewCX - pw / 2 - 20, previewCY - pw / 2 - 20, previewCX + pw / 2 + 20, previewCY + pw / 2 + 20, 16, 16, false);
character_draw(look, floor(frame), facingRows[facing], previewCX - pw / 2, previewCY - pw / 2, previewScale);
draw_text_transformed_colour(previewCX, previewCY + 212, "Turn", textScale, textScale, 0, c_white, c_white, c_white, c_white, 1);

// Slot rows
var ts = textScale;
for(var i = 0; i < rowCount; i++){
	var s = slots[i];
	var part = look[$ s.key];
	var y1 = top + i * rowH;
	var cy = y1 + rowH / 2;

	if(i == hoverRow){
		draw_set_colour(cHover);
		draw_roundrect_ext(colLabel - 10, y1, palX + palW + 10, y1 + rowH - 2, 8, 8, false);
	}

	// Label
	draw_set_halign(fa_left);
	draw_text_transformed_colour(colLabel, cy, s.label, ts, ts, 0, cAccent, cAccent, cAccent, cAccent, 1);

	// Sprite selector
	var si = array_get_index(s.sprites, part.spr);
	var name = (si == -1) ? "none" : s.names[si];
	var cName = (si == -1) ? cDim : c_white;
	draw_set_colour(cPanel);
	draw_roundrect_ext(optX, y1 + 2, optX + optW, y1 + rowH - 4, 6, 6, false);
	draw_set_halign(fa_center);
	draw_text_transformed_colour(optX + arrowW / 2, cy, "<", ts, ts, 0, cAccent, cAccent, cAccent, cAccent, 1);
	draw_text_transformed_colour(optX + optW - arrowW / 2, cy, ">", ts, ts, 0, cAccent, cAccent, cAccent, cAccent, 1);
	draw_text_transformed_colour(optX + optW / 2, cy, name, ts, ts, 0, cName, cName, cName, cName, 1);

	// Colour selector (ears and nose use the skin colour)
	if(array_length(s.palettes) > 0){
		var palIdx = array_get_index(s.palettes, part.pal);
		draw_set_colour(cPanel);
		draw_roundrect_ext(palX, y1 + 2, palX + palW, y1 + rowH - 4, 6, 6, false);
		draw_text_transformed_colour(palX + arrowW / 2, cy, "<", ts, ts, 0, cAccent, cAccent, cAccent, cAccent, 1);
		draw_text_transformed_colour(palX + palW - arrowW / 2, cy, ">", ts, ts, 0, cAccent, cAccent, cAccent, cAccent, 1);
		if(palIdx != -1){
			// Swatch: the palette sprite stretched into a strip
			var sw = 56;
			var sx = palX + arrowW + 4;
			draw_sprite_stretched(s.palettes[palIdx], 0, sx, y1 + 8, sw, rowH - 16);
			draw_set_halign(fa_left);
			draw_text_transformed_colour(sx + sw + 8, cy, s.palNames[palIdx], ts * 0.85, ts * 0.85, 0, c_white, c_white, c_white, c_white, 1);
		}
	} else {
		draw_set_halign(fa_left);
		draw_text_transformed_colour(palX + 8, cy, "skin colour", ts * 0.85, ts * 0.85, 0, cDim, cDim, cDim, cDim, 1);
	}
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
