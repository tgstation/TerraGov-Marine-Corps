/datum/keybinding/item
	category = CATEGORY_ITEM
	weight = WEIGHT_MOB

/datum/keybinding/item/jetpack
	name = "Jetpack"
	full_name = "Toggle jetpack"
	description = "Toggles your jetpack on, allowing you to fly a short distance."
	keybind_signal = COMSIG_ITEM_TOGGLE_JETPACK
	hotkey_keys = list("G")

/datum/keybinding/item/jetpack_select
	name = "Jetpack_select"
	full_name = "Select jetpack"
	description = "Toggles your jetpack on, allowing you to fly a short distance."
	keybind_signal = COMSIG_ITEM_TOGGLE_JETPACK_SELECT

/datum/keybinding/item/blinkdrive
	name = "Blink drive toggle"
	full_name = "Toggle blink drive"
	description = "Toggles your blink drive on, allowing you to instantly teleport short distances."
	keybind_signal = COMSIG_ITEM_TOGGLE_BLINKDRIVE
	hotkey_keys = list("G")

/datum/keybinding/item/blinkdrive_active_select
	name = "Blink drive_select"
	full_name = "Select blink drive"
	description = "instantly teleports you a short distance."
	keybind_signal = COMSIG_ITEM_BLINKDRIVE_SELECT

/datum/keybinding/item/toggle_strap
	name = "item_toggle_strap"
	full_name = "Activates item strap"
	description = "Tightens or loosens the strap on your held item, if it has one."
	keybind_signal = COMSIG_ITEM_TOGGLE_STRAP
