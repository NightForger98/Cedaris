/// @description Menu setup
// One object for the title screen and the pause menu. game_pause() sets isPause and screen = "pause".
// Screens: main, pause, slots (load or save), options, controls, credits
isPause = false;
justOpened = true;   // skip the Esc press that opened the pause menu
screen = "main";
guiW = display_get_gui_width();
guiH = display_get_gui_height();

slotMode = "load";     // what the slots screen does: "load" or "save"
slotData = [];         // save data per slot (index 0 = slot 1), undefined when empty
slotLooks = [];        // character looks for the slot previews
confirm = "";          // e.g. "del2" or "save1" while waiting for a second click
message = "";
messageTime = 0;
creditsScroll = 0;

refreshSlots = function(){
	slotData = [];
	slotLooks = [];
	for(var s = 1; s <= SAVE_SLOTS; s++){
		var d = save_read(s);
		array_push(slotData, d);
		array_push(slotLooks, (d == undefined) ? undefined : character_look_from_save(d.look));
	}
	latestSlot = save_latest_slot();
};
refreshSlots();

showMessage = function(_text){
	message = _text;
	messageTime = game_get_speed(gamespeed_fps) * 3;
};

openScreen = function(_screen){
	screen = _screen;
	confirm = "";
	creditsScroll = (_screen == "credits") ? guiH * 0.55 : 0; // start with the first lines already on screen
	if(_screen == "slots") refreshSlots();
};

// Villagers strolling along the bottom of the title screen
parade = [];
for(var i = 0; i < 6; i++){
	array_push(parade, {look: character_random_look(), x: random(guiW), spd: random_range(0.6, 1.4), frame: random(8)});
}
