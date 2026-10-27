/// @description Draw the current screen and handle its buttons
var c = ui_colours();
var cx = guiW / 2;
draw_set_font(fnt_eq);

// Background: the frozen game when paused, else the villager parade
if(isPause){
	if(game.pauseShot != -1) draw_sprite_stretched(game.pauseShot, 0, 0, 0, guiW, guiH);
	draw_set_alpha(0.65);
	draw_rectangle_colour(0, 0, guiW, guiH, c_black, c_black, c_black, c_black, false);
	draw_set_alpha(1);
} else {
	for(var i = 0; i < array_length(parade); i++){
		var p = parade[i];
		character_draw(p.look, floor(p.frame), 11, p.x, guiH - 230, 3);
	}
}

switch(screen){

case "main":
	ui_text(cx, 140, "Harvest Valley", 2.6, c.accent);
	ui_text(cx, 210, "a farming tale", 0.8, c.dim);
	var hasSave = (latestSlot != -1);
	var labels = hasSave ? ["Continue", "New Game", "Load Game", "Options", "Credits", "Exit"]
	                     : ["New Game", "Load Game", "Options", "Credits", "Exit"];
	var picked = ui_button_column(cx, 260, 340, 50, 12, labels);
	if(picked != -1){
		switch(labels[picked]){
			case "Continue":  load_game(latestSlot); break;
			case "New Game":  openScreen("newgame"); break;
			case "Load Game": slotMode = "load"; openScreen("slots"); break;
			case "Options":   openScreen("options"); break;
			case "Credits":   openScreen("credits"); break;
			case "Exit":      game_end(); break;
		}
	}
	ui_text(16, guiH - 16, "v0.1", 0.5, c.dim, fa_left);
	break;

case "newgame":
	ui_text(cx, 130, "New Game", 1.8, c.accent);
	var bw = 420, bh = 210, gap = 40;
	var modes = [
		["Story Mode", "story", "Start as a human farmer in plain clothes.\nEarn materials and dyes from quests and\nevents to unlock new clothing and colours.\nBuy tools from the blacksmith."],
		["Free Mode", "free", "Every race, body, outfit and colour is\nunlocked in the character creator, and\ncrafting and the shop are free.\nA sandbox to play however you like."],
	];
	for(var i = 0; i < 2; i++){
		var x1 = cx - bw - gap / 2 + i * (bw + gap), y1 = 230;
		if(ui_button(x1, y1, x1 + bw, y1 + 64, modes[i][0], true, 1)) game_new(modes[i][1]);
		draw_set_colour(c.panel);
		draw_roundrect_ext(x1, y1 + 76, x1 + bw, y1 + 76 + bh, 12, 12, false);
		draw_set_halign(fa_center);
		draw_set_valign(fa_top);
		draw_text_ext_transformed_colour(x1 + bw / 2, y1 + 96, modes[i][2], 34, bw / 0.55, 0.55, 0.55, 0, c_white, c_white, c_white, c_white, 1);
	}
	if(ui_button(cx - 120, guiH - 90, cx + 120, guiH - 40, "Back")) openScreen("main");
	break;

case "pause":
	ui_text(cx, 160, "Paused", 2, c.accent);
	var labels = ["Resume", "Save Game", "Load Game", "Options", "Main Menu", "Quit to Desktop"];
	var picked = ui_button_column(cx, 250, 340, 50, 12, labels);
	switch(picked){
		case 0: game_unpause(); exit;
		case 1: slotMode = "save"; openScreen("slots"); break;
		case 2: slotMode = "load"; openScreen("slots"); break;
		case 3: openScreen("options"); break;
		case 4: game_unpause(); room_goto(rm_menu); exit;
		case 5: game_end(); break;
	}
	break;

case "slots":
	ui_text(cx, 90, (slotMode == "save") ? "Save Game" : "Load Game", 1.6, c.accent);
	if(messageTime > 0) ui_text(cx, 140, message, 0.7, c_white);
	var pw = 820, ph = 150;
	for(var s = 1; s <= SAVE_SLOTS; s++){
		var d = slotData[s - 1];
		var x1 = cx - pw / 2, y1 = 170 + (s - 1) * (ph + 20);
		draw_set_colour(c.panel);
		draw_roundrect_ext(x1, y1, x1 + pw, y1 + ph, 14, 14, false);

		if(d == undefined){
			ui_text(x1 + 40, y1 + ph / 2, "Slot " + string(s) + "  -  empty", 0.9, c.dim, fa_left);
		} else {
			// Mini portrait of the saved character
			character_draw(slotLooks[s - 1], 0, 10, x1 + 10, y1 - 30, 2.6);
			var look = slotLooks[s - 1];
			ui_text(x1 + 190, y1 + 36, "Slot " + string(s) + "  -  " + look.race + " " + look.body, 0.9, c_white, fa_left);
			ui_text(x1 + 190, y1 + 78, save_room_name(d.room) + "   -   played " + save_format_time(d.playtime), 0.65, c.dim, fa_left);
			ui_text(x1 + 190, y1 + 112, date_datetime_string(d.savedAt), 0.6, c.dim, fa_left);
		}

		// Buttons: Load or Save, then Delete. Overwrite and delete need a second click.
		var bx = x1 + pw - 170;
		if(slotMode == "save"){
			var key = "save" + string(s);
			var label = (d != undefined && confirm == key) ? "Overwrite?" : "Save";
			if(ui_button(bx, y1 + 22, bx + 150, y1 + 70, label)){
				if(d != undefined && confirm != key){ confirm = key; }
				else if(save_game(s)){ refreshSlots(); confirm = ""; showMessage("Saved to slot " + string(s)); }
				else { showMessage("You can't save here"); }
			}
		} else if(ui_button(bx, y1 + 22, bx + 150, y1 + 70, "Load", d != undefined)){
			if(isPause) game_unpause();
			load_game(s);
			exit;
		}
		var dkey = "del" + string(s);
		if(ui_button(bx, y1 + 82, bx + 150, y1 + 128, (confirm == dkey) ? "Sure?" : "Delete", d != undefined, 0.65)){
			if(confirm != dkey){ confirm = dkey; }
			else { save_delete(s); refreshSlots(); confirm = ""; showMessage("Slot " + string(s) + " deleted"); }
		}
	}
	if(ui_button(cx - 120, guiH - 90, cx + 120, guiH - 40, "Back")) openScreen(isPause ? "pause" : "main");
	break;

case "options":
	ui_text(cx, 120, "Options", 1.6, c.accent);
	var st = global.settings;
	var lx = cx - 260, rx = cx + 60, y0 = 220, gap = 70;

	ui_text(lx, y0, "Fullscreen", 0.9, c_white, fa_left);
	if(ui_button(rx, y0 - 24, rx + 200, y0 + 24, st.fullscreen ? "On" : "Off")){
		st.fullscreen = !st.fullscreen; settings_apply(); settings_save();
	}

	ui_text(lx, y0 + gap, "Master volume", 0.9, c_white, fa_left);
	if(ui_button(rx, y0 + gap - 24, rx + 48, y0 + gap + 24, "<")){ st.volume = max(0, st.volume - 10); settings_apply(); settings_save(); }
	ui_text(rx + 100, y0 + gap, string(st.volume) + "%", 0.9, c_white);
	if(ui_button(rx + 152, y0 + gap - 24, rx + 200, y0 + gap + 24, ">")){ st.volume = min(100, st.volume + 10); settings_apply(); settings_save(); }

	ui_text(lx, y0 + gap * 2, "Show FPS", 0.9, c_white, fa_left);
	if(ui_button(rx, y0 + gap * 2 - 24, rx + 200, y0 + gap * 2 + 24, st.showFps ? "On" : "Off")){
		st.showFps = !st.showFps; settings_save();
	}

	if(ui_button(cx - 150, y0 + gap * 3 + 10, cx + 150, y0 + gap * 3 + 60, "Controls")) openScreen("controls");
	if(ui_button(cx - 120, guiH - 90, cx + 120, guiH - 40, "Back")) openScreen(isPause ? "pause" : "main");
	break;

case "controls":
	ui_text(cx, 110, "Controls", 1.6, c.accent);
	var rows = [
		["Arrow keys", "Walk"],
		["Shift", "Run"],
		["Ctrl", "Walk slowly"],
		["P", "Planting mode (mouse wheel picks a crop, click to plant)"],
		["G", "Grow crops by one day (testing)"],
		["C", "Free camera, move it with W A S D"],
		["Insert", "Show collision boxes and grid"],
		["I", "Inventory and equipment"],
		["1 - 0", "Pick a hotbar item to hold"],
		["E", "Trade with the blacksmith / use the crafting table"],
		["Esc", "Pause menu / back"],
	];
	for(var i = 0; i < array_length(rows); i++){
		ui_text(cx - 200, 170 + i * 46, rows[i][0], 0.8, c.accent, fa_right);
		ui_text(cx - 170, 170 + i * 46, rows[i][1], 0.7, c_white, fa_left);
	}
	if(ui_button(cx - 120, guiH - 90, cx + 120, guiH - 40, "Back")) openScreen("options");
	break;

case "credits":
	var cr = lpc_credits();
	var lines = [["Harvest Valley", 2, c.accent], ["A game by NightForger98", 0.8, c_white], ["", 0.6, c_white],
	             ["Character art", 1.1, c.accent],
	             ["Liberated Pixel Cup artists, via the Universal LPC Spritesheet Character Generator", 0.6, c.dim]];
	for(var i = 0; i < array_length(cr.authors); i++) array_push(lines, [cr.authors[i], 0.65, c_white]);
	array_push(lines, ["", 0.6, c_white], ["Licences", 1.1, c.accent]);
	var lic = "";
	for(var i = 0; i < array_length(cr.licences); i++) lic += (i > 0 ? ", " : "") + cr.licences[i];
	array_push(lines, [lic, 0.5, c.dim], ["Full per-item credits: LPC_CREDITS.csv", 0.55, c.dim],
	           ["", 0.6, c_white], ["Palette swapping: Lorikeet by DragoniteSpam", 0.65, c_white],
	           ["Made with GameMaker", 0.65, c_white]);

	// Scroll from the bottom up, looping once everything has passed
	var lineH = 34;
	var total = array_length(lines) * lineH + guiH;
	var yy = guiH - (creditsScroll mod total);
	for(var i = 0; i < array_length(lines); i++){
		var ly = yy + i * lineH;
		if(ly > -40 && ly < guiH - 100) ui_text(cx, ly, lines[i][0], lines[i][1], lines[i][2]);
	}
	if(ui_button(cx - 120, guiH - 70, cx + 120, guiH - 24, "Back")) openScreen("main");
	break;
}

draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_colour(c_white);
