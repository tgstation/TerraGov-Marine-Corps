/datum/ai_mind/carbon/xeno/hivelord
	var/datum/action/xeno_action/plant_weeds/plantweeds = new

/datum/ai_mind/carbon/xeno/hivelord/New()
	..()
	plantweeds.owner = mob_parent

/datum/ai_mind/carbon/xeno/hivelord/do_process()
	for(var/obj/effect/alien/weeds/node/node in range(1, mob_parent))
		if(node)
			return ..()
	plantweeds.action_activate()
	return ..()
