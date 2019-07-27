/mob/living/carbon/xenomorph/queen/ai
	var/datum/ai_behavior/xeno/queen/ai_datum = new

/mob/living/carbon/xenomorph/queen/ai/Initialize()
	..()
	ai_datum.parentmob = src
	ai_datum.Init()

/datum/ai_behavior/xeno/queen
	var/datum/action/xeno_action/activable/screech/screech = new
	var/datum/action/xeno_action/plant_weeds/plantweeds = new
	var/datum/action/xeno_action/activable/xeno_spit/spit = new

/datum/ai_behavior/xeno/queen/Init()
	..()
	screech.owner = parentmob
	plantweeds.owner = parentmob
	spit.owner = parentmob
	var/mob/living/carbon/xenomorph/parentmob2 = parentmob
	parentmob2.ammo = new/datum/ammo/xeno/acid/heavy(src)
	if(SSai.init_pheromones)
		parentmob2.current_aura = pick(list("recovery", "warding", "frenzy"))

/datum/ai_behavior/xeno/queen/HandleAbility()
	. = ..()
	if(!.)
		return FALSE

	if(ability_tick_threshold % 2 == 0)
		for(var/obj/effect/alien/weeds/node/node in range(1, parentmob))
			if(node)
				return FALSE
		plantweeds.action_activate()

	if(istype(action_state, /datum/action_state/hunt_and_destroy))
		var/datum/action_state/hunt_and_destroy/action_state2 = action_state
		if(get_dist(parentmob, action_state2.atomtowalkto) < 4 && screech.can_use_ability(action_state2.atomtowalkto, FALSE, XACT_IGNORE_SELECTED_ABILITY))
			screech.use_ability()

		if(spit.can_use_ability(action_state2.atomtowalkto))
			spit.use_ability(action_state2.atomtowalkto)

