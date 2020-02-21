//A runner that runs around using it's pounce ability
/mob/living/carbon/xenomorph/runner/ai

/mob/living/carbon/xenomorph/runner/ai/Initialize()
	. = ..()
	AddElement(/datum/element/ai_behavior/carbon/xeno, 1, 75)
	a_intent = INTENT_HARM
