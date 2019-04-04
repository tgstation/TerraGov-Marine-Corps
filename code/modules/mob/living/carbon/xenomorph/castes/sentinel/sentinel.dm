/mob/living/carbon/Xenomorph/Sentinel
	caste_base_type = /mob/living/carbon/Xenomorph/Sentinel
	name = "Sentinel"
	desc = "A slithery, spitting kind of alien."
	icon = 'icons/Xeno/48x48_Xenos.dmi'
	icon_state = "Sentinel Walking"
	health = 150
	maxHealth = 150
	plasma_stored = 75
	pixel_x = -12
	old_x = -12
	tier = XENO_TIER_ONE
	upgrade = XENO_UPGRADE_ZERO
	speed = -0.8
	pull_speed = -2
	wound_type = "alien" //used to match appropriate wound overlays
	actions = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/regurgitate,
		/datum/action/xeno_action/activable/corrosive_acid/drone,
		/datum/action/xeno_action/activable/xeno_spit,
		/datum/action/xeno_action/activable/neurotox_sting
		)
	inherent_verbs = list(
		/mob/living/carbon/Xenomorph/proc/vent_crawl
		)
