/datum/keybinding/weapon
	category = CATEGORY_WEAPON
	weight = WEIGHT_MOB

/datum/keybinding/weapon/axe_sweep
	name = "Axe sweep"
	full_name = "Breaching axe: Axe sweep"
	description = "A powerful sweeping blow that hits foes in the direction you are facing. Cannot stun."
	keybind_signal = COMSIG_WEAPONABILITY_AXESWEEP
	hotkey_keys = list("R")

/datum/keybinding/weapon/axe_sweep_select
	name = "Axe sweep select"
	full_name = "Breaching axe: Select axe sweep"
	description = "Selected axe sweep, a powerful sweeping blow that hits foes in the direction you are facing. Cannot stun."
	keybind_signal = COMSIG_WEAPONABILITY_AXESWEEP_SELECT

/datum/keybinding/weapon/machete_lunge
	name = "Lunging strike"
	full_name = "Machete: Lunging strike"
	description = "Dash a short distance to inflict a staggering blow on an opponent. Cannot stun."
	keybind_signal = COMSIG_WEAPONABILITY_MACHETELUNGE
	hotkey_keys = list("R")
