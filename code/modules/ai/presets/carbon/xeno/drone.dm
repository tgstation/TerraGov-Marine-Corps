//A drone that walks around, slashes and uses its weeding abilities
/mob/living/carbon/xenomorph/drone/ai

/mob/living/carbon/xenomorph/drone/ai/Initialize()
	. = ..()
	AddComponent(/datum/component/ai_controller, /datum/ai_behavior/carbon/xeno)
	a_intent = INTENT_HARM
	current_aura = pick("recovery", "frenzy", "warding")
