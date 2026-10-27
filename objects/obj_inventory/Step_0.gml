/// @description Mouse and keys
if(messageTime > 0) messageTime--;
frame += 8 / 60;
if(frame >= 9) frame = 1;

var mx = device_mouse_x_to_gui(0);
var my = device_mouse_y_to_gui(0);
var loc = slotAt(mx, my);

// Close with I or Esc (game's Step opened us this frame on the same I press, so skip the first frame)
if(!justOpened && (keyboard_check_pressed(ord("I")) || keyboard_check_pressed(vk_escape))){
	returnCursor();
	game.resumeLock = 2;
	instance_destroy();
	exit;
}
justOpened = false;

// Left button: pick up / put down / drag
if(mouse_check_button_pressed(mb_left) && loc != undefined){
	if(cursor == undefined){
		if(inv_get(loc) != undefined){
			if(keyboard_check(vk_shift)) quickMove(loc);
			else {
				cursor = inv_get(loc);
				inv_set(loc, undefined);
				origin = loc;
				dragging = true;
				changed();
			}
		}
	} else {
		place(loc);
	}
}
// Releasing over a different slot finishes a drag; releasing on the same slot keeps carrying it
if(mouse_check_button_released(mb_left)){
	if(dragging && cursor != undefined){
		if(loc == undefined) snapBack();                                     // dropped on nothing
		else if(!inv_same_loc(loc, origin) && !place(loc)) snapBack();       // refused
	}
	dragging = false;
}

// Right button: sell one to the blacksmith, or split one off onto the mouse
if(mouse_check_button_pressed(mb_right) && loc != undefined && loc.area == "inv"){
	var st = inv_get(loc);
	if(st != undefined){
		if(ship){
			// Into the shipping bin (paid overnight); tools and clothing can't be shipped
			var dd = item_def(st.id);
			if(dd.type == "held" || dd.type == "clothing") showMessage("You can't ship that");
			else {
				var n = keyboard_check(vk_shift) ? st.count : 1;
				shipping_add(st, n);
				st.count -= n;
				if(st.count <= 0) inv_set(loc, undefined);
				changed();
			}
		} else if(shop){
			var price = inv_is_free() ? 0 : item_sell_price(st.id);
			global.inv.gold += price;
			st.count--;
			if(st.count <= 0) inv_set(loc, undefined);
			showMessage("Sold " + item_def(st.id).name + " for " + string(price) + " gold");
			changed();
		} else if(cursor == undefined || (cursor.id == st.id && cursor.pal == st.pal && cursor.count < item_def(st.id).max)){
			if(cursor == undefined){ cursor = item_stack(st.id, 0, st.pal); origin = loc; }
			cursor.count++;
			st.count--;
			if(st.count <= 0) inv_set(loc, undefined);
			changed();
		}
	}
}

// Clicking an equipment or dye slot filters the crafting list to it
if(mouse_check_button_pressed(mb_left) && loc != undefined && cursor == undefined && craft){
	if(loc.area == "equip"){ filter = loc.key; scroll = 0; }
	if(loc.area == "dye"){ filter = "dye"; scroll = 0; }
}

// Scroll the crafting / shop list
if(mx >= panelX1 && mx < panelX2 && my >= panelY1 && my < panelY2){
	scroll = max(0, scroll + (mouse_wheel_down() - mouse_wheel_up()) * 48);
}
