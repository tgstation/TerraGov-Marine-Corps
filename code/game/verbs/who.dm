/client/verb/who()
	set name = "Who"
	set category = "OOC"

	var/count_observers = 0
	var/count_nonadmin_observers = 0
	var/count_humans = 0
	var/count_marine_humans = 0
	var/count_som_marine_humans = 0
	var/count_infectedhumans = 0
	var/count_aliens = 0

	for(var/client/C in GLOB.clients)
		if(isobserver(C.mob))
			count_observers++
			if(!check_other_rights(C, R_ADMIN, FALSE))
				count_nonadmin_observers++
		if(C.mob && C.mob.stat != DEAD)
			if(ishuman(C.mob))
				count_humans++
				var/mob/living/carbon/human/human_mob = C.mob
				if(ismarinejob(human_mob.job))
					count_marine_humans++
				if(issommarinejob(human_mob.job))
					count_som_marine_humans++
				if(C.mob.status_flags & XENO_HOST)
					count_infectedhumans++
			if(isxeno(C.mob))
				count_aliens++


	var/msg = "<b>Current Players:</b><br>"

	var/list/Lines = list()


	if(check_rights(R_ADMIN, FALSE))
		for(var/client/C in GLOB.clients)
			var/entry = "[C.key]"
			if(C.holder?.fakekey)
				entry += " <i>(as [C.holder.fakekey])</i>"
			entry += " - Playing as [C.mob.real_name]"
			switch(C.mob.stat)
				if(UNCONSCIOUS)
					entry += " - <b>Unconscious</b>"
				if(DEAD)
					if(isobserver(C.mob))
						var/mob/dead/observer/O = C.mob
						if(O.started_as_observer)
							entry += " - Observing"
						else
							entry += " - <b>DEAD</b>"
					else
						entry += " - <b>DEAD</b>"
			entry += " (<A HREF='?src=[REF(usr.client.holder)];[HrefToken()];moreinfo=[REF(C.mob)]'>?</A>)"
			Lines += entry
	else
		for(var/client/C in GLOB.clients)
			if(C.holder?.fakekey)
				Lines += C.holder.fakekey
			else
				Lines += C.key

	for(var/line in sortList(Lines))
		msg += "[line]<br>"

	if(check_rights(R_ADMIN, FALSE))
		var/datum/hive_status/hive = GLOB.hive_datums[XENO_HIVE_NORMAL]
		msg += "<b>Total Players: [length(Lines)]</b>"
		msg += "<br><b>Observers: [count_observers] (Non-Admin: [count_nonadmin_observers])</b>"
		msg += "<br><b>Humans: [count_humans]</b> <b>(Marines: ~[count_marine_humans])</b> <b>(Sons of Mars: ~[count_som_marine_humans])</b> <b>(Infected: [count_infectedhumans])</b><br>"
		msg += "<br><b>Xenos: [count_aliens]</b> <b>(Ruler: [hive.living_xeno_ruler ? "Alive" : "Dead"])</b>"
	else
		msg += "<b>Total Players: [length(Lines)]</b>"

	var/datum/browser/browser = new(usr, "who", "<div align='center'>Who</div>", 400, 500)
	browser.set_content(msg)
	browser.open()


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
				msg += "\t <a href='?_src_=holder;[HrefToken()];playerpanel=[REF(C.mob)]'>[C]</a> - [C.holder.rank]"

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

				msg += "[isobserver(C.mob) || isnewplayer(C.mob) ? "" : " as [C.mob.real_name]"] (<A HREF='?src=[REF(usr.client.holder)];[HrefToken()];moreinfo=[REF(C.mob)]'>?</A>)"

				msg += "\n"
				num_admins_online++

			else if(is_mentor(C))
				mentmsg += "\t[C] - [C.holder.rank]"
				if(isobserver(C.mob))
					mentmsg += " - Observing"
				else if(istype(C.mob, /mob/new_player))
					mentmsg += " - Lobby"
				else
					mentmsg += " - Playing"

				if(C.is_afk())
					mentmsg += " (AFK)"

				mentmsg += "[isobserver(C.mob) || isnewplayer(C.mob) ? "" : " as [C.mob.real_name]"] (<A HREF='?src=[REF(usr.client.holder)];[HrefToken()];moreinfo=[REF(C.mob)]'>?</A>)"

				mentmsg += "\n"
				num_mentors_online++

	else
		for(var/client/C in GLOB.admins)
			if(check_other_rights(C, R_ADMIN, FALSE) && !C.holder.fakekey)
				msg += "\t[C] - [C.holder.rank]\n"
				num_admins_online++
			else if(is_mentor(C))
				mentmsg += "\t[C] - [C.holder.rank]\n"
				num_mentors_online++

	to_chat(src, "\n<b> Current Admins ([num_admins_online]):</b>\n[msg]")
	to_chat(src, "\n<b> Current Mentors ([num_mentors_online]):</b>\n[mentmsg]<br>")
