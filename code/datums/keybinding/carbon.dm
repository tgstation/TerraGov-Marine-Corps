/datum/keybinding/carbon
	category = CATEGORY_CARBON
	weight = WEIGHT_MOB


/datum/keybinding/carbon/hold_run_move_intent
	hotkey_keys = list("Alt")
	name = "hold_run_move_intent"
	full_name = "Hold to Sprint/Stalk"
	description = "Hold down to sprint if human or stalk if xeno, release to return to previous mode."
	keybind_signal = COMSIG_KB_CARBON_HOLDRUNMOVEINTENT_DOWN

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
	hotkey_keys = list("R")
	name = "toggle_throw_mode"
	full_name = "Toggle throw mode"
	description = "Toggle throwing the current item or not."
	keybind_signal = COMSIG_KB_CARBON_TOGGLETHROWMODE_DOWN

/datum/keybinding/carbon/toggle_throw_mode/down(client/user)
	if(!iscarbon(user.mob))
		return FALSE
	. = ..()
	if(.)
		return
	var/mob/living/carbon/C = user.mob
	C.toggle_throw_mode()
	return TRUE

/datum/keybinding/carbon/toggle_rest
	hotkey_keys = list("K")
	name = "toggle_rest"
	full_name = "Toggle resting"
	description = "Toggle whether you are resting or not."
	keybind_signal = COMSIG_KB_CARBON_TOGGLEREST_DOWN

/datum/keybinding/carbon/toggle_rest/down(client/user)
	if(!iscarbon(user.mob))
		return FALSE
	. = ..()
	if(.)
		return
	var/mob/living/carbon/C = user.mob
	C.lay_down()
	return TRUE

/datum/keybinding/carbon/select_help_intent
	hotkey_keys = list("1")
	name = "select_help_intent"
	full_name = "Select help intent"
	description = ""
	keybind_signal = COMSIG_KB_CARBON_SELECTHELPINTENT_DOWN

/datum/keybinding/carbon/select_help_intent/down(client/user)
	. = ..()
	if(.)
		return
	user.mob?.a_intent_change(INTENT_HELP)
	return TRUE


/datum/keybinding/carbon/select_disarm_intent
	hotkey_keys = list("2")
	name = "select_disarm_intent"
	full_name = "Select disarm intent"
	description = ""
	keybind_signal = COMSIG_KB_CARBON_SELECTDISARMINTENT_DOWN

/datum/keybinding/carbon/select_disarm_intent/down(client/user)
	. = ..()
	if(.)
		return
	user.mob?.a_intent_change(INTENT_DISARM)
	return TRUE


/datum/keybinding/carbon/select_grab_intent
	hotkey_keys = list("3")
	name = "select_grab_intent"
	full_name = "Select grab intent"
	description = ""
	keybind_signal = COMSIG_KB_CARBON_SELECTGRABINTENT_DOWN

/datum/keybinding/carbon/select_grab_intent/down(client/user)
	. = ..()
	if(.)
		return
	user.mob?.a_intent_change(INTENT_GRAB)
	return TRUE


/datum/keybinding/carbon/select_harm_intent
	hotkey_keys = list("4")
	name = "select_harm_intent"
	full_name = "Select harm intent"
	description = ""
	keybind_signal = COMSIG_KB_CARBON_SELECTHARMINTENT_DOWN

/datum/keybinding/carbon/select_harm_intent/down(client/user)
	. = ..()
	if(.)
		return
	user.mob?.a_intent_change(INTENT_HARM)
	return TRUE

/datum/keybinding/carbon/specialclick
	hotkey_keys = list("Ctrl")
	name = "specialclick"
	full_name = "Special Click"
	description = "Hold this hotkey_keys and click to trigger special object interactions."
	keybind_signal = COMSIG_KB_CARBON_SPECIALCLICK_DOWN


/datum/keybinding/carbon/specialclick/down(client/user)
	. = ..()
	if(.)
		return
	RegisterSignal(user.mob, list(COMSIG_MOB_CLICKON), .proc/specialclicky)
	RegisterSignal(user.mob, list(COMSIG_MOB_MOUSEDOWN, COMSIG_MOB_MOUSEUP), .keybinding/proc/intercept_mouse_special)
	return TRUE


/datum/keybinding/carbon/specialclick/up(client/user)
	UnregisterSignal(user.mob, list(COMSIG_MOB_MOUSEDOWN, COMSIG_MOB_MOUSEUP, COMSIG_MOB_CLICKON))
	return TRUE

/datum/keybinding/carbon/specialclick/proc/specialclicky(datum/source, atom/A, params)
	SIGNAL_HANDLER
	var/mob/living/carbon/user = source
	if(!user.client || !(user.client.eye == user || user.client.eye == user.loc))
		UnregisterSignal(user, (COMSIG_MOB_CLICKON))
		return
	A.specialclick(user)
