/mob/living/carbon/xenomorph/sentinel/ai
	var/datum/ai_behavior/xeno/sentinel/ai_datum = new
	distance_to_maintain = 5 //Far enough to be 'fair'

/mob/living/carbon/xenomorph/sentinel/ai/Initialize()
	..()
	ai_datum.parentmob = src
	ai_datum.Init()

/datum/ai_behavior/xeno/sentinel
	var//datum/action/xeno_action/activable/xeno_spit/spit = new

/datum/ai_behavior/xeno/sentinel/Init()
	..()
	spit.owner = parentmob
	var/mob/living/carbon/xenomorph/parentmob2 = parentmob
	parentmob2.ammo = new/datum/ammo/xeno/toxin(src)

/datum/ai_behavior/xeno/sentinel/HandleAbility()
	. = ..()
	if(!.)
		return FALSE

	if(istype(action_state, /datum/action_state/hunt_and_destroy))
		var/datum/action_state/hunt_and_destroy/action_state2 = action_state

		if(spit.can_use_ability(action_state2.atomtowalkto))
			spit.use_ability(action_state2.atomtowalkto)
