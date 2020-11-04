 /**
  * tgui state: xeno_state
  *
  * Checks that the user is a xeno, ezpz.
 **/

GLOBAL_DATUM_INIT(xeno_state, /datum/ui_state/xeno_state, new)

/datum/ui_state/xeno_state/can_use_topic(src_object, mob/user)
	if(!isxeno(user))
		return UI_CLOSE
	if(user.stat == DEAD)
		return UI_DISABLED
	if(user.stat == UNCONSCIOUS || user.incapacitated())
		return UI_UPDATE
	return UI_INTERACTIVE
