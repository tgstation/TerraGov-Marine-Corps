/mob/living/carbon/xenomorph/warlock
	caste_base_type = /mob/living/carbon/xenomorph/warlock
	name = "Warlock"
	desc = "A large, physically frail creature. It hovers in the air and seems to buzz with psychic power."
	icon = 'icons/Xeno/2x2_Xenos.dmi'
	icon_state = "Overmind Walking"
	attacktext = "slashes"
	attack_sound = null
	friendly = "nuzzles"
	wall_smash = FALSE
	health = 240
	maxHealth = 240
	plasma_stored = 300
	pixel_x = -16
	old_x = -16
	drag_delay = 3 //pulling a medium dead xeno is hard
	tier = XENO_TIER_THREE
	upgrade = XENO_UPGRADE_ZERO
	inherent_verbs = list(
		/mob/living/carbon/xenomorph/proc/vent_crawl,
		/mob/living/carbon/xenomorph/proc/hijack,
	)

// ***************************************
// *********** Life overrides
// ***************************************
/mob/living/carbon/xenomorph/warlock/handle_decay() //the heck is this?
	if(prob(20+abs(3*upgrade_as_number())))
		use_plasma(min(rand(1,2), plasma_stored))

/mob/living/carbon/xenomorph/warlock/Initialize()
	. = ..()
	ammo = GLOB.ammo_list[/datum/ammo/energy/xeno/psy_blast]
