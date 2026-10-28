/// @description A way between the village and Whisperwood. Set on creation (or in the room): target - "forest" (the
/// east bridge in the village; it needs mending first) or "village" (the path back, in Whisperwood).
if(!variable_instance_exists(id, "target")) target = "forest";
near = false;
