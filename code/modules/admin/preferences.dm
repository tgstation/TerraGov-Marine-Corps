/client/proc/toggleattacklogs()
	set name = "Toggle Attack Log Messages"
	set category = "Preferences"

	prefs.toggles_chat ^= CHAT_ATTACKLOGS
	if (prefs.toggles_chat & CHAT_ATTACKLOGS)
		to_chat(usr, "<span class='boldnotice'>You will now get attack log messages.</span>")
	else
		to_chat(usr, "<span class='boldnotice'>You will no longer get attack log messages.</span>")

/client/proc/toggleffattacklogs()
	set name = "Toggle FF Attack Log Messages"
	set category = "Preferences"

	prefs.toggles_chat ^= CHAT_FFATTACKLOGS
	if (prefs.toggles_chat & CHAT_FFATTACKLOGS)
		to_chat(usr, "<span class='boldnotice'>You will now get friendly fire attack log messages.</span>")
	else
		to_chat(usr, "<span class='boldnotice'>You will no longer get friendly fire attack log messages.</span>")

/client/proc/toggleendofroundattacklogs()
	set name = "Toggle End-Of-Round Attack Log Messages"
	set category = "Preferences"
	prefs.toggles_chat ^= CHAT_ENDROUNDLOGS
	if (prefs.toggles_chat & CHAT_ENDROUNDLOGS)
		to_chat(usr, "<span class='boldnotice'>You will now get end-round attack log messages.</span>")
	else
		to_chat(usr, "<span class='boldnotice'>You will no longer get end-round attack log messages.</span>")

/client/proc/toggledebuglogs()
	set name = "Toggle Debug Log Messages"
	set category = "Preferences"

	if(!prefs)
		return

	prefs.load_preferences()
	prefs.toggles_chat ^= CHAT_DEBUGLOGS
	prefs.save_preferences()
	if(prefs.toggles_chat & CHAT_DEBUGLOGS)
		to_chat(usr, "<span class='boldnotice'>You will now get debug log messages.</span>")
	else
		to_chat(usr, "<span class='boldnotice'>You will no longer get debug log messages.</span>")

/client/proc/toggle_own_ghost_vis()
	set name = "Ghost visiblity"
	set desc = "Toggle your visibility as a ghost to other ghosts."
	set category = "Preferences"

	if(!holder) return

	if(isobserver(usr))
		if(usr.invisibility <> 60 && usr.layer <> 4.0)
			usr.invisibility = 60
			usr.layer = MOB_LAYER
			to_chat(usr, "<span class='warning'>Ghost visibility returned to normal.</span>")
		else
			usr.invisibility = 70
			usr.layer = BELOW_MOB_LAYER
			to_chat(usr, "<span class='warning'>Your ghost is now invisibile to other ghosts.</span>")
		log_admin("Admin [key_name(src)] has toggled Ordukai Mode.")
	else
		to_chat(usr, "<span class='warning'>You need to be a ghost in order to use this.</span>")