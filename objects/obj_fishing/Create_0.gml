/// @description Fishing in progress. Set on creation: fish (what will bite), bobX, bobY (where the line went in).
/// Wait for a bite, then press Space while the marker is in the green zone. Esc reels in.
state = "wait";               // "wait" -> "bite" -> gone
waitT = irandom_range(60, 200); // frames until the bite
zone = fishing_zone_width(fish);
zoneAt = random_range(0.1, 0.9 - zone); // where the green zone starts on the bar (0-1)
marker = 0;
markerDir = 1;
markerSpeed = 0.012 + fish_def(fish).hard * 0.022;
biteT = 0;                    // how long the bite has lasted (a fish won't wait forever)
justOpened = true;
