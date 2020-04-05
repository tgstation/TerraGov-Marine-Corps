//Pretty much useless
/mob/living/carbon/xenomorph/defender/ai

/mob/living/carbon/xenomorph/defender/ai/Initialize()
	. = ..()
	AddComponent(/datum/component/ai_controller, /datum/ai_behavior/carbon/xeno)
	a_intent = INTENT_HARM
