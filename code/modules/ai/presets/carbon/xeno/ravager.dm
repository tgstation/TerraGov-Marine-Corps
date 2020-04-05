/mob/living/carbon/xenomorph/ravager/ai

/mob/living/carbon/xenomorph/ravager/ai/Initialize()
	. = ..()
	AddComponent(/datum/component/ai_controller, /datum/ai_behavior/carbon/xeno)
	a_intent = INTENT_HARM
