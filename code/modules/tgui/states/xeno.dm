/**
 * tgui state: xeno_evo_state
 *
 * Checks that the user is a xeno for evolution panel.
 **/
GLOBAL_DATUM_INIT(xeno_evo_state, /datum/ui_state/xeno_evo_state, new)

/datum/ui_state/xeno_evo_state/can_use_topic(src_object, mob/user)
	if(!isxeno(user))
		return UI_CLOSE
	if(user.stat == DEAD)
		return UI_DISABLED
	if(user.stat == UNCONSCIOUS || user.incapacitated())
		return UI_UPDATE
	return UI_INTERACTIVE

/**
 * tgui state: xeno_hive_state
 **/
GLOBAL_DATUM_INIT(xeno_hive_state, /datum/ui_state/xeno_hive_state, new)

/datum/ui_state/xeno_hive_state/can_use_topic(src_object, mob/user)
	return UI_INTERACTIVE
