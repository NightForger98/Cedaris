/// @description Insert description here
// You can write your code in this editor
w_spd= 1;
n_spd= 2;
r_spd= 3;
spd = n_spd;
x_frame =0;
y_frame =0;
moveX=0;
moveY=0;
//pallets
//base0
pal_skn=pal_skin_light;//ear,nose
pal_eyes=pal_eyes_blue;
pal_hair=pal_hair_sandy;
pal_beard=pal_hair_sandy;

//layer1
pal_earing=pal_metal_silver;
pal_headcover= pal_mixmetal_marooonsilver;
pal_hat= pal_hair_black;
pal_shirt=pal_clothes_purple;
pal_necklace=pal_metal_silver;
pal_vest=pal_clothes_bluegrey;
pal_between=pal_clothes_forest;
pal_band=pal_clothes_leather;
pal_pants=pal_clothes_blue;
pal_shoes=pal_clothes_black;
pal_armor=pal_clothes_navy;
pal_belt=pal_clothes_leather;
pal_scarf=pal_clothes_bluegrey;
pal_shoulders=pal_clothes_leather;
pal_wrist=pal_clothes_blue;
pal_gloves=pal_clothes_maroon;
pal_cape = pal_clothes_lavender;


idx_blank=index_blankref;

//Base 0

idx_bs=index_base0_male_norm;


//layer1
idx_bse=index_base1__ears_elven;
idx_bsn=index_base1__nose_straight;
idx_iz=index_base1_eyes;
idx_hair=index_bs1_hair_short_mess3;
idx_brd=index_bs1_beard_full;

//Base 1, layer0

idx_trs=index_bs3_torso_shirt_longsleeve;
idx_pnt=index_bs3_leg_pants;
idx_shs=index_bs3_shoes_shoes;

//layer 2
idx_top= index_bs2_headtop_headcover_hijab;
idx_acc=index_bs2_face_earing;
idx_nck=index_bs2_neck_necklace;
idx_trs2=index_bs3_torso_chainmail;
idx_bld= index_bs2_body_bauldron ;
idx_shldr=index_bs2_shoulder_leather
idx_wrst=index_bs3_arms_wrist_bracers
idx_glv=index_bs3_arms_hands_gloves
idx_wst=index_bs3_torso_waist_leatherbelt;
idx_cp = index_bs3_cape_tattered;
idx_trs3 =index_bs3_torso_overarmor_leather;





///////

x_offset = sprite_get_xoffset(mask_index);
y_offset = sprite_get_yoffset(mask_index);
facing = 0;