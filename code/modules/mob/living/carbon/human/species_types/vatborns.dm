/datum/species/human/vatborn
	name = "Vatborn"
	icobase = 'icons/mob/human_races/r_vatborn.dmi'
	namepool = /datum/namepool/vatborn
	limb_type = SPECIES_LIMB_CLONE

/datum/species/human/vatborn/prefs_name(datum/preferences/prefs)
	return prefs.real_name

/datum/species/human/vatgrown
	name = "Vat-Grown Human"
	icobase = 'icons/mob/human_races/r_vatgrown.dmi'
	brute_mod = 1.05
	burn_mod = 1.05
	slowdown = 0.05
	joinable_roundstart = FALSE
	limb_type = SPECIES_LIMB_CLONE

/datum/species/human/vatgrown/random_name(gender)
	return "CS-[gender == FEMALE ? "F": "M"]-[rand(111,999)]"

/datum/species/human/vatgrown/prefs_name(datum/preferences/prefs)
	return prefs.real_name

/datum/species/human/vatgrown/handle_post_spawn(mob/living/carbon/human/H)
	. = ..()
	H.h_style = "Bald"
	H.set_skills(getSkillsType(/datum/skills/vatgrown))

/datum/species/human/vatgrown/early
	name = "Early Vat-Grown Human"
	brute_mod = 1.3
	burn_mod = 1.3
	slowdown = 0.3

	var/timerid

/datum/species/human/vatgrown/early/handle_post_spawn(mob/living/carbon/human/H)
	. = ..()
	H.set_skills(getSkillsType(/datum/skills/vatgrown/early))
	timerid = addtimer(CALLBACK(src, PROC_REF(handle_age), H), 15 MINUTES, TIMER_STOPPABLE)

/datum/species/human/vatgrown/early/post_species_loss(mob/living/carbon/human/H)
	. = ..()
	// Ensure we don't update the species again
	if(timerid)
		deltimer(timerid)
		timerid = null

/datum/species/human/vatgrown/early/proc/handle_age(mob/living/carbon/human/H)
	H.set_species("Vat-Grown Human")
