/client/verb/who()
	set name = "Who"
	set category = "OOC"

	var/msg = "<b>Current Players:</b>\n"

	var/list/Lines = list()

	for(var/client/C in clients)
		Lines += "[C.key]\n"

	msg += "<b>Total Players: [length(Lines)]</b>"

	to_chat(src, msg)


/client/verb/staffwho()
	set category = "Admin"
	set name = "Staffwho"

	var/msg = ""
	var/mentmsg = ""
	var/num_admins_online = 0
	var/num_mentors_online = 0

	if(holder)
		for(var/client/C in admins)
			if(check_other_rights(C, R_ADMIN))
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
		for(var/client/C in admins)
			if(check_other_rights(C, R_ADMIN))
				msg += "\t[C] is a [C.holder.rank]\n"
				num_admins_online++
			else if(is_mentor(C))
				mentmsg += "\t[C] is a [C.holder.rank]\n"
				num_mentors_online++

	to_chat(src, "\n<b> Current Admins ([num_admins_online]):</b>\n[msg]")
	to_chat(src, "\n<b> Current Mentors ([num_mentors_online]):</b>\n[mentmsg]")