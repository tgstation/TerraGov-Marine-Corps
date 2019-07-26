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
		var/datum/action_state/hunt_and_destroy/action_state2 = action_state
		if((get_dist(parentmob, action_state2.atomtowalkto) > 1) && istype(action_state2.atomtowalkto, /mob/living/carbon))
			var/mob/living/carbon/target = action_state2.atomtowalkto
			if(!target.canmove) //If it's a carbon target (xeno/human) and it can move, we'll pounce to be able to chainstun effectively
				return
		if(pounce.can_use_ability(action_state2.atomtowalkto, FALSE, XACT_IGNORE_SELECTED_ABILITY))
			pounce.use_ability(action_state2.atomtowalkto)
