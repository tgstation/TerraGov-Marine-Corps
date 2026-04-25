// Atom x_act() procs signals. Format:
// When the signal is called: (signal arguments)
// All signals send the source datum of the signal as the first argument

///from base of atom/CheckParts(): (list/parts_list, datum/crafting_recipe/R)
#define COMSIG_ATOM_CHECKPARTS "atom_checkparts"
///from base of atom/CheckParts(): (atom/movable/new_craft) - The atom has just been used in a crafting recipe and has been moved inside new_craft.
#define COMSIG_ATOM_USED_IN_CRAFT "atom_used_in_craft"
/// signal sent when a mouse is hovering over us, sent by atom/proc/on_mouse_entered
#define COMSIG_ATOM_MOUSE_ENTERED "mouse_entered"
