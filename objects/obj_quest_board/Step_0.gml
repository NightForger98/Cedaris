/// @description E nearby opens the board; E or Esc closes it
if(messageTime > 0) messageTime--;
near = interact_near(48);
if(open){
	if(input_pressed(ord("E")) || input_pressed(vk_escape) || point_distance(x, y, obj_plyr.x, obj_plyr.y) > 64){
		open = false;
		game.resumeLock = 2;
		global.talkCooldown = current_time + 300;
	}
	exit;
}
if(near && input_pressed(ord("E")) && interact_ready()){
	open = true;
	quests_offers(); // today's requests go up
}
