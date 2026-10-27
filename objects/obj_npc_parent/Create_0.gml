/// @description Insert description here
// You can write your code in this editor
w_spd= 1;
n_spd= 2;
r_spd= 3;
spd = w_spd;
x_frame =0;
y_frame =0;
moveX=0;
moveY=0;
//pallets




pal_skn=-1;//0,1,2
pal_eyes=-1;//3
pal_shirt=-1;//4
pal_pants=-1;//5
pal_shoes=-1;//6
pal_vest=-1;//7
pal_armor=-1;//8
pal_earing=-1;//9
pal_headcover= -1;//10
pal_necklace=-1;//11
pal_band=-1;//12
pal_belt=-1;//13
pal_shoulders=-1;//14
pal_wrist=-1;//15
pal_gloves=-1;//16
pal_cape = -1;//17
pal_beard=-1;//18
pal_hair=-1;//19
pal_hat= -1;//20



idx_bs=-1;//0
idx_bse= -1;//1
idx_bsn=-1;//2
idx_iz=-1;//3
idx_trs=-1;//4
idx_pnt=-1;//5
idx_shs=-1;//6
idx_trs2=-1;//7
idx_trs3 = -1;//8
idx_acc=-1;//9
idx_ring=-1//10
idx_nck=-1;//11
idx_bld= -1;//12
idx_wst=-1;//13
idx_shldr=-1;//14
idx_wrst=-1//15
idx_glv=-1;//16
idx_cp = -1;//17
idx_brd=-1;//18
idx_hair=-1;//19
idx_top= -1;//20
///////
x_offset = sprite_get_xoffset(mask_index);
y_offset = sprite_get_yoffset(mask_index);
//

/*
ar_pal = array_create(21,noone);
array_insert(ar_pal,0,pal_skn,pal_skn,pal_skn,pal_eyes,pal_shirt,pal_pants,pal_shoes,pal_vest,pal_armor,pal_earing,pal_headcover,
pal_necklace,pal_band,pal_belt,pal_shoulders,pal_wrist,pal_gloves,pal_cape,pal_beard,pal_hair,pal_hat)


ar_idx = array_create(21,noone);
array_insert(ar_idx,0,idx_bs,idx_bse,idx_bsn,idx_iz,idx_trs,idx_pnt,idx_shs,idx_trs2,idx_trs3,
idx_acc,idx_ring,idx_nck,idx_bld,idx_wst,idx_shldr,idx_wrst,idx_glv,idx_cp,idx_brd,idx_hair,idx_top);

*/

alarm[1] = 1;
