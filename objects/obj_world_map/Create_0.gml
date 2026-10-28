/// @description The world map (M): the outdoor rooms as they join (spr_world_map, scripts/world_map), where you
/// are, and who lives in each building when the mouse is over it. The clock stops while it's open (ui_blocking).
justOpened = true;   // ignore the M press that opened it
guiW = display_get_gui_width();
guiH = display_get_gui_height();
testHover = "";     // tests: a building (the room inside) to treat as under the mouse
