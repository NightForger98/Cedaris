/// @description Female human villager
event_inherited();
look = character_random_look("Human");
character_set_body(look, "female");
// A villager who lives here, if one is free (the same person every time) - or a guest at the festival
who = variable_instance_exists(id, "festivalWho") ? festivalWho : villager_take("woman");
// On a festival day everyone who lives elsewhere is in the village
if(who != "" && room != rm_2 && festival_today() != undefined && !variable_instance_exists(id, "festivalWho")){ instance_destroy(); exit; }
if(who != "") look = villager_look(who);
