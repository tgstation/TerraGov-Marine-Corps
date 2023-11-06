/datum/status_effect/incapacitating/offguard_slowdown
	id = "offguard_slow"
	status_type = STATUS_EFFECT_REPLACE
	var/off_guard_slowdown = 9

/datum/status_effect/incapacitating/offguard_slowdown/on_apply()
	. = ..()
	if(!.)
		return
	owner.add_movespeed_modifier(MOVESPEED_ID_OFF_GUARD_SLOWDOWN, TRUE, 0, NONE, TRUE, off_guard_slowdown)

/datum/status_effect/incapacitating/offguard_slowdown/on_remove()
	owner.remove_movespeed_modifier(MOVESPEED_ID_OFF_GUARD_SLOWDOWN)
	return ..()
