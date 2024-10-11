/mob/living/carbon/xenomorph/defender
	caste_base_type = /datum/xeno_caste/defender
	name = "Defender"
	desc = "An alien with an armored head crest."
	icon = 'icons/Xeno/castes/defender.dmi'
	icon_state = "Defender Walking"
	bubble_icon = "alienroyal"
	health = 200
	maxHealth = 200
	plasma_stored = 50
	pixel_x = -16
	tier = XENO_TIER_ONE
	upgrade = XENO_UPGRADE_NORMAL
	pull_speed = -2

// ***************************************
// *********** Icon
// ***************************************
/mob/living/carbon/xenomorph/defender/handle_special_state()
	if(fortify)
		icon_state = "[xeno_caste.caste_name][(xeno_flags & XENO_ROUNY) ? " rouny" : ""] Fortify"
		return TRUE
	if(crest_defense)
		icon_state = "[xeno_caste.caste_name][(xeno_flags & XENO_ROUNY) ? " rouny" : ""] Crest"
		return TRUE
	return FALSE

/mob/living/carbon/xenomorph/defender/handle_special_wound_states(severity)
	. = ..()
	if(fortify)
		return "wounded_fortify_[severity]" // we don't have the icons, but still
	if(crest_defense)
		return "wounded_crest_[severity]"

// ***************************************
// *********** Life overrides
// ***************************************
/mob/living/carbon/xenomorph/defender/set_stat()
	. = ..()
	if(isnull(.))
		return
	if(. == CONSCIOUS && fortify) //No longer conscious.
		var/datum/action/ability/xeno_action/fortify/FT = actions_by_path[/datum/action/ability/xeno_action/fortify]
		FT.set_fortify(FALSE) //Fortify prevents dragging due to the anchor component.


// ***************************************
// *********** Mob overrides
// ***************************************

/mob/living/carbon/xenomorph/defender/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/throw_parry)
