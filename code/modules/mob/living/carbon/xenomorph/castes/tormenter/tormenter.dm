/mob/living/carbon/xenomorph/tormenter
	caste_base_type = /mob/living/carbon/xenomorph/tormenter
	name = "Tormenter"
	desc = "You don't feel so well..."
	icon = 'icons/Xeno/48x48_Xenos.dmi'
	icon_state = "Tormenter Walking"
	speak_emote = list("hisses")
	health = 225
	maxHealth = 225
	plasma_stored = 400
	tier = XENO_TIER_THREE
	upgrade = XENO_UPGRADE_ZERO
	var/emitting_gas = FALSE
	inherent_verbs = list(
		/mob/living/carbon/xenomorph/proc/vent_crawl,
	)
