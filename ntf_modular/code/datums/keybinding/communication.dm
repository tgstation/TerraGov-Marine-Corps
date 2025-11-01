/datum/keybinding/client/communication/xmooc
	name = XMOOC_CHANNEL
	full_name = "Xeno-Marine OOC(XMOOC)"
	keybind_signal = COSMIG_KB_CLIENT_XMOOC_DOWN

/datum/keybinding/client/xmooc_multiline
	name = XMOOC_CHANNEL +" (Multiline)"
	full_name = "Xeno-Marine OOC(XMOOC) (Multiline editor)"
	keybind_signal = COSMIG_KB_CLIENT_XMOOC_MULTILINE_DOWN

/datum/keybinding/client/xmooc_multiline/down(client/user)
	. = ..()
	if(.)
		return
	user.xmooc()

/datum/keybinding/client/communication/whisper
	name = WHISPER_CHANNEL
	full_name = "Whisper"
	keybind_signal = COSMIG_KB_CLIENT_WHISPER_DOWN

/datum/keybinding/client/whisper_multiline
	name = WHISPER_CHANNEL + " (Multiline)"
	full_name = "Whisper (Multiline editor)"
	keybind_signal = COSMIG_KB_CLIENT_WHISPER_MULTILINE_DOWN

/datum/keybinding/client/whisper_multiline/down(client/user)
	. = ..()
	if(.)
		return
	user.mob.whisper_verb()

/datum/keybinding/client/communication/subtle
	name = SUBTLE_CHANNEL
	full_name = "Subtle"
	keybind_signal = COSMIG_KB_CLIENT_SUBTLE_DOWN

/datum/keybinding/client/subtle_multiline
	name = SUBTLE_CHANNEL + " (Multiline)"
	full_name = "Subtle (Multiline editor)"
	keybind_signal = COSMIG_KB_CLIENT_SUBTLE_MULTILINE_DOWN

/datum/keybinding/client/subtle_multiline/down(client/user)
	. = ..()
	if(.)
		return
	user.mob.subtle()

/datum/keybinding/client/communication/subtler
	name = SUBTLER_CHANNEL
	full_name = "Subtler"
	keybind_signal = COSMIG_KB_CLIENT_SUBTLER_DOWN

/datum/keybinding/client/subtler_multiline
	name = SUBTLER_CHANNEL + " (Multiline)"
	full_name = "Subtler (Multiline editor)"
	keybind_signal = COSMIG_KB_CLIENT_SUBTLER_MULTILINE_DOWN

/datum/keybinding/client/subtler_multiline/down(client/user)
	. = ..()
	if(.)
		return
	user.mob.subtler()

/datum/keybinding/client/say_multiline
	name = SAY_CHANNEL + " (Multiline)"
	full_name = "IC Say (Multiline editor)"
	keybind_signal = COMSIG_KB_CLIENT_SAY_MULTILINE_DOWN

/datum/keybinding/client/say_multiline/down(client/user)
	. = ..()
	if(.)
		return
	user.mob.say_verb()

/datum/keybinding/client/ooc_multiline
	name = OOC_CHANNEL + " (Multiline)"
	full_name = "Out Of Character Say (OOC) (Multiline editor)"
	keybind_signal = COMSIG_KB_CLIENT_OOC_MULTILINE_DOWN

/datum/keybinding/client/ooc_multiline/down(client/user)
	. = ..()
	if(.)
		return
	user.ooc()

/datum/keybinding/client/me_multiline
	name = ME_CHANNEL + " (Multiline)"
	full_name = "Custom Emote (/Me) (Multiline editor)"
	keybind_signal = COMSIG_KB_CLIENT_ME_MULTILINE_DOWN

/datum/keybinding/client/me_multiline/down(client/user)
	. = ..()
	if(.)
		return
	user.mob.me_verb()

/datum/keybinding/client/xooc_multiline
	name = XOOC_CHANNEL + " (Multiline)"
	full_name = "Xeno OOC(XOOC) (Multiline editor)"
	keybind_signal = COMSIG_KB_CLIENT_XOOC_MULTILINE_DOWN

/datum/keybinding/client/xooc_multiline/down(client/user)
	. = ..()
	if(.)
		return
	user.xooc()

/datum/keybinding/client/mooc_multiline
	name = MOOC_CHANNEL + " (Multiline)"
	full_name = "Marine OOC(MOOC) (Multiline editor)"
	keybind_signal = COMSIG_KB_CLIENT_MOOC_MULTILINE_DOWN

/datum/keybinding/client/mooc_multiline/down(client/user)
	. = ..()
	if(.)
		return
	user.mooc()

/datum/keybinding/client/looc_multiline
	name = LOOC_CHANNEL + " (Multiline)"
	full_name = "Local OOC(LOOC) (Multiline editor)"
	keybind_signal = COMSIG_KB_CLIENT_LOOC_MULTILINE_DOWN

/datum/keybinding/client/looc_multiline/down(client/user)
	. = ..()
	if(.)
		return
	user.looc()
