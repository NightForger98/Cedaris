/// @description Brom the blacksmith: stands at his post and sells tools and weapons (press E nearby)
event_inherited();
npcName = "Brom";
who = "brom";     // a villager: friendship, gifts (see the people script)
talkRange = 80;   // he stands back from his anvil
alarm[1] = -1;   // no wandering
moveX = 0;
moveY = 0;
y_frame = 10;    // face down
near = false;

// Every few seconds he swings his hammer (the same action system as the player)
act = undefined;
actStep = 0;
hammerTimer = 60;

// A stout dwarf smith in an apron, hammer in hand
look = character_empty_look("Dwarf", "male");
var p = look.parts;
p.body.pal  = character_find_palette("body", "bronze");
p.head      = {item: character_find_item("head", "Human Male Plump"), pal: -1};
p.hair      = {item: character_find_item("hair", "Balding"),          pal: character_find_palette("hair", "dark_gray")};
p.beard     = {item: character_find_item("beard", "Winter Beard"),    pal: character_find_palette("hair", "dark_gray")};
p.shirt     = {item: character_find_item("shirt", "Longsleeve"),      pal: character_find_palette("cloth", "charcoal")};
p.vest      = {item: character_find_item("vest", "Apron"),            pal: character_find_palette("cloth", "leather")};
p.pants     = {item: character_find_item("pants", "Pants"),           pal: character_find_palette("cloth", "brown")};
p.shoes     = {item: character_find_item("shoes", "Basic Boots"),     pal: character_find_palette("cloth", "black")};
p.belt      = {item: character_find_item("belt", "Leather Belt"),     pal: -1};
p.held      = {item: character_find_item("held", "Hammer"),           pal: -1};
