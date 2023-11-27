
/datum/action/ability/xeno_action
	///If you are going to add an explanation for an ability. don't use stats, give a very brief explanation of how to use it.
	desc = "This ability can not be found in codex."
	action_icon = 'icons/Xeno/actions.dmi'

/datum/action/ability/xeno_action/New(Target)
	. = ..()
	var/mutable_appearance/empowered_appearence = mutable_appearance('icons/Xeno/actions.dmi', "borders_center", ACTION_LAYER_EMPOWERED, FLOAT_PLANE)
	visual_references[VREF_MUTABLE_EMPOWERED_FRAME] = empowered_appearence

/datum/action/ability/xeno_action/give_action(mob/living/L)
	. = ..()
	RegisterSignal(L, COMSIG_XENOMORPH_ABILITY_ON_UPGRADE, TYPE_PROC_REF(/datum/action/ability, on_xeno_upgrade))

/datum/action/ability/xeno_action/remove_action(mob/living/L)
	UnregisterSignal(L, COMSIG_XENOMORPH_ABILITY_ON_UPGRADE)
	return ..()

/datum/action/ability/xeno_action/can_use_action(silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return

	var/mob/living/carbon/xenomorph/X = owner
	if(!X)
		return FALSE
	var/flags_to_check = use_state_flags|override_flags

	if(!(flags_to_check & ABILITY_USE_FORTIFIED) && X.fortify)
		if(!silent)
			X.balloon_alert(X, "Cannot while fortified")
		return FALSE

	if(!(flags_to_check & ABILITY_USE_CRESTED) && X.crest_defense)
		if(!silent)
			X.balloon_alert(X, "Cannot while in crest defense")
		return FALSE

	if(!(flags_to_check & ABILITY_USE_ROOTED) && HAS_TRAIT_FROM(X, TRAIT_IMMOBILE, BOILER_ROOTED_TRAIT))
		if(!silent)
			X.balloon_alert(X, "Cannot while rooted")
		return FALSE

	if(!(flags_to_check & ABILITY_USE_AGILITY) && X.agility)
		if(!silent)
			X.balloon_alert(X, "Cannot in agility mode")
		return FALSE

	if(!(flags_to_check & ABILITY_IGNORE_PLASMA) && X.plasma_stored < ability_cost)
		if(!silent)
			X.balloon_alert(X, "Need [ability_cost - X.plasma_stored] more plasma")
		return FALSE

	return TRUE

///Plasma cost override allows for actions/abilities to override the normal plasma costs
/datum/action/ability/xeno_action/succeed_activate(ability_cost_override)
	//the sig call means we need to override this proc it seems
	if(QDELETED(owner))
		return
	ability_cost_override = ability_cost_override? ability_cost_override : ability_cost
	if(SEND_SIGNAL(owner, COMSIG_XENO_ACTION_SUCCEED_ACTIVATE, src, ability_cost_override) & SUCCEED_ACTIVATE_CANCEL)
		return
	if(ability_cost_override > 0)
		var/mob/living/carbon/xenomorph/xeno_owner = owner
		xeno_owner.deduct_ability_cost(ability_cost_override)

//activatable
/datum/action/ability/activable/xeno/New(Target)
	. = ..()
	var/mutable_appearance/empowered_appearence = mutable_appearance('icons/Xeno/actions.dmi', "borders_center", ACTION_LAYER_EMPOWERED, FLOAT_PLANE)
	visual_references[VREF_MUTABLE_EMPOWERED_FRAME] = empowered_appearence

/datum/action/ability/activable/xeno/give_action(mob/living/L)
	. = ..()
	RegisterSignal(L, COMSIG_XENOMORPH_ABILITY_ON_UPGRADE, TYPE_PROC_REF(/datum/action/ability, on_xeno_upgrade))

/datum/action/ability/activable/xeno/remove_action(mob/living/L)
	UnregisterSignal(L, COMSIG_XENOMORPH_ABILITY_ON_UPGRADE)
	return ..()

/datum/action/ability/activable/xeno/can_use_action(silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return

	var/mob/living/carbon/xenomorph/X = owner
	if(!X)
		return FALSE
	var/flags_to_check = use_state_flags|override_flags

	if(!(flags_to_check & ABILITY_USE_FORTIFIED) && X.fortify)
		if(!silent)
			X.balloon_alert(X, "Cannot while fortified")
		return FALSE

	if(!(flags_to_check & ABILITY_USE_CRESTED) && X.crest_defense)
		if(!silent)
			X.balloon_alert(X, "Cannot while in crest defense")
		return FALSE

	if(!(flags_to_check & ABILITY_USE_ROOTED) && HAS_TRAIT_FROM(X, TRAIT_IMMOBILE, BOILER_ROOTED_TRAIT))
		if(!silent)
			X.balloon_alert(X, "Cannot while rooted")
		return FALSE

	if(!(flags_to_check & ABILITY_USE_AGILITY) && X.agility)
		if(!silent)
			X.balloon_alert(X, "Cannot in agility mode")
		return FALSE

	if(!(flags_to_check & ABILITY_IGNORE_PLASMA) && X.plasma_stored < ability_cost)
		if(!silent)
			X.balloon_alert(X, "Need [ability_cost - X.plasma_stored] more plasma")
		return FALSE

	return TRUE
