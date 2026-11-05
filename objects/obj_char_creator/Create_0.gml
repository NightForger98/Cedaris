/// @description Character creator setup
// Story mode: a human man or woman (character_story_rules), chosen first; then head, face and hair for that gender
// only. Clothing is the fixed starter outfit (earned later in the world). Free mode: every race, body and part.
story = variable_global_exists("gameMode") && global.gameMode == "story";
slots = character_slots();
if(story){
	var storyKeys = character_story_rules().keys;
	var keep = [];
	for(var i = 0; i < array_length(slots); i++){
		var s = slots[i];
		if(array_get_index(storyKeys, s.key) == -1) continue;
		// The Body row picks the gender (the slot table is shared, so a relabelled copy)
		if(s.key == "body") s = {label: "Gender", key: s.key, items: s.items, canBeEmpty: false, emptyChance: 0};
		array_push(keep, s);
	}
	slots = keep;
}

/// Story mode: a man's or a woman's parts only, and the starter outfit
storyRules = function(){
	if(!story) return;
	character_story_validate(look);
	global.inv = inv_new_story();
	inv_apply_look(look);
};

// Edit a copy, so backing out of the creator doesn't change the saved look
look = (variable_global_exists("look") && is_struct(global.look) && variable_struct_exists(global.look, "parts"))
	? variable_clone(global.look) : (story ? character_story_default_look("male") : character_default_look());

// Story mode starts by asking man or woman (stage "gender"), then shows the rows (stage "edit")
stage = story ? "gender" : "edit";
genders = story ? character_story_rules().genders : [];
genderLooks = [];
for(var i = 0; i < array_length(genders); i++) array_push(genderLooks, character_story_default_look(genders[i]));
genderNames = {male: "Male", female: "Female"};

/// Story mode: take gender _g ("male" / "female") as the first choice and go on to the rows
pickGender = function(_g){
	look = character_story_default_look(_g);
	storyRules();
	stage = "edit";
};

// Preview animation
facingRows = [10, 9, 8, 11]; // sheet rows: down, left, up, right
facing = 0;
frame = 1;

// Layout (GUI coordinates)
guiW = display_get_gui_width();
guiH = display_get_gui_height();
rowCount = array_length(slots);
top = 78;
rowH = min(34, floor((guiH - top - 92) / rowCount));
textScale = min(0.7, rowH / 44);

colLabel = floor(guiW * 0.42);
arrowW = 28;
optX = colLabel + 140;       // sprite selector: [<] name [>]
optW = 300;
palX = optX + optW + 24;     // colour selector: [<] swatch name [>]
palW = 270;

previewCX = floor(guiW * 0.21);
previewCY = floor(guiH * 0.45);
previewScale = 5;

// Buttons: label, x1, y1, x2, y2, action
var by = guiH - 70;
var bw = 170;
var bx = palX + palW - bw * 3 - 24;
buttons = [
	{label: "Back",      x1: bx - bw - 12,     y1: by, x2: bx - 12,           y2: by + 44, action: "back"},
	{label: "Randomise", x1: bx,               y1: by, x2: bx + bw,           y2: by + 44, action: "random"},
	{label: "Reset",     x1: bx + bw + 12,     y1: by, x2: bx + bw * 2 + 12,  y2: by + 44, action: "reset"},
	{label: "Done",      x1: bx + bw * 2 + 24, y1: by, x2: bx + bw * 3 + 24,  y2: by + 44, action: "done"},
	{label: "<",         x1: previewCX - 120,  y1: previewCY + 190, x2: previewCX - 76,  y2: previewCY + 234, action: "turnleft"},
	{label: ">",         x1: previewCX + 76,   y1: previewCY + 190, x2: previewCX + 120, y2: previewCY + 234, action: "turnright"},
];
hoverRow = -1;
storyRules();
// The gender cards wear the starter outfit too (global.inv is the story inventory now)
for(var i = 0; i < array_length(genderLooks); i++) inv_apply_look(genderLooks[i]);

// Story mode's first screen: one card per gender, each with a walking preview
cardW = 360;
cardH = 470;
cardY = floor(guiH / 2) - cardH / 2 + 10;
cards = [];
for(var i = 0; i < array_length(genders); i++){
	var cx = floor(guiW / 2) + (i - (array_length(genders) - 1) / 2) * (cardW + 60);
	array_push(cards, {x1: cx - cardW / 2, y1: cardY, x2: cx + cardW / 2, y2: cardY + cardH, gender: genders[i]});
}
hoverCard = -1;

/// Step creator row _i by _d (arrows or the wheel)
cycleRow = function(_i, _d){
	var s = slots[_i];
	if(story) character_story_cycle_item(look, s, _d);
	else character_cycle_item(look, s, _d);
	storyRules();
};

/// A button's action (also the keys): random, reset, turnleft, turnright, back, done
act = function(_action){
	switch(_action){
		case "random":
			if(story) character_story_randomise(look); else character_randomise(look, "");
			storyRules();
			break;
		case "reset":     look = story ? character_story_default_look(character_gender(look)) : character_default_look(); storyRules(); break;
		case "turnleft":  facing = (facing + 1) mod 4; break;
		case "turnright": facing = (facing + 3) mod 4; break;
		case "back":
			// Story mode: back to the man / woman question first
			if(story && stage == "edit") stage = "gender";
			else room_goto(rm_menu);
			break;
		case "done":
			if(story && stage != "edit") break; // the gender comes first
			storyRules();
			global.look = look;
			global.inv = story ? inv_new_story() : inv_new_free(look);
			inv_apply_look(global.look);
			room_goto(rm_1);
			break;
	}
};
