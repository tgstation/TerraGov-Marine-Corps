//A drone that walks around, slashes and uses its weeding abilities
/mob/living/carbon/xenomorph/drone/ai

/mob/living/carbon/xenomorph/drone/ai/Initialize()
	. = ..()
	AddElement(/datum/element/ai_behavior/carbon/xeno, 1, 50)
	a_intent = INTENT_HARM
	current_aura = pick("recovery", "warding", "frenzy")
