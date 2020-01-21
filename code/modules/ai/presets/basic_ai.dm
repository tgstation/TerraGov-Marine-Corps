/mob/living/carbon/human/node_pathing //A human using the basic random node traveling

/mob/living/carbon/human/node_pathing/Initialize()
	. = ..()
	AddComponent(/datum/component/ai_controller, /datum/ai_behavior)
