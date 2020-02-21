//A carbon human that just walks around
/mob/living/carbon/human/node_walker

/mob/living/carbon/human/node_walker/Initialize()
	. = ..()
	AddElement(/datum/element/ai_behavior/carbon, 1, 0)
