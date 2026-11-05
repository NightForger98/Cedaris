/// @description Insert description here
// You can write your code in this editor
if(keyboard_check_pressed(ord("C"))) {move_cam = !move_cam}

if(move_cam){
var in_left =keyboard_check(ord("A"));
var in_right =keyboard_check(ord("D"));
var in_up=keyboard_check(ord("W"));
var in_down =keyboard_check(ord("S"));
y += (in_down - in_up) * 6;
x += (in_right - in_left) * 6; 
}else {
x = clamp(x, following.x-h_border,following.x+h_border);
y = clamp(y, following.y-v_border,following.y+ v_border);
}
// A top-level charged hit shakes the screen for a few frames (global.camShake, charging script)
if(variable_global_exists("camShake") && global.camShake > 0){
	global.camShake--;
	x += irandom_range(-3, 3);
	y += irandom_range(-2, 2);
}







