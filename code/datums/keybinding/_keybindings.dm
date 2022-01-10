/datum/keybinding
	var/list/hotkey_keys
	var/name
	var/full_name
	var/description = ""
	var/category = CATEGORY_MISC
	var/weight = WEIGHT_LOWEST
	var/keybind_signal

/datum/keybinding/New()
	if(!keybind_signal)
		CRASH("Keybind [src] called unredefined down() without a keybind_signal.")

/datum/keybinding/proc/down(client/user)
	SHOULD_CALL_PARENT(TRUE)
	return CHECK_BITFIELD(SEND_SIGNAL(user.mob, keybind_signal), COMSIG_KB_ACTIVATED)

/datum/keybinding/proc/up(client/user)
	return FALSE

/datum/keybinding/proc/intercept_mouse_special(datum/source)
	SIGNAL_HANDLER
	return COMSIG_MOB_CLICK_CANCELED
