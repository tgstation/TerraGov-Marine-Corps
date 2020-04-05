//Good amount of screeching
/mob/living/carbon/xenomorph/queen/ai

/mob/living/carbon/xenomorph/queen/ai/Initialize()
	. = ..()
	AddComponent(/datum/component/ai_controller, /datum/ai_behavior/carbon/xeno)
	a_intent = INTENT_HARM
