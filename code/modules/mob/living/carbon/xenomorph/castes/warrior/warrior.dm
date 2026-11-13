/mob/living/carbon/xenomorph/warrior
	caste_base_type = /datum/xeno_caste/warrior
	name = "Warrior"
	desc = "A beefy, alien with an armored carapace."
	icon = 'icons/Xeno/castes/warrior.dmi'
	icon_state = "Warrior Walking"
	bubble_icon = "alienroyal"
	health = 200
	maxHealth = 200
	plasma_stored = 50
	pixel_x = -16
	tier = XENO_TIER_TWO
	upgrade = XENO_UPGRADE_NORMAL

// ***************************************
// *********** Icons
// ***************************************
/mob/living/carbon/xenomorph/warrior/handle_special_state()
	var/datum/action/ability/xeno_action/toggle_agility/agility_action = actions_by_path[/datum/action/ability/xeno_action/toggle_agility]
	if(agility_action?.toggled)
		icon_state = "[xeno_caste.caste_name][(xeno_flags & XENO_ROUNY) ? " rouny" : ""] Agility"
		return TRUE
	return FALSE

/mob/living/carbon/xenomorph/warrior/handle_special_wound_states(severity)
	. = ..()
	var/datum/action/ability/xeno_action/toggle_agility/agility_action = actions_by_path[/datum/action/ability/xeno_action/toggle_agility]
	if(agility_action?.toggled)
		return "wounded_agility_[severity]"
