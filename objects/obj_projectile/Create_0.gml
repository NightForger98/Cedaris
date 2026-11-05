/// @description A shot from a slingshot, crossbow or boomerang. Set on creation: dx, dy, life, weapon, ang.
// It flies at chest height; its ground point (for walls and hits) is 20 px below.
// A boomerang's (combat_player_hit sets them): who threw it, whether it's on its way back, what it has hit this way
if(!variable_instance_exists(id, "owner")) owner = noone;
if(!variable_instance_exists(id, "back")) back = false;
if(!variable_instance_exists(id, "hits")) hits = [];
if(!variable_instance_exists(id, "pierce")) pierce = 0;   // monsters a shot flies on through
spin = 0;
