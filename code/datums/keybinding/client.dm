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

/datum/keybinding/client/fullscreen
	hotkey_keys = list("F11")
	name = "fullscreen"
	full_name = "Fullscreen"
	description = "Swap to fullscreen."
	keybind_signal = COMSIG_KB_CLIENT_FULLSCREEN_DOWN

/datum/keybinding/client/fullscreen/down(client/user)
	. = ..()
	if(.)
		return
	user.prefs.fullscreen_mode = !user.prefs.fullscreen_mode
	user.set_fullscreen(user.prefs.fullscreen_mode)
	return TRUE
