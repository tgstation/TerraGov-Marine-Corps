/mob/living/carbon/xenomorph/boiler
	caste_base_type = /datum/xeno_caste/boiler
	name = "Boiler"
	desc = "A huge, grotesque xenomorph covered in glowing, oozing acid slime."
	icon = 'icons/Xeno/castes/boiler.dmi'
	icon_state = "Boiler Walking"
	bubble_icon = "alienroyal"
	health = 200
	maxHealth = 200
	plasma_stored = 450
	pixel_x = -16
	mob_size = MOB_SIZE_BIG
	tier = XENO_TIER_THREE
	upgrade = XENO_UPGRADE_NORMAL
	drag_delay = 6 //pulling a big dead xeno is hard

/mob/living/carbon/xenomorph/boiler/get_liquid_slowdown()
	return BOILER_WATER_SLOWDOWN

/mob/living/carbon/xenomorph/boiler/sizzler
	caste_base_type = /datum/xeno_caste/boiler/sizzler

