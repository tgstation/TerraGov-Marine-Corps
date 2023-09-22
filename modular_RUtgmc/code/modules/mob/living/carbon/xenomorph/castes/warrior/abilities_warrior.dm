/datum/action/xeno_action/toggle_agility/action_activate()
	. = ..()
	var/mob/living/carbon/xenomorph/X = owner
	if(X.agility)
		owner.drop_all_held_items() // drop items (hugger/jelly)
