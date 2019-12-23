/mob/living/carbon/xenomorph/queen/ai

/mob/living/carbon/xenomorph/queen/ai/Initialize()
	. = ..()
	AddComponent(/datum/component/ai_behavior, /datum/ai_mind/carbon/xeno/queen)
	a_intent = INTENT_HARM
	current_aura = pick("recovery", "frenzy", "warding")
	//Cheat codes
	xeno_caste.caste_flags += CASTE_INNATE_HEALING
	xeno_caste.caste_flags += CASTE_QUICK_HEAL_STANDING
	xeno_caste.caste_flags += CASTE_CAN_HEAL_WIHOUT_QUEEN
