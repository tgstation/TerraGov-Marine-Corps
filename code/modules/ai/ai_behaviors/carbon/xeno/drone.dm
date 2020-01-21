//A example drone that uses it's weeding ability provided no other weeds are nearby

/datum/ai_behavior/carbon/xeno/drone
	var/datum/action/xeno_action/plant_weeds/plantweeds

/datum/ai_behavior/carbon/xeno/drone/New()
	..()
	plantweeds = new
	plantweeds.owner = mob_parent

/datum/ai_behavior/carbon/xeno/drone/do_process()
	if(!plantweeds.can_use_action(override_flags = XACT_IGNORE_SELECTED_ABILITY))
		return ..()
	for(var/obj/effect/alien/weeds/node/node in range(1, mob_parent))
		//There's already a node nearby (but not directly on location) don't plant anything
		return ..()
	plantweeds.action_activate()
	return ..()
