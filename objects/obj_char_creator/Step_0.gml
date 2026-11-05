/// @description Input
var mx = device_mouse_x_to_gui(0);
var my = device_mouse_y_to_gui(0);
var click = mouse_check_button_pressed(mb_left);
var wheel = mouse_wheel_down() - mouse_wheel_up();

// Walk cycle frames 1-8
frame += 8 / 60;
if(frame >= 9) frame = 1;

// Story mode's first screen: click Male or Female (or press M / F)
if(stage == "gender"){
	hoverCard = -1;
	for(var i = 0; i < array_length(cards); i++){
		var c = cards[i];
		if(mx >= c.x1 && mx < c.x2 && my >= c.y1 && my < c.y2) hoverCard = i;
	}
	if(click && hoverCard != -1){ pickGender(cards[hoverCard].gender); exit; }
	if(keyboard_check_pressed(ord("M"))){ pickGender("male"); exit; }
	if(keyboard_check_pressed(ord("F"))){ pickGender("female"); exit; }
	if(keyboard_check_pressed(vk_escape) || (click && mx >= buttons[0].x1 && mx < buttons[0].x2 && my >= buttons[0].y1 && my < buttons[0].y2)) act("back");
	exit;
}

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
		if(d != 0) cycleRow(i, d);
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
if(action != "") act(action);
