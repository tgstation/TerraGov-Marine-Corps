/mob/living/carbon/xenomorph/behemoth
	caste_base_type = /mob/living/carbon/xenomorph/behemoth
	name = "Behemoth"
	desc = "Behemoth description here"
	icon = 'icons/Xeno/3x3_Xenos.dmi'
	icon_state = "Behemoth Walking"
	bubble_icon = "alienleft"
	health = 425
	maxHealth = 425
	plasma_stored = 175
	tier = XENO_TIER_THREE
	upgrade = XENO_UPGRADE_ZERO
	drag_delay = 6
	mob_size = MOB_SIZE_BIG
	buckle_flags = CAN_BUCKLE

	pixel_x = -28.5
	old_x = -28.5


// ***************************************
// *********** Icons
// ***************************************
/mob/living/carbon/xenomorph/behemoth/handle_special_state()
	var/datum/action/xeno_action/ready_charge/behemoth_roll/behemoth_roll_action = actions_by_path?[/datum/action/xeno_action/ready_charge/behemoth_roll]
	if(behemoth_roll_action && behemoth_roll_action.charge_ability_on)
		if(is_charging >= CHARGE_MAX)
			icon_state = "Behemoth Charging"
			return TRUE
		icon_state = "Behemoth Rolling"
		return TRUE
	icon_state = "Behemoth Walking"
	return TRUE

/mob/living/carbon/xenomorph/behemoth/handle_special_wound_states(severity)
	. = ..()
	var/datum/action/xeno_action/ready_charge/behemoth_roll/behemoth_roll_action = actions_by_path?[/datum/action/xeno_action/ready_charge/behemoth_roll]
	if(behemoth_roll_action && behemoth_roll_action.charge_ability_on)
		return "behemoth_wounded_rolling_[severity]"


// ***************************************
// *********** Overrides
// ***************************************
/mob/living/carbon/xenomorph/behemoth/Initialize(mapload, footstep_type)
	footstep_type = FOOTSTEP_XENO_HEAVY
	return . = ..()
