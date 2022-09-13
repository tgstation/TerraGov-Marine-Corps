/mob/living/carbon/xenomorph/widow
	caste_base_type = /mob/living/carbon/xenomorph/widow
	name = "Widow"
	desc = "A large arachnid xeno, godspeed"
	icon = 'icons/Xeno/2x2_Xenos.dmi'
	icon_state = "Widow Walking"
	health = 200
	maxHealth = 200
	plasma_stored = 150
	flags_pass = PASSTABLE
	tier = XENO_TIER_THREE
	upgrade = XENO_UPGRADE_ZERO
	pixel_x = -16
	old_x = -16
	inherent_verbs = list(
		/mob/living/carbon/xenomorph/proc/vent_crawl,
	)
