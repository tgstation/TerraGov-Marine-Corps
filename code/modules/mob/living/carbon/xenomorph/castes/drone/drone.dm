/mob/living/carbon/xenomorph/drone
	caste_base_type = /mob/living/carbon/xenomorph/drone
	name = "Drone"
	desc = "An Alien Drone"
	icon = 'icons/Xeno/48x48_Xenos.dmi'
	icon_state = "Drone Walking"
	health = 120
	maxHealth = 120
	plasma_stored = 350
	tier = XENO_TIER_ONE
	upgrade = XENO_UPGRADE_ZERO
	pixel_x = -12
	old_x = -12
	pull_speed = -2
	inherent_verbs = list(
		/mob/living/carbon/xenomorph/proc/vent_crawl,
	)
	orbit_icon = "chess-pawn"
