/mob/living/carbon/xenomorph/afflictor
	caste_base_type = /mob/living/carbon/xenomorph/afflictor
	name = "Afflictor"
	desc = "A small snake-like creature with a dangerously looking tail."
	icon = 'icons/Xeno/48x48_Xenos.dmi'
	icon_state = "Afflictor Walking"
	speak_emote = list("hisses")
	health = 100
	maxHealth = 100
	plasma_stored = 50
	flags_pass = PASSTABLE
	tier = XENO_TIER_TWO
	upgrade = XENO_UPGRADE_ZERO
	inherent_verbs = list(
		/mob/living/carbon/xenomorph/proc/vent_crawl,
		)



// ***************************************
// *********** Mob overrides
// ***************************************

/mob/living/carbon/xenomorph/afflictor/apply_alpha_channel(image/I)
	I.alpha = src.alpha
	return I
