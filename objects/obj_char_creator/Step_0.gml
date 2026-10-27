/// @description Input
var mx = device_mouse_x_to_gui(0);
var my = device_mouse_y_to_gui(0);
var click = mouse_check_button_pressed(mb_left);
var wheel = mouse_wheel_down() - mouse_wheel_up();

// Walk cycle frames 1-8
frame += 8 / 60;
if(frame >= 9) frame = 1;

// Slot rows: click the arrows, or scroll over a name
hoverRow = -1;
for(var i = 0; i < rowCount; i++){
	var y1 = top + i * rowH;
	if(my < y1 || my >= y1 + rowH) continue;
	hoverRow = i;
	var s = slots[i];

	var d = 0;
	if(mx >= optX && mx < optX + optW){
		if(click) d = (mx < optX + arrowW) ? -1 : ((mx >= optX + optW - arrowW) ? 1 : 0);
		if(d == 0) d = wheel;
		if(d != 0) character_cycle_item(look, s, d);
	}
	d = 0;
	if(mx >= palX && mx < palX + palW){
		if(click) d = (mx < palX + arrowW) ? -1 : ((mx >= palX + palW - arrowW) ? 1 : 0);
		if(d == 0) d = wheel;
		if(d != 0) character_cycle_palette(look, s, d);
	}
}

// Buttons
var action = "";
if(click){
	for(var i = 0; i < array_length(buttons); i++){
		var b = buttons[i];
		if(mx >= b.x1 && mx < b.x2 && my >= b.y1 && my < b.y2) action = b.action;
	}
}
if(keyboard_check_pressed(ord("R"))) action = "random";
if(keyboard_check_pressed(vk_enter)) action = "done";
if(keyboard_check_pressed(vk_escape)) action = "back";
if(keyboard_check_pressed(vk_left)) action = "turnleft";
if(keyboard_check_pressed(vk_right)) action = "turnright";

switch(action){
	case "random":    character_randomise(look); break;
	case "reset":     look = character_default_look(); break;
	case "turnleft":  facing = (facing + 1) mod 4; break;
	case "turnright": facing = (facing + 3) mod 4; break;
	case "back":      room_goto(rm_menu); break;
	case "done":
		global.look = look;
		room_goto(rm_1);
		break;
}
