/client/verb/who()
	set name = "Who"
	set category = "OOC"

	var/msg = "<b>Current Players:</b>\n"

	var/list/keys = list()

	for(var/client/C in GLOB.clients)
		if(C.holder?.fakekey && !check_rights(R_ADMIN, FALSE))
			continue
		if(check_rights(R_ADMIN, FALSE))
			keys += "[ADMIN_TPMONTY(C.mob)]\n"
		else
			keys += "[C.key]\n"

	msg += list2text(sortKey(keys))

	msg += "<b>Total Players: [length(keys)]</b>"

	to_chat(src, msg)


/client/verb/staffwho()
	set category = "Admin"
	set name = "Staffwho"

	var/msg = ""
	var/mentmsg = ""
	var/num_admins_online = 0
	var/num_mentors_online = 0

	if(check_rights(R_ADMIN|R_MENTOR, FALSE))
		for(var/client/C in GLOB.admins)
			if(check_other_rights(C, R_ADMIN, FALSE))
				if(is_mentor(src) && C.holder.fakekey)
					continue
				msg += "[C] is a [C.holder.rank]"

				if(isobserver(C.mob))
					msg += " - Observing"
				else if(istype(C.mob, /mob/new_player))
					msg += " - Lobby"
				else
					msg += " - Playing"

				if(C.is_afk())
					msg += " (AFK)"
				msg += "\n"
				num_admins_online++

			else if(is_mentor(C))
				mentmsg += "[C] is a [C.holder.rank]"
				if(isobserver(C.mob))
					mentmsg += " - Observing"
				else if(istype(C.mob, /mob/new_player))
					mentmsg += " - Lobby"
				else
					mentmsg += " - Playing"

				if(C.is_afk())
					mentmsg += " (AFK)"
				mentmsg += "\n"
				num_mentors_online++

	else
		for(var/client/C in GLOB.admins)
			if(check_other_rights(C, R_ADMIN, FALSE) && !C.holder.fakekey)
				msg += "[C] is a [C.holder.rank]\n"
				num_admins_online++
			else if(is_mentor(C))
				mentmsg += "[C] is a [C.holder.rank]\n"
				num_mentors_online++

	to_chat(src, "\n<b> Current Admins ([num_admins_online]):</b>\n[msg]")
	to_chat(src, "<b> Current Mentors ([num_mentors_online]):</b>\n[mentmsg]")