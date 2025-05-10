ADMIN_VERB(pref_ff_attack_logs, R_ADMIN, "Toggle FF Attack Log Messages", "Toggle ff attack log preferences", ADMIN_CATEGORY_MAIN)
	user.prefs.load_preferences() // todo dleete this and just put it in the admin tab on the pref ui
	user.prefs.toggles_chat ^= CHAT_FFATTACKLOGS
	user.prefs.save_preferences()

	if(user.prefs.toggles_chat & CHAT_FFATTACKLOGS)
		to_chat(user, span_boldnotice("You will now get friendly fire attack log messages."))
	else
		to_chat(user, span_boldnotice("You will no longer get friendly fire attack log messages."))

ADMIN_VERB(pref_end_attack_logs, R_ADMIN, "Toggle End-Of-Round Attack Log Messages", "Toggle attack logs after the round ends", ADMIN_CATEGORY_MAIN)
	user.prefs.load_preferences() // todo dleete this and just put it in the admin tab on the pref ui
	user.prefs.toggles_chat ^= CHAT_ENDROUNDLOGS
	user.prefs.save_preferences()

	if(user.prefs.toggles_chat & CHAT_ENDROUNDLOGS)
		to_chat(user, span_boldnotice("You will now get end-round attack log messages."))
	else
		to_chat(user, span_boldnotice("You will no longer get end-round attack log messages."))

ADMIN_VERB(pref_debug_logs, R_ADMIN, "Toggle Debug Log Messages", "Toggle Debug Log Messages", ADMIN_CATEGORY_MAIN)
	user.prefs.load_preferences() // todo dleete this and just put it in the admin tab on the pref ui
	user.prefs.toggles_chat ^= CHAT_DEBUGLOGS
	user.prefs.save_preferences()

	if(user.prefs.toggles_chat & CHAT_DEBUGLOGS)
		to_chat(user, span_boldnotice("You will now get debug log messages."))
	else
		to_chat(user, span_boldnotice("You will no longer get debug log messages."))

ADMIN_VERB(set_ooc_color_self, R_COLOR, "OOC Text Color", "Set your own color for OOC", ADMIN_CATEGORY_FUN)
	var/new_ooccolor = input(user, "Please select your OOC colour", "OOC colour") as color|null
	if(!new_ooccolor) // todo dleete this and just put it in the admin tab on the pref ui
		return

	user.prefs.load_preferences()
	user.prefs.ooccolor = new_ooccolor
	user.prefs.save_preferences()

ADMIN_VERB(toggle_prayers, R_MENTOR|R_ADMIN, "Toggle Prayers", "Toggle IC prayers from players", ADMIN_CATEGORY_MAIN)
	user.prefs.toggles_chat ^= CHAT_PRAYER // todo dleete this and just put it in the admin tab on the pref ui
	user.prefs.save_preferences()

	to_chat(user, span_notice("You will [(user.prefs.toggles_chat & CHAT_PRAYER) ? "now" : "no longer"] see prayerchat."))

ADMIN_VERB(toggle_adminhelp_sound, R_NONE, "Toggle Adminhelp Sound", "Toggle playing the ahelp sound.", ADMIN_CATEGORY_MAIN)
	user.prefs.toggles_sound ^= SOUND_ADMINHELP
	user.prefs.save_preferences() // todo dleete this and just put it in the admin tab on the pref ui

	to_chat(user, span_notice("You will [(user.prefs.toggles_sound & SOUND_ADMINHELP) ? "now" : "no longer"] hear a sound when adminhelps arrive."))

