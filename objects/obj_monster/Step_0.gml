/// @description Wander until you come close, then chase and attack; stunned and pushed back when hit
// The world holds still in menus and fades
if(ui_blocking() || instance_exists(obj_menu) || game.doTransition || game.dying || game.sleeping) exit;
if(dying){ if(++deathT > 24) instance_destroy(); exit; }
if(flash > 0) flash--;
if(cooldown > 0) cooldown--;
// Flyers pass over rocks but not through the cave walls
var solids = collision_solids(false);
if(def[$ "flies"] ?? false) solids = (global.mineWalls != -1) ? global.mineWalls : obj_col_box;

if(hurtT > 0){
	hurtT--;
	monster_move(kx, ky, solids);
	kx *= 0.8;
	ky *= 0.8;
	depth_sort();
	exit;
}

var p = instance_exists(obj_plyr) ? obj_plyr : noone;
if(attacking){
	step += actFps / game_get_speed(gamespeed_fps);
	if(!hitDone && step >= actHit){
		hitDone = true;
		// A shot at range, or a blow up close
		if(shooting && p != noone) monster_shoot(id, p);
		else if(p != noone && point_distance(x, y, p.x, p.y) <= def.reach + 10) player_hurt(irandom_range(def.dmg[0], def.dmg[1]) * toughness, x, y);
	}
	if(step >= actFrames){ attacking = false; cooldown = shooting ? irandom_range(70, 120) : irandom_range(40, 80); }
	depth_sort();
	exit;
}

var d = (p != noone) ? point_distance(x, y, p.x, p.y) : infinity;
// Pixies and moths never attack: they flutter about, and dart away when you come close
if(def[$ "passive"] ?? false){
	if(d < 70){
		var away = point_direction(p.x, p.y, x, y) + random_range(-30, 30);
		moveX = lengthdir_x(def.speed, away);
		moveY = lengthdir_y(def.speed, away);
	} else if(--wanderT <= 0){
		wanderT = irandom_range(30, 90);
		var a = random(360);
		moveX = lengthdir_x(def.speed * 0.5, a);
		moveY = lengthdir_y(def.speed * 0.5, a);
	}
	if(moveX != 0) dirIdx = (moveX < 0) ? 1 : 3;
	monster_move(moveX, moveY, solids);
	frame += 0.25;
	depth_sort();
	exit;
}
if(d < aggro){
	var a = point_direction(x, y, p.x, p.y);
	dirIdx = monster_dir(a);
	// Shooters (slimes spit, watchers fire bolts, lizards throw spears) attack from range; the rest up close
	var rg = def[$ "ranged"];
	var canShoot = rg != undefined && d > def.reach && d <= rg.range;
	if((d <= def.reach || canShoot) && cooldown <= 0){
		attacking = true;
		shooting = canShoot;
		step = 0;
		hitDone = false;
		moveX = 0;
		moveY = 0;
		if(look != undefined){
			// Its weapon's swing, or a bare-handed slash
			act = character_action_for(look) ?? {name: "slash", custom: false, row: 12, seq: [0, 1, 2, 3, 4, 5], frames: 6, fs: 64, fps: 12, hit: 3};
			actFrames = act.frames;
			actHit = act.hit;
			actFps = act.fps;
		} else {
			actFrames = def.frames;
			actHit = floor(def.frames * 0.6);
			actFps = 10;
		}
	} else if(d > ((rg != undefined) ? rg.range * 0.7 : def.reach * 0.6)){
		moveX = lengthdir_x(def.speed, a);
		moveY = lengthdir_y(def.speed, a);
		monster_move(moveX, moveY, solids);
	} else { moveX = 0; moveY = 0; }
} else {
	if(--wanderT <= 0){
		wanderT = irandom_range(60, 150);
		var w = choose(-1, 0, 1, 2, 3);
		moveX = 0;
		moveY = 0;
		if(w >= 0){ dirIdx = w; moveX = [0, -1, 0, 1][w] * def.speed * 0.5; moveY = [-1, 0, 1, 0][w] * def.speed * 0.5; }
	}
	monster_move(moveX, moveY, solids);
}
frame += (moveX != 0 || moveY != 0) ? 0.15 : 0.08;
depth_sort();
