//Like runner but doesn't run fast
/mob/living/carbon/xenomorph/hunter/ai

/mob/living/carbon/xenomorph/hunter/ai/Initialize()
	. = ..()
	AddComponent(/datum/component/ai_controller, /datum/ai_behavior/carbon/xeno)
	a_intent = INTENT_HARM
