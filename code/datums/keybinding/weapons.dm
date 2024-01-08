/datum/keybinding/weapon
	category = CATEGORY_WEAPON
	weight = WEIGHT_MOB

/datum/keybinding/weapon/axe_sweep
	name = "Axe sweep"
	full_name = "Breaching axe: Axe sweep"
	description = "A powerful sweeping blow that hits foes in the direction you are facing. Cannot stun."
	keybind_signal = COMSIG_WEAPONABILITY_AXESWEEP
	hotkey_keys = list("G")

/datum/keybinding/weapon/axe_sweep_select
	name = "Axe sweep select"
	full_name = "Breaching axe: Select axe sweep"
	description = "Selected axe sweep, a powerful sweeping blow that hits foes in the direction you are facing. Cannot stun."
	keybind_signal = COMSIG_WEAPONABILITY_AXESWEEP_SELECT

/datum/keybinding/weapon/sword_lunge
	name = "Lunging strike"
	full_name = "Sword: Lunging strike"
	description = "Dash a short distance to inflict a staggering blow on an opponent. Cannot stun."
	keybind_signal = COMSIG_WEAPONABILITY_SWORDLUNGE
	hotkey_keys = list("G")

/datum/keybinding/item
	category = CATEGORY_WEAPON
	weight = WEIGHT_MOB

/datum/keybinding/item/jetpack
	name = "Axe sweep"
	full_name = "Breaching axe: Axe sweep"
	description = "A powerful sweeping blow that hits foes in the direction you are facing. Cannot stun."
	keybind_signal = COMSIG_ITEM_TOGGLE_JETPACK
	hotkey_keys = list("G")

/datum/keybinding/item/blinkdrive
	name = "Axe sweep"
	full_name = "Breaching axe: Axe sweep"
	description = "A powerful sweeping blow that hits foes in the direction you are facing. Cannot stun."
	keybind_signal = COMSIG_ITEM_TOGGLE_BLINKDRIVE
	hotkey_keys = list("G")
