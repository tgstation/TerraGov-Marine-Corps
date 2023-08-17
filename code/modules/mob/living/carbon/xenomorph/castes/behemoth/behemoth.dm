/mob/living/carbon/xenomorph/behemoth
	caste_base_type = /mob/living/carbon/xenomorph/behemoth
	name = "Behemoth"
	desc = "A resilient and equally ferocious monster that commands the earth itself."
	icon = 'icons/Xeno/3x3_Xenos.dmi'
	icon_state = "Behemoth Walking"
	bubble_icon = "alienleft"
	health = 725
	maxHealth = 725
	plasma_stored = 140
	tier = XENO_TIER_THREE
	upgrade = XENO_UPGRADE_ZERO
	drag_delay = 6
	mob_size = MOB_SIZE_BIG
	buckle_flags = CAN_BUCKLE
	max_buckled_mobs = 2
	pixel_x = -28.5
	old_x = -28.5
	footstep_type = FOOTSTEP_XENO_HEAVY


// ***************************************
// *********** Special States
// ***************************************
/mob/living/carbon/xenomorph/behemoth/handle_special_state()
	var/datum/action/xeno_action/ready_charge/behemoth_roll/behemoth_roll_action = actions_by_path[/datum/action/xeno_action/ready_charge/behemoth_roll]
	if(!behemoth_roll_action || !behemoth_roll_action.charge_ability_on)
		return FALSE
	if(behemoth_roll_action.valid_steps_taken == behemoth_roll_action.max_steps_buildup)
		icon_state = "Behemoth[is_a_rouny ? " rouny" : ""] Charging"
	else
		icon_state = "Behemoth Rolling"
	return TRUE

/mob/living/carbon/xenomorph/behemoth/handle_special_wound_states(severity)
	. = ..()
	var/datum/action/xeno_action/ready_charge/behemoth_roll/behemoth_roll_action = actions_by_path[/datum/action/xeno_action/ready_charge/behemoth_roll]
	if(behemoth_roll_action?.charge_ability_on)
		return "behemoth_wounded_charging_[severity]"

/mob/living/carbon/xenomorph/behemoth/Stat()
	. = ..()
	if(statpanel("Game") && xeno_caste.wrath_max > 0)
		stat("Wrath:", "[wrath_stored] / [xeno_caste.wrath_max]")
