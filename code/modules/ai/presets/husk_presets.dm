/mob/living/carbon/human/species/husk/ai
	///If this husk should patrol
	var/should_patrol = FALSE

/mob/living/carbon/human/species/husk/ai/Initialize()
	. = ..()
	AddComponent(/datum/component/ai_controller, should_patrol ? /datum/ai_behavior/xeno/husk/patrolling : /datum/ai_behavior/xeno/husk, should_patrol ? null : get_turf(src))

/mob/living/carbon/human/species/husk/ai/patrol
	should_patrol = TRUE

