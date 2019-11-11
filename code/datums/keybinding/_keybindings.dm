/datum/keybinding
	var/key
	var/classic_key = "Unbound"
	var/hotkey_key = "Unbound"
	var/name
	var/full_name
	var/description = ""
	var/category = CATEGORY_MISC
	var/weight = WEIGHT_LOWEST
	var/keybind_signal

/datum/keybinding/New()
	if(!keybind_signal)
		CRASH("Keybind [src] called unredefined down() without a keybind_signal.")

	if(!key)
		return

	// Default keys to the master "key"
	classic_key = (initial(classic_key) != "Unbound") ? initial(classic_key) : key
	hotkey_key = (initial(hotkey_key) != "Unbound") ? initial(hotkey_key) : key

/datum/keybinding/proc/down(client/user)
	return CHECK_BITFIELD(SEND_SIGNAL(user.mob, keybind_signal), COMSIG_KB_ACTIVATED)

/datum/keybinding/proc/up(client/user)
	return FALSE

/datum/keybinding/proc/intercept_mouse_special(datum/source)
	return COMSIG_MOB_CLICK_CANCELED
