/mob/living/carbon/human/species/possessed
		race = "Possessed Human"

/datum/species/possessed/handle_post_spawn(mob/living/carbon/human/H)
	. = ..()
	H.g_hair = 255
	H.h_style = "Crewcut"
	H.r_eyes = 255

/datum/species/human/possessed
	name = "Possessed Human"
	name_plural = "Possessed Humans"
	brute_mod = 0.55
	burn_mod = 0.55
	unarmed_type = /datum/unarmed_attack/punch/strong
	slowdown = 1