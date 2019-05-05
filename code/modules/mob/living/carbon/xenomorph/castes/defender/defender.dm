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

/mob/living/carbon/Xenomorph/Defender/handle_special_wound_states()
	. = ..()
	if(fortify)
		return image("icon"='icons/Xeno/wound_overlays.dmi', "icon_state"="defender_wounded_fortify", "layer"=-X_WOUND_LAYER)
	if(crest_defense)
		return image("icon"='icons/Xeno/wound_overlays.dmi', "icon_state"="defender_wounded_crest", "layer"=-X_WOUND_LAYER)

// ***************************************
// *********** Life overrides
// ***************************************
/mob/living/carbon/Xenomorph/Defender/update_stat()
	. = ..()
	if(stat && fortify)
		set_fortify(FALSE) //Fortify prevents dragging due to the anchor component.
