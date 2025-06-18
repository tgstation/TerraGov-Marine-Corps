/datum/keybinding/mecha
	category = CATEGORY_MECHA
	weight = WEIGHT_MOB

/datum/keybinding/mecha/mech_toggle_internals
	name = "mech_toggle_internals"
	full_name = "Toggle Internals"
	description = "Toggle the internal ventilation on your mecha"
	keybind_signal = COMSIG_MECHABILITY_TOGGLE_INTERNALS
	hotkey_keys = list("I")

/datum/keybinding/mecha/mech_toggle_strafe
	name = "mech_toggle_strafe"
	full_name = "Toggle Strafe"
	description = "Toggle strafing for your mecha"
	keybind_signal = COMSIG_MECHABILITY_TOGGLE_STRAFE
	hotkey_keys = list("V")

/datum/keybinding/mecha/mech_view_stats
	name = "mech_view_stats"
	full_name = "View Stats"
	description = "View the diagnostics of your mecha"
	keybind_signal = COMSIG_MECHABILITY_VIEW_STATS
	hotkey_keys = list("Unbound")

/datum/keybinding/mecha/smoke
	name = "mecha_smoke"
	full_name = "Mecha Smoke"
	description = "Deploy smoke around you"
	keybind_signal = COMSIG_MECHABILITY_SMOKE
	hotkey_keys = list("F")

/datum/keybinding/mecha/toggle_zoom
	name = "toggle_zoom"
	full_name = "Mecha Zoom"
	description = "Zoom in or out"
	keybind_signal = COMSIG_MECHABILITY_TOGGLE_ZOOM
	hotkey_keys = list("Q")

/datum/keybinding/mecha/mech_assault_armor
	name = "mech_assault_armor"
	full_name = "Mecha Assault Armor"
	description = "Activate Mecha Assault armor"
	keybind_signal = COMSIG_MECHABILITY_ASSAULT_ARMOR
	hotkey_keys = list("Q")

/datum/keybinding/mecha/skyfall
	name = "mech_skyfall"
	full_name = "Mecha Skyfall"
	description = "Fly into the sky and prepare to strike"
	keybind_signal = COMSIG_MECHABILITY_SKYFALL
	hotkey_keys = list("Y")

/datum/keybinding/mecha/strike
	name = "mech_strike"
	full_name = "Mecha Strike"
	description = "Bombard an area with rockets"
	keybind_signal = COMSIG_MECHABILITY_STRIKE
	hotkey_keys = list("F")

/datum/keybinding/mecha/mech_reload_weapons
	name = "mech_reload_weapons"
	full_name = "Mech Reload Weapons"
	description = "Reload any equipped weapons"
	keybind_signal = COMSIG_MECHABILITY_RELOAD
	hotkey_keys = list("R")

/datum/keybinding/mecha/mech_repairpack
	name = "mech_repairpack"
	full_name = "Mech Use Repairpack"
	description = "Use a repair pack to repair the mech."
	keybind_signal = COMSIG_MECHABILITY_REPAIRPACK
	hotkey_keys = list("C")

/datum/keybinding/mecha/mech_swapweapons
	name = "mech_swapweapons"
	full_name = "Mech Swap Weapons"
	description = "Swap from hand to back weapons or vice versa."
	keybind_signal = COMSIG_MECHABILITY_SWAPWEAPONS
	hotkey_keys = list("E")

/datum/keybinding/mecha/mech_toggle_actuators
	name = "mech_toggle_actuators"
	full_name = "Mecha Toggle Actuators"
	description = "Toggle leg actuator overload for your mecha"
	keybind_signal = COMSIG_MECHABILITY_TOGGLE_ACTUATORS
	hotkey_keys = list("X")

/datum/keybinding/mecha/mech_cloak
	name = "mech_cloak"
	full_name = "Mecha Toggle Cloak"
	description = "Toggle mech cloaking device."
	keybind_signal = COMSIG_MECHABILITY_CLOAK
	hotkey_keys = list("Q")

/datum/keybinding/mecha/mech_overboost
	name = "mech_overboost"
	full_name = "Mecha activate overboost"
	description = "Toggle mech overboost module."
	keybind_signal = COMSIG_MECHABILITY_OVERBOOST
	hotkey_keys = list("Q")


/datum/keybinding/mecha/mech_pulse_armor
	name = "mech_pulse_armor"
	full_name = "Mecha Pulse Armor"
	description = "Activate mecha pulse armor."
	keybind_signal = COMSIG_MECHABILITY_PULSE_ARMOR
	hotkey_keys = list("Q")
