/mob/living/carbon/xenomorph/crusher/ai

/mob/living/carbon/xenomorph/crusher/ai/Initialize()
	. = ..()
	AddComponent(/datum/component/ai_behavior, /datum/ai_mind/carbon/xeno/crusher)
	a_intent = INTENT_HARM
	//Cheat codes
	xeno_caste.caste_flags += CASTE_INNATE_HEALING
	xeno_caste.caste_flags += CASTE_QUICK_HEAL_STANDING
	xeno_caste.caste_flags += CASTE_CAN_HEAL_WIHOUT_QUEEN
