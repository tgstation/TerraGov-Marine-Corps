// ***************************************
// *********** Bull charge types
// ***************************************

/datum/action/xeno_action/toggle_charge_type
	name = "Toggle Charge Type"
	action_icon_state = "toggle_long_range"
	mechanics_text = "Toggles between the different charge types."
	plasma_cost = 0
	keybind_signal = COMSIG_XENOABILITY_LONG_RANGE_SIGHT


/datum/action/xeno_action/toggle_charge_type/action_activate()
	var/mob/living/carbon/xenomorph/charger = owner
	if(charger.is_charging >= CHARGE_ON)
		to_chat(charger, "<span class='warning'>We are too focused charging!</span>")
		return FALSE
	SEND_SIGNAL(owner, COMSIG_XENOACTION_TOGGLECHARGETYPE)
