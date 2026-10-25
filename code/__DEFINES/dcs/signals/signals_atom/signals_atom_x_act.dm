// Atom x_act() procs signals. Format:
// When the signal is called: (signal arguments)
// All signals send the source datum of the signal as the first argument

///from base of atom/CheckParts(): (list/parts_list, datum/crafting_recipe/R)
#define COMSIG_ATOM_CHECKPARTS "atom_checkparts"
///from base of atom/CheckParts(): (atom/movable/new_craft) - The atom has just been used in a crafting recipe and has been moved inside new_craft.
#define COMSIG_ATOM_USED_IN_CRAFT "atom_used_in_craft"
/// signal sent when a mouse is hovering over us, sent by atom/proc/on_mouse_entered
#define COMSIG_ATOM_MOUSE_ENTERED "mouse_entered"

/// Sent from [atom/proc/item_interaction()] to the atom: [/mob/user, /obj/item/tool]
#define COMSIG_ATOM_TOOL_ACT(tooltype) "tool_act_[tooltype]"
/// Sent from [atom/proc/item_interaction()] to the atom: [/mob/user, /obj/item/tool]
#define COMSIG_ATOM_SECONDARY_TOOL_ACT(tooltype) "tool_secondary_act_[tooltype]"
/// Sent from [atom/proc/tool_act()] to the item: [/atom/target]
#define COMSIG_TOOL_ATOM_ACTED_PRIMARY(tooltype) "tool_atom_acted_[tooltype]"
/// Sent from [atom/proc/tool_act()] to the item: [/atom/target]
#define COMSIG_TOOL_ATOM_ACTED_SECONDARY(tooltype) "tool_atom_acted_[tooltype]"
/// Sent from [atom/proc/tool_act()] to the item: [/atom/target, /mob/user, tool_type]
#define COMSIG_ITEM_TOOL_ACTED "tool_item_acted"
