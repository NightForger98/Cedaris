/// @description Insert description here
// You can write your code in this editor
debug =false;
randomize();
settings_load();
playtime = 0;     // seconds played, saved with the game
pauseShot = -1;   // snapshot of the screen behind the pause menu
resumeLock = 0;   // frames to ignore Esc after resuming, so the same press doesn't pause again
sleeping = false; // fading out to end the day (sleep_now)
passedOut = false;
sleepDone = false;
waking = false;   // fading in after waking up
wakeAtBed = false;
autosavePending = false;
dayReport = {lost: 0, died: 0, paid: 0}; // what the last new day did, for the morning message
hudMessage = "";
hudTime = 0;
room_goto_next(); // the main menu

guiWidth = display_get_gui_width();
guiHeight = display_get_gui_height();
blackAlpha = 0;

spawnRoom = -1;
spawnX=0;
spawnY= 0;
spawnPlayerFacing = -1;
doTransition = false;


enum dir {
	 
	 right = 0,
	 up = 90,
	 left = 180,
	 down = 270,
}








