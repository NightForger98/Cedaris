/// @description The stock crate in a shop of yours (scripts/pshops): E with something in hand leaves the whole stack
/// for your employee (if the shop uses it); with an empty hand, says what's in stock. Set on creation: plot.
if(!variable_instance_exists(id, "plot")) plot = "";
near = false;
