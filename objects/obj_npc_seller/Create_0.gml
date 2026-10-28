/// @description Mara the seed seller: stands at her stall and sells seeds for the season (press E nearby)
event_inherited();
npcName = "Mara";
who = "mara";
talkRange = 70;   // across her stall
alarm[1] = -1;   // no wandering
moveX = 0;
moveY = 0;
y_frame = 10;    // face down
near = false;

look = character_empty_look("Halfling", "teen");
var p = look.parts;
p.body.pal  = character_find_palette("body", "amber");
p.head      = {item: character_find_item("head", "Human Female Small"), pal: -1};
p.hair      = {item: character_find_item("hair", "Ponytail"),           pal: character_find_palette("hair", "ginger")};
p.shirt     = {item: character_find_item("shirt", "Longsleeve"),        pal: character_find_palette("cloth", "green")};
p.vest      = {item: character_find_item("vest", "Apron"),              pal: character_find_palette("cloth", "tan")};
p.pants     = {item: character_find_item("pants", "Pants"),             pal: character_find_palette("cloth", "brown")};
p.shoes     = {item: character_find_item("shoes", "Basic Shoes"),       pal: character_find_palette("cloth", "brown")};
p.hat       = {item: character_find_item("hat", "Bandana"),             pal: character_find_palette("cloth", "yellow")};
character_validate(look);
