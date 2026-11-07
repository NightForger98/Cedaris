/// @description M or Esc closes it; the wheel (or + / -) zooms toward the mouse, dragging (or the arrows) moves the
/// map, Home shows all of it
if(justOpened){ justOpened = false; exit; }
if(input_pressed(key_of("map")) || input_pressed(vk_escape)){
	game.resumeLock = 2;   // so the same Esc doesn't pause the game
	instance_destroy();
	exit;
}
var m = world_map();
var gx = device_mouse_x_to_gui(0), gy = device_mouse_y_to_gui(0);
var inFrame = point_in_rectangle(gx, gy, frameX, frameY, frameX + frameW, frameY + frameH);

// Zoom (x1 to x6), keeping the point under the mouse where it is (the keys zoom toward the middle)
var z = zoom;
var cx = inFrame ? gx : frameX + frameW / 2, cy = inFrame ? gy : frameY + frameH / 2;
if(inFrame && mouse_wheel_up()) z *= 1.25;
if(inFrame && mouse_wheel_down()) z /= 1.25;
if(keyboard_check_pressed(187) || keyboard_check_pressed(vk_add)){ z *= 1.25; cx = frameX + frameW / 2; cy = frameY + frameH / 2; }        // = / + and the keypad's +
if(keyboard_check_pressed(189) || keyboard_check_pressed(vk_subtract)){ z /= 1.25; cx = frameX + frameW / 2; cy = frameY + frameH / 2; }   // - and the keypad's -
z = clamp(z, 1, 6);
if(z != zoom){
	var u = (cx - mapX) / (fitS * zoom), v = (cy - mapY) / (fitS * zoom);   // the map pixel at the zoom's centre
	zoom = z;
	mapX = cx - u * fitS * zoom;
	mapY = cy - v * fitS * zoom;
}
if(keyboard_check_pressed(vk_home)){ zoom = 1; mapX = frameX; mapY = frameY; }

// Drag with the left button, or the arrow keys
if(mouse_check_button_pressed(mb_left) && inFrame){ dragging = true; dragLast = [gx, gy]; }
if(dragging){
	if(mouse_check_button(mb_left)){ mapX += gx - dragLast[0]; mapY += gy - dragLast[1]; dragLast = [gx, gy]; }
	else dragging = false;
}
var spd = 12;
if(keyboard_check(vk_left)) mapX += spd;
if(keyboard_check(vk_right)) mapX -= spd;
if(keyboard_check(vk_up)) mapY += spd;
if(keyboard_check(vk_down)) mapY -= spd;

// The map always fills the frame
var w = m.w * fitS * zoom, h = m.h * fitS * zoom;
mapX = clamp(mapX, frameX + frameW - w, frameX);
mapY = clamp(mapY, frameY + frameH - h, frameY);
