/mob/living/carbon/xenomorph/shrike
	caste_base_type = /datum/xeno_caste/shrike
	name = "Shrike"
	desc = "A large, lanky alien creature. It seems psychically unstable."
	icon = 'icons/Xeno/castes/shrike.dmi'
	icon_state = "Shrike Walking"
	bubble_icon = "alienroyal"
	health = 240
	maxHealth = 240
	plasma_stored = 300
	pixel_x = -16
	drag_delay = 3 //pulling a medium dead xeno is hard
	tier = XENO_TIER_FOUR
	upgrade = XENO_UPGRADE_NORMAL
	inherent_verbs = list(
		/mob/living/carbon/xenomorph/proc/vent_crawl,
		/mob/living/carbon/xenomorph/proc/hijack,
	)

