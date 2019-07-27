/mob/living/carbon/xenomorph/hivelord/ai
	ai_datum = new/datum/ai_behavior/xeno/hivelord

/mob/living/carbon/xenomorph/hivelord/ai/Initialize()
	..()
	ai_datum.parentmob = src
	ai_datum.Init()

//Build that wall
/datum/ai_behavior/xeno/hivelord
	var/datum/action/xeno_action/plant_weeds/plantweeds = new
	var/datum/action/xeno_action/activable/secrete_resin/hivelord/secrete = new

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

	if(ability_tick_threshold % 2 == 0)

		if(!parentmob2.speed_activated)
			parentmob2.speed_activated = TRUE //Vroom vroom

		if(!(/obj/effect/alien/weeds/node) in range(1, parentmob2))
			plantweeds.action_activate()
		else

			var/got_wall = FALSE
			for(var/turf/closed/wall/resin/wall in range(1, parentmob2))
				if(wall)
					got_wall = TRUE
					break
			if(!got_wall)
				var/turf/T = get_turf(parentmob2)
				T.ChangeTurf(/turf/closed/wall/resin)
				return //We plopped a thicc wall, can't build anything else here

	var/turf/T2 = get_turf(parentmob2)
	var/obj/effect/alien/resin/sticky/thingy
	if(!(locate(thingy) in T2))
		var/turf/T = get_turf(parentmob2)
		new/obj/effect/alien/resin/sticky(T)
		//parentmob2.selected_resin = /obj/effect/alien/resin/sticky
		//secrete.use_ability()
