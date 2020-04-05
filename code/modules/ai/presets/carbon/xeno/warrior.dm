//Wombo combo: xeno edition
/mob/living/carbon/xenomorph/warrior/ai

/mob/living/carbon/xenomorph/warrior/ai/Initialize()
	. = ..()
	AddComponent(/datum/component/ai_controller, /datum/ai_behavior/carbon/xeno)
	a_intent = INTENT_HARM
