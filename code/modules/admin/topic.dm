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

	if(usr.client != src.owner || !check_rights(0))
		log_admin("[key_name(usr)] tried to use the admin panel without authorization.")
		message_admins("[ADMIN_TPMONTY(usr)] has attempted to override the admin panel!")
		return

	if(!CheckAdminHref(href, href_list))
		return


	if(href_list["ahelp"])
		if(!check_rights(R_ADMIN))
			return

		var/ahelp_ref = href_list["ahelp"]
		var/datum/admin_help/AH = locate(ahelp_ref)
		if(AH)
			AH.Action(href_list["ahelp_action"])
		else
			to_chat(usr, "<span class='warning'>Ticket [ahelp_ref] has been deleted!</span>")


	else if(href_list["ahelp_tickets"])
		if(!check_rights(R_ADMIN))
			return

		GLOB.ahelp_tickets.BrowseTickets(text2num(href_list["ahelp_tickets"]))


	else if(href_list["moreinfo"])
		if(!check_rights(R_ADMIN))
			return

		var/mob/M = locate(href_list["moreinfo"]) in mob_list

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
		if(M.mind)
			special_role_description = "Role: <b>[M.mind.assigned_role]</b>; Antagonist: <font color='red'><b>[M.mind.special_role]</b></font>"
		else
			special_role_description = "Role: <i>Mind datum missing</i> Antagonist: <i>Mind datum missing</i>"

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
		to_chat(usr, ADMIN_FULLMONTY_NONAME(M))


	else if(href_list["playerpanel"])
		var/mob/M = locate(href_list["playerpanel"])
		show_player_panel(M)


	else if(href_list["subtlemessage"])
		var/mob/M = locate(href_list["subtlemessage"])
		subtle_message(M)


	else if(href_list["individuallog"])
		var/mob/M = locate(href_list["individuallog"])
		show_individual_logging_panel(M, href_list["log_src"], href_list["log_type"])


	else if(href_list["observecoodjump"])
		var/x = text2num(href_list["X"])
		var/y = text2num(href_list["Y"])
		var/z = text2num(href_list["Z"])

		if(!isobserver(usr))
			usr.client.holder.admin_ghost()

		usr.client.holder.jump_coord(x,y,z)


	else if(href_list["observefollow"])
		var/atom/movable/AM = locate(href_list["observefollow"])

		if(!isobserver(usr))
			admin_ghost()

		var/mob/dead/observer/A = usr
		A.ManualFollow(AM)


	else if(href_list["secrets"])
		switch(href_list["secrets"])
			if("blackout")
				log_admin("[key_name(usr)] broke all lights.")
				message_admins("[ADMIN_TPMONTY(usr)] broke all lights.")
				lightsout(0, 0)
			if("whiteout")
				log_admin("[key_name(usr)] fixed all lights.")
				message_admins("[ADMIN_TPMONTY(usr)] fixed all lights.")
				for(var/obj/machinery/light/L in machines)
					L.fix()
			if("power")
				log_admin("[key_name(usr)] powered all SMESs and APCs")
				message_admins("[ADMIN_TPMONTY(usr)] powered all SMESs and APCs.")
				power_restore()
			if("unpower")
				log_admin("[key_name(usr)] unpowered all SMESs and APCs.")
				message_admins("[ADMIN_TPMONTY(usr)] unpowered all SMESs and APCs.")
				power_failure()
			if("quickpower")
				log_admin("[key_name(usr)] powered all SMESs.")
				message_admins("[ADMIN_TPMONTY(usr)] powered all SMESs.")
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
				log_admin("[key_name(usr)] mass-rejuvenated everyone.")
				message_admins("[ADMIN_TPMONTY(usr)] mass-rejuvenated everyone.")
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
		notes_add(mob_key, "Banned by [usr.client.ckey] | Duration: [mins] minutes | Reason: [sanitize(reason)]", usr)
		message_admins("[ADMIN_TPMONTY(usr)] has banned [ADMIN_TPMONTY(M)] | Duration: [mins] minutes| Reason: [sanitize(reason)]")


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
		var/index = text2num(href_list["remove_index"])

		notes_hide(key, index)
		player_notes_show(key)


	else if(href_list["notes_unhide"])
		if(!check_rights(R_BAN))
			return

		var/key = href_list["notes_unhide"]
		var/index = text2num(href_list["remove_index"])

		notes_unhide(key, index)
		player_notes_show(key)


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

		jobban_panel(M)


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

		if(!RoleAuthority)
			return

		var/list/joblist = list()
		switch(href_list["jobban"])
			if("commanddept")
				for(var/jobPos in ROLES_COMMAND)
					if(!jobPos)
						continue
					var/datum/job/temp = RoleAuthority.roles_by_name[jobPos]
					if(!temp)
						continue
					joblist += temp.title
			if("policedept")
				for(var/jobPos in ROLES_POLICE)
					if(!jobPos)
						continue
					var/datum/job/temp = RoleAuthority.roles_by_name[jobPos]
					if(!temp)
						continue
					joblist += temp.title
			if("engineeringdept")
				for(var/jobPos in ROLES_ENGINEERING)
					if(!jobPos)
						continue
					var/datum/job/temp = RoleAuthority.roles_by_name[jobPos]
					if(!temp)
						continue
					joblist += temp.title
			if("cargodept")
				for(var/jobPos in ROLES_REQUISITION)
					if(!jobPos)
						continue
					var/datum/job/temp = RoleAuthority.roles_by_name[jobPos]
					if(!temp)
						continue
					joblist += temp.title
			if("medicaldept")
				for(var/jobPos in ROLES_MEDICAL)
					if(!jobPos)
						continue
					var/datum/job/temp = RoleAuthority.roles_by_name[jobPos]
					if(!temp)
						continue
					joblist += temp.title
			if("marinedept")
				for(var/jobPos in ROLES_MARINES)
					if(!jobPos)
						continue
					var/datum/job/temp = RoleAuthority.roles_by_name[jobPos]
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
					log_admin_private("[key_name(usr)] jobbanned [key_name(M)] from [job] for [reason].")
					jobban_fullban(M, job, "[reason]; By [usr.client.ckey] on [time2text(world.realtime)]")
					if(!msg)
						msg = job
					else
						msg += ", [job]"
				notes_add(M.ckey, "Banned  from [msg] - [reason]", usr)
				message_admins("[ADMIN_TPMONTY(usr)] banned [ADMIN_TPMONTY(M)] from [msg] for [reason].")
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

		mute(M, mute_type)



	else if(href_list["transform"])
		if(!check_rights(R_ADMIN))
			return

		var/mob/M = locate(href_list["mob"])

		if(!ismob(M) || M.gc_destroyed)
			return

		var/delmob = FALSE
		switch(alert("Delete old mob?","Message","Yes","No","Cancel"))
			if("Cancel")
				return
			if("Yes")
				delmob = TRUE

		var/turf/location
		switch(alert("Teleport to your location?","Message","Yes","No","Cancel"))
			if("Cancel")
				return
			if("Yes")
				location = get_turf(usr)

		log_admin("[key_name(usr)] has transformed [key_name(M)] into [href_list["transform"]].[delmob ? " Old mob deleted." : ""][location ? " Teleported to [AREACOORD(location)]" : ""]")
		message_admins("[ADMIN_TPMONTY(usr)] has transformed [ADMIN_TPMONTY(M)] into [href_list["transform"]].[delmob ? " Old mob deleted." : ""][location ? " Teleported to new location." : ""]")

		switch(href_list["transform"])
			if("observer")
				M.change_mob_type(/mob/dead/observer, location, null, delmob)
			if("larva")
				M.change_mob_type(/mob/living/carbon/Xenomorph/Larva, location, null, delmob)
			if("defender")
				M.change_mob_type(/mob/living/carbon/Xenomorph/Defender, location, null, delmob)
			if("warrior")
				M.change_mob_type(/mob/living/carbon/Xenomorph/Warrior, location, null, delmob)
			if("runner")
				M.change_mob_type(/mob/living/carbon/Xenomorph/Runner, location, null, delmob)
			if("drone")
				M.change_mob_type(/mob/living/carbon/Xenomorph/Drone, location, null, delmob)
			if("sentinel")
				M.change_mob_type(/mob/living/carbon/Xenomorph/Sentinel, location, null, delmob)
			if("hunter")
				M.change_mob_type(/mob/living/carbon/Xenomorph/Hunter, location, null, delmob)
			if("carrier")
				M.change_mob_type(/mob/living/carbon/Xenomorph/Carrier, location, null, delmob)
			if("hivelord")
				M.change_mob_type(/mob/living/carbon/Xenomorph/Hivelord, location, null, delmob)
			if("praetorian")
				M.change_mob_type(/mob/living/carbon/Xenomorph/Praetorian, location, null, delmob)
			if("ravager")
				M.change_mob_type(/mob/living/carbon/Xenomorph/Ravager, location, null, delmob)
			if("spitter")
				M.change_mob_type(/mob/living/carbon/Xenomorph/Spitter, location, null, delmob)
			if("boiler")
				M.change_mob_type(/mob/living/carbon/Xenomorph/Boiler, location, null, delmob)
			if("crusher")
				M.change_mob_type(/mob/living/carbon/Xenomorph/Crusher, location, null, delmob)
			if("defiler")
				M.change_mob_type(/mob/living/carbon/Xenomorph/Defiler, location, null, delmob)
			if("queen")
				M.change_mob_type(/mob/living/carbon/Xenomorph/Queen, location, null, delmob)
			if("human")
				M.change_mob_type(/mob/living/carbon/human, location, null, delmob,)
			if("monkey")
				M.change_mob_type(/mob/living/carbon/monkey, location, null, delmob,)


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
			var/turf/T = get_turf(H)
			if(H.put_in_hands(new /obj/item/reagent_container/food/snacks/cookie(M)))
				H.update_inv_r_hand()
				H.update_inv_l_hand()
			else
				new /obj/item/reagent_container/food/snacks/cookie(T)
		else
			var/turf/T = get_turf(M)
			new /obj/item/reagent_container/food/snacks/cookie(T)

		to_chat(M, "<span class='boldnotice'>Your prayers have been answered!! You received the best cookie!</span>")

		log_admin("[key_name(M)] got their cookie, spawned by [key_name(usr)]")
		message_admins("[ADMIN_TPMONTY(M)] got their cookie, spawned by [ADMIN_TPMONTY(usr)].")


	else if(href_list["reply"])
		var/mob/living/carbon/human/H = locate(href_list["reply"])

		if(!istype(H))
			return

		var/input = input("Please enter a message to reply to [key_name(H)].", "Outgoing message from TGMC", "")
		if(!input)
			return

		to_chat(H, "<span class='boldnotice'>Please stand by for a message from TGMC:[input]</span>")

		log_admin("[ADMIN_TPMONTY(usr)] replied to [ADMIN_TPMONTY(H)]'s TGMC message with: [input].")
		message_admins("[ADMIN_TPMONTY(usr)] replied to [ADMIN_TPMONTY(H)]'s' TGMC message with: [input]")


	if(href_list["deny"])
		var/mob/M = locate(href_list["deny"])
		distress_cancel = TRUE
		command_announcement.Announce("The distress signal has been blocked, the launch tubes are now recalibrating.", "Distress Beacon")
		log_game("[key_name(usr)] has denied a distress beacon, requested by [key_name(M)]")
		message_admins("[ADMIN_TPMONTY(usr)] has denied a distress beacon, requested by [ADMIN_TPMONTY(M)]")


	if(href_list["distress"])
		var/mob/M = locate(href_list["distress"])

		if(ticker?.mode?.waiting_for_candidates)
			return

		ticker.mode.activate_distress()

		log_game("[key_name(usr)] has sent a randomized distress beacon early, requested by [key_name(M)]")
		message_admins("[ADMIN_TPMONTY(usr)] has sent a randomized distress beacon early, requested by [ADMIN_TPMONTY(M)]")