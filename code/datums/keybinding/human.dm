/datum/keybinding/human
	category = CATEGORY_HUMAN
	weight = WEIGHT_MOB

/datum/keybinding/human/New()
	. = ..()
	if(!keybind_signal)
		CRASH("Keybind [src] called unredefined down() without a keybind_signal.")

/datum/keybinding/human/down(client/user)
	return CHECK_BITFIELD(SEND_SIGNAL(user.mob, keybind_signal), COMSIG_KB_ACTIVATED)


/datum/keybinding/human/quick_equip
	key = "E"
	name = "quick_equip"
	full_name = "Quick equip"
	description = ""
	keybind_signal = COMSIG_KB_QUICKEQUIP


/datum/keybinding/human/holster
	key = "H"
	name = "holster"
	full_name = "Holster"
	description = ""
	keybind_signal = COMSIG_KB_HOLSTER


/datum/keybinding/human/unique_action
	key = "Space"
	name = "unique_action"
	full_name = "Perform unique action"
	description = ""
	keybind_signal = COMSIG_KB_UNIQUEACTION