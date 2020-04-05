//The slashing raid boss
/mob/living/carbon/xenomorph/crusher/ai

/mob/living/carbon/xenomorph/crusher/ai/Initialize()
	. = ..()
	AddComponent(/datum/component/ai_controller, /datum/ai_behavior/carbon/xeno)
	a_intent = INTENT_HARM
