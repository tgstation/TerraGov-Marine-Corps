/datum/keybinding/vehicle
	category = CATEGORY_VEHICLE
	weight = WEIGHT_MOB

/datum/keybinding/vehicle/tesla
	name = "vehicle_tesla"
	full_name = "Vehicle Tesla"
	description = "Electrifies the hull, throwing off any mobs"
	keybind_signal = COMSIG_VEHICLEABILITY_TESLA
	hotkey_keys = list("F")

/datum/keybinding/vehicle/smoke
	name = "vehicle_smoke"
	full_name = "Vehicle Smoke"
	description = "Deploy a smokescreen in front of you"
	keybind_signal = COMSIG_VEHICLEABILITY_SMOKE
	hotkey_keys = list("F")
