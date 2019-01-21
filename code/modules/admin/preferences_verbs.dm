/datum/admins/proc/pref_attack_logs()
	set category = "Preferences"
	set name = "Toggle Attack Log Messages"

	if(!check_rights(R_ADMIN))
		return

	owner.prefs.load_preferences()
	owner.prefs.toggles_chat ^= CHAT_ATTACKLOGS
	owner.prefs.save_preferences()

	if(owner.prefs.toggles_chat & CHAT_ATTACKLOGS)
		to_chat(usr, "<span class='boldnotice'>You will now get attack log messages.</span>")
	else
		to_chat(usr, "<span class='boldnotice'>You will no longer get attack log messages.</span>")


/datum/admins/proc/pref_ff_attack_logs()
	set category = "Preferences"
	set name = "Toggle FF Attack Log Messages"

	if(!check_rights(R_ADMIN))
		return

	if(!owner?.prefs)
		return

	owner.prefs.load_preferences()
	owner.prefs.toggles_chat ^= CHAT_FFATTACKLOGS
	owner.prefs.save_preferences()

	if(owner.prefs.toggles_chat & CHAT_FFATTACKLOGS)
		to_chat(usr, "<span class='boldnotice'>You will now get friendly fire attack log messages.</span>")
	else
		to_chat(usr, "<span class='boldnotice'>You will no longer get friendly fire attack log messages.</span>")


/datum/admins/proc/pref_end_attack_logs()
	set category = "Preferences"
	set name = "Toggle End-Of-Round Attack Log Messages"

	if(!check_rights(R_ADMIN))
		return

	if(!owner?.prefs)
		return

	owner.prefs.load_preferences()
	owner.prefs.toggles_chat ^= CHAT_ENDROUNDLOGS
	owner.prefs.save_preferences()

	if(owner.prefs.toggles_chat & CHAT_ENDROUNDLOGS)
		to_chat(usr, "<span class='boldnotice'>You will now get end-round attack log messages.</span>")
	else
		to_chat(usr, "<span class='boldnotice'>You will no longer get end-round attack log messages.</span>")


/datum/admins/proc/pref_debug_logs()
	set name = "Toggle Debug Log Messages"
	set category = "Preferences"

	if(!check_rights(R_ADMIN))
		return

	if(!owner?.prefs)
		return

	owner.prefs.load_preferences()
	owner.prefs.toggles_chat ^= CHAT_DEBUGLOGS
	owner.prefs.save_preferences()

	if(owner.prefs.toggles_chat & CHAT_DEBUGLOGS)
		to_chat(usr, "<span class='boldnotice'>You will now get debug log messages.</span>")
	else
		to_chat(usr, "<span class='boldnotice'>You will no longer get debug log messages.</span>")


/datum/admins/proc/set_ooc_color_self()
	set category = "Preferences"
	set name = "OOC Text Color"

	if(!check_rights(R_FUN))
		return

	var/new_ooccolor = input(src, "Please select your OOC colour", "OOC colour") as color|null
	if(!new_ooccolor || !owner?.prefs)
		return

	owner.prefs.load_preferences()
	owner.prefs.ooccolor = new_ooccolor
	owner.prefs.save_preferences()