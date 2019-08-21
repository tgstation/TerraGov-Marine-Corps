/datum/admins/proc/pref_attack_logs()
	set category = "Preferences"
	set name = "Toggle Attack Log Messages"

	if(!check_rights(R_ADMIN))
		return

	usr.client.prefs.load_preferences()
	usr.client.prefs.toggles_chat ^= CHAT_ATTACKLOGS
	usr.client.prefs.save_preferences()

	if(usr.client.prefs.toggles_chat & CHAT_ATTACKLOGS)
		to_chat(usr, "<span class='boldnotice'>You will now get attack log messages.</span>")
	else
		to_chat(usr, "<span class='boldnotice'>You will no longer get attack log messages.</span>")


/datum/admins/proc/pref_ff_attack_logs()
	set category = "Preferences"
	set name = "Toggle FF Attack Log Messages"

	if(!check_rights(R_ADMIN))
		return

	usr.client.prefs.load_preferences()
	usr.client.prefs.toggles_chat ^= CHAT_FFATTACKLOGS
	usr.client.prefs.save_preferences()

	if(usr.client.prefs.toggles_chat & CHAT_FFATTACKLOGS)
		to_chat(usr, "<span class='boldnotice'>You will now get friendly fire attack log messages.</span>")
	else
		to_chat(usr, "<span class='boldnotice'>You will no longer get friendly fire attack log messages.</span>")


/datum/admins/proc/pref_end_attack_logs()
	set category = "Preferences"
	set name = "Toggle End-Of-Round Attack Log Messages"

	if(!check_rights(R_ADMIN))
		return

	usr.client.prefs.load_preferences()
	usr.client.prefs.toggles_chat ^= CHAT_ENDROUNDLOGS
	usr.client.prefs.save_preferences()

	if(usr.client.prefs.toggles_chat & CHAT_ENDROUNDLOGS)
		to_chat(usr, "<span class='boldnotice'>You will now get end-round attack log messages.</span>")
	else
		to_chat(usr, "<span class='boldnotice'>You will no longer get end-round attack log messages.</span>")


/datum/admins/proc/pref_debug_logs()
	set name = "Toggle Debug Log Messages"
	set category = "Preferences"

	if(!check_rights(R_ADMIN))
		return

	usr.client.prefs.load_preferences()
	usr.client.prefs.toggles_chat ^= CHAT_DEBUGLOGS
	usr.client.prefs.save_preferences()

	if(usr.client.prefs.toggles_chat & CHAT_DEBUGLOGS)
		to_chat(usr, "<span class='boldnotice'>You will now get debug log messages.</span>")
	else
		to_chat(usr, "<span class='boldnotice'>You will no longer get debug log messages.</span>")


/datum/admins/proc/set_ooc_color_self()
	set category = "Preferences"
	set name = "OOC Text Color"

	if(!check_rights(R_FUN))
		return

	var/new_ooccolor = input(src, "Please select your OOC colour", "OOC colour") as color|null
	if(!new_ooccolor)
		return

	usr.client.prefs.load_preferences()
	usr.client.prefs.ooccolor = new_ooccolor
	usr.client.prefs.save_preferences()


/datum/admins/proc/toggle_prayers()
	set category = "Preferences"
	set name = "Toggle Prayers"

	usr.client.prefs.toggles_chat ^= CHAT_PRAYER
	usr.client.prefs.save_preferences()

	to_chat(src, "<span class='notice'>You will [(usr.client.prefs.toggles_chat & CHAT_PRAYER) ? "now" : "no longer"] see prayerchat.</span>")


/datum/admins/proc/toggle_adminhelp_sound()
	set category = "Preferences"
	set name = "Toggle Adminhelp Sound"

	usr.client.prefs.toggles_sound ^= SOUND_ADMINHELP
	usr.client.prefs.save_preferences()

	to_chat(usr, "<span class='notice'>You will [(usr.client.prefs.toggles_sound & SOUND_ADMINHELP) ? "now" : "no longer"] hear a sound when adminhelps arrive.</span>")
