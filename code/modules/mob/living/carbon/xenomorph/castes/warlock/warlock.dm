/mob/living/carbon/xenomorph/warlock
	caste_base_type = /mob/living/carbon/xenomorph/warlock
	name = "Warlock"
	desc = "A large, physically frail creature. It hovers in the air and seems to buzz with psychic power."
	icon = 'icons/Xeno/2x2_Xenos.dmi'
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
	upgrade = XENO_UPGRADE_ZERO
	flags_pass = PASSTABLE

/mob/living/carbon/xenomorph/warlock/Initialize()
	. = ..()
	ammo = GLOB.ammo_list[/datum/ammo/energy/xeno/psy_blast]
