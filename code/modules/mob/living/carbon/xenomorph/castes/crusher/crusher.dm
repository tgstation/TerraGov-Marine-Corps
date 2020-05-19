/mob/living/carbon/xenomorph/crusher
	caste_base_type = /mob/living/carbon/xenomorph/crusher
	name = "Crusher"
	desc = "A huge alien with an enormous armored head crest."
	icon = 'icons/Xeno/2x2_Xenos.dmi'
	icon_state = "Crusher Walking"
	health = 300
	maxHealth = 300
	plasma_stored = 200
	tier = XENO_TIER_THREE
	upgrade = XENO_UPGRADE_ZERO
	drag_delay = 6 //pulling a big dead xeno is hard
	mob_size = MOB_SIZE_BIG

	pixel_x = -16
	pixel_y = -3
	old_x = -16
	old_y = -3



/mob/living/carbon/xenomorph/crusher/ex_act(severity)

	flash_act()

	if(severity == EXPLODE_DEVASTATE)
		adjustBruteLoss(rand(200, 300))
		UPDATEHEALTH(src)


/mob/living/carbon/xenomorph/crusher/handle_special_state()
	if(is_charging >= CHARGE_ON)
		icon_state = "Crusher Charging"
		return TRUE
	return FALSE


/mob/living/carbon/xenomorph/crusher/handle_special_wound_states()
	. = ..()
	if(is_charging >= CHARGE_ON)
		return image("icon"='icons/Xeno/wound_overlays.dmi', "icon_state"="crusher_wounded_charging", "layer"=-X_WOUND_LAYER)
