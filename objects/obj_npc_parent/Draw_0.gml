/// @description Insert description here
// You can write your code in this editor

/// @description Insert description here
// You can write your code in this editor
/// @description Insert description here
// You can write your code in this editor
var anim_length=9;
var anim_speed =10;
var frame_size = 64;
var in_run =keyboard_check(vk_shift);
var skn_Index ;


if( moveX < 0){ y_frame = 9}
else if(moveX > 0){y_frame = 11}
else if(moveY < 0){y_frame = 8}
else if(moveY > 0){y_frame = 10}
else				{x_frame = 0;}

if(x_frame + anim_speed/60  < anim_length - 1)	{ x_frame += anim_speed/60;}
else							{x_frame = 0}



if(in_run){anim_speed = 18} else{anim_speed = 12}

var xx = x-x_offset;
var yy = y- y_offset;


//base0
if(pal_skn != -1){
lorikeet_set(pal_skn)
draw_sprite_part(idx_bs,0,floor(x_frame)*frame_size,y_frame*frame_size,frame_size,frame_size,xx,yy);//skin
if(idx_bse != -1){
draw_sprite_part(idx_bse,0,floor(x_frame)*frame_size,y_frame*frame_size,frame_size,frame_size,xx,yy);//ears
}
if(idx_bsn != -1){
draw_sprite_part(idx_bsn,0,floor(x_frame)*frame_size,y_frame*frame_size,frame_size,frame_size,xx,yy);//nose
}
lorikeet_reset()
}else{}
if(pal_eyes !=-1){
lorikeet_set(pal_eyes)
draw_sprite_part(idx_iz,0,floor(x_frame)*frame_size,y_frame*frame_size,frame_size,frame_size,xx,yy);//eyes
lorikeet_reset()
}
else{}

//layer1
if(pal_earing !=-1){
lorikeet_set(pal_earing)
draw_sprite_part(idx_acc,0,floor(x_frame)*frame_size,y_frame*frame_size,frame_size,frame_size,xx,yy);//accsory
lorikeet_reset()
}
if(pal_necklace !=-1){
lorikeet_set(pal_necklace)
draw_sprite_part(idx_nck,0,floor(x_frame)*frame_size,y_frame*frame_size,frame_size,frame_size,xx,yy);//neck
lorikeet_reset()
}
if(pal_hat !=-1){
lorikeet_set(pal_hat)
draw_sprite_part(idx_top,0,floor(x_frame)*frame_size,y_frame*frame_size,frame_size,frame_size,xx,yy);//top1
lorikeet_reset()
}
						//top2

//layer2
if(pal_shirt !=-1){
lorikeet_set(pal_shirt)
draw_sprite_part(idx_trs,0,floor(x_frame)*frame_size,y_frame*frame_size,frame_size,frame_size,xx,yy);//torso
lorikeet_reset()
}
if(pal_pants !=-1){
lorikeet_set(pal_pants)
draw_sprite_part(idx_pnt,0,floor(x_frame)*frame_size,y_frame*frame_size,frame_size,frame_size,xx,yy);//bottom
lorikeet_reset()
}
if(pal_shoes !=-1){
lorikeet_set(pal_shoes)
draw_sprite_part(idx_shs,0,floor(x_frame)*frame_size,y_frame*frame_size,frame_size,frame_size,xx,yy);//shoes
lorikeet_reset()
}
						
//layer3
if(pal_vest !=-1){
lorikeet_set(pal_vest)
draw_sprite_part(idx_trs2,0,floor(x_frame)*frame_size,y_frame*frame_size,frame_size,frame_size,xx,yy);//torso2
lorikeet_reset()
}
if(pal_armor !=-1){
lorikeet_set(pal_armor)
draw_sprite_part(idx_trs3,0,floor(x_frame)*frame_size,y_frame*frame_size,frame_size,frame_size,xx,yy);//torso3
lorikeet_reset()
}
if(pal_band != -1){
lorikeet_set(pal_band);
draw_sprite_part(idx_bld,0,floor(x_frame)*frame_size,y_frame*frame_size,frame_size,frame_size,xx,yy);//bauldron
lorikeet_reset()
}
if(pal_belt != -1){
lorikeet_set(pal_belt)
draw_sprite_part(idx_wst,0,floor(x_frame)*frame_size,y_frame*frame_size,frame_size,frame_size,xx,yy);//waist
lorikeet_reset()
}
if(pal_shoulders !=-1){
lorikeet_set(pal_shoulders)
draw_sprite_part(idx_shldr,0,floor(x_frame)*frame_size,y_frame*frame_size,frame_size,frame_size,xx,yy);//shoulder
lorikeet_reset()
}


if(pal_wrist !=-1){
lorikeet_set(pal_wrist)
draw_sprite_part(idx_wrst,0,floor(x_frame)*frame_size,y_frame*frame_size,frame_size,frame_size,xx,yy);//wrist
lorikeet_reset()
}

if(pal_gloves !=-1){
lorikeet_set(pal_gloves)
draw_sprite_part(idx_glv,0,floor(x_frame)*frame_size,y_frame*frame_size,frame_size,frame_size,xx,yy);//glove
lorikeet_reset()
}

if(pal_cape !=-1){
lorikeet_set(pal_cape)
draw_sprite_part(idx_cp,0,floor(x_frame)*frame_size,y_frame*frame_size,frame_size,frame_size,xx,yy);//cape
lorikeet_reset()
}
if(pal_beard !=-1){
lorikeet_set(pal_beard)
draw_sprite_part(idx_brd,0,floor(x_frame)*frame_size,y_frame*frame_size,frame_size,frame_size,xx,yy);//beard
lorikeet_reset()
}

if(pal_hair !=-1){
lorikeet_set(pal_hair)
draw_sprite_part(idx_hair,0,floor(x_frame)*frame_size,y_frame*frame_size,frame_size,frame_size,xx,yy);//hair
lorikeet_reset()
}


/*
for(var i =0; i < array_length(ar_pal) ; i++){
	if( array_get(ar_pal,i) != -1){
	lorikeet_set(object_get_sprite(array_get(ar_pal,i)));
	
		if(array_get(ar_idx,i) != -1){
		draw_sprite_part(object_get_sprite(array_get(ar_pal,i)),0,floor(x_frame)*frame_size,y_frame*frame_size,frame_size,frame_size,xx,yy);
		}else{}
	}else{}
		
	
	lorikeet_reset();
	
}

*/
