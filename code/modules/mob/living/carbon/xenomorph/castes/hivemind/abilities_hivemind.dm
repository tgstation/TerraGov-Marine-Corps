/datum/action/xeno_action/return_to_core
	name = "Return to Core"
	action_icon_state = "lay_hivemind"
	mechanics_text = "Teleport back to your core."

/datum/action/xeno_action/return_to_core/action_activate()
	SEND_SIGNAL(owner, COMSIG_XENOMORPH_CORE_RETURN)

/datum/action/xeno_action/activable/mirage
	name = "Mirage"
	action_icon_state = ""
	mechanics_text = "Create mirror images of the targeted xeno."
	///How long will the illusions live
	var/illusion_life_time = 1 MINUTES
	///How many illusions are created
	var/illusion_count = 3

/datum/action/xeno_action/activable/mirage/can_use_ability(atom/A, silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return FALSE
	if(!isxeno(A) || !owner.issamexenohive(A))
		return FALSE
	return TRUE

/datum/action/xeno_action/activable/mirage/use_ability(atom/A)
	for(var/i in 1 to illusion_count)
		new /mob/living/carbon/xenomorph/illusion(A.loc, A, illusion_life_time)
