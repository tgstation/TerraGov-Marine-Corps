/mob/living/carbon/xenomorph/bull
	caste_base_type = /mob/living/carbon/xenomorph/bull
	name = "Bull"
	desc = "A huge alien with an enormous armored head crest."
	icon = 'icons/Xeno/2x2_Xenos.dmi'
	icon_state = "Bull Walking"
	health = 160
	maxHealth = 160
	plasma_stored = 200
	speed = -1
	tier = XENO_TIER_TWO
	upgrade = XENO_UPGRADE_BASETYPE
	drag_delay = 6 //pulling a big dead xeno is hard
	mob_size = MOB_SIZE_BIG

	pixel_x = -16
	pixel_y = -3
	old_x = -16
	old_y = -3

	actions = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/regurgitate,
		/datum/action/xeno_action/ready_charge/bull_charge,
		/datum/action/xeno_action/toggle_charge_type
		)


/mob/living/carbon/xenomorph/bull/handle_special_state()
	if(is_charging >= CHARGE_ON)
		icon_state = "Bull Charging"
		return TRUE
	return FALSE
