//Spit time but acidic
/mob/living/carbon/xenomorph/spitter/ai

/mob/living/carbon/xenomorph/spitter/ai/Initialize()
	. = ..()
	AddComponent(/datum/component/ai_controller, /datum/ai_behavior/carbon/xeno)
	a_intent = INTENT_HARM
