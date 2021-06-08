/datum/species/amd_robot //No Intel fanboys allowed.
	name = "Autonomous Military Droid"
	name_plural = "Autonomous Military Droids"
	icobase = 'icons/mob/human_races/r_amd.dmi'
	taste_sensitivity = TASTE_NUMB
	remains_type = /obj/effect/decal/remains/robot
	species_flags = NO_BLOOD|NO_BREATHE|NO_SLIP|NO_CHEM_METABOLIZATION|HAS_NO_HAIR|IS_SYNTHETIC|NO_STAMINA|DETACHABLE_HEAD
	has_organ = list(
		"brain" =    /datum/internal_organ/brain/prosthetic,
		"eyes" = /datum/internal_organ/eyes/prosthetic,
	)
