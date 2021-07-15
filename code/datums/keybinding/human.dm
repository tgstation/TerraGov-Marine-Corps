/datum/keybinding/human
	category = CATEGORY_HUMAN
	weight = WEIGHT_MOB


/datum/keybinding/human/quick_equip
	hotkey_keys = list("E")
	name = "quick_equip"
	full_name = "Quick equip"
	description = ""
	keybind_signal = COMSIG_KB_QUICKEQUIP

/datum/keybinding/human/holster
	hotkey_keys = list("H")
	name = "holster"
	full_name = "Holster"
	description = ""
	keybind_signal = COMSIG_KB_HOLSTER

/datum/keybinding/human/unique_action
	hotkey_keys = list("Space")
	name = "unique_action"
	full_name = "Perform unique action"
	description = ""
	keybind_signal = COMSIG_KB_UNIQUEACTION

/datum/keybinding/human/rail_attachment
	hotkey_keys = list("F")
	name = "rail_attachment"
	full_name = "Activate Rail attachment"
	description = ""
	keybind_signal = COMSIG_KB_RAILATTACHMENT

/datum/keybinding/human/underrail_attachment
	name = "underrail_attachment"
	full_name = "Activate Underrail attachment"
	description = ""
	keybind_signal = COMSIG_KB_UNDERRAILATTACHMENT

/datum/keybinding/human/unload_gun
	name = "unload_gun"
	full_name = "Unload gun"
	description = ""
	keybind_signal = COMSIG_KB_UNLOADGUN

/datum/keybinding/human/toggle_gun_safety
	name = "toggle_safety"
	full_name = "Toggle gun safety"
	description = ""
	keybind_signal = COMSIG_KB_GUN_SAFETY

/datum/keybinding/human/toggle_aim_mode
	hotkey_keys = list("6")
	name = "toggle_aim_mode"
	full_name = "Toggle aim mode"
	description = ""
	keybind_signal = COMSIG_KB_AIMMODE

/datum/keybinding/human/switch_fire_mode
	name = "switch_fire_mode"
	full_name = "Switch fire mode"
	description = ""
	keybind_signal = COMSIG_KB_FIREMODE

/datum/keybinding/human/give
	name = "give"
	full_name = "Give"
	description = "Give the held item to the nearby marine"
	keybind_signal = COMSIG_KB_GIVE
