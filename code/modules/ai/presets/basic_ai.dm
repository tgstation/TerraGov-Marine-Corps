/mob/living/carbon/human/node_pathing //A human using the basic random node traveling

/mob/living/carbon/human/node_pathing/Initialize()
	. = ..()
	AddComponent(/datum/component/ai_behavior, /datum/ai_mind)

/mob/living/carbon/xenomorph/drone/ai //A drone that walks around, slashes and uses its weeding abilities

/mob/living/carbon/xenomorph/drone/ai/Initialize()
	. = ..()
	AddComponent(/datum/component/ai_behavior, /datum/ai_mind/carbon/xeno)
