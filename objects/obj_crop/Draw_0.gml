/// @description Insert description here
// You can write your code in this editor
draw_sprite_part(
spr_crops, 0 ,growthStage * frameWidth,
cropType * frameHeight,
frameWidth, frameHeight,
xx,yy
);
// The twinkle over a ripe crop: a little four-pointed star that grows and fades (5 steps)
if(sparkle >= 0){
	var r = [1, 2, 3, 2, 1][floor(sparkle)], sx = x + 8, sy = y - 34;
	draw_set_alpha(1 - floor(sparkle) * 0.12);
	draw_set_colour(c_white);
	draw_line(sx - r - 1, sy, sx + r + 1, sy);
	draw_line(sx, sy - r - 1, sx, sy + r + 1);
	draw_set_colour(make_colour_rgb(255, 240, 150));
	draw_point(sx, sy);
	draw_set_alpha(1);
	draw_set_colour(c_white);
	sparkle += .1;
if(sparkle >= 5){
	sparkle = -1;
	alarm[1] = random_range(4,5)*room_speed;
}
}


