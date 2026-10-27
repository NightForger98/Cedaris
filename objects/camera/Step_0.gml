/// @description Insert description here
// You can write your code in this editor

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







