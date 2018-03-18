
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
	var/count_zed = 0

	for(var/client/C in clients)
		if(isobserver(C.mob))
			count_observers++
			if(!C.holder)
				count_nonadmin_observers++
		if(C.mob && C.mob.stat != DEAD)
			if(ishuman(C.mob) && !iszombie(C.mob))
				count_humans++
				if(C.mob.job in (ROLES_MARINES))
					count_marine_humans++
				if(C.mob.status_flags & XENO_HOST)
					count_infectedhumans++
			if(isXeno(C.mob))
				count_aliens++
			if(isYautja(C.mob))
				count_preds++
		if(iszombie(C.mob))
			count_zed++


	var/msg = "<b>Current Players:</b>\n"

	var/list/Lines = list()

	if(holder && (R_ADMIN & holder.rights || R_MOD & holder.rights))
		for(var/client/C in clients)
			var/entry = "\t[C.key]"
			if(C.holder && C.holder.fakekey)
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

/*			var/age
			if(isnum(C.player_age))
				age = C.player_age
			else
				age = 0

			if(age <= 1)
				age = "<font color='#ff0000'><b>[age]</b></font>"
			else if(age < 10)
				age = "<font color='#ff8c00'><b>[age]</b></font>"

			entry += " - [age]"*/

			if(is_special_character(C.mob))
				entry += " - <b><font color='red'>Antagonist</font></b>"
			entry += " (<A HREF='?_src_=holder;adminmoreinfo=\ref[C.mob]'>?</A>)"
			Lines += entry
	else
		for(var/client/C in clients)
			if(C.holder && C.holder.fakekey)
				Lines += C.holder.fakekey
			else
				Lines += C.key

	for(var/line in sortList(Lines))
		msg += "[line]\n"

	if(holder)
		var/datum/hive_status/hive = hive_datum[XENO_HIVE_NORMAL]
		msg += "<b>Total Players: [length(Lines)]</b>"
		msg += "<br><b style='color:#777'>Observers: [count_observers] (Non-Admin: [count_nonadmin_observers])</b>"
		msg += "<br><b style='color:#2C7EFF'>Humans: [count_humans]</b> <b style='color:#688944'>(Marines: ~[count_marine_humans])</b> <b style='color:#F00'>(Infected: [count_infectedhumans])</b><br><b style='color:#2C7EFF'>Zeds: [count_zed]</b>"
		msg += "<br><b style='color:#8200FF'>Aliens: [count_aliens]</b> <b style='color:#4D0096'>(Queen: [hive.living_xeno_queen ? "Alive" : "Dead"])</b>"
		msg += "<br><b style='color:#7ABA19'>Predators: [count_preds]</b>"
	else
		msg += "<b>Total Players: [length(Lines)]</b>"
	src << msg

/client/verb/staffwho()
	set category = "Admin"
	set name = "Staffwho"

	var/msg = ""
	var/modmsg = ""
	var/mentmsg = ""
	var/num_mods_online = 0
	var/num_admins_online = 0
	var/num_mentors_online = 0
	if(holder)
		for(var/client/C in admins)
			if(R_ADMIN & C.holder.rights || (!R_MOD & C.holder.rights && !R_MENTOR & C.holder.rights))	//Used to determine who shows up in admin rows

				if(C.holder.fakekey && (!R_ADMIN & holder.rights && !R_MOD & holder.rights))		//Mentors can't see stealthmins
					continue

				msg += "\t[C] is a [C.holder.rank]"

				if(C.holder.fakekey)
					msg += " <i>(as [C.holder.fakekey])</i>"

				if(isobserver(C.mob))
					msg += " - Observing"
				else if(istype(C.mob,/mob/new_player))
					msg += " - Lobby"
				else
					msg += " - Playing"

				if(C.is_afk())
					msg += " (AFK)"
				msg += "\n"

				num_admins_online++
			else if(R_MOD & C.holder.rights)				//Who shows up in mod/mentor rows.
				modmsg += "\t[C] is a [C.holder.rank]"

				if(isobserver(C.mob))
					modmsg += " - Observing"
				else if(istype(C.mob,/mob/new_player))
					modmsg += " - Lobby"
				else
					modmsg += " - Playing"

				if(C.is_afk())
					modmsg += " (AFK)"
				modmsg += "\n"
				num_mods_online++

			else if(R_MENTOR & C.holder.rights)
				mentmsg += "\t[C] is a [C.holder.rank]"
				if(isobserver(C.mob))
					mentmsg += " - Observing"
				else if(istype(C.mob,/mob/new_player))
					mentmsg += " - Lobby"
				else
					mentmsg += " - Playing"

				if(C.is_afk())
					mentmsg += " (AFK)"
				mentmsg += "\n"
				num_mentors_online++

	else
		for(var/client/C in admins)
			if(R_ADMIN & C.holder.rights || (!R_MOD & C.holder.rights && !R_MENTOR & C.holder.rights))
				if(!C.holder.fakekey)
					msg += "\t[C] is a [C.holder.rank]\n"
					num_admins_online++
			else if (R_MOD & C.holder.rights)
				modmsg += "\t[C] is a [C.holder.rank]\n"
				num_mods_online++
			else if (R_MENTOR & C.holder.rights)
				mentmsg += "\t[C] is a [C.holder.rank]\n"
				num_mentors_online++

	if(config.admin_irc)
		src << "<span class='info'>Adminhelps are also sent to IRC. If no admins are available in game try anyway and an admin on IRC may see it and respond.</span>"
	msg = "<b>Current Admins ([num_admins_online]):</b>\n" + msg

	if(config.show_mods)
		msg += "\n<b> Current Moderators ([num_mods_online]):</b>\n" + modmsg

	if(config.show_mentors)
		msg += "\n<b> Current Mentors ([num_mentors_online]):</b>\n" + mentmsg

	src << msg
