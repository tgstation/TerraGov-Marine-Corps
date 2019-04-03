/mob/living/carbon/Xenomorph/Spitter
	caste_base_type = /mob/living/carbon/Xenomorph/Spitter
	name = "Spitter"
	desc = "A gross, oozing alien of some kind."
	icon = 'icons/Xeno/48x48_Xenos.dmi'
	icon_state = "Spitter Walking"
	health = 180
	maxHealth = 180
	plasma_stored = 150
	speed = -0.5
	pixel_x = -12
	old_x = -12
	tier = XENO_TIER_TWO
	upgrade = XENO_UPGRADE_ZERO
	acid_cooldown = 0
	wound_type = "alien" //used to match appropriate wound overlays

	actions = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/regurgitate,
		/datum/action/xeno_action/activable/corrosive_acid,
		/datum/action/xeno_action/activable/xeno_spit,
		/datum/action/xeno_action/activable/spray_acid,
		)
	inherent_verbs = list(
		/mob/living/carbon/Xenomorph/proc/vent_crawl,
		)
