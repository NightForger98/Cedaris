/// @description Insert description here
// You can write your code in this editor

if(doTransition){
	//handle transition
	if(room != spawnRoom){
		blackAlpha += 0.1;
		if(blackAlpha >= 1){
			room_goto(spawnRoom)}
			}else{blackAlpha -= 0.1;
				if(blackAlpha <= 0)
			doTransition=false;
			}
	
	
	
	//draw black fade
draw_set_alpha(blackAlpha);
draw_rectangle_colour(0,0,guiWidth,guiHeight,c_black,c_black,c_black,c_black,false);
draw_set_alpha(1);
}











// Frame rate (Options > Show FPS)
if(global.settings.showFps){
	draw_set_font(fnt_eq);
	draw_text_transformed_colour(8, 8, string(fps) + " fps", 0.6, 0.6, 0, c_yellow, c_yellow, c_yellow, c_yellow, 1);
}
