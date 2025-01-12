/mob/living/carbon/xenomorph/pyrogen
	caste_base_type = /datum/xeno_caste/pyrogen
	name = "Pyrogen"
	desc = "A skittish alien, it burns with fury."
	icon = 'icons/Xeno/castes/pyrogen.dmi'
	icon_state = "pyrogen Walking"
	health = 325
	maxHealth = 325
	plasma_stored = 300
	mob_size = MOB_SIZE_XENO
	drag_delay = 3
	tier = XENO_TIER_TWO
	upgrade = XENO_UPGRADE_NORMAL
	pixel_x = -16
	bubble_icon = "alienroyal"

/mob/living/carbon/xenomorph/pyrogen/on_floored_trait_loss(datum/source)
	. = ..()
	flick("stunned_comeback",src)

/mob/living/carbon/xenomorph/pyrogen/set_resting()
	. = ..()
	if(resting)
		flick("demanifest", src)
	else
		flick("manifest", src)

/mob/living/carbon/xenomorph/pyrogen/primordial
	upgrade = XENO_UPGRADE_PRIMO
