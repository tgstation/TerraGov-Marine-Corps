/datum/keybinding/admin
	category = CATEGORY_ADMIN
	weight = WEIGHT_ADMIN


/datum/keybinding/admin/admin_say
	hotkey_keys = list("F3")
	name = "admin_say"
	full_name = "Admin say"
	description = "Talk with other admins."
	keybind_signal = COMSIG_KB_ADMIN_ASAY_DOWN

/datum/keybinding/admin/admin_say/down(client/user)
	. = ..()
	if(.)
		return
	user.get_asay()
	return TRUE


/datum/keybinding/admin/mentor_say
	hotkey_keys = list("F4")
	name = "mentor_say"
	full_name = "Mentor say"
	description = "Speak with other mentors."
	keybind_signal = COMSIG_KB_ADMIN_MSAY_DOWN

/datum/keybinding/admin/mentor_say/down(client/user)
	. = ..()
	if(.)
		return
	user.get_msay()
	return TRUE


/datum/keybinding/admin/dead_say
	hotkey_keys = list("F5")
	name = "dead_say"
	full_name = "Dead chat"
	description = "Speak with the dead."
	keybind_signal = COMSIG_KB_ADMIN_DSAY_DOWN

/datum/keybinding/admin/dead_say/down(client/user)
	. = ..()
	if(.)
		return
	user.get_dsay()
	return TRUE

/datum/keybinding/admin/toggle_buildmode_self
	hotkey_keys = list("F7")
	name = "toggle_buildmode"
	full_name = "Toggle Buildmode"
	description = "Toggles buildmode"
	keybind_signal = COMSIG_KB_ADMIN_TOGGLEBUILDMODE_DOWN

/datum/keybinding/admin/toggle_buildmode_self/down(client/user)
	. = ..()
	if(.)
		return
	user.get_togglebuildmode()
	return TRUE
