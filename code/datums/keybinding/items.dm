/datum/keybinding/item
	category = CATEGORY_PSIONIC
	weight = WEIGHT_MOB

/datum/keybinding/item/axe_sweep
	name = "Axe sweep"
	full_name = "Breaching axe: Axe sweep"
	description = "A powerful sweeping blow that hits foes in the direction you are facing. Cannot stun."
	keybind_signal = COMSIG_ITEMABILITY_AXESWEEP
	hotkey_keys = list("R")

/datum/keybinding/item/axe_sweep_select
	name = "Axe sweep select"
	full_name = "Breaching axe: Select axe sweep"
	description = "Selected axe sweep, a powerful sweeping blow that hits foes in the direction you are facing. Cannot stun."
	keybind_signal = COMSIG_ITEMABILITY_AXESWEEP_SELECT
