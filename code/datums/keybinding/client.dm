/datum/keybinding/client
	category = CATEGORY_CLIENT
	weight = WEIGHT_HIGHEST


/datum/keybinding/client/get_help
	hotkey_keys = list("F1")
	name = "get_help"
	full_name = "Get Help"
	description = "Ask an admin or mentor for help."
	keybind_signal = COMSIG_KB_CLIENT_GETHELP_DOWN

/datum/keybinding/client/get_help/down(client/user)
	. = ..()
	if(.)
		return
	user.choosehelp()
	return TRUE


/datum/keybinding/client/screenshot
	hotkey_keys = list("F2")
	name = "screenshot"
	full_name = "Screenshot"
	description = "Take a screenshot."
	keybind_signal = COMSIG_KB_CLIENT_SCREENSHOT_DOWN

/datum/keybinding/client/screenshot/down(client/user)
	. = ..()
	if(.)
		return
	winset(user, null, "command=.screenshot [!user.keys_held["shift"] ? "auto" : ""]")
	return TRUE


/datum/keybinding/client/minimal_hud
	hotkey_keys = list("F12")
	name = "minimal_hud"
	full_name = "Minimal HUD"
	description = "Hide most HUD features"
	keybind_signal = COMSIG_KB_CLIENT_MINIMALHUD_DOWN

/datum/keybinding/client/minimal_hud/down(client/user)
	. = ..()
	if(.)
		return
	user.mob.button_pressed_F12()
	return TRUE


/datum/keybinding/client/ooc
	name = "ooc"
	full_name = "OOC"
	hotkey_keys = list("O")
	description = "Speak in OOC"
	keybind_signal = COMSIG_KB_CLIENT_OOC_DOWN

/datum/keybinding/client/ooc/down(client/user)
	. = ..()
	if(.)
		return
	user.ooc_wrapper()
	return TRUE


/datum/keybinding/client/xooc
	name = "xooc"
	full_name = "XOOC"
	description = "Speak in XOOC"
	keybind_signal = COMSIG_KB_CLIENT_XOOC_DOWN

/datum/keybinding/client/xooc/down(client/user)
	. = ..()
	if(.)
		return
	user.xooc_wrapper()
	return TRUE


/datum/keybinding/client/mooc
	name = "mooc"
	full_name = "MOOC"
	description = "Speak in MOOC"
	keybind_signal = COMSIG_KB_CLIENT_MOOC_DOWN

/datum/keybinding/client/mooc/down(client/user)
	. = ..()
	if(.)
		return
	user.mooc_wrapper()
	return TRUE


/datum/keybinding/client/looc
	name = "looc"
	full_name = "LOOC"
	hotkey_keys = list("L")
	description = "Speak in local OOC"
	keybind_signal = COMSIG_KB_CLIENT_LOOC_DOWN

/datum/keybinding/client/looc/down(client/user)
	. = ..()
	if(.)
		return
	user.looc_wrapper()
	return TRUE
