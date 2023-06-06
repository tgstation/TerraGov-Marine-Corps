/mob/living/carbon/xenomorph/baneling
	caste_base_type = /mob/living/carbon/xenomorph/baneling
	name = "Baneling"
	desc = ""
	icon = 'icons/Xeno/2x2_Xenos.dmi'
	icon_state = "Runner Walking"
	bubble_icon = "alienleft"
	health = 100
	maxHealth = 100
	plasma_stored = 50
	tier = XENO_TIER_ONE
	upgrade = XENO_UPGRADE_ZERO
	pixel_x = -16
	old_x = -16

// ***************************************
// *********** Icons
// ***************************************
/mob/living/carbon/xenomorph/baneling/handle_special_state()
	if(rolling)
		icon_state = "Baneling Rolling"
		return TRUE
	return FALSE

/mob/living/carbon/xenomorph/baneling/set_stat()
	. = ..()
	if(isnull(.))
		return
	if(. == CONSCIOUS && layer != initial(layer))
		layer = MOB_LAYER
