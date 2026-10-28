/// @description A named villager, out on their schedule (made by villagers_update with villagerKey set): they walk where
/// villager_where says, and stop to talk (E). Brom swings his hammer at the anvil.
event_inherited();
who = villagerKey;   // after the parent, which clears who
alarm[1] = -1;     // no wandering: the schedule moves them
spd = 2;           // legs keep pace with WALK_SPEED (Draw animates at this speed)
look = villager_look(who);
y_frame = 10;      // facing down
atWork = false;
hammer = villager_routine(who)[$ "hammer"] ?? false;
act = undefined;   // a hammer swing (the player's action system)
actStep = 0;
hammerTimer = 60;
var w = villager_where(who);
x = w.x;
y = w.y;
