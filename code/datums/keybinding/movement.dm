/datum/keybinding/movement
	category = CATEGORY_MOVEMENT
	weight = WEIGHT_HIGHEST

/datum/keybinding/movement/north
	key = "W"
	classic_key = "North"
	name = "North"
	full_name = "Move North"
	description = "Moves your character north"
	keybind_signal = COMSIG_KB_MOVEMENT_NORTH_DOWN

/datum/keybinding/movement/south
	key = "S"
	classic_key = "South"
	name = "South"
	full_name = "Move South"
	description = "Moves your character south"
	keybind_signal = COMSIG_KB_MOVEMENT_SOUTH_DOWN

/datum/keybinding/movement/west
	key = "A"
	classic_key = "West"
	name = "West"
	full_name = "Move West"
	description = "Moves your character left"
	keybind_signal = COMSIG_KB_MOVEMENT_WEST_DOWN

/datum/keybinding/movement/east
	key = "D"
	classic_key = "East"
	name = "East"
	full_name = "Move East"
	description = "Moves your character east"
	keybind_signal = COMSIG_KB_MOVEMENT_EAST_DOWN
