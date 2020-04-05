//A drone that walks around, slashes and uses its weeding abilities
/mob/living/carbon/xenomorph/hivelord/ai

/mob/living/carbon/xenomorph/hivelord/ai/Initialize()
	. = ..()
	AddComponent(/datum/component/ai_controller, /datum/ai_behavior/carbon/xeno)
	a_intent = INTENT_HARM
