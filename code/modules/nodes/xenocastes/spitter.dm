/mob/living/carbon/xenomorph/spitter/ai
	var/datum/ai_behavior/xeno/spitter/ai_datum = new

/mob/living/carbon/xenomorph/spitter/ai/Initialize()
	..()
	ai_datum.parentmob = src
	ai_datum.Init()

/datum/ai_behavior/xeno/spitter
	distance_to_maintain = 5 //Far enough to be 'fair'
	var/datum/action/xeno_action/activable/xeno_spit/spit = new

/datum/ai_behavior/xeno/spitter/Init()
	..()
	spit.owner = parentmob
	var/mob/living/carbon/xenomorph/parentmob2 = parentmob
	parentmob2.ammo = new/datum/ammo/xeno/acid(src)

/datum/ai_behavior/xeno/spitter/HandleAbility()
	. = ..()
	if(!.)
		return FALSE

	if(istype(action_state, /datum/action_state/hunt_and_destroy))
		var/datum/action_state/hunt_and_destroy/action_state2 = action_state

		if(spit.can_use_ability(action_state2.atomtowalkto))
			spit.use_ability(action_state2.atomtowalkto)
