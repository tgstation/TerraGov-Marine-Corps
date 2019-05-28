/datum/keybinding/xeno
	category = CATEGORY_XENO
	weight = WEIGHT_MOB


/datum/keybinding/xeno/drop_weeds
	key = "V"
	name = "drop_weeds"
	full_name = "Drop Weed"
	description = "Drop weeds to help grow your hive."
	category = CATEGORY_XENO

/datum/keybinding/xeno/drop_weeds/down(client/user)
	if(SEND_SIGNAL(user.mob, COMSIG_XENOABILITY_DROP_WEEDS) & COMSIG_XENOABILITY_HAS_ABILITY)
		return TRUE

	if(!isxeno(user.mob))
		return

	to_chat(user, "<span class='notice'>You don't have this ability.</span>") // TODO Is this spammy?
	return TRUE
