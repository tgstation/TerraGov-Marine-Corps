/mob/living/carbon/xenomorph/pyrogen
	caste_base_type = /datum/xeno_caste/pyrogen
	name = "Pyrogen"
	desc = "An alien formation of sorts, containing a wrathful flame."
	icon = 'icons/Xeno/castes/pyrogen.dmi'
	icon_state = "pyrogen Walking"
	health = 400
	maxHealth = 400
	plasma_stored = 325
	mob_size = MOB_SIZE_XENO
	drag_delay = 3
	tier = XENO_TIER_TWO
	upgrade = XENO_UPGRADE_NORMAL
	pixel_x = -16
	bubble_icon = "alienroyal"

/mob/living/carbon/xenomorph/pyrogen/on_floored_trait_loss(datum/source)
	. = ..()
	flick(xeno_caste ? "[xeno_caste.caste_name] Comeback" : "Comeback", src)

/mob/living/carbon/xenomorph/pyrogen/set_resting()
	. = ..()
	if(resting)
		flick(xeno_caste ? "[xeno_caste.caste_name] Demanifest" : "Demanifest", src)
	else
		flick(xeno_caste ? "[xeno_caste.caste_name] Manifest" : "Manifest", src)

/mob/living/carbon/xenomorph/pyrogen/primordial
	upgrade = XENO_UPGRADE_PRIMO

/mob/living/carbon/xenomorph/pyrogen/cryogen
	caste_base_type = /datum/xeno_caste/pyrogen/cryogen
	name = "Cryogen"
	desc = "An alien formation of sorts, containing a most frigid flame."
	health = 375
	maxHealth = 375
	plasma_stored = 650

/mob/living/carbon/xenomorph/pyrogen/cryogen/primordial
	upgrade = XENO_UPGRADE_PRIMO
	upgrade_stored = TIER_THREE_THRESHOLD
