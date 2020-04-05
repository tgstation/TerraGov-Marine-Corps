//Spit time but now pheromones
/mob/living/carbon/xenomorph/praetorian/ai

/mob/living/carbon/xenomorph/praetorian/ai/Initialize()
	. = ..()
	AddComponent(/datum/component/ai_controller, /datum/ai_behavior/carbon/xeno)
	a_intent = INTENT_HARM
