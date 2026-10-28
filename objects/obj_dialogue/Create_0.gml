/// @description Talking to a villager. Set on creation: who (villager key), npc (the instance), text (what they say),
/// note (a heart reward message, or "").
justOpened = true;  // ignore the E press that opened us
guiW = display_get_gui_width();
guiH = display_get_gui_height();
// They stop and face you
with(npc){ moveX = 0; moveY = 0; y_frame = 10; }
// A heart event (see heart_events) plays its lines one by one, then maybe a choice; otherwise these are unused
if(!variable_instance_exists(id, "event")) event = undefined;
if(!variable_instance_exists(id, "line")) line = 0;
if(!variable_instance_exists(id, "chosen")) chosen = -1;
eventDone = false;
