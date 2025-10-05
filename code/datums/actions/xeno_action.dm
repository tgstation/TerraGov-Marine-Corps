
/datum/action/ability/xeno_action
	///If you are going to add an explanation for an ability. don't use stats, give a very brief explanation of how to use it.
	desc = "This ability can not be found in codex."
	action_icon = 'icons/Xeno/actions/general.dmi'
	///Typecast owner since this is used constantly
	var/mob/living/carbon/xenomorph/xeno_owner

/datum/action/ability/xeno_action/New(Target)
	. = ..()
	var/mutable_appearance/empowered_appearence = mutable_appearance('icons/Xeno/actions/general.dmi', "borders_center", ACTION_LAYER_EMPOWERED)
	visual_references[VREF_MUTABLE_EMPOWERED_FRAME] = empowered_appearence

/datum/action/ability/xeno_action/give_action(mob/living/L)
	. = ..()
	RegisterSignal(L, COMSIG_XENOMORPH_ABILITY_ON_UPGRADE, TYPE_PROC_REF(/datum/action/ability, on_xeno_upgrade))
	xeno_owner = L

/datum/action/ability/xeno_action/remove_action(mob/living/L)
	UnregisterSignal(L, COMSIG_XENOMORPH_ABILITY_ON_UPGRADE)
	xeno_owner = null
	return ..()

/datum/action/ability/xeno_action/can_use_action(silent, override_flags, selecting)
	. = ..()
	if(!.)
		return

	if(!xeno_owner)
		return FALSE
	var/to_check_flags = use_state_flags|override_flags

	if(!(to_check_flags & ABILITY_USE_FORTIFIED) && xeno_owner.fortify)
		if(!silent)
			xeno_owner.balloon_alert(xeno_owner, "cannot while fortified!")
		return FALSE

	if(!(to_check_flags & ABILITY_USE_CRESTED) && xeno_owner.crest_defense)
		if(!silent)
			xeno_owner.balloon_alert(xeno_owner, "cannot while in crest defense!")
		return FALSE

	if(!(to_check_flags & ABILITY_IGNORE_PLASMA) && xeno_owner.plasma_stored < ability_cost)
		if(!silent)
			xeno_owner.balloon_alert(xeno_owner, "need [ability_cost - xeno_owner.plasma_stored] more plasma!")
		return FALSE

	return TRUE

//activatable
/datum/action/ability/activable/xeno
	///Typecast owner since this is used constantly
	var/mob/living/carbon/xenomorph/xeno_owner

/datum/action/ability/activable/xeno/New(Target)
	. = ..()
	var/mutable_appearance/empowered_appearence = mutable_appearance('icons/Xeno/actions/general.dmi', "borders_center", ACTION_LAYER_EMPOWERED)
	visual_references[VREF_MUTABLE_EMPOWERED_FRAME] = empowered_appearence

/datum/action/ability/activable/xeno/give_action(mob/living/L)
	. = ..()
	RegisterSignal(L, COMSIG_XENOMORPH_ABILITY_ON_UPGRADE, TYPE_PROC_REF(/datum/action/ability, on_xeno_upgrade))
	xeno_owner = L

/datum/action/ability/activable/xeno/remove_action(mob/living/L)
	UnregisterSignal(L, COMSIG_XENOMORPH_ABILITY_ON_UPGRADE)
	xeno_owner = null
	return ..()

/datum/action/ability/activable/xeno/can_use_action(silent, override_flags, selecting)
	. = ..()
	if(!.)
		return

	if(!xeno_owner)
		return FALSE
	var/to_check_flags = use_state_flags|override_flags

	if(!(to_check_flags & ABILITY_USE_FORTIFIED) && xeno_owner.fortify)
		if(!silent)
			xeno_owner.balloon_alert(xeno_owner, "cannot while fortified!")
		return FALSE

	if(!(to_check_flags & ABILITY_USE_CRESTED) && xeno_owner.crest_defense)
		if(!silent)
			xeno_owner.balloon_alert(xeno_owner, "cannot while in crest defense!")
		return FALSE

	if(!(to_check_flags & ABILITY_IGNORE_PLASMA) && xeno_owner.plasma_stored < ability_cost)
		if(!silent)
			xeno_owner.balloon_alert(xeno_owner, "need [ability_cost - xeno_owner.plasma_stored] more plasma!")
		return FALSE

	return TRUE
