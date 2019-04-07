/mob/living/carbon/Xenomorph/Defender
	caste_base_type = /mob/living/carbon/Xenomorph/Defender
	name = "Defender"
	desc = "A alien with an armored head crest."
	icon = 'icons/Xeno/2x2_Xenos.dmi'
	icon_state = "Defender Walking"
	health = 200
	maxHealth = 200
	plasma_stored = 50
	speed = -0.2
	pixel_x = -16
	old_x = -16
	tier = XENO_TIER_ONE
	upgrade = XENO_UPGRADE_ZERO
	pull_speed = -2
	actions = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/regurgitate,
		/datum/action/xeno_action/activable/toggle_crest_defense,
		/datum/action/xeno_action/activable/fortify,
		/datum/action/xeno_action/activable/headbutt,
		/datum/action/xeno_action/activable/tail_sweep
		)

// ***************************************
// *********** Icon
// ***************************************
/mob/living/carbon/Xenomorph/Defender/update_icons()
	if (stat == DEAD)
		icon_state = "Defender Dead"
	else if (lying)
		if ((resting || sleeping) && (!knocked_down && !knocked_out && health > 0))
			icon_state = "Defender Sleeping"
		else
			icon_state = "Defender Knocked Down"
	else if (fortify)
		icon_state = "Defender Fortify"
	else if (crest_defense)
		icon_state = "Defender Crest"
	else
		if (m_intent == MOVE_INTENT_RUN)
			icon_state = "Defender Running"
		else
			icon_state = "Defender Walking"

	update_fire() //the fire overlay depends on the xeno's stance, so we must update it.
	update_wounds()

// ***************************************
// *********** Life overrides
// ***************************************
/mob/living/carbon/Xenomorph/Defender/update_stat()
	. = ..()
	if(stat != CONSCIOUS && fortify == TRUE)
		fortify_off() //Fortify prevents dragging due to the anchor component.
