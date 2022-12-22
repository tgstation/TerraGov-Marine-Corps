/datum/keybinding/client/communication
	category = CATEGORY_COMMUNICATION

/datum/keybinding/client/communication/say
	hotkey_keys = list("T,Е")
	name = SAY_CHANNEL
	full_name = "IC Say"
	keybind_signal = COMSIG_KB_CLIENT_SAY_DOWN

/datum/keybinding/client/communication/radio
	hotkey_keys = list("Y,Н")
	name = RADIO_CHANNEL
	full_name = "IC Radio (;)"
	keybind_signal = COMSIG_KB_CLIENT_RADIO_DOWN

/datum/keybinding/client/communication/ooc
	hotkey_keys = list("O,Щ")
	name = OOC_CHANNEL
	full_name = "Out Of Character Say (OOC)"
	keybind_signal = COMSIG_KB_CLIENT_OOC_DOWN

/datum/keybinding/client/communication/me
	hotkey_keys = list("M,Ь")
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

