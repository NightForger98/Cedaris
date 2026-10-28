/// @description Male human villager
event_inherited();
look = character_random_look("Human");
character_set_body(look, "male");
// A villager who lives here, if one is free (the same person every time)
who = villager_take("man");
if(who != "") look = villager_look(who);
