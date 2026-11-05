/// @description A building drawn as one sprite (the Meshy and PixelLab houses), placed by tools/rooms/build.js: its
/// creation code sets sprite_index. x is the sprite's left edge and y its bottom (the building's foot): it draws up
/// from there and sorts by y like the player, so you're hidden behind it north of its front and drawn over it south
/// of it. Its collision is the room's (obj_col_box over its foot), and the way in an obj_transition at its door.
sorted = false;
