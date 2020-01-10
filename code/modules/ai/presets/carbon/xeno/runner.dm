//A runner that runs around using it's pounce ability
/mob/living/carbon/xenomorph/runner/ai

/mob/living/carbon/xenomorph/runner/ai/Initialize()
	. = ..()
	AddComponent(/datum/component/ai_behavior, /datum/ai_mind/carbon/xeno/runner)
	a_intent = INTENT_HARM
