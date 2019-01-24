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
			if(MALE,FEMALE)
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
		player_panel()


	else if(href_list["subtlemessage"])
		var/mob/M = locate(href_list["subtlemessage"])
		subtle_message(M)


	else if(href_list["individuallog"])
		var/mob/M = locate(href_list["individuallog"]) in GLOB.mob_list
		show_individual_logging_panel(M, href_list["log_src"], href_list["log_type"])


	else if(href_list["observecoodjump"])
		if(!check_rights(R_ADMIN))
			return

		var/x = text2num(href_list["X"])
		var/y = text2num(href_list["Y"])
		var/z = text2num(href_list["Z"])

		if(!isobserver(usr))
			admin_ghost()

		jump_coord(x,y,z)


	else if(href_list["observefollow"])
		if(!check_rights(R_ADMIN))
			return

		var/atom/movable/AM = locate(href_list["observefollow"])

		if(!isobserver(usr))
			admin_ghost()

		var/mob/dead/observer/A = usr
		A.ManualFollow(AM)


	else if(href_list["secrets"])
		switch(href_list["secretsfun"])
			if("blackout")
				lightsout(0, 0)
				log_admin("[key_name(usr)] broke all lights.")
				message_admins("[ADMIN_TPMONTY(usr)] broke all lights.")
			if("whiteout")
				for(var/obj/machinery/light/L in machines)
					L.fix()
				log_admin("[key_name(usr)] fixed all lights.")
				message_admins("[ADMIN_TPMONTY(usr)] fixed all lights.")
			if("power")
				power_restore()
				log_admin("[key_name(usr)] powered all SMESs and APCs")
				message_admins("[ADMIN_TPMONTY(usr)] powered all SMESs and APCs.")
			if("unpower")
				power_failure()
				log_admin("[key_name(usr)] unpowered all SMESs and APCs.")
				message_admins("[ADMIN_TPMONTY(usr)] unpowered all SMESs and APCs.")
			if("quickpower")
				power_restore_quick()
				log_admin("[key_name(usr)] powered all SMESs.")
				message_admins("[ADMIN_TPMONTY(usr)] powered all SMESs.")
			if("powereverything")
				power_restore_everything()
				log_admin("[key_name(usr)] powered all SMESs and APCs everywhere.")
				message_admins("[ADMIN_TPMONTY(usr)] powered all SMESs and APCs everywhere.")
			if("gethumans")
				get_all_humans()
				log_admin("[key_name(usr)] mass-teleported all humans.")
				message_admins("[ADMIN_TPMONTY(usr)] mass-teleported all humans.")
			if("getxenos")
				get_all_xenos()
				log_admin("[key_name(usr)] mass-teleported all Xenos.")
				message_admins("[ADMIN_TPMONTY(usr)] mass-teleported all Xenos.")
			if("getall")
				get_all()
				log_admin("[key_name(usr)] mass-teleported everyone.")
				message_admins("[ADMIN_TPMONTY(usr)] mass-teleported everyone.")
			if("rejuvall")
				rejuv_all()
				log_admin("[key_name(usr)] mass-rejuvenated everyone.")
				message_admins("[ADMIN_TPMONTY(usr)] mass-rejuvenated everyone.")