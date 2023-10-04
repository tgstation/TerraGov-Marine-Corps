/mob/living/carbon/xenomorph/drone
	caste_base_type = /mob/living/carbon/xenomorph/drone
	name = "Drone"
	desc = "An Alien Drone"
	icon = 'icons/Xeno/castes/drone.dmi'
	icon_state = "Drone Walking"
	bubble_icon = "alienleft"
	health = 120
	maxHealth = 120
	plasma_stored = 350
	tier = XENO_TIER_ONE
	upgrade = XENO_UPGRADE_NORMAL
	pixel_x = -12
	old_x = -12
	pull_speed = -2
	inherent_verbs = list(
		/mob/living/carbon/xenomorph/proc/vent_crawl,
	)
