///Handles storing things on the attached atom
/datum/component/storage
	var/stamina_state = STAMINA_STATE_IDLE

/datum/component/stamina_behavior/Initialize()
	. = ..()
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE
	RegisterSignal(parent, COMSIG_MOB_TOGGLEMOVEINTENT, .proc/on_toggle_move_intent)
