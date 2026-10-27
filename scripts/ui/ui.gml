/// Shared menu drawing: colours and a GUI button. Used by obj_menu.

function ui_colours(){
	static c = {
		panel:  make_colour_rgb(46, 36, 26),
		hover:  make_colour_rgb(78, 61, 42),
		button: make_colour_rgb(96, 74, 48),
		accent: make_colour_rgb(236, 196, 104),
		dim:    make_colour_rgb(170, 160, 140),
		off:    make_colour_rgb(60, 52, 44),
	};
	return c;
}

/// @description Draw a button in GUI space; returns true on the frame it is clicked.
function ui_button(_x1, _y1, _x2, _y2, _label, _enabled = true, _scale = 0.8){
	var c = ui_colours();
	var mx = device_mouse_x_to_gui(0);
	var my = device_mouse_y_to_gui(0);
	var over = _enabled && mx >= _x1 && mx < _x2 && my >= _y1 && my < _y2;
	draw_set_colour(!_enabled ? c.off : (over ? c.accent : c.button));
	draw_roundrect_ext(_x1, _y1, _x2, _y2, 10, 10, false);
	var tc = !_enabled ? c.dim : (over ? c.panel : c_white);
	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);
	draw_text_transformed_colour((_x1 + _x2) / 2, (_y1 + _y2) / 2, _label, _scale, _scale, 0, tc, tc, tc, tc, 1);
	return over && mouse_check_button_pressed(mb_left);
}

/// @description A column of buttons centred on _cx; returns the index clicked or -1. _enabled is optional.
function ui_button_column(_cx, _top, _w, _h, _gap, _labels, _enabled = undefined){
	var clicked = -1;
	for(var i = 0; i < array_length(_labels); i++){
		var y1 = _top + i * (_h + _gap);
		var en = (_enabled == undefined) ? true : _enabled[i];
		if(ui_button(_cx - _w / 2, y1, _cx + _w / 2, y1 + _h, _labels[i], en)) clicked = i;
	}
	return clicked;
}

function ui_text(_x, _y, _text, _scale, _colour, _halign = fa_center){
	draw_set_halign(_halign);
	draw_set_valign(fa_middle);
	draw_text_transformed_colour(_x, _y, _text, _scale, _scale, 0, _colour, _colour, _colour, _colour, 1);
}
