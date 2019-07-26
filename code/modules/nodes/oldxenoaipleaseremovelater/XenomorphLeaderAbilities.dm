//When a AI xenomorph gets occupied by a player or ghost, they will be granted these abilities to help with commanding the horde of xenos

/datum/action/xeno_action/followleader //All nearby AI's follow the xeno that uses the ability
	name = "All nearby AI xenos follow you"
	action_icon_state = "plant_weeds"
	plasma_cost = 75

/datum/action/xeno_action/followleader/action_activate()
	var/mob/living/carbon/Xenomorph/X = owner
	if(X.check_plasma(75))
		X.use_plasma(75)
		for(var/mob/living/carbon/Xenomorph/AI/H in range(14))
			if(!H.stat || H.canmove)
				H.LeaderToFollow = usr //Follow the leader time
	else
		to_chat(owner, "YOU MUST CONSTRUCT 75 PLASMA TO USE THIS ABILITY!")