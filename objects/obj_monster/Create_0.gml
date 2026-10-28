/// @description A monster (see the combat script). Set on creation: kind, def (its monster_table row), hp, hpMax, toughness.
// Same feet-sized footprint as the player
mask_index = spr_collision_charachter;
// Bosses are drawn bigger, and their footprint grows with them
sc = def[$ "scale"] ?? 1;
image_xscale = sc;
image_yscale = sc;
look = variable_struct_exists(def, "race") ? monster_look(def) : undefined; // humanoids wear an LPC look
dirIdx = 2;          // facing: 0 north, 1 west, 2 south, 3 east
frame = 0;
moveX = 0;
moveY = 0;
wanderT = 0;
aggro = (def[$ "boss"] ?? false) ? 420 : 170; // how close you get before it comes for you (bosses: anywhere in sight)
attacking = false;
act = undefined;     // the attack animation (humanoids)
actFrames = 1;
actHit = 0;
actFps = 10;
step = 0;
hitDone = false;
cooldown = 60;
hurtT = 0;           // stunned and sliding back after a hit
flash = 0;
kx = 0;
ky = 0;
dying = false;
deathT = 0;
shooting = false;    // this attack is a shot (see monster_shoot)
