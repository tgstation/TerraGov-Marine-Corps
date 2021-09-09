/mob/living/carbon/human/species/husk/ai
	faction = FACTION_XENO
	///If this zombie should patrol
	var/should_patrol = FALSE

/mob/living/carbon/human/species/husk/ai/Initialize()
	. = ..()
	var/datum/outfit/outfit = pick(GLOB.survivor_outfits)
	outfit.equip(src)
	AddComponent(/datum/component/ai_controller, /datum/ai_behavior/xeno/zombie, should_patrol ? null : get_turf(src))
	a_intent = INTENT_HARM

/mob/living/carbon/human/species/husk/ai/patrol
	should_patrol = TRUE

