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
dying = false;    // fading out after being knocked out in the mine (player_knocked_out)
revived = false;  // waking from that: no autosave, and deathReport is the morning message
deathReport = "";
restartRoom = false; // the transition rebuilds the current room (going down a mine floor)
lightSurf = -1;   // the mine's darkness, drawn in Draw GUI
wakeAtBed = false;
autosavePending = false;
dayReport = {lost: 0, died: 0, paid: 0, blessed: 0}; // what the last new day did, for the morning message
hudMessage = "";
hintQueue = [];  // first-time hints waiting to show (hints script)
hintText = "";
hintTime = 0;
hudTime = 0;
autotest_start(); // automated test run, if autotest.txt is in the save folder
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








