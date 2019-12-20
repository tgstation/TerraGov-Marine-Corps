// ***************************************
// *********** Stealth
// ***************************************
/datum/action/xeno_action/track
	name = "Track Xeno"
	action_icon_state = "stealth_on"
	mechanics_text = "Track a xeno."
	ability_name = "stealth"
	plasma_cost = 1
	keybind_signal = COMSIG_XENOABILITY_TOGGLE_STEALTH
	cooldown_timer = 0


/datum/action/xeno_action/track/can_use_action(silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return FALSE
	return TRUE


/datum/action/xeno_action/track/on_cooldown_finish()
	return ..()


/datum/action/xeno_action/track/action_activate()
	// Select a mob
	// Check if mob is on weeds
	// Track mob
	succeed_activate()
	add_cooldown()
	return TRUE

