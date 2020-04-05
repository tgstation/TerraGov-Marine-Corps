//Spit time
/mob/living/carbon/xenomorph/sentinel/ai

/mob/living/carbon/xenomorph/sentinel/ai/Initialize()
	. = ..()
	AddComponent(/datum/component/ai_controller, /datum/ai_behavior/carbon/xeno)
	a_intent = INTENT_HARM
