/datum/species/skeleton
	name = "Skeleton"
	icobase = 'icons/mob/human_races/r_skeleton.dmi'
	unarmed_type = /datum/unarmed_attack/punch
	count_human = TRUE

	species_flags = NO_BREATHE|NO_SCAN|NO_BLOOD|NO_POISON|NO_CHEM_METABOLIZATION|DETACHABLE_HEAD // Where we're going, we don't NEED underwear

	screams = list("neuter" = 'sound/voice/skeleton_scream.ogg') // RATTLE ME BONES
	paincries = list("neuter" = 'sound/voice/skeleton_scream.ogg')
	goredcries = list("neuter" = 'sound/voice/skeleton_scream.ogg')
	burstscreams = list("neuter" = 'sound/voice/moth_scream.ogg')
	death_message = "collapses in a pile of bones, with a final rattle..."
	death_sound = list("neuter" = 'sound/voice/skeleton_scream.ogg')
	warcries = list("neuter" = 'sound/voice/skeleton_warcry.ogg') // AAAAAAAAAAAAAAAAAAAAAAAAAAAAA
	namepool = /datum/namepool/skeleton
