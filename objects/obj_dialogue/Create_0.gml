/// @description Talking to a villager. Set on creation: who (villager key), npc (the instance), text (what they say),
/// note (a heart reward message, or "").
justOpened = true;  // ignore the E press that opened us
guiW = display_get_gui_width();
guiH = display_get_gui_height();
// They stop and face you
with(npc){ moveX = 0; moveY = 0; y_frame = 10; }
