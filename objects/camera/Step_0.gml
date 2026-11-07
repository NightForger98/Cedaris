/// @description Follow the player: trailing a little behind (up to h_border / v_border px), and running or sprinting,
/// leading ahead in the direction they move. C toggles a free camera (W A S D) - a debug tool, in debug mode only.
if(keyboard_check_pressed(ord("C")) && instance_exists(game) && game.debug) move_cam = !move_cam;
if(move_cam && !(instance_exists(game) && game.debug)) move_cam = false;   // leaving debug mode gives the camera back

if(!instance_exists(following)) following = obj_plyr;
if(move_cam){
	var in_left = keyboard_check(ord("A")), in_right = keyboard_check(ord("D"));
	var in_up = keyboard_check(ord("W")), in_down = keyboard_check(ord("S"));
	y += (in_down - in_up) * 6;
	x += (in_right - in_left) * 6;
} else if(instance_exists(following)){
	// the trailing follow (as ever) on bx, by; then the lead: running, and more so sprinting, the camera eases ahead
	// in the direction you move (a third of the view when sprinting, half that running) and holds there; walking
	// slowly or stopping, it glides back
	bx = clamp(bx, following.x - h_border, following.x + h_border);
	by = clamp(by, following.y - v_border, following.y + v_border);
	var mx = following.moveX, my = following.moveY, m = point_distance(0, 0, mx, my), k = 0;
	if(m > 0 && room_is_outdoors()){   // (indoors: the old camera)
		if(following.sprinting) k = 1;
		else if(variable_instance_exists(following, "spd") && following.spd >= following.n_spd) k = 0.5;
	}
	var c0 = view_camera[0], tx = 0, ty = 0;
	if(k > 0){ tx = mx / m * camera_get_view_width(c0) * 0.3 * k; ty = my / m * camera_get_view_height(c0) * 0.3 * k; }
	var ease = (k > 0) ? 0.025 : 0.04;   // out a little slower than back
	lead_x = lerp(lead_x, tx, ease);
	lead_y = lerp(lead_y, ty, ease);
	x = bx + lead_x;
	y = by + lead_y;
	// a safety net: the player off screen for half a second (whatever the cause) - straight back to them
	var c = view_camera[0], vx = camera_get_view_x(c), vy = camera_get_view_y(c);
	if(following.x < vx || following.y < vy || following.x > vx + camera_get_view_width(c) || following.y > vy + camera_get_view_height(c)) offscreen++;
	else offscreen = 0;
	if(offscreen > 30){ bx = following.x; by = following.y; lead_x = 0; lead_y = 0; x = bx; y = by; offscreen = 0; }
}
// A top-level charged hit shakes the screen for a few frames (global.camShake, charging script)
if(variable_global_exists("camShake") && global.camShake > 0){
	global.camShake--;
	x += irandom_range(-3, 3);
	y += irandom_range(-2, 2);
}
