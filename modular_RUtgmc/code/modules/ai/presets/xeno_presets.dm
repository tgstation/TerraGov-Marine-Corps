/mob/living/carbon/xenomorph/facehugger/ai

/mob/living/carbon/xenomorph/facehugger/ai/Initialize(mapload)
	. = ..()
	GLOB.hive_datums[hivenumber].facehuggers -= src
	AddComponent(/datum/component/ai_controller, /datum/ai_behavior/xeno)
