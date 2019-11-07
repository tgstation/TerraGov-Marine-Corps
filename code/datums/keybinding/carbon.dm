/datum/keybinding/carbon
	category = CATEGORY_CARBON
	weight = WEIGHT_MOB


/datum/keybinding/carbon/hold_run_move_intent
	key = "Alt"
	name = "hold_run_move_intent"
	full_name = "Hold to Sprint/Stalk"
	description = "Hold down to sprint if human or stalk if xeno, release to return to previous mode."
	keybind_signal = COMSIG_KB_HOLD_RUN_MOVE_INTENT_DOWN

/datum/keybinding/carbon/hold_run_move_intent/down(client/user)
	. = ..()
	if(.)
		return
	user.mob.toggle_move_intent(!initial(user.mob.m_intent))
	return TRUE

/datum/keybinding/carbon/hold_run_move_intent/up(client/user)
	if(SEND_SIGNAL(user.mob, COMSIG_KB_HOLD_RUN_MOVE_INTENT_UP) & COMSIG_KB_ACTIVATED)
		return TRUE
	user.mob.toggle_move_intent(initial(user.mob.m_intent))
	return TRUE



/datum/keybinding/carbon/toggle_throw_mode
	key = "R"
	classic_key = "END"
	name = "toggle_throw_mode"
	full_name = "Toggle throw mode"
	description = "Toggle throwing the current item or not."
	category = CATEGORY_CARBON

/datum/keybinding/carbon/toggle_throw_mode/down(client/user)
	if (!iscarbon(user.mob))
		return FALSE
	var/mob/living/carbon/C = user.mob
	C.toggle_throw_mode()
	return TRUE


/datum/keybinding/carbon/select_help_intent
	key = "1"
	name = "select_help_intent"
	full_name = "Select help intent"
	description = ""
	category = CATEGORY_CARBON

/datum/keybinding/carbon/select_help_intent/down(client/user)
	user.mob?.a_intent_change(INTENT_HELP)
	return TRUE


/datum/keybinding/carbon/select_disarm_intent
	key = "2"
	name = "select_disarm_intent"
	full_name = "Select disarm intent"
	description = ""
	category = CATEGORY_CARBON

/datum/keybinding/carbon/select_disarm_intent/down(client/user)
	user.mob?.a_intent_change(INTENT_DISARM)
	return TRUE


/datum/keybinding/carbon/select_grab_intent
	key = "3"
	name = "select_grab_intent"
	full_name = "Select grab intent"
	description = ""
	category = CATEGORY_CARBON

/datum/keybinding/carbon/select_grab_intent/down(client/user)
	user.mob?.a_intent_change(INTENT_GRAB)
	return TRUE


/datum/keybinding/carbon/select_harm_intent
	key = "4"
	name = "select_harm_intent"
	full_name = "Select harm intent"
	description = ""
	category = CATEGORY_CARBON

/datum/keybinding/carbon/select_harm_intent/down(client/user)
	user.mob?.a_intent_change(INTENT_HARM)
	return TRUE

/datum/keybinding/mob/specialclick
	key = "Control"
	name = "specialclick"
	full_name = "Special Click"
	description = "Hold this key and click to trigger special object interactions."


/datum/keybinding/mob/specialclick/down(client/user)
	RegisterSignal(user.mob, list(COMSIG_MOB_CLICKON), .proc/specialclicky)
	RegisterSignal(user.mob, list(COMSIG_MOB_MOUSEDOWN, COMSIG_MOB_MOUSEUP), .proc/intercept_mouse_special)
	return TRUE


/datum/keybinding/mob/specialclick/up(client/user)
	UnregisterSignal(user.mob, list(COMSIG_MOB_MOUSEDOWN, COMSIG_MOB_MOUSEUP, COMSIG_MOB_CLICKON))
	return TRUE

/datum/keybinding/mob/specialclick/proc/specialclicky(datum/source, atom/A, params)
	var/mob/living/carbon/user = source
	if(!user.client || !(user.client.eye == user || user.client.eye == user.loc))
		UnregisterSignal(user, (COMSIG_MOB_CLICKON))
		return
	A.specialclick(user)
