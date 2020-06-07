/datum/keybinding/mob/spacedash
	hotkey_keys = list("CtrlW", "CtrlNorth")
	classic_keys = list("CtrlNorth")
	name = "spacedash_north"
	full_name = "Space Dash North"
	description = ""
	keybind_signal = COMSIG_KB_MOB_DASHNORTH_DOWN
	var/dash_dir = NORTH

/datum/keybinding/mob/spacedash/down(client/user)
	. = ..()
	if(.)
		return
	var/mob/M = user.mob
	if(M.incapacitated())
		return
	for(var/obj/item/I in M.get_equipped_items())
		var/datum/component/jetpack_dash/thruster = I.GetComponent(/datum/component/jetpack_dash)
		if(thruster && thruster.dash(M, dash_dir))
			return TRUE

/datum/keybinding/mob/spacedash/east
	hotkey_keys = list("CtrlD", "CtrlEast")
	classic_keys = list("CtrlEast")
	name = "spacedash_east"
	full_name = "Space Dash East"
	description = ""
	keybind_signal = COMSIG_KB_MOB_DASHEAST_DOWN
	dash_dir = EAST

/datum/keybinding/mob/spacedash/south
	hotkey_keys = list("CtrlS", "CtrlSouth")
	classic_keys = list("CtrlSouth")
	name = "spacedash_south"
	full_name = "Space Dash South"
	description = ""
	keybind_signal = COMSIG_KB_MOB_DASHSOUTH_DOWN
	dash_dir = SOUTH

/datum/keybinding/mob/spacedash/west
	hotkey_keys = list("CtrlA", "CtrlWest")
	classic_keys = list("CtrlWest")
	name = "spacedash_west"
	full_name = "Space Dash West"
	description = ""
	keybind_signal = COMSIG_KB_MOB_DASHWEST_DOWN
	dash_dir = WEST