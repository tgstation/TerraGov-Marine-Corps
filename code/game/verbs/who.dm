/client/verb/who()
	set name = "Who"
	set category = "OOC"

	var/count_observers = 0
	var/count_nonadmin_observers = 0
	var/count_humans = 0
	var/count_marine_humans = 0
	var/count_infectedhumans = 0
	var/count_aliens = 0
	var/count_preds = 0

	for(var/client/C in GLOB.clients)
		if(isobserver(C.mob))
			count_observers++
			if(!check_other_rights(C, R_ADMIN, FALSE))
				count_nonadmin_observers++
		if(C.mob && C.mob.stat != DEAD)
			if(ishuman(C.mob) && !iszombie(C.mob))
				count_humans++
				if(C.mob.mind.assigned_role in (ROLES_MARINES))
					count_marine_humans++
				if(C.mob.status_flags & XENO_HOST)
					count_infectedhumans++
			if(isxeno(C.mob))
				count_aliens++
			if(isyautja(C.mob))
				count_preds++


	var/msg = "<b>Current Players:</b>\n"

	var/list/Lines = list()


	if(check_rights(R_ADMIN, FALSE))
		for(var/client/C in GLOB.clients)
			var/entry = "[C.key]"
			if(C.holder?.fakekey)
				entry += " <i>(as [C.holder.fakekey])</i>"
			entry += " - Playing as [C.mob.real_name]"
			switch(C.mob.stat)
				if(UNCONSCIOUS)
					entry += " - <font color='#404040'><b>Unconscious</b></font>"
				if(DEAD)
					if(isobserver(C.mob))
						var/mob/dead/observer/O = C.mob
						if(O.started_as_observer)
							entry += " - <font color='#777'>Observing</font>"
						else
							entry += " - <font color='#000'><b>DEAD</b></font>"
					else
						entry += " - <font color='#000'><b>DEAD</b></font>"
			if(is_special_character(C.mob))
				entry += " - <b><font color='red'>Antagonist</font></b>"
			entry += " (<A HREF='?src=[REF(usr.client.holder)];[HrefToken()];moreinfo=[REF(C.mob)]'>?</A>)"
			Lines += entry
	else
		for(var/client/C in GLOB.clients)
			if(C.holder?.fakekey)
				Lines += C.holder.fakekey
			else
				Lines += C.key

	for(var/line in sortList(Lines))
		msg += "[line]\n"

	if(check_rights(R_ADMIN, FALSE))
		var/datum/hive_status/hive = hive_datum[XENO_HIVE_NORMAL]
		msg += "<b>Total Players: [length(Lines)]</b>"
		msg += "<br><b style='color:#777'>Observers: [count_observers] (Non-Admin: [count_nonadmin_observers])</b>"
		msg += "<br><b style='color:#2C7EFF'>Humans: [count_humans]</b> <b style='color:#688944'>(Marines: ~[count_marine_humans])</b> <b style='color:#F00'>(Infected: [count_infectedhumans])</b><br>"
		msg += "<br><b style='color:#8200FF'>Aliens: [count_aliens]</b> <b style='color:#4D0096'>(Queen: [hive.living_xeno_queen ? "Alive" : "Dead"])</b>"
		msg += "<br><b style='color:#7ABA19'>Predators: [count_preds]</b>"
	else
		msg += "<b>Total Players: [length(Lines)]</b>"

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
				if(!check_rights(R_ADMIN, FALSE) && C.holder.fakekey)
					continue
				msg += "\t[C] - [C.holder.rank]"

				if(C.holder.fakekey)
					msg += " as ([C.holder.fakekey])"

				if(isobserver(C.mob))
					msg += " - Observing"
				else if(istype(C.mob, /mob/new_player))
					msg += " - Lobby"
				else
					msg += " - Playing"

				if(C.is_afk())
					msg += " (AFK)"

				msg += "[isobserver(C.mob) || istype(C.mob, /mob/new_player) ? "" : " as [C.mob.real_name]"] (<A HREF='?src=[REF(usr.client.holder)];[HrefToken()];moreinfo=[REF(C.mob)]'>?</A>)"

				msg += "\n"
				num_admins_online++

			else if(is_mentor(C))
				mentmsg += "\t[C] is [C.holder.rank]"
				if(isobserver(C.mob))
					mentmsg += " - Observing"
				else if(istype(C.mob, /mob/new_player))
					mentmsg += " - Lobby"
				else
					mentmsg += " - Playing"

				if(C.is_afk())
					mentmsg += " (AFK)"

				mentmsg += "[isobserver(C.mob) ? "" : " as [C.mob.real_name]"] (<A HREF='?src=[REF(usr.client.holder)];[HrefToken()];moreinfo=[REF(C.mob)]'>?</A>)"

				mentmsg += "\n"
				num_mentors_online++

	else
		for(var/client/C in GLOB.admins)
			if(check_other_rights(C, R_ADMIN, FALSE) && !C.holder.fakekey)
				msg += "\t[C] is a [C.holder.rank]\n"
				num_admins_online++
			else if(is_mentor(C))
				mentmsg += "\t[C] is a [C.holder.rank]\n"
				num_mentors_online++

	to_chat(src, "\n<b> Current Admins ([num_admins_online]):</b>\n[msg]")
	to_chat(src, "\n<b> Current Mentors ([num_mentors_online]):</b>\n[mentmsg]")