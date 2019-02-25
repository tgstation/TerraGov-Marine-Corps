/datum/admins/proc/CheckAdminHref(href, href_list)
	var/auth = href_list["admin_token"]
	. = auth && (auth == href_token || auth == GLOB.href_token)
	if(.)
		return
	var/msg = !auth ? "no" : "a bad"
	log_admin_private("[key_name(usr)] clicked an href with [msg] authorization key! [href]")
	message_admins("[ADMIN_TPMONTY(usr)] clicked an href with [msg] authorization key.")



/datum/admins/Topic(href, href_list)
	. = ..()

	if(usr.client != src.owner || !check_rights(NONE))
		log_admin("[key_name(usr)] tried to use the admin panel without authorization.")
		message_admins("[ADMIN_TPMONTY(usr)] tried to use the admin panel without authorization.")
		return

	if(!CheckAdminHref(href, href_list))
		return


	if(href_list["ahelp"])
		var/ahelp_ref = href_list["ahelp"]
		var/datum/admin_help/AH = locate(ahelp_ref)
		if(AH)
			AH.Action(href_list["ahelp_action"])
		else
			to_chat(usr, "<span class='warning'>Ticket [ahelp_ref] has been deleted!</span>")


	else if(href_list["ahelp_tickets"])
		GLOB.ahelp_tickets.BrowseTickets(text2num(href_list["ahelp_tickets"]))


	else if(href_list["moreinfo"])
		if(!check_rights(R_ADMIN))
			return

		var/mob/M = locate(href_list["moreinfo"]) in GLOB.mob_list

		if(!ismob(M))
			return

		var/location_description = ""
		var/special_role_description = ""
		var/health_description = ""
		var/gender_description = ""
		var/turf/T = get_turf(M)

		//Location
		if(isturf(T))
			if(isarea(T.loc))
				location_description = "([M.loc == T ? "at coordinates " : "in [M.loc] at coordinates "] [T.x], [T.y], [T.z] in area <b>[T.loc]</b>)"
			else
				location_description = "([M.loc == T ? "at coordinates " : "in [M.loc] at coordinates "] [T.x], [T.y], [T.z])"

		//Job + antagonist
		special_role_description = "Role: <b>[M.mind.assigned_role]</b>"

		//Health
		if(isliving(M))
			var/mob/living/L = M
			var/status
			switch(M.stat)
				if(CONSCIOUS)
					status = "Alive"
				if(UNCONSCIOUS)
					status = "<font color='orange'><b>Unconscious</b></font>"
				if(DEAD)
					status = "<font color='red'><b>Dead</b></font>"
			health_description = "Status = [status]"
			health_description += "<BR>Oxy: [L.getOxyLoss()] - Tox: [L.getToxLoss()] - Fire: [L.getFireLoss()] - Brute: [L.getBruteLoss()] - Clone: [L.getCloneLoss()] - Brain: [L.getBrainLoss()]"
		else
			health_description = "This mob type has no health to speak of."

		//Gender
		switch(M.gender)
			if(MALE, FEMALE)
				gender_description = "[M.gender]"
			else
				gender_description = "<font color='red'><b>[M.gender]</b></font>"

		to_chat(usr, "<b>Info about [M.name]:</b> ")
		to_chat(usr, "Mob type = [M.type]; Gender = [gender_description] Damage = [health_description]")
		to_chat(usr, "Name = <b>[M.name]</b>; Real_name = [M.real_name]; Mind_name = [M.mind ? "[M.mind.name]" : ""]; Key = <b>[M.key]</b>;")
		to_chat(usr, "Location = [location_description];")
		to_chat(usr, "[special_role_description]")
		to_chat(usr, ADMIN_FULLMONTY(M))


	else if(href_list["playerpanel"])
		if(!check_rights(R_ADMIN))
			return
		var/mob/M = locate(href_list["playerpanel"])
		show_player_panel(M)


	else if(href_list["subtlemessage"])
		var/mob/M = locate(href_list["subtlemessage"])
		subtle_message(M)


	else if(href_list["individuallog"])
		if(!check_rights(R_ADMIN))
			return
		var/mob/M = locate(href_list["individuallog"])
		show_individual_logging_panel(M, href_list["log_src"], href_list["log_type"])


	else if(href_list["observecoordjump"])
		if(istype(usr, /mob/new_player))
			return

		var/x = text2num(href_list["X"])
		var/y = text2num(href_list["Y"])
		var/z = text2num(href_list["Z"])

		var/client/C = usr.client

		if(!isobserver(usr))
			admin_ghost()
			log_admin("[key_name(C.mob)] jumped to coordinates ([x], [y], [z]).")
			message_admins("[ADMIN_TPMONTY(C.mob)] jumped to coordinates ([x], [y], [z]).")

		var/mob/dead/observer/M = C.mob

		M.on_mob_jump()
		M.x = x
		M.y = y
		M.z = z
		M.forceMove(M.loc)


	else if(href_list["observefollow"])
		var/atom/movable/AM = locate(href_list["observefollow"])

		if(QDELETED(AM) || !ismovableatom(AM))
			return

		if(istype(usr, /mob/new_player) || istype(AM, /mob/new_player))
			return

		var/client/C = usr.client

		if(!isobserver(usr))
			admin_ghost()
			log_admin("[key_name(C.mob)] jumped to follow [key_name(AM)].")
			message_admins("[ADMIN_TPMONTY(C.mob)] jumped to follow [ADMIN_TPMONTY(AM)].")

		var/mob/dead/observer/ghost = C.mob
		ghost.ManualFollow(AM)


	else if(href_list["observejump"])
		var/atom/movable/AM = locate(href_list["observejump"])

		if(istype(usr, /mob/new_player) || istype(AM, /mob/new_player))
			return

		var/client/C = usr.client

		if(!isobserver(usr))
			admin_ghost()
			log_admin("[key_name(usr)] jumped to [key_name(AM)].")
			message_admins("[ADMIN_TPMONTY(usr)] jumped to [ADMIN_TPMONTY(AM)].")

		C.mob.forceMove(AM.loc)


	else if(href_list["secrets"])
		switch(href_list["secrets"])
			if("blackout")
				log_admin("[key_name(usr)] broke all lights.")
				message_admins("[ADMIN_TPMONTY(usr)] broke all lights.")
				for(var/obj/machinery/power/apc/apc in GLOB.machines)
					apc.overload_lighting()
			if("whiteout")
				log_admin("[key_name(usr)] fixed all lights.")
				message_admins("[ADMIN_TPMONTY(usr)] fixed all lights.")
				for(var/obj/machinery/light/L in GLOB.machines)
					L.fix()
			if("power")
				log_admin("[key_name(usr)] powered all ship SMESs and APCs")
				message_admins("[ADMIN_TPMONTY(usr)] powered all ship SMESs and APCs.")
				power_restore()
			if("unpower")
				log_admin("[key_name(usr)] unpowered all ship SMESs and APCs.")
				message_admins("[ADMIN_TPMONTY(usr)] unpowered all ship SMESs and APCs.")
				power_failure()
			if("quickpower")
				log_admin("[key_name(usr)] powered all ship SMESs.")
				message_admins("[ADMIN_TPMONTY(usr)] powered all ship SMESs.")
				power_restore_quick()
			if("powereverything")
				log_admin("[key_name(usr)] powered all SMESs and APCs everywhere.")
				message_admins("[ADMIN_TPMONTY(usr)] powered all SMESs and APCs everywhere.")
				power_restore_everything()
			if("gethumans")
				log_admin("[key_name(usr)] mass-teleported all humans.")
				message_admins("[ADMIN_TPMONTY(usr)] mass-teleported all humans.")
				get_all_humans()
			if("getxenos")
				log_admin("[key_name(usr)] mass-teleported all Xenos.")
				message_admins("[ADMIN_TPMONTY(usr)] mass-teleported all Xenos.")
				get_all_xenos()
			if("getall")
				log_admin("[key_name(usr)] mass-teleported everyone.")
				message_admins("[ADMIN_TPMONTY(usr)] mass-teleported everyone.")
				get_all()
			if("rejuvall")
				log_admin("[key_name(usr)] mass-rejuvenated cliented mobs.")
				message_admins("[ADMIN_TPMONTY(usr)] mass-rejuvenated cliented mobs.")
				rejuv_all()


	else if(href_list["unban"])
		if(!check_rights(R_BAN))
			return

		var/banfolder = href_list["unban"]
		Banlist.cd = "/base/[banfolder]"
		var/key = Banlist["key"]
		if(alert(usr, "Are you sure you want to unban [key]?", "Confirmation", "Yes", "No") != "Yes")
			return

		if(RemoveBan(banfolder))
			unban_panel()
			log_admin("[key_name(usr)] removed [key]'s permaban.")
			message_admins("[ADMIN_TPMONTY(usr)] removed [key]'s permaban.")
		else
			to_chat(usr, "<span class='warning'>Error, ban failed to be removed.</span>")
			unban_panel()


	else if(href_list["permaban"])
		if(!check_rights(R_BAN))
			return

		var/reason
		var/banfolder = href_list["permaban"]
		Banlist.cd = "/base/[banfolder]"
		var/reason2 = Banlist["reason"]

		var/minutes = Banlist["minutes"]

		var/banned_key = Banlist["key"]
		Banlist.cd = "/base"

		var/mins = 0
		if(minutes > ((world.realtime / 10) / 60))
			mins = minutes - ((world.realtime / 10) / 60)
		if(!mins)
			return
		mins = max(5255990,mins) // 10 years
		minutes = ((world.realtime / 10) / 60) + mins
		reason = input(usr, "Reason?", "reason", reason2) as message|null
		if(!reason)
			return

		Banlist.cd = "/base/[banfolder]"
		Banlist["reason"] << sanitize(reason)
		Banlist["temp"] << 0
		Banlist["minutes"] << minutes
		Banlist["bannedby"] << usr.ckey
		Banlist.cd = "/base"
		unban_panel()
		log_admin("[key_name(usr)] upgraded [banned_key]'s ban to a permaban. Reason: [sanitize(reason)]")
		message_admins("[ADMIN_TPMONTY(usr)] upgraded [banned_key]'s ban to a permaban. Reason: [sanitize(reason)]")


	else if(href_list["editban"])
		if(!check_rights(R_BAN))
			return

		var/reason

		var/banfolder = href_list["editban"]
		Banlist.cd = "/base/[banfolder]"
		var/reason2 = Banlist["reason"]
		var/temp = Banlist["temp"]

		var/minutes = Banlist["minutes"]

		var/banned_key = Banlist["key"]
		Banlist.cd = "/base"

		var/duration

		var/mins = 0
		if(minutes > ((world.realtime / 10) / 60))
			mins = minutes - ((world.realtime / 10) / 60)
		mins = input(usr, "How long (in minutes)? \n 1440 = 1 day \n 4320 = 3 days \n 10080 = 7 days", "Ban time", 1440) as num|null
		if(!mins)
			return
		mins = min(525599,mins)
		minutes = ((world.realtime / 10) / 60) + mins
		duration = GetExp(minutes)
		reason = input(usr,"Reason?","reason",reason2) as message|null
		if(!reason)
			return

		Banlist.cd = "/base/[banfolder]"
		Banlist["reason"] << sanitize(reason)
		Banlist["temp"] << temp
		Banlist["minutes"] << minutes
		Banlist["bannedby"] << usr.ckey
		Banlist.cd = "/base"
		unban_panel()

		log_admin("[key_name(usr)] edited [banned_key]'s ban. Reason: [sanitize(reason)] Duration: [duration]")
		message_admins("[ADMIN_TPMONTY(usr)] edited [banned_key]'s ban. Reason: [sanitize(reason)] Duration: [duration]")


	else if(href_list["kick"])
		if(!check_rights(R_BAN))
			return

		var/mob/M = locate(href_list["kick"])
		if(ismob(M))
			if(!check_if_greater_rights_than(M.client))
				return
			if(alert(usr, "Are you sure you want to kick [key_name(M)]?", "Warning", "Yes", "No") != "Yes")
				return
			if(!M)
				to_chat(usr, "<span class='warning'>Error: [M] no longer exists!</span>")
				return
			if(!M.client)
				to_chat(usr, "<span class='warning'>Error: [M] no longer has a client!</span>")
				return
			to_chat(M, "<span class='danger'>You have been kicked from the server by [usr.client.holder.fakekey ? "an Administrator" : "[usr.client.key]"].</span>")
			qdel(M.client)

			log_admin_private("[key_name(usr)] kicked [key_name(M)].")
			message_admins("[ADMIN_TPMONTY(usr)] kicked [ADMIN_TPMONTY(M)].")


	else if(href_list["ban"])
		if(!check_rights(R_BAN))
			return

		var/mob/M = locate(href_list["ban"])
		if(!ismob(M))
			return

		if(!M.ckey)
			return

		var/mob_key = M.ckey
		var/mob_id = M.computer_id
		var/mob_ip = M.lastKnownIP
		var/client/mob_client = M.client
		if(!check_if_greater_rights_than(mob_client))
			return
		var/mins = input("How long (in minutes)? \n 1440 = 1 day \n 4320 = 3 days \n 10080 = 7 days", "Ban time", 1440) as num|null
		if(!mins)
			return
		if(mins >= 525600) mins = 525599
		var/reason = input("Please enter the ban reason.", "Ban Reason", "") as message|null
		if(!reason)
			return
		if(alert("Are you sure you want to ban [key_name(M)] for [reason]?", "Confirmation", "Yes", "No") != "Yes")
			return
		AddBan(mob_key, mob_id, reason, usr.ckey, TRUE, mins, mob_ip)

		to_chat(M, "<span class='danger'>You have been banned by [usr.client.ckey].\nReason: [sanitize(reason)].</span>")
		to_chat(M, "<span class='warning'>This is a temporary ban, it will be removed in [mins] minutes.</span>")
		if(CONFIG_GET(string/banappeals))
			to_chat(M, "<span class='warning'>To try to resolve this matter head to [CONFIG_GET(string/banappeals)]</span>")
		if(mob_client)
			qdel(mob_client)

		log_admin_private("[key_name(usr)] has banned [key_name(M)] | Duration: [mins] minutes | Reason: [sanitize(reason)]")
		notes_add(mob_key, "Banned by [usr.client.holder.fakekey ? "an Administrator" : usr.client.ckey] | Duration: [mins] minutes | Reason: [sanitize(reason)]", usr)
		message_admins("[ADMIN_TPMONTY(usr)] has banned [ADMIN_TPMONTY(M)] | Duration: [mins] minutes| Reason: [sanitize(reason)]")


	else if(href_list["bankey"])
		if(!check_rights(R_BAN))
			return

		var/key = href_list["bankey"]
		if(!key)
			return

		var/mins
		var/reason

		switch(alert(usr, "Permanent or temporary?", "Ban Type", "Permanent", "Temporary", "Cancel"))
			if("Permanent")
				reason = input("Please enter the ban reason.", "Ban Reason") as message|null
				reason = sanitize(reason)
				if(!reason)
					return
				if(alert("Are you sure you want to permanently ban [key] for [reason]?", "Confirmation", "Yes", "No") != "Yes")
					return
				notes_add(key, "Banned by [usr.client.holder.fakekey ? "an Administrator" : usr.client.ckey] | Duration: Permanent | Reason: [reason]", usr)
				AddBan(key, null, reason, usr.ckey, FALSE, 525599, null)

				log_admin_private("[key_name(usr)] has banned [key] | Duration: Permanent | Reason: [reason]")
				message_admins("[ADMIN_TPMONTY(usr)] has banned [key] | Duration: Permanent | Reason: [reason]")
			if("Temporary")
				mins = input("How long (in minutes)? \n 1440 = 1 day \n 4320 = 3 days \n 10080 = 7 days", "Ban time", 1440) as num|null
				if(isnull(mins) || mins < 0)
					return
				if(mins >= 525600)
					mins = 525599
				reason = input("Please enter the ban reason.", "Ban Reason") as message|null
				reason = sanitize(reason)
				if(!reason)
					return
				if(alert("Are you sure you want to ban [key] for [reason] for [mins] minutes?", "Confirmation", "Yes", "No") != "Yes")
					return
				notes_add(key, "Banned by [usr.client.holder.fakekey ? "an Administrator" : usr.client.ckey] | Duration: [mins] minutes | Reason: [reason]", usr)
				AddBan(key, null, reason, usr.ckey, TRUE, mins, null)

				log_admin_private("[key_name(usr)] has banned [key] | Duration: [mins] minutes | Reason: [reason]")
				message_admins("[ADMIN_TPMONTY(usr)] has banned [key] | Duration: [mins] minutes | Reason: [reason]")


	else if(href_list["notes_add"])
		if(!check_rights(R_BAN))
			return

		var/key = href_list["notes_add"]
		var/add = input("Add Player Info") as null|message
		if(!add)
			return

		notes_add(key, add, usr)
		player_notes_show(key)


	else if(href_list["notes_remove"])
		if(!check_rights(R_BAN))
			return

		var/key = href_list["notes_remove"]
		var/index = text2num(href_list["remove_index"])

		notes_del(key, index)
		player_notes_show(key)


	else if(href_list["notes_hide"])
		if(!check_rights(R_BAN))
			return

		var/key = href_list["notes_hide"]
		var/index = text2num(href_list["hide_index"])

		notes_hide(key, index)
		player_notes_show(key)


	else if(href_list["notes_unhide"])
		if(!check_rights(R_BAN))
			return

		var/key = href_list["notes_unhide"]
		var/index = text2num(href_list["unhide_index"])

		notes_unhide(key, index)
		player_notes_show(key)


	else if(href_list["notes_edit"])
		if(!check_rights(R_BAN))
			return

		var/key = href_list["notes_edit"]
		var/index = text2num(href_list["edit_index"])
		notes_edit(key, index)


	else if(href_list["notes"])
		if(!check_rights(R_BAN))
			return

		var/ckey = href_list["ckey"]
		if(!ckey)
			var/mob/M = locate(href_list["mob"])
			if(ismob(M))
				ckey = M.ckey

		switch(href_list["notes"])
			if("show")
				player_notes_show(ckey)
			if("list")
				PlayerNotesPage(text2num(href_list["index"]))


	else if(href_list["notes_copy"])
		if(!check_rights(R_BAN))
			return

		var/key = href_list["notes_copy"]
		player_notes_copy(key)


	else if(href_list["jobbanpanel"])
		if(!check_rights(R_BAN))
			return

		var/mob/M = locate(href_list["jobbanpanel"])
		if(!ismob(M))
			return

		mob_jobban_panel(M)


	else if(href_list["jobban"])
		if(!check_rights(R_BAN))
			return

		var/mob/M = locate(href_list["mob"])
		if(!ismob(M))
			return

		if(!check_if_greater_rights_than(M.client))
			return

		if(!M.ckey)
			return

		if(!SSjob)
			return

		var/list/joblist = list()
		switch(href_list["jobban"])
			if("commanddept")
				for(var/jobPos in JOBS_COMMAND)
					if(!jobPos)
						continue
					var/datum/job/temp = SSjob.name_occupations[jobPos]
					if(!temp)
						continue
					joblist += temp.title
			if("policedept")
				for(var/jobPos in JOBS_POLICE)
					if(!jobPos)
						continue
					var/datum/job/temp = SSjob.name_occupations[jobPos]
					if(!temp)
						continue
					joblist += temp.title
			if("engineeringdept")
				for(var/jobPos in JOBS_ENGINEERING)
					if(!jobPos)
						continue
					var/datum/job/temp = SSjob.name_occupations[jobPos]
					if(!temp)
						continue
					joblist += temp.title
			if("cargodept")
				for(var/jobPos in JOBS_REQUISITIONS)
					if(!jobPos)
						continue
					var/datum/job/temp = SSjob.name_occupations[jobPos]
					if(!temp)
						continue
					joblist += temp.title
			if("medicaldept")
				for(var/jobPos in JOBS_MEDICAL)
					if(!jobPos)
						continue
					var/datum/job/temp = SSjob.name_occupations[jobPos]
					if(!temp)
						continue
					joblist += temp.title
			if("marinedept")
				for(var/jobPos in JOBS_MARINES)
					if(!jobPos)
						continue
					var/datum/job/temp = SSjob.name_occupations[jobPos]
					if(!temp)
						continue
					joblist += temp.title
			else
				joblist += href_list["jobban"]

		//Create a list of unbanned jobs within joblist
		var/list/notbannedlist = list()
		for(var/job in joblist)
			if(!jobban_isbanned(M, job))
				notbannedlist += job

		if(length(notbannedlist))
			var/reason = input("Please state the reason for the jobban.", "Reason", "") as text|null
			if(reason)
				var/msg
				for(var/job in notbannedlist)
					log_admin_private("[key_name(usr)] jobbanned [key_name(M)] from [job].")
					jobban_fullban(M, job, "[reason]; By [usr.client.ckey] on [time2text(world.realtime)]")
					if(!msg)
						msg = job
					else
						msg += ", [job]"
				notes_add(M.ckey, "Banned  from [msg] - [reason]", usr)
				message_admins("[ADMIN_TPMONTY(usr)] banned [ADMIN_TPMONTY(M)] from [msg].")
				to_chat(M, "<span class='danger'>You have been jobbanned by [usr.client.ckey] from: [msg].</span>")
				to_chat(M, "<span class='warning'>The reason is: [reason]</span>")
				jobban_savebanfile()
			return

		if(length(joblist))
			var/msg
			for(var/job in joblist)
				var/reason = jobban_isbanned(M, job)
				if(!reason)
					continue
				if(alert("Job: '[job]' Reason: '[reason]' Un-jobban?","Please Confirm","Yes","No") != "Yes")
					continue
				log_admin_private("[key_name(usr)] un-jobbanned [key_name(M)] from [job].")
				jobban_unban(M, job)
				if(!msg)
					msg = job
				else
					msg += ", [job]"
			if(msg)
				message_admins("[ADMIN_TPMONTY(usr)] un-jobbanned [ADMIN_TPMONTY(M)] from [msg].")
				to_chat(M, "<span class='danger'>You have been un-jobbanned by [usr.client.ckey] from [msg].</span>")
			jobban_savebanfile()


	else if(href_list["jobbankey"])
		if(!check_rights(R_BAN))
			return

		var/key = href_list["key"]
		if(!key)
			return

		if(!SSjob)
			return

		var/list/joblist = list()
		switch(href_list["jobbankey"])
			if("commanddept")
				for(var/jobPos in JOBS_COMMAND)
					if(!jobPos)
						continue
					var/datum/job/temp = SSjob.name_occupations[jobPos]
					if(!temp)
						continue
					joblist += temp.title
			if("policedept")
				for(var/jobPos in JOBS_POLICE)
					if(!jobPos)
						continue
					var/datum/job/temp = SSjob.name_occupations[jobPos]
					if(!temp)
						continue
					joblist += temp.title
			if("engineeringdept")
				for(var/jobPos in JOBS_ENGINEERING)
					if(!jobPos)
						continue
					var/datum/job/temp = SSjob.name_occupations[jobPos]
					if(!temp)
						continue
					joblist += temp.title
			if("cargodept")
				for(var/jobPos in JOBS_REQUISITIONS)
					if(!jobPos)
						continue
					var/datum/job/temp = SSjob.name_occupations[jobPos]
					if(!temp)
						continue
					joblist += temp.title
			if("medicaldept")
				for(var/jobPos in JOBS_MEDICAL)
					if(!jobPos)
						continue
					var/datum/job/temp = SSjob.name_occupations[jobPos]
					if(!temp)
						continue
					joblist += temp.title
			if("marinedept")
				for(var/jobPos in JOBS_MARINES)
					if(!jobPos)
						continue
					var/datum/job/temp = SSjob.name_occupations[jobPos]
					if(!temp)
						continue
					joblist += temp.title
			else
				joblist += href_list["jobbankey"]

		//Create a list of unbanned jobs within joblist
		var/list/notbannedlist = list()
		for(var/job in joblist)
			if(!jobban_key_isbanned(key, job))
				notbannedlist += job

		if(length(notbannedlist))
			var/reason = input("Please state the reason for the jobban.", "Reason", "") as text|null
			if(reason)
				var/msg
				for(var/job in notbannedlist)
					log_admin_private("[key_name(usr)] jobbanned [key] from [job].")
					jobban_key_fullban(key, job, "[reason]; By [usr.client.ckey] on [time2text(world.realtime)]")
					if(!msg)
						msg = job
					else
						msg += ", [job]"
				notes_add(key, "Banned  from [msg] - [reason]", usr)
				message_admins("[ADMIN_TPMONTY(usr)] banned [key] from [msg].")
				jobban_savebanfile()
			return

		if(length(joblist))
			var/msg
			for(var/job in joblist)
				var/reason = jobban_key_isbanned(key, job)
				if(!reason)
					continue
				if(alert("Job: '[job]' Reason: '[reason]' Un-jobban?","Please Confirm","Yes","No") != "Yes")
					continue
				log_admin_private("[key_name(usr)] un-jobbanned [key] from [job].")
				jobban_key_unban(key, job)
				if(!msg)
					msg = job
				else
					msg += ", [job]"
			if(msg)
				message_admins("[ADMIN_TPMONTY(usr)] un-jobbanned [key] from [msg].")
			jobban_savebanfile()


	else if(href_list["mute"])
		if(!check_rights(R_BAN))
			return

		var/mob/M = locate(href_list["mute"])

		if(!ismob(M))
			return

		if(!M.client || !check_if_greater_rights_than(M.client))
			return

		var/mute_type = href_list["mute_type"]

		if(istext(mute_type))
			mute_type = text2num(mute_type)

		if(!isnum(mute_type))
			return

		usr.client.mute(M.client, mute_type)



	else if(href_list["transform"])
		if(!check_rights(R_ADMIN))
			return

		var/mob/M = locate(href_list["mob"])

		if(!ismob(M) || M.gc_destroyed)
			return

		var/delmob = FALSE
		switch(alert("Delete old mob?", "Message", "Yes", "No", "Cancel"))
			if("Cancel")
				return
			if("Yes")
				delmob = TRUE

		var/turf/location
		switch(alert("Teleport to your location?", "Message", "Yes", "No", "Cancel"))
			if("Cancel")
				return
			if("Yes")
				location = get_turf(usr)

		var/mob/oldusr = usr
		var/mob/newmob

		switch(href_list["transform"])
			if("observer")
				newmob = M.change_mob_type(/mob/dead/observer, location, null, delmob)
			if("larva")
				newmob = M.change_mob_type(/mob/living/carbon/Xenomorph/Larva, location, null, delmob)
			if("defender")
				newmob = M.change_mob_type(/mob/living/carbon/Xenomorph/Defender, location, null, delmob)
			if("warrior")
				newmob = M.change_mob_type(/mob/living/carbon/Xenomorph/Warrior, location, null, delmob)
			if("runner")
				newmob = M.change_mob_type(/mob/living/carbon/Xenomorph/Runner, location, null, delmob)
			if("drone")
				newmob = M.change_mob_type(/mob/living/carbon/Xenomorph/Drone, location, null, delmob)
			if("sentinel")
				newmob = M.change_mob_type(/mob/living/carbon/Xenomorph/Sentinel, location, null, delmob)
			if("hunter")
				newmob = M.change_mob_type(/mob/living/carbon/Xenomorph/Hunter, location, null, delmob)
			if("carrier")
				newmob = M.change_mob_type(/mob/living/carbon/Xenomorph/Carrier, location, null, delmob)
			if("hivelord")
				newmob = M.change_mob_type(/mob/living/carbon/Xenomorph/Hivelord, location, null, delmob)
			if("praetorian")
				newmob = M.change_mob_type(/mob/living/carbon/Xenomorph/Praetorian, location, null, delmob)
			if("ravager")
				newmob = M.change_mob_type(/mob/living/carbon/Xenomorph/Ravager, location, null, delmob)
			if("spitter")
				newmob = M.change_mob_type(/mob/living/carbon/Xenomorph/Spitter, location, null, delmob)
			if("boiler")
				newmob = M.change_mob_type(/mob/living/carbon/Xenomorph/Boiler, location, null, delmob)
			if("crusher")
				newmob = M.change_mob_type(/mob/living/carbon/Xenomorph/Crusher, location, null, delmob)
			if("defiler")
				newmob = M.change_mob_type(/mob/living/carbon/Xenomorph/Defiler, location, null, delmob)
			if("queen")
				newmob = M.change_mob_type(/mob/living/carbon/Xenomorph/Queen, location, null, delmob)
			if("human")
				newmob = M.change_mob_type(/mob/living/carbon/human, location, null, delmob)
			if("monkey")
				newmob = M.change_mob_type(/mob/living/carbon/monkey, location, null, delmob)
			if("moth")
				newmob = M.change_mob_type(/mob/living/carbon/human, location, null, delmob, "Moth")
			if("yautja")
				newmob = M.change_mob_type(/mob/living/carbon/human, location, null, delmob, "Yautja")

		log_admin("[key_name(oldusr)] has transformed [key_name(newmob)] into [href_list["transform"]].[delmob ? " Old mob deleted." : ""][location ? " Teleported to [AREACOORD(location)]" : ""]")
		message_admins("[ADMIN_TPMONTY(oldusr)] has transformed [ADMIN_TPMONTY(newmob)] into [href_list["transform"]].[delmob ? " Old mob deleted." : ""][location ? " Teleported to new location." : ""]")


	else if(href_list["revive"])
		if(!check_rights(R_ADMIN))
			return

		var/mob/living/L = locate(href_list["revive"])

		if(!istype(L))
			return

		L.revive()
		log_admin("[key_name(usr)] revived [key_name(L)].")
		message_admins("[ADMIN_TPMONTY(usr)] revived [ADMIN_TPMONTY(L)].")



	else if(href_list["editrightsbrowser"])
		permissions_edit(0)


	else if(href_list["editrightsbrowserlog"])
		permissions_edit(1, href_list["editrightstarget"], href_list["editrightsoperation"], href_list["editrightspage"])


	else if(href_list["editrightsbrowsermanage"])
		if(href_list["editrightschange"])
			change_admin_rank(ckey(href_list["editrightschange"]), href_list["editrightschange"], TRUE)
		else if(href_list["editrightsremove"])
			remove_admin(ckey(href_list["editrightsremove"]), href_list["editrightsremove"], TRUE)
		else if(href_list["editrightsremoverank"])
			remove_rank(href_list["editrightsremoverank"])
		permissions_edit(2)


	else if(href_list["editrights"])
		edit_rights_topic(href_list)


	else if(href_list["spawncookie"])
		if(!check_rights(R_ADMIN|R_FUN))
			return

		var/mob/M = locate(href_list["spawncookie"])

		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			H.put_in_hands(new /obj/item/reagent_container/food/snacks/cookie(M))
			H.update_inv_r_hand()
			H.update_inv_l_hand()
		else
			if(isobserver(M))
				if(alert("Are you sure you want to spawn the cookie at observer location [AREACOORD(M.loc)]?", "Confirmation", "Yes", "No") != "Yes")
					return
			var/turf/T = get_turf(M)
			new /obj/item/reagent_container/food/snacks/cookie(T)

		to_chat(M, "<span class='boldnotice'>Your prayers have been answered!! You received the best cookie!</span>")

		log_admin("[key_name(M)] got their cookie, spawned by [key_name(usr)]")
		message_admins("[ADMIN_TPMONTY(M)] got their cookie, spawned by [ADMIN_TPMONTY(usr)].")

	else if(href_list["spawnfortunecookie"])
		if(!check_rights(R_ADMIN|R_FUN))
			return

		var/mob/M = locate(href_list["spawnfortunecookie"])

		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			H.put_in_hands(new /obj/item/reagent_container/food/snacks/fortunecookie(M))
			H.update_inv_r_hand()
			H.update_inv_l_hand()
		else if(isobserver(M))
			if(alert("Are you sure you want to spawn the fortune cookie at observer location [AREACOORD(M.loc)]?", "Confirmation", "Yes", "No") != "Yes")
				return
			var/turf/T = get_turf(M)
			new /obj/item/reagent_container/food/snacks/fortunecookie(T)
		else if(isxeno(M))
			if(alert("Are you sure you want to tell the Xeno a Xeno tip?", "Confirmation", "Yes", "No") != "Yes")
				return
			to_chat(M, "<span class='tip'>[pick(GLOB.xenotips)]</span>")

		if(isxeno(M))
			to_chat(M, "<span class='boldnotice'>Your prayers have been answered!! Hope the advice helped.</span>")
		else
			to_chat(M, "<span class='boldnotice'>Your prayers have been answered!! You received the best fortune cookie!</span>")

		log_admin("[key_name(M)] got their fortune cookie, spawned by [key_name(usr)]")
		message_admins("[ADMIN_TPMONTY(M)] got their fortune cookie, spawned by [ADMIN_TPMONTY(usr)].")

	else if(href_list["reply"])
		var/mob/living/carbon/human/H = locate(href_list["reply"])

		if(!istype(H))
			return

		var/input = input("Please enter a message to reply to [key_name(H)].", "Outgoing message from TGMC", "") as message|null
		if(!input)
			return

		to_chat(H, "<span class='boldnotice'>Please stand by for a message from TGMC:[input]</span>")

		log_admin("[ADMIN_TPMONTY(usr)] replied to [ADMIN_TPMONTY(H)]'s TGMC message with: [input].")
		message_admins("[ADMIN_TPMONTY(usr)] replied to [ADMIN_TPMONTY(H)]'s' TGMC message with: [input]")


	if(href_list["deny"])
		var/mob/M = locate(href_list["deny"])

		if(!istype(M))
			return

		distress_cancel = TRUE
		command_announcement.Announce("The distress signal has been blocked, the launch tubes are now recalibrating.", "Distress Beacon")
		log_game("[key_name(usr)] has denied a distress beacon, requested by [key_name(M)]")
		message_admins("[ADMIN_TPMONTY(usr)] has denied a distress beacon, requested by [ADMIN_TPMONTY(M)]")


	if(href_list["distress"])
		var/mob/M = locate(href_list["distress"])

		if(!istype(M))
			return

		if(!SSticker?.mode || SSticker.mode.waiting_for_candidates)
			return

		SSticker.mode.activate_distress()

		log_game("[key_name(usr)] has sent a randomized distress beacon early, requested by [key_name(M)]")
		message_admins("[ADMIN_TPMONTY(usr)] has sent a randomized distress beacon early, requested by [ADMIN_TPMONTY(M)]")


	else if(href_list["forcesay"])
		if(!check_rights(R_ADMIN))
			return

		var/mob/M = locate(href_list["forcesay"])
		if(!ismob(M))
			return

		var/speech = input("What will [key_name(M)] say?", "Force say", "")
		if(!speech)
			return
		M.say(speech)

		log_admin("[key_name(usr)] forced [key_name(M)] to say: [speech]")
		message_admins("[ADMIN_TPMONTY(usr)] forced [ADMIN_TPMONTY(M)] to say: [speech]")


	else if(href_list["thunderdome"])
		if(!check_rights(R_ADMIN))
			return

		var/mob/M = locate(href_list["thunderdome"])
		if(!ismob(M))
			return

		if(alert("Do you want to send [key_name(M)] to the Thunderdome?", "Confirmation", "Yes", "No") != "Yes")
			return

		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			for(var/obj/item/W in H)
				if(istype(W, /obj/item/alien_embryo))
					continue
				H.dropItemToGround(W)

		M.forceMove(pick(GLOB.tdome1))

		to_chat(M, "<span class='boldnotice'>You have been sent to the Thunderdome!</span>")

		log_admin("[key_name(usr)] has sent [key_name(M)] to the thunderdome.")
		message_admins("[ADMIN_TPMONTY(usr)] has sent [ADMIN_TPMONTY(M)] to the thunderdome.")


	else if(href_list["gib"])
		if(!check_rights(R_ADMIN))
			return

		var/mob/M = locate(href_list["gib"])
		if(!ismob(M) || isobserver(M))
			return

		if(alert("Are you sure you want to gib [M]?", "Warning", "Yes", "No") != "Yes")
			return

		log_admin("[key_name(usr)] has gibbed [key_name(M)].")
		message_admins("[ADMIN_TPMONTY(usr)] has gibbed [ADMIN_TPMONTY(M)].")

		M.gib()


	else if(href_list["lobby"])
		if(!check_rights(R_ADMIN))
			return

		var/mob/M = locate(href_list["lobby"])

		if(isnewplayer(M))
			var/mob/new_player/N = M
			N.new_player_panel()
			return

		if(!M.client)
			to_chat(usr, "<span class='warning'>[M] doesn't seem to have an active client.</span>")
			return

		if(alert("Send [key_name(M)] back to Lobby?", "Send to Lobby", "Yes", "No") != "Yes")
			return

		log_admin("[key_name(usr)] has sent [key_name(M)] back to the lobby.")
		message_admins("[ADMIN_TPMONTY(usr)] has sent [key_name_admin(M)] back to the lobby.")

		var/mob/new_player/NP = new()
		M.client.screen.Cut()
		NP.key = M.key
		NP.name = M.key
		if(NP.client)
			NP.client.change_view(world.view)
		if(isobserver(M))
			qdel(M)
		else
			M.ghostize()


	else if(href_list["cryo"])
		if(!check_rights(R_ADMIN))
			return

		var/mob/M = locate(href_list["cryo"])
		if(!istype(M))
			return

		if(alert("Cryo [key_name(M)]?", "Cryosleep", "Yes", "No") != "Yes")
			return

		var/client/C = M.client
		if(C && alert("They have a client attached, are you sure?", "Cryosleep", "Yes", "No") != "Yes")
			return

		var/turf/T = get_turf(M)
		var/name = M.real_name
		var/obj/machinery/cryopod/P = new(T)
		P.density = FALSE
		P.alpha = 0
		P.name = null
		P.occupant = M
		P.time_till_despawn = 0
		P.process()
		qdel(P)

		var/lobby
		if(C?.mob?.mind && alert("Do you also want to send them to the lobby?", "Cryosleep", "Yes", "No") == "Yes")
			lobby = TRUE
			var/mob/new_player/NP = new()
			var/mob/N = C.mob
			NP.name = C.mob.name
			C.screen.Cut()
			C.mob.mind.transfer_to(NP, TRUE)
			if(isobserver(N))
				qdel(N)

		log_admin("[key_name(usr)] has cryo'd [C ? key_name(C) : name][lobby ? " sending them to the lobby" : ""].")
		message_admins("[ADMIN_TPMONTY(usr)] has cryo'd [C ? key_name_admin(C) : name] [lobby ? " sending them to the lobby" : ""].")


	else if(href_list["jumpto"])
		if(!check_rights(R_ADMIN))
			return

		var/mob/M = locate(href_list["jumpto"])
		if(!istype(M))
			return

		usr.forceMove(M.loc)

		log_admin("[key_name(usr)] has jumped to [key_name(M)]'s mob.")
		message_admins("[ADMIN_TPMONTY(usr)] has jumped to [ADMIN_TPMONTY(M)]'s mob.")


	else if(href_list["getmob"])
		if(!check_rights(R_ADMIN))
			return

		var/mob/M = locate(href_list["getmob"])
		if(!istype(M))
			return

		M.forceMove(usr.loc)

		log_admin("[key_name(usr)] has sent [key_name(M)]'s mob to themselves.")
		message_admins("[ADMIN_TPMONTY(usr)] has sent [ADMIN_TPMONTY(M)]'s mob to themselves.")


	else if(href_list["sendmob"])
		if(!check_rights(R_ADMIN))
			return

		var/mob/M = locate(href_list["sendmob"])
		if(!istype(M))
			return

		var/atom/target

		switch(input("Where do you want to send it to?", "Send Mob") as null|anything in list("Area", "Mob", "Key", "Coords"))
			if("Area")
				var/area/A = input("Pick an area.", "Pick an area") as null|anything in return_sorted_areas()
				if(!A || !M)
					return
				target = pick(get_area_turfs(A))
			if("Mob")
				var/mob/N = input("Pick a mob.", "Pick a mob") as null|anything in sortmobs(GLOB.mob_list)
				if(!N || !M)
					return
				target = N.loc
			if("Key")
				var/client/C = input("Pick a key.", "Pick a key") as null|anything in sortKey(GLOB.clients)
				if(!C || !M)
					return
				target = C.mob.loc
			if("Coords")
				var/X = input("Select coordinate X", "Coordinate X") as null|num
				var/Y = input("Select coordinate Y", "Coordinate Y") as null|num
				var/Z = input("Select coordinate Z", "Coordinate Z") as null|num
				if(isnull(X) || isnull(Y) || isnull(Z) || !M)
					return
				target = locate(X, Y, Z)

		M.on_mob_jump()
		M.forceMove(target)

		log_admin("[key_name(usr)] has sent [key_name(M)]'s mob to [AREACOORD(target)].")
		message_admins("[ADMIN_TPMONTY(usr)] has sent [ADMIN_TPMONTY(M)]'s mob to [ADMIN_VERBOSEJMP(target)].")


	else if(href_list["faxreply"])
		var/ref = locate(href_list["faxreply"])
		if(!ref)
			return
		var/datum/fax/F = GLOB.faxes[ref]
		if(!F)
			return

		var/mob/sender = F.sender

		var/dep = input("Who do you want to message?", "Fax Message") as null|anything in list("Corporate Liaison", "Combat Information Center", "Chief Military Police", "Brig", "Research", "Warden")
		if(!dep)
			return

		if(dep == "Warden" && SSmapping.config.map_name != MAP_PRISON_STATION)
			if(alert("Are you sure? By default noone will receive this fax unless you spawned the proper fax machine.", "Warning", "Yes", "No") != "Yes")
				return

		var/department = input("Which department do you want to reply as?", "Fax Message") as null|anything in list("TGMC High Command", "TGMC Provost General", "Nanotrasen")
		if(!department)
			return

		var/subject = input("Enter the subject line", "Fax Message", "") as text|null
		if(!subject)
			return

		var/fax_message
		var/type = input("Do you want to use the template or type a custom message?", "Template") as null|anything in list("Template", "Custom")
		if(!type)
			return

		switch(type)
			if("Template")
				var/addressed_to
				var/addressed = input("Address it to the sender or custom?", "Fax Message") as null|anything in list("Sender", "Custom")
				if(!addressed)
					return

				switch(addressed)
					if("Sender")
						addressed_to = "[sender.real_name]"
					if("Custom")
						addressed_to = input("Who is it addressed to?", "Fax Message", "") as text|null
						if(!addressed_to)
							return

				var/message_body = input("Enter Message Body, use <p></p> for paragraphs", "Fax Message", "") as message|null
				if(!message_body)
					return

				var/sent_by = input("Enter the name and rank you are sending from.", "Fax Message", "") as text|null
				if(!sent_by)
					return

				fax_message = generate_templated_fax(department, subject, addressed_to, message_body, sent_by, department)

			if("Custom")
				var/input = input("Please enter a message to send via secure connection.", "Fax Message", "") as message|null
				if(!input)
					return
				fax_message = "[input]"

		if(!fax_message)
			return

		usr << browse(fax_message, "window=faxpreview;size=600x600")

		if(alert("Send this fax?", "Confirmation", "Yes", "No") != "Yes")
			return

		send_fax(usr, null, dep, subject, fax_message, TRUE)

		log_admin("[key_name(usr)] replied to a fax message from [key_name(sender)].")
		message_admins("[ADMIN_TPMONTY(usr)] replied to a fax message from [ADMIN_TPMONTY(sender)].")


	else if(href_list["faxview"])
		if(!check_rights(R_ADMIN|R_MENTOR))
			return

		var/ref = locate(href_list["faxview"])
		if(!ref)
			return
		var/datum/fax/F = GLOB.faxes[ref]
		if(!F)
			return

		var/dat = "<html><head><title>Fax Message: [F.title]</title></head>"
		dat += "<body>[F.message]</body></html>"

		usr << browse(dat, "window=fax")


	else if(href_list["faxcreate"])
		if(!check_rights(R_ADMIN|R_MENTOR))
			return

		var/mob/sender = locate(href_list["faxcreate"])

		var/dep = input("Who do you want to message?", "Fax Message") as null|anything in list("Corporate Liaison", "Combat Information Center", "Chief Military Police", "Brig", "Research", "Warden")
		if(!dep)
			return

		if(dep == "Warden" && SSmapping.config.map_name != MAP_PRISON_STATION)
			if(alert("Are you sure? By default noone will receive this fax unless you spawned the proper fax machine.", "Warning", "Yes", "No") != "Yes")
				return

		var/department = input("Which department do you want to reply AS?", "Fax Message") as null|anything in list("TGMC High Command", "TGMC Provost General", "Nanotrasen")
		if(!department)
			return

		var/subject = input("Enter the subject line", "Fax Message", "") as text|null
		if(!subject)
			return

		var/fax_message
		var/addressed_to
		var/type = input("Do you want to use the template or type a custom message?", "Template") as null|anything in list("Template", "Custom")
		if(!type)
			return

		switch(type)
			if("Template")
				addressed_to = input("Who is it addressed to?", "Fax Message", "") as text|null
				if(!addressed_to)
					return

				var/message_body = input("Enter Message Body, use <p></p> for paragraphs", "Fax Message", "") as message|null
				if(!message_body)
					return

				var/sent_by = input("Enter the name and rank you are sending from.", "Fax Message", "") as text|null
				if(!sent_by)
					return

				fax_message = generate_templated_fax(department, subject, addressed_to, message_body, sent_by, department)

			if("Custom")
				var/input = input("Please enter a message to send via secure connection.", "Fax Message", "") as message|null
				if(!input)
					return
				fax_message = "[input]"

		if(!fax_message)
			return

		usr << browse(fax_message, "window=faxpreview;size=600x600")

		if(alert("Send this fax?", "Confirmation", "Yes", "No") != "Yes")
			return

		send_fax(sender, null, dep, subject, fax_message, TRUE)

		log_admin("[key_name(usr)] created a new fax to: [dep].")
		message_admins("[ADMIN_TPMONTY(usr)] created a new fax to: [dep].")


	else if(href_list["create_object"])
		if(!check_rights(R_SPAWN))
			return
		return usr.client.holder.create_object(usr)


	else if(href_list["quick_create_object"])
		if(!check_rights(R_SPAWN))
			return
		return usr.client.holder.quick_create_object(usr)


	else if(href_list["create_turf"])
		if(!check_rights(R_SPAWN))
			return
		return usr.client.holder.create_turf(usr)


	else if(href_list["create_mob"])
		if(!check_rights(R_SPAWN))
			return
		return usr.client.holder.create_mob(usr)


	else if(href_list["modemenu"])
		if(!check_rights(R_SERVER))
			return

		if(SSticker?.mode)
			return alert("The game has already started.")

		var/dat = {"<B>What mode do you wish to play?</B><HR>"}
		for(var/mode in config.modes)
			dat += {"<A href='?src=[REF(usr.client.holder)];[HrefToken()];changemode=[mode]'>[config.mode_names[mode]]</A><br>"}
		dat += {"Now: [GLOB.master_mode]"}
		usr << browse(dat, "window=c_mode")


	else if(href_list["changemode"])
		if(!check_rights(R_SERVER))
			return

		if(SSticker?.mode)
			return alert("The game has already started.")

		GLOB.master_mode = href_list["changemode"]

		log_admin("[key_name(usr)] set the mode as [GLOB.master_mode].")
		message_admins("[ADMIN_TPMONTY(usr)] set the mode as [GLOB.master_mode].")
		to_chat(world, "<span class='boldnotice'>The mode is now: [GLOB.master_mode].</span>")
		world.save_mode(GLOB.master_mode)


	if(href_list["evac_authority"])
		if(!check_rights(R_ADMIN))
			return

		switch(href_list["evac_authority"])
			if("init_evac")
				if(!EvacuationAuthority.initiate_evacuation())
					to_chat(usr, "<span class='warning'>You are unable to initiate an evacuation right now!</span>")
				else
					log_admin("[key_name(usr)] called an evacuation.")
					message_admins("[ADMIN_TPMONTY(usr)] called an evacuation.")

			if("cancel_evac")
				if(!EvacuationAuthority.cancel_evacuation())
					to_chat(usr, "<span class='warning'>You are unable to cancel an evacuation right now!</span>")
				else
					log_admin("[key_name(usr)] canceled an evacuation.")
					message_admins("[ADMIN_TPMONTY(usr)] canceled an evacuation.")

			if("toggle_evac")
				EvacuationAuthority.flags_scuttle ^= FLAGS_EVACUATION_DENY
				log_admin("[key_name(src)] has [EvacuationAuthority.flags_scuttle & FLAGS_EVACUATION_DENY ? "forbidden" : "allowed"] ship-wide evacuation.")
				message_admins("[ADMIN_TPMONTY(usr)] has [EvacuationAuthority.flags_scuttle & FLAGS_EVACUATION_DENY ? "forbidden" : "allowed"] ship-wide evacuation.")

			if("force_evac")
				if(!EvacuationAuthority.begin_launch())
					to_chat(usr, "<span class='warning'>You are unable to launch the pods directly right now!</span>")
				else
					log_admin("[key_name(usr)] force-launched the escape pods.")
					message_admins("[ADMIN_TPMONTY(usr)] force-launched the escape pods.")

			if("init_dest")
				if(!EvacuationAuthority.enable_self_destruct())
					to_chat(usr, "<span class='warning'>You are unable to authorize the self-destruct right now!</span>")
				else
					log_admin("[key_name(usr)] force-enabled the self-destruct system.")
					message_admins("[ADMIN_TPMONTY(usr)] force-enabled the self-destruct system.")

			if("cancel_dest")
				if(!EvacuationAuthority.cancel_self_destruct(TRUE))
					to_chat(usr, "<span class='warning'>You are unable to cancel the self-destruct right now!</span>")
				else
					log_admin("[key_name(usr)] canceled the self-destruct system.")
					message_admins("[ADMIN_TPMONTY(usr)] canceled the self-destruct system.")

			if("use_dest")
				if(alert("Are you sure you want to destroy the [MAIN_SHIP_NAME] right now?", "Self-Destruct", "Yes", "No") != "Yes")
					return

				if(!EvacuationAuthority.initiate_self_destruct(TRUE))
					to_chat(usr, "<span class='warning'>You are unable to trigger the self-destruct right now!</span>")
					return

				log_admin("[key_name(usr)] forced the self-destruct system, destroying the [MAIN_SHIP_NAME].")
				message_admins("[ADMIN_TPMONTY(usr)] forced the self-destrust system, destroying the [MAIN_SHIP_NAME].")

			if("toggle_dest")
				EvacuationAuthority.flags_scuttle ^= FLAGS_SELF_DESTRUCT_DENY
				log_admin("[key_name(src)] has [EvacuationAuthority.flags_scuttle & FLAGS_SELF_DESTRUCT_DENY ? "forbidden" : "allowed"] the self-destruct system.")
				message_admins("[ADMIN_TPMONTY(usr)] has [EvacuationAuthority.flags_scuttle & FLAGS_SELF_DESTRUCT_DENY ? "forbidden" : "allowed"] the self-destruct system.")


	else if(href_list["object_list"])
		if(!check_rights(R_SPAWN))
			return

		var/atom/loc = usr.loc

		var/dirty_paths
		if(istext(href_list["object_list"]))
			dirty_paths = list(href_list["object_list"])
		else if(istype(href_list["object_list"], /list))
			dirty_paths = href_list["object_list"]

		var/paths = list()

		for(var/dirty_path in dirty_paths)
			var/path = text2path(dirty_path)
			if(!path)
				continue
			else if(!ispath(path, /obj) && !ispath(path, /turf) && !ispath(path, /mob))
				continue
			paths += path

		if(!paths)
			alert("The path list you sent is empty.")
			return
		if(length(paths) > 5)
			alert("Select fewer object types, (max 5).")
			return

		var/list/offset = splittext(href_list["offset"],",")
		var/number = CLAMP(text2num(href_list["object_count"]), 1, 100)
		var/X = offset.len > 0 ? text2num(offset[1]) : 0
		var/Y = offset.len > 1 ? text2num(offset[2]) : 0
		var/Z = offset.len > 2 ? text2num(offset[3]) : 0
		var/obj_dir = text2num(href_list["object_dir"])
		if(obj_dir && !(obj_dir in list(1,2,4,8,5,6,9,10)))
			obj_dir = null
		var/obj_name = sanitize(href_list["object_name"])


		var/atom/target
		var/where = href_list["object_where"]
		if(!( where in list("onfloor","frompod","inhand","inmarked")))
			where = "onfloor"


		switch(where)
			if("inhand")
				if(!iscarbon(usr))
					to_chat(usr, "Can only spawn in hand when you're a carbon mob or cyborg.")
					where = "onfloor"
				target = usr

			if("onfloor", "frompod")
				switch(href_list["offset_type"])
					if("absolute")
						target = locate(0 + X,0 + Y,0 + Z)
					if("relative")
						target = locate(loc.x + X,loc.y + Y,loc.z + Z)
			if("inmarked")
				if(!marked_datum)
					to_chat(usr, "You don't have any object marked. Abandoning spawn.")
					return
				else if(!istype(marked_datum, /atom))
					to_chat(usr, "The object you have marked cannot be used as a target. Target must be of type /atom. Abandoning spawn.")
					return
				else
					target = marked_datum

		if(target)
			for(var/path in paths)
				for (var/i = 0; i < number; i++)
					if(path in typesof(/turf))
						var/turf/O = target
						var/turf/N = O.ChangeTurf(path)
						if(N && obj_name)
							N.name = obj_name
					else
						var/atom/O
						O = new path(target)

						if(!QDELETED(O))
							if(obj_dir)
								O.setDir(obj_dir)
							if(obj_name)
								O.name = obj_name
								if(ismob(O))
									var/mob/M = O
									M.real_name = obj_name
							if(where == "inhand" && isliving(usr) && isitem(O))
								var/mob/living/L = usr
								var/obj/item/I = O
								L.put_in_hands(I)


		if(number == 1)
			log_admin("[key_name(usr)] created a [english_list(paths)].")
			for(var/path in paths)
				if(ispath(path, /mob))
					message_admins("[ADMIN_TPMONTY(usr)] created a [english_list(paths)].")
					break
		else
			log_admin("[key_name(usr)] created [number]ea [english_list(paths)].")
			for(var/path in paths)
				if(ispath(path, /mob))
					message_admins("[ADMIN_TPMONTY(usr)] created [number]ea [english_list(paths)].")
					break


	else if(href_list["admin_log"])
		if(!check_rights(R_ASAY))
			return

		var/dat = "<html><head><title>Admin Log</title></head><body>"

		for(var/x in GLOB.admin_log)
			dat += "[x]<br>"

		dat += "</body></html>"

		usr << browse(dat, "window=adminlog")


	else if(href_list["ffattack_log"])
		if(!check_rights(R_ADMIN))
			return

		var/dat = "<html><head><title>FF Attack Log</title></head><body>"

		for(var/x in GLOB.ffattack_log)
			dat += "[x]<br>"

		dat += "</body></html>"

		usr << browse(dat, "window=ffattack_log")


	else if(href_list["explosion_log"])
		if(!check_rights(R_ADMIN))
			return

		var/dat = "<html><head><title>Explosion Log</title></head><body>"

		for(var/x in GLOB.explosion_log)
			dat += "[x]<br>"

		dat += "</body></html>"

		usr << browse(dat, "window=explosion_log")


	else if(href_list["outfit_name"])
		if(!check_rights(R_FUN))
			return

		var/datum/outfit/O = new /datum/outfit
		O.name = href_list["outfit_name"]
		O.w_uniform = text2path(href_list["outfit_uniform"])
		O.shoes = text2path(href_list["outfit_shoes"])
		O.gloves = text2path(href_list["outfit_gloves"])
		O.wear_suit = text2path(href_list["outfit_suit"])
		O.head = text2path(href_list["outfit_head"])
		O.back = text2path(href_list["outfit_back"])
		O.mask = text2path(href_list["outfit_mask"])
		O.glasses = text2path(href_list["outfit_glasses"])
		O.r_hand = text2path(href_list["outfit_r_hand"])
		O.l_hand = text2path(href_list["outfit_l_hand"])
		O.suit_store = text2path(href_list["outfit_s_store"])
		O.l_store = text2path(href_list["outfit_l_pocket"])
		O.r_store = text2path(href_list["outfit_r_pocket"])
		O.id = text2path(href_list["outfit_id"])
		O.belt = text2path(href_list["outfit_belt"])
		O.ears = text2path(href_list["outfit_ears"])

		GLOB.custom_outfits.Add(O)
		log_admin("[key_name(usr)] created outfit named '[O.name]'.")
		message_admins("[ADMIN_TPMONTY(usr)] created outfit named '[O.name]'.")