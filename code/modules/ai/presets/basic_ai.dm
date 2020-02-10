/mob/living/carbon/human/node_pathing //A human using the basic random node traveling

/mob/living/carbon/human/node_pathing/Initialize()
	. = ..()
	AddElement(/datum/element/ai_behavior)
