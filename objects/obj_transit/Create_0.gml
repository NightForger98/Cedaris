/// @description A cable car or tram station (scripts/transit). Set on creation: kind ("cable" / "tram"), stop (its
/// name). E rides: the cable car straight to the other end, the tram from a menu of its other stops.
if(!variable_instance_exists(id, "kind")) kind = "tram";
if(!variable_instance_exists(id, "stop")) stop = "";
near = false;
menuOpen = false;
pick = 0;
message = "";
messageTime = 0;
