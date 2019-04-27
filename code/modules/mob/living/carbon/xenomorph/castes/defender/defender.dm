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
/mob/living/carbon/Xenomorph/Defender/handle_special_state()
	if(fortify)
		icon_state = "Defender Fortify"
		return TRUE
	if(crest_defense)
		icon_state = "Defender Crest"
		return TRUE
	return FALSE

// ***************************************
// *********** Life overrides
// ***************************************
/mob/living/carbon/Xenomorph/Defender/update_stat()
	. = ..()
	if(stat != CONSCIOUS && fortify == TRUE)
		fortify_off() //Fortify prevents dragging due to the anchor component.

/mob/living/carbon/Xenomorph/Defender/update_wounds()
	remove_overlay(X_WOUND_LAYER)
	if(health < maxHealth * 0.5) //Injuries appear at less than 50% health
		var/image/I
		if(resting)
			I = image("icon"='icons/Xeno/wound_overlays.dmi', "icon_state"="defender_wounded_resting", "layer"=-X_WOUND_LAYER)
		else if(sleeping || stat == DEAD)
			I = image("icon"='icons/Xeno/wound_overlays.dmi', "icon_state"="defender_wounded_sleeping", "layer"=-X_WOUND_LAYER)
		else if(fortify)
			I = image("icon"='icons/Xeno/wound_overlays.dmi', "icon_state"="defender_wounded_fortify", "layer"=-X_WOUND_LAYER)
		else if(crest_defense)
			I = image("icon"='icons/Xeno/wound_overlays.dmi', "icon_state"="defender_wounded_crest", "layer"=-X_WOUND_LAYER)
		else
			I = image("icon"='icons/Xeno/wound_overlays.dmi', "icon_state"="defender_wounded", "layer"=-X_WOUND_LAYER)

		overlays_standing[X_WOUND_LAYER] = I
		apply_overlay(X_WOUND_LAYER)