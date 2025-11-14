/datum/keybinding/client/communication
	category = CATEGORY_COMMUNICATION

/datum/keybinding/client/communication/down(client/user)
	. = ..()
	if(.)
		return
	winset(user, null, "command=[user.tgui_say_create_open_command(name)]")
	winset(user, "tgui_say.browser", "focus=true")

/datum/keybinding/client/communication/say
	hotkey_keys = list("T")
	name = SAY_CHANNEL
	full_name = "IC Say"
	keybind_signal = COMSIG_KB_CLIENT_SAY_DOWN

/datum/keybinding/client/communication/radio
	hotkey_keys = list("Y")
	name = RADIO_CHANNEL
	full_name = "IC Radio (;)"
	keybind_signal = COMSIG_KB_CLIENT_RADIO_DOWN

/datum/keybinding/client/communication/ooc
	hotkey_keys = list("O")
	name = OOC_CHANNEL
	full_name = "Out Of Character Say (OOC)"
	keybind_signal = COMSIG_KB_CLIENT_OOC_DOWN

/datum/keybinding/client/communication/me
	hotkey_keys = list("M")
	name = ME_CHANNEL
	full_name = "Custom Emote (/Me)"
	keybind_signal = COMSIG_KB_CLIENT_ME_DOWN

/datum/keybinding/client/communication/xooc
	name = XOOC_CHANNEL
	full_name = "Xeno OOC(XOOC)"
	keybind_signal = COMSIG_KB_CLIENT_XOOC_DOWN

/datum/keybinding/client/communication/mooc
	name = MOOC_CHANNEL
	full_name = "Marine OOC(MOOC)"
	keybind_signal = COMSIG_KB_CLIENT_MOOC_DOWN

/datum/keybinding/client/communication/looc
	name = LOOC_CHANNEL
	full_name = "Local OOC(LOOC)"
	keybind_signal = COMSIG_KB_CLIENT_LOOC_DOWN
