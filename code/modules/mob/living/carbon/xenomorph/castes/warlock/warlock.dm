/mob/living/carbon/xenomorph/warlock
	caste_base_type = /mob/living/carbon/xenomorph/warlock
	name = "Warlock"
	desc = "A large, physically frail creature. It hovers in the air and seems to buzz with psychic power."
	icon = 'icons/Xeno/castes/warlock.dmi'
	icon_state = "Warlock Walking"
	bubble_icon = "alienroyal"
	attacktext = "slashes"
	attack_sound = null
	friendly = "nuzzles"
	wall_smash = FALSE
	health = 320
	maxHealth = 320
	plasma_stored = 1400
	pixel_x = -16
	old_x = -16
	drag_delay = 3
	tier = XENO_TIER_THREE
	upgrade = XENO_UPGRADE_NORMAL
	pass_flags = PASS_LOW_STRUCTURE

/mob/living/carbon/xenomorph/warlock/Initialize(mapload)
	. = ..()
	ammo = GLOB.ammo_list[/datum/ammo/energy/xeno/psy_blast]
	ADD_TRAIT(src, TRAIT_SILENT_FOOTSTEPS, XENO_TRAIT)

/mob/living/carbon/xenomorph/warlock/get_liquid_slowdown()
	return WARLOCK_WATER_SLOWDOWN
