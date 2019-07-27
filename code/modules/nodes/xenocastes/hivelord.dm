/mob/living/carbon/xenomorph/hivelord/ai
	var/datum/ai_behavior/xeno/hivelord/ai_datum = new

/mob/living/carbon/xenomorph/hivelord/ai/Initialize()
	..()
	ai_datum.parentmob = src
	ai_datum.Init()

//Build that wall
/datum/ai_behavior/xeno/hivelord
	var/datum/action/xeno_action/plant_weeds/plantweeds = new
	var/datum/action/xeno_action/activable/secrete_resin/secrete = new

/datum/ai_behavior/xeno/hivelord/Init()
	..()
	var/mob/living/carbon/xenomorph/hivelord/parentmob2 = parentmob
	if(SSai.init_pheromones)
		parentmob2.current_aura = pick(list("recovery", "warding", "frenzy"))
	plantweeds.owner = parentmob2
	secrete.owner = parentmob2

//We make magic weeds, walls and sticky resin
/datum/ai_behavior/xeno/hivelord/HandleAbility()
	. = ..()
	if(!.)
		return FALSE

	var/mob/living/carbon/xenomorph/hivelord/parentmob2 = parentmob

	if(ability_tick_threshold % 4 == 0)

		if(!locate(/turf/closed/wall/resin) in range(1, parentmob))
			parentmob2.selected_resin = /turf/closed/wall/resin/thick
			secrete.action_activate()
			return //We plopped a thicc wall, can't build anything else here

		else
			if(!(locate(/obj/effect/alien/weeds/node) in range(1, parentmob)))
				plantweeds.action_activate()

	if(ability_tick_threshold % 2 == 0)
		if(!locate(/obj/effect/alien/resin/sticky in get_turf(parentmob)))
			parentmob2.selected_resin = /obj/effect/alien/resin/sticky
			secrete.action_activate()
