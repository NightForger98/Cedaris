/// @description A plot of land for sale in town (scripts/pshops; laid out by tools/world2/areas_build.js). Set on
/// creation: plot (its id), pw, ph (its size in cells); x, y its top-left corner. Its For Sale sign stands by the door
/// at the middle of its front: a Land Deed claims it, then the sign's menu orders a shop - a kind, then a building.
/// Once built, the building stands here and its door (an obj_transition the builder placed) opens.
if(!variable_instance_exists(id, "plot")) plot = "";
if(!variable_instance_exists(id, "pw")) pw = 7;
if(!variable_instance_exists(id, "ph")) ph = 6;
ready = false;
near = false;
menuOpen = false;
stage = 0;        // 0: the kind of shop, 1: the building
pick = 0;
kindPick = "";
midX = 0; doorY = 0; signX = 0; signY = 0;
