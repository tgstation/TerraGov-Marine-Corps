
/mob/living/carbon/xenomorph/jester
	caste_base_type = /datum/xeno_caste/jester
	name = "Jester"
	desc = "A beefy, fast alien with sharp claws."
	icon = 'icons/Xeno/castes/jester.dmi'
	icon_state = "Puppeteer Running"
	bubble_icon = "alien"
	health = 150
	maxHealth = 150
	plasma_stored = 50
	tier = XENO_TIER_TWO
	upgrade = XENO_UPGRADE_NORMAL
	inherent_verbs = list(
		/mob/living/carbon/xenomorph/proc/vent_crawl,
	)
