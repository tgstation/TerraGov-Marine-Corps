/mob/living/carbon/xenomorph/shrike
	caste_base_type = /mob/living/carbon/xenomorph/shrike
	name = "Shrike"
	desc = "A large, lanky alien creature. It seems psychically unstable."
	icon = 'icons/Xeno/2x2_Xenos.dmi'
	icon_state = "Shrike Walking"
	attacktext = "bites"
	attack_sound = null
	friendly = "nuzzles"
	wall_smash = FALSE
	health = 240
	maxHealth = 240
	plasma_stored = 300
	pixel_x = -16
	old_x = -16
	drag_delay = 3 //pulling a medium dead xeno is hard
	tier = XENO_TIER_FOUR
	upgrade = XENO_UPGRADE_ZERO
	var/shrike_flags = SHRIKE_FLAG_PAIN_HUD_ON
	orbit_icon = "dragon"
	inherent_verbs = list(
		/mob/living/carbon/xenomorph/proc/vent_crawl,
		/mob/living/carbon/xenomorph/proc/hijack,
	)

// ***************************************
// *********** Life overrides
// ***************************************
/mob/living/carbon/xenomorph/shrike/handle_decay()
	if(prob(20+abs(3*upgrade_as_number())))
		use_plasma(min(rand(1,2), plasma_stored))

