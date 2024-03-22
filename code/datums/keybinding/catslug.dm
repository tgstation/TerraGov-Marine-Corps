/datum/keybinding/catslug
	category = CATEGORY_CATSLUG
	weight = WEIGHT_MOB

/datum/keybinding/catslug/spearthrow
	name = "Spear Throw"
	full_name = "Catslug: Spear Throw"
	description = "We throw a spear at our enemies."
	keybind_signal = COMSIG_ABILITY_SPEARTHROW
	hotkey_keys = list("U")

/datum/keybinding/catslug/healingtouch
	name = "Healing Touch"
	full_name = "Catslug: Healing Touch"
	description = "Apply a minor heal to the target."
	keybind_signal = COMSIG_ABILITY_HEALINGTOUCH
	hotkey_keys = list("H")
