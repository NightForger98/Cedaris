/// @description The world map (M): the outdoor rooms as they join (spr_world_map, scripts/world_map), where you
/// are, and who lives in each building when the mouse is over it. The clock stops while it's open (ui_blocking).
/// Zoom with the mouse wheel (or + / -), toward the mouse; drag with the left button (or the arrow keys) to move
/// round it; Home shows all of it again.
justOpened = true;   // ignore the M press that opened it
guiW = display_get_gui_width();
guiH = display_get_gui_height();
testHover = "";     // tests: a building (the room inside) to treat as under the mouse
// The frame the map fits in (all of it at zoom 1), and the map's top-left corner and scale now
var m = world_map();
fitS = min((guiW - 160) / m.w, (guiH - 190) / m.h);
frameX = (guiW - m.w * fitS) / 2;
frameY = 90 + (guiH - 190 - m.h * fitS) / 2;
frameW = m.w * fitS;
frameH = m.h * fitS;
zoom = 1;
mapX = frameX;
mapY = frameY;
dragging = false;
dragLast = [0, 0];
