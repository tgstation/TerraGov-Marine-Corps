/mob/living/carbon/xenomorph/runner/ai
	var/datum/ai_behavior/xeno/runner/ai_datum = new

/mob/living/carbon/xenomorph/runner/ai/Initialize()
	..()
	ai_datum.parentmob = src
	ai_datum.Init()

//Uses runner abilities
/datum/ai_behavior/xeno/runner
	var/datum/action/xeno_action/activable/pounce/pounce = new

/datum/ai_behavior/xeno/runner/Init()
	..()
	pounce.owner = parentmob

/datum/ai_behavior/xeno/runner/HandleAbility()
	..()
	if(istype(action_state, /datum/action_state/hunt_and_destroy))
		if(pounce.can_use_ability())
			var/datum/action_state/hunt_and_destroy/action_state2 = action_state
			pounce.use_ability(action_state2.atomtowalkto)
