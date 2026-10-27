/// @description Character creator setup
// Story mode: human only, body features only; clothing is the fixed starter outfit (earned later in the world).
story = variable_global_exists("gameMode") && global.gameMode == "story";
storyKeys = ["race", "body", "head", "eyes", "ears", "nose", "eyebrows", "hair", "beard"];
storyBodies = ["male", "female", "teen"]; // the bodies the red shirt / blue pants / brown shoes exist for
slots = character_slots();
if(story){
	var keep = [];
	for(var i = 0; i < array_length(slots); i++) if(array_get_index(storyKeys, slots[i].key) != -1) array_push(keep, slots[i]);
	slots = keep;
}

/// Story mode: force human, an allowed body, and the starter outfit
storyRules = function(){
	if(!story) return;
	if(look.race != "Human") character_set_race(look, "Human");
	if(array_get_index(storyBodies, look.body) == -1) character_set_body(look, storyBodies[0]);
	global.inv = inv_new_story();
	inv_apply_look(look);
};

// Edit a copy, so backing out of the creator doesn't change the saved look
look = (variable_global_exists("look") && is_struct(global.look) && variable_struct_exists(global.look, "parts"))
	? variable_clone(global.look) : character_default_look();

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
