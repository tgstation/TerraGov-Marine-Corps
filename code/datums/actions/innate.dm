//Preset for general and toggled actions
/datum/action/innate
	var/active = FALSE


/datum/action/innate/action_activate()
	if(!can_use_action())
		return FALSE
	if(!active)
		Activate()
	else
		Deactivate()
	return TRUE

/datum/action/innate/proc/Activate()
	return


/datum/action/innate/proc/Deactivate()
	return
