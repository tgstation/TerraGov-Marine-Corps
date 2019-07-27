/mob/living/carbon/xenomorph/praetorian/ai
	var/datum/ai_behavior/xeno/queen/ai_datum = new

/mob/living/carbon/xenomorph/praetorian/ai/Initialize()
	..()
	ai_datum.parentmob = src
	ai_datum.Init()

/datum/ai_behavior/xeno/praetorian
	var//datum/action/xeno_action/activable/xeno_spit/spit = new

/datum/ai_behavior/xeno/praetorian/Init()
	..()
	spit.owner = parentmob
	var/mob/living/carbon/xenomorph/parentmob2 = parentmob
	parentmob2.ammo = new/datum/ammo/xeno/acid/heavy(src)
	if(SSai.init_pheromones)
		parentmob2.current_aura = pick(list("recovery", "warding", "frenzy"))

/datum/ai_behavior/xeno/praetorian/HandleAbility()
	. = ..()
	if(!.)
		return FALSE

	if(istype(action_state, /datum/action_state/hunt_and_destroy))

		if(spit.can_use_ability(action_state2.atomtowalkto))
			spit.use_ability(action_state2.atomtowalkto)
