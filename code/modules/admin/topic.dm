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
				lightsout(0, 0)
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
			if("moth")
				M.change_mob_type(/mob/living/carbon/human, location, null, delmob, "Moth")

		log_admin("[key_name(usr)] has transformed [key_name(M)] into [href_list["transform"]].[delmob ? " Old mob deleted." : ""][location ? " Teleported to [AREACOORD(location)]" : ""]")
		message_admins("[ADMIN_TPMONTY(usr)] has transformed [ADMIN_TPMONTY(M)] into [href_list["transform"]].[delmob ? " Old mob deleted." : ""][location ? " Teleported to new location." : ""]")


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
			to_chat(M, "<span class='tip'>[pick(xenotips)]</span>")

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

		if(!ticker?.mode || ticker.mode.waiting_for_candidates)
			return

		ticker.mode.activate_distress()

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
			return

		if(!M.client)
			to_chat(usr, "<span class='warning'>[M] doesn't seem to have an active client.</span>")
			return

		if(alert("Send [key_name(M)] back to Lobby?", "Confirmation", "Yes", "No") != "Yes")
			return

		log_admin("[key_name(usr)] has sent [key_name(M)] back to the lobby.")
		message_admins("[ADMIN_TPMONTY(usr)] has sent [key_name_admin(M)] back to the lobby.")

		var/mob/new_player/NP = new()
		NP.key = M.key
		if(NP.client)
			NP.client.change_view(world.view)
		if(isobserver(M))
			qdel(M)
		else
			M.ghostize()

	else if(href_list["jumpto"])
		if(!check_rights(R_ADMIN))
			return

		var/mob/M = locate(href_list["jumpto"])
		if(!istype(M))
			return

		usr.forceMove(M.loc)

		log_admin("[key_name(usr)] has jumped to [key_name(M)].")
		message_admins("[ADMIN_TPMONTY(usr)] has jumped to [ADMIN_TPMONTY(M)].")


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

		switch(input("To an area or to a mob?", "Send Mob", null, null) as null|anything in list("Area", "Mob"))
			if("Area")
				var/area/A = input("Pick an area.", "Pick an area") as null|anything in return_sorted_areas()
				if(!A || !M)
					return
				target = pick(get_area_turfs(A))
			if("Mob")
				var/mob/N = input("Pick an area.", "Pick an area") as null|anything in sortmobs(GLOB.mob_list)
				if(!N || !M)
					return
				target = N.loc

		M.on_mob_jump()
		M.forceMove(target)

		log_admin("[key_name(usr)] has sent [key_name(M)]'s mob to [target].")
		message_admins("[ADMIN_TPMONTY(usr)] has sent [ADMIN_TPMONTY(M)]'s mob to [target].")



	else if(href_list["faxreply"])
		var/mob/living/carbon/human/H = locate(href_list["faxreply"])
		var/obj/machinery/faxmachine/fax = locate(href_list["originfax"])

		var/template_choice = input("Which template do you want to use?") in list("TGMC High Command", "TGMC Provost General", "Corporate Liaison", "Custom")
		var/fax_message = ""
		switch(template_choice)
			if("Custom")
				var/input = input("Please enter a message to reply to [key_name(H)] via secure connection.", "Outgoing message", "") as text|null
				if(!input)
					return
				fax_message = "[input]"

			if("TGMC High Command", "TGMC Provost General")
				var/subject = input("Enter subject line", "Outgoing message", "") as text|null
				if(!subject)
					return
				var/addressed_to = ""
				var/address_option = input("Address it to the sender or custom?") in list("Sender", "Custom")
				if(address_option == "Sender")
					addressed_to = "[H.real_name]"
				else if(address_option == "Custom")
					addressed_to = input("Who is it addressed to?", "Outgoing message", "") as text|null
					if(!addressed_to)
						return
				else
					return
				var/message_body = input("Enter Message Body, use <p></p> for paragraphs", "Outgoing message", "") as message|null
				if(!message_body)
					return
				var/sent_by = input("Enter the name and rank you are sending from.", "Outgoing message from USCM", "") as text|null
				if(!sent_by)
					return

				var/sent_title = template_choice


				fax_message = generate_templated_fax(FALSE, "TGMC CENTRAL COMMAND", subject, addressed_to, message_body, sent_by, sent_title, "TerraGov Marine Corps")


				usr << browse(fax_message, "window=tgmcfaxpreview;size=600x600")

				if(alert("Send this fax?", "Confirmation", "Yes", "No") != "Yes")
					return

				fax_contents += fax_message


			if("Corporate Liaison")
				var/subject = input("Enter subject line", "Outgoing message", "") as text|null
				if(!subject)
					return
				var/addressed_to = ""
				var/address_option = input("Address it to the sender or custom?") in list("Sender", "Custom")
				if(address_option == "Sender")
					addressed_to = "[H.real_name]"
				else if(address_option == "Custom")
					addressed_to = input("Who do you want to address it to?", "Outgoing message", "") as text|null
					if(!addressed_to)
						return
				else
					return
				var/message_body = input("Enter Message Body, use <p></p> for paragraphs", "Outgoing message", "") as message|null
				if(!message_body)
					return
				var/sent_by = input("Enter the name you are sending this from", "Outgoing message", "") as text|null
				if(!sent_by)
					return

				fax_message = generate_templated_fax(TRUE, "NANOTRASEN CORPORATE AFFAIRS - TGS THESEUS", subject, addressed_to, message_body, sent_by, "Corporate Affairs Director", "Nanotrasen")

				usr << browse(fax_message, "window=clfaxpreview;size=600x600")

				if(alert("Send this fax?", "Confirmation", "Yes", "No") != "Yes")
					return

				fax_contents += fax_message

		var/customname = input("Pick a title for the report", "Title") as text|null

		for(var/obj/machinery/faxmachine/F in GLOB.machines)
			if(F == fax)
				if(!(F.stat & (BROKEN|NOPOWER)))
					flick("faxreceive", F)

					spawn(20)
						var/obj/item/paper/P = new /obj/item/paper( F.loc )
						P.name = "USCM High Command - [customname]"
						P.info = fax_message
						P.update_icon()

						playsound(F.loc, "sound/machines/fax.ogg", 15)

						var/image/stampoverlay = image('icons/obj/items/paper.dmi')
						stampoverlay.icon_state = "paper_stamp-uscm"
						if(!P.stamped)
							P.stamped = new
						P.stamped += /obj/item/tool/stamp
						P.overlays += stampoverlay
						P.stamps += "<HR><i>This paper has been stamped by the High Command Quantum Relay.</i>"

				log_admin("[key_name(usr)] replied to a fax message from [key_name(H)]: [fax_message]")
				message_admins("[ADMIN_TPMONTY(usr)] replied to a fax message from [ADMIN_TPMONTY(H)].")


	else if(href_list["faxview"])
		var/info = locate(href_list["faxview"])

		usr << browse("<HTML><HEAD><TITLE>Fax Message</TITLE></HEAD><BODY>[info]</BODY></HTML>", "window=Fax Message")


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

		if(ticker && ticker.mode)
			return alert("The game has already started.")

		var/dat = {"<B>What mode do you wish to play?</B><HR>"}
		for(var/mode in config.modes)
			dat += {"<A href='?src=[REF(usr.client.holder)];[HrefToken()];changemode=[mode]'>[config.mode_names[mode]]</A><br>"}
		dat += {"Now: [master_mode]"}
		usr << browse(dat, "window=c_mode")


	else if(href_list["changemode"])
		if(!check_rights(R_SERVER))
			return

		if(ticker?.mode)
			return alert("The game has already started.")

		master_mode = href_list["changemode"]

		log_admin("[key_name(usr)] set the mode as [master_mode].")
		message_admins("[ADMIN_TPMONTY(usr)] set the mode as [master_mode].")
		to_chat(world, "<span class='boldnotice'>The mode is now: [master_mode].</span>")
		world.save_mode(master_mode)


	if(href_list["evac_authority"])
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
				var/confirm = alert("Are you sure you want to self-destruct the Almayer?", "Self-Destruct", "Yes", "Cancel")
				if(confirm != "Yes")
					return

				if(alert("Are you sure you want to destroy the Almayer right now?",, "Yes", "No") != "Yes")
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
