/mob/living/carbon/xenomorph/drone/ai
	var/datum/ai_behavior/xeno/drone/ai_datum = new

/mob/living/carbon/xenomorph/drone/ai/Initialize()
	..()
	ai_datum.parentmob = src
	ai_datum.Init()

//An AI datum for drones; it makes weeds and pheromones
/datum/ai_behavior/xeno/drone
	var/datum/action/xeno_action/plant_weeds/plantweeds = new

/datum/ai_behavior/xeno/drone/Init()
	..()
	var/mob/living/carbon/xenomorph/drone/parentmob2 = parentmob
	if(SSai.init_pheromones)
		parentmob2.current_aura = pick(list("recovery", "warding", "frenzy"))
	plantweeds.owner = parentmob2

//We make magic weeds
/datum/ai_behavior/xeno/drone/HandleAbility()
	. = ..()
	if(!.)
		return FALSE
	if(ability_tick_threshold % 2 == 0)
		for(var/obj/effect/alien/weeds/node/node in range(1, parentmob))
			if(node)
				return FALSE
		plantweeds.action_activate()
