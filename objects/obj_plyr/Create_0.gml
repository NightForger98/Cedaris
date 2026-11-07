/// @description Insert description here
// You can write your code in this editor
w_spd= 1.5;
n_spd= 3;
r_spd= 4.5;   // walk / normal / run: px a frame (the new world is bigger; roads add ROAD_BOOST)
spd = n_spd;
sprinting = false;   // the run key held (Step): moving shows the LPC run cycle
x_frame =0;
y_frame =0;
moveX=0;
moveY=0;

// Appearance: the look picked in the character creator, or the default look
// (body parts, clothes and palettes - see character_default_look in character_look)
look = (variable_global_exists("look") && is_struct(global.look)) ? global.look : character_default_look();


///////

x_offset = sprite_get_xoffset(mask_index);
y_offset = sprite_get_yoffset(mask_index);
facing = 0;
act = undefined;     // the action being played (see the actions script), or undefined
actStep = 0;         // current step of it
actDir = 2;          // facing while acting: 0 north, 1 west, 2 south, 3 east
actHit = false;      // the hit step has fired
baseDepth = depth; // depth of the room layer the player was placed on, used by depth_sort()
iframes = 0;        // frames of invulnerability after a monster hits (see player_hurt)
castSpell = "";     // the spell the current action casts (F with a staff), or ""
charge = undefined; // winding a tool up while the button is held: {item, t, level, max, flash} (charging script)
actCharge = 0;      // the level the current action was charged to (0: a tap)
motion = undefined;  // how a charged release plays out: a spin or a big swing (charge_release_motion), or undefined
doorPrev = undefined; // the transition (door, road out) you stood on last step: walking onto a new one takes you through it (Step)

// Dancing (scripts/skills): frames left, the dance, its step
danceT = 0;
danceKey = "";
danceStep = 0;

// Combat feel (scripts/combat_feel): guarding, the dodge and its afterimages, the knockback that eases off, a
// queued swing, the combo and the aim
blocking = false;
blockT = 0;          // frames since the guard went up (a parry in the first few)
parryCrit = false;   // a parry makes the next hit a critical
dodgeT = 0;
dodgeTotal = 1;
dodgeHop = false;
dodgeVX = 0;
dodgeVY = 0;
dodgeCool = 0;
afterimages = [];
knX = 0;
knY = 0;
bufAttack = 0;       // a swing pressed during the last one, waiting its turn
comboN = 0;          // 0, 1, 2: the third swing in a row is the finisher
comboT = 0;          // frames left to keep the combo going
aimAng = -1;         // the swing's angle (the mouse, with a little help), or -1: where you face
