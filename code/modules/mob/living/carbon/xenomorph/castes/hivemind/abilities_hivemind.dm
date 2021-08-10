/datum/action/xeno_action/return_to_core
	name = "Return to Core"
	action_icon_state = "lay_hivemind"
	mechanics_text = "Teleport back to your core."

/datum/action/xeno_action/return_to_core/action_activate()
	SEND_SIGNAL(owner, COMSIG_XENOMORPH_CORE_RETURN)
