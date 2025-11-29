/mob/living/carbon/xenomorph/behemoth
	caste_base_type = /datum/xeno_caste/behemoth
	name = "Behemoth"
	desc = "A ferocious monster that commands the earth itself."
	icon = 'icons/Xeno/castes/behemoth.dmi'
	icon_state = "Behemoth Walking"
	bubble_icon = "alienleft"
	health = 450
	maxHealth = 450
	plasma_stored = 300
	tier = XENO_TIER_THREE
	upgrade = XENO_UPGRADE_NORMAL
	drag_delay = 5
	mob_size = MOB_SIZE_BIG
	pixel_x = -28.5

// Exception added in the case of god mode. We don't want to appear fully healthy while using Primal Wrath.
/mob/living/carbon/xenomorph/behemoth/updatehealth()
	SEND_SIGNAL(src, COMSIG_LIVING_UPDATE_HEALTH)
	health = maxHealth - getOxyLoss() - getToxLoss() - getFireLoss() - getBruteLoss() - getCloneLoss()
	if(update_stat()) // Gibbing returns TRUE.
		return
	med_hud_set_health()
	update_wounds()
	return TRUE
