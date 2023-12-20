/datum/admins/proc/CheckAdminHref(href, href_list)
	var/auth = href_list["admin_token"]
	. = auth && (auth == href_token || auth == GLOB.href_token)
	if(.)
		return
	var/msg = !auth ? "no" : "a bad"
	log_admin_private("[key_name(usr)] clicked an href with [msg] authorization key! [href]")
	message_admins("[ADMIN_TPMONTY(usr)] clicked an href with [msg] authorization key.")


/datum/admins/can_interact(mob/user)
	if(user.client != owner || !check_rights(NONE))
		log_admin("[key_name(user)] tried to use the admin panel without authorization.")
		message_admins("[ADMIN_TPMONTY(user)] tried to use the admin panel without authorization.")
		return FALSE

	return TRUE


/datum/admins/Topic(href, href_list)
	. = ..()
	if(.)
		return

	if(!CheckAdminHref(href, href_list))
		return

	if(href_list["ahelp"])
		var/ahelp_ref = href_list["ahelp"]
		var/datum/admin_help/AH = locate(ahelp_ref)
		if(!AH)
			to_chat(usr, span_warning("Ticket [ahelp_ref] has been deleted!"))
			return

		AH.Action(href_list["ahelp_action"])


	else if(href_list["ahelp_tickets"])
		GLOB.ahelp_tickets.BrowseTickets(text2num(href_list["ahelp_tickets"]))


	else if(href_list["moreinfo"])
		if(!check_rights(R_ADMIN))
			return

		var/mob/M = locate(href_list["moreinfo"]) in GLOB.mob_list

		if(!istype(M))
			return

		var/status
		var/health
		var/datum/job/job

		if(isliving(M))
			var/mob/living/L = M
			job = L.job
			switch(L.stat)
				if(CONSCIOUS)
					status = "Alive"
				if(UNCONSCIOUS)
					status = "Unconscious"
				if(DEAD)
					status = "Dead"
			health = "Oxy: [L.getOxyLoss()]  Tox: [L.getToxLoss()]  Fire: [L.getFireLoss()]  Brute: [L.getBruteLoss()]  Clone: [L.getCloneLoss()]  Brain: [L.getBrainLoss()]  Stamina: [L.getStaminaLoss()]"

		to_chat(usr, {"<span class='notice'><hr><b>Info about [M.real_name]:</b>
Type: [M.type] | Gender: [M.gender] |[job ? " Job: [job.title]" : ""]
Location: [AREACOORD(M.loc)]
Status: [status ? status : "Unknown"] | Damage: [health ? health : "None"]
[span_admin("<span class='message'>[ADMIN_FULLMONTY(M)]")]</span><hr></span>"})


	else if(href_list["playerpanel"])
		if(!check_rights(R_ADMIN))
			return
		var/mob/M = locate(href_list["playerpanel"])
		show_player_panel(M)

	else if(href_list["showrelatedacc"])
		if(!check_rights(R_ADMIN))
			return
		var/client/C = locate(href_list["client"]) in GLOB.clients
		var/thing_to_check
		if(href_list["showrelatedacc"] == "cid")
			thing_to_check = C.related_accounts_cid
		else
			thing_to_check = C.related_accounts_ip
		thing_to_check = splittext(thing_to_check, ", ")


		var/list/dat = list("Related accounts by [uppertext(href_list["showrelatedacc"])]:")
		dat += thing_to_check

		usr << browse(dat.Join("<br>"), "window=related_[C];size=420x300")

	else if(href_list["centcomlookup"])
		if(!check_rights(R_ADMIN))
			return

		if(!CONFIG_GET(string/centcom_ban_db))
			to_chat(usr, span_warning("Centcom Galactic Ban DB is disabled!"))
			return

		var/ckey = href_list["centcomlookup"]

		// Make the request
		var/datum/http_request/request = new()
		request.prepare(RUSTG_HTTP_METHOD_GET, "[CONFIG_GET(string/centcom_ban_db)]/[ckey]", "", "")
		request.begin_async()
		UNTIL(request.is_complete() || !usr)
		if (!usr)
			return
		var/datum/http_response/response = request.into_response()

		var/list/bans

		var/list/dat = list("<meta http-equiv='Content-Type' content='text/html; charset=UTF-8'><body>")

		if(response.errored)
			dat += "<br>Failed to connect to CentCom."
		else if(response.status_code != 200)
			dat += "<br>Failed to connect to CentCom. Status code: [response.status_code]"
		else
			if(response.body == "[]")
				dat += "<center><b>0 bans detected for [ckey]</b></center>"
			else
				bans = json_decode(response["body"])
				dat += "<center><b>[length(bans)] ban\s detected for [ckey]</b></center>"
				for(var/list/ban in bans)
					dat += "<b>Server: </b> [sanitize(ban["sourceName"])]<br>"
					dat += "<b>RP Level: </b> [sanitize(ban["sourceRoleplayLevel"])]<br>"
					dat += "<b>Type: </b> [sanitize(ban["type"])]<br>"
					dat += "<b>Banned By: </b> [sanitize(ban["bannedBy"])]<br>"
					dat += "<b>Reason: </b> [sanitize(ban["reason"])]<br>"
					dat += "<b>Datetime: </b> [sanitize(ban["bannedOn"])]<br>"
					var/expiration = ban["expires"]
					dat += "<b>Expires: </b> [expiration ? "[sanitize(expiration)]" : "Permanent"]<br>"
					if(ban["type"] == "job")
						dat += "<b>Jobs: </b> "
						var/list/jobs = ban["jobs"]
						dat += sanitize(jobs.Join(", "))
						dat += "<br>"
					dat += "<hr>"

		dat += "<br></body>"
		var/datum/browser/popup = new(usr, "centcomlookup-[ckey]", "<div align='center'>Central Command Galactic Ban Database</div>", 700, 600)
		popup.set_content(dat.Join())
		popup.open(0)


	else if(href_list["subtlemessage"])
		var/mob/M = locate(href_list["subtlemessage"])
		subtle_message(M)

	else if(href_list["imginaryfriend"])
		var/mob/M = locate(href_list["imginaryfriend"])
		create_ifriend(M, TRUE)

	else if(href_list["individuallog"])
		if(!check_rights(R_ADMIN))
			return
		var/mob/M = locate(href_list["individuallog"])
		show_individual_logging_panel(M, href_list["log_src"], href_list["log_type"])


	else if(href_list["observecoordjump"])
		var/x = text2num(href_list["X"])
		var/y = text2num(href_list["Y"])
		var/z = text2num(href_list["Z"])
		var/client/C = usr.client

		if(x == 0 && y == 0 && z == 0)
			return

		var/message
		if(!isobserver(usr))
			admin_ghost()
			message = TRUE

		var/mob/dead/observer/O = C.mob
		var/turf/T = locate(x, y, z)
		O.forceMove(T)

		if(message)
			log_admin("[key_name(O)] jumped to coordinates [AREACOORD(T)].")
			message_admins("[ADMIN_TPMONTY(O)] jumped to coordinates [ADMIN_VERBOSEJMP(T)].")


	else if(href_list["observefollow"])
		var/atom/movable/AM = locate(href_list["observefollow"])
		var/client/C = usr.client

		if(!ismovableatom(AM))
			return

		if(isnewplayer(C.mob) || isnewplayer(AM))
			return

		var/message
		if(!isobserver(C.mob))
			admin_ghost()
			message = TRUE

		var/mob/dead/observer/O = C.mob
		O.ManualFollow(AM)

		if(message)
			log_admin("[key_name(O)] jumped to follow [key_name(AM)].")
			message_admins("[ADMIN_TPMONTY(O)] jumped to follow [ADMIN_TPMONTY(AM)].")


	else if(href_list["observejump"])
		var/atom/movable/AM = locate(href_list["observejump"])
		var/client/C = usr.client

		if(isnewplayer(usr) || isnewplayer(usr))
			return

		var/message
		if(!isobserver(usr))
			admin_ghost()
			message = TRUE

		var/mob/dead/observer/O = C.mob
		O.forceMove(get_turf(AM))

		if(message)
			log_admin("[key_name(O)] jumped to [key_name(AM)].")
			message_admins("[ADMIN_TPMONTY(O)] jumped to [ADMIN_TPMONTY(AM)].")


	else if(href_list["secrets"])
		var/turf/T = get_turf(usr)
		switch(href_list["secrets"])
			if("blackout")
				log_admin("[key_name(usr)] broke all lights.")
				message_admins("[ADMIN_TPMONTY(usr)] broke all lights.")
				for(var/obj/machinery/power/apc/apc in GLOB.machines)
					apc.break_lights()
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
				to_chat(GLOB.alive_human_list, span_highdanger("[key_name_admin(usr, FALSE)] mass-teleported all humans."))
				for(var/i in GLOB.alive_human_list)
					var/mob/M = i
					M.forceMove(T)
			if("getxenos")
				log_admin("[key_name(usr)] mass-teleported all Xenos.")
				message_admins("[ADMIN_TPMONTY(usr)] mass-teleported all Xenos.")
				to_chat(GLOB.alive_xeno_list_hive[XENO_HIVE_NORMAL], span_highdanger("[key_name_admin(usr, FALSE)] mass-teleported all xenos."))
				for(var/i in GLOB.alive_xeno_list_hive[XENO_HIVE_NORMAL])
					var/mob/M = i
					M.forceMove(T)
			if("getall")
				log_admin("[key_name(usr)] mass-teleported everyone.")
				message_admins("[ADMIN_TPMONTY(usr)] mass-teleported everyone.")
				to_chat(GLOB.mob_living_list, span_highdanger("[key_name_admin(usr, FALSE)] mass-teleported everyone."))
				for(var/i in GLOB.mob_living_list)
					var/mob/M = i
					M.forceMove(T)
			if("rejuvall")
				log_admin("[key_name(usr)] mass-rejuvenated cliented mobs.")
				message_admins("[ADMIN_TPMONTY(usr)] mass-rejuvenated cliented mobs.")
				to_chat(GLOB.mob_living_list, span_highdanger("[key_name_admin(usr, FALSE)] mass-rejuvenated everyone."))
				for(var/i in GLOB.mob_living_list)
					var/mob/living/L = i
					if(!L.client)
						continue
					L.revive(TRUE)
	else if(href_list["force_event"])
		if(!check_rights(R_FUN))
			return
		var/datum/round_event_control/E = locate(href_list["force_event"]) in SSevents.control
		if(!E)
			return
		E.admin_setup(usr)
		var/datum/round_event/event = E.run_event()
		if(event.announce_when>0)
			event.processing = FALSE
			var/prompt = alert(usr, "Would you like to alert the crew?", "Alert", "Yes", "No", "Cancel")
			switch(prompt)
				if("Yes")
					event.announce_chance = 100
				if("Cancel")
					event.kill()
					return
				if("No")
					event.announce_chance = 0
			event.processing = TRUE
		message_admins("[key_name_admin(usr)] has triggered an event. ([E.name])")
		log_admin("[key_name(usr)] has triggered an event. ([E.name])")
		return


	else if(href_list["kick"])
		if(!check_rights(R_BAN))
			return

		var/mob/M = locate(href_list["kick"])
		if(ismob(M))
			if(!check_if_greater_rights_than(M.client))
				return
			if(alert(usr, "Are you sure you want to kick [key_name(M)]?", "Warning", "Yes", "No") != "Yes")
				return
			if(!M?.client)
				to_chat(usr, span_warning("Error: [M] no longer has a client!"))
				return
			to_chat_immediate(M, span_danger("You have been kicked from the server by [usr.client.holder.fakekey ? "an Administrator" : "[usr.client.key]"]."))
			qdel(M.client)

			log_admin_private("[key_name(usr)] kicked [key_name(M)].")
			message_admins("[ADMIN_TPMONTY(usr)] kicked [ADMIN_TPMONTY(M)].")


	else if(href_list["mute"])
		if(!check_rights(R_BAN))
			return

		var/mob/M = locate(href_list["mute"])

		if(!istype(M))
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
		var/client/C = usr.client
		var/mob/oldusr = C.mob

		if(!istype(M))
			return

		var/delmob
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
				location = get_turf(oldusr)

		var/mob/newmob

		oldusr << browse(null, "window=player_panel_[key_name(M)]")

		switch(href_list["transform"])
			if("observer")
				newmob = M.ghostize()
				if(isobserver(M) && newmob.icon == initial(newmob.icon))
					newmob.alpha = 255 // If the original mob was a ghost this would incorrectly affect their alpha, resetting it back to 255.
				if(delmob)
					qdel(M)
				if(location)
					newmob.forceMove(location)
			if("larva")
				newmob = M.change_mob_type(/mob/living/carbon/xenomorph/larva, location, null, delmob)
			if("defender")
				newmob = M.change_mob_type(/mob/living/carbon/xenomorph/defender, location, null, delmob)
			if("warrior")
				newmob = M.change_mob_type(/mob/living/carbon/xenomorph/warrior, location, null, delmob)
			if("runner")
				newmob = M.change_mob_type(/mob/living/carbon/xenomorph/runner, location, null, delmob)
			if("baneling")
				newmob = M.change_mob_type(/mob/living/carbon/xenomorph/baneling, location, null, delmob)
			if("drone")
				newmob = M.change_mob_type(/mob/living/carbon/xenomorph/drone, location, null, delmob)
			if("sentinel")
				newmob = M.change_mob_type(/mob/living/carbon/xenomorph/sentinel, location, null, delmob)
			if("bull")
				newmob = M.change_mob_type(/mob/living/carbon/xenomorph/bull, location, null, delmob)
			if("hunter")
				newmob = M.change_mob_type(/mob/living/carbon/xenomorph/hunter, location, null, delmob)
			if("carrier")
				newmob = M.change_mob_type(/mob/living/carbon/xenomorph/carrier, location, null, delmob)
			if("hivelord")
				newmob = M.change_mob_type(/mob/living/carbon/xenomorph/hivelord, location, null, delmob)
			if("praetorian")
				newmob = M.change_mob_type(/mob/living/carbon/xenomorph/praetorian, location, null, delmob)
			if("ravager")
				newmob = M.change_mob_type(/mob/living/carbon/xenomorph/ravager, location, null, delmob)
			if("spitter")
				newmob = M.change_mob_type(/mob/living/carbon/xenomorph/spitter, location, null, delmob)
			if("boiler")
				newmob = M.change_mob_type(/mob/living/carbon/xenomorph/boiler, location, null, delmob)
			if("crusher")
				newmob = M.change_mob_type(/mob/living/carbon/xenomorph/crusher, location, null, delmob)
			if("widow")
				newmob = M.change_mob_type(/mob/living/carbon/xenomorph/widow, location, null, delmob)
			if("defiler")
				newmob = M.change_mob_type(/mob/living/carbon/xenomorph/defiler, location, null, delmob)
			if("gorger")
				newmob = M.change_mob_type(/mob/living/carbon/xenomorph/gorger, location, null, delmob)
			if("warlock")
				newmob = M.change_mob_type(/mob/living/carbon/xenomorph/warlock, location, null, delmob)
			if("shrike")
				newmob = M.change_mob_type(/mob/living/carbon/xenomorph/shrike, location, null, delmob)
			if("hivemind")
				newmob = M.change_mob_type(/mob/living/carbon/xenomorph/hivemind, location, null, delmob)
			if("queen")
				newmob = M.change_mob_type(/mob/living/carbon/xenomorph/queen, location, null, delmob)
			if("king")
				newmob = M.change_mob_type(/mob/living/carbon/xenomorph/king, location, null, delmob)
			if("wraith")
				newmob = M.change_mob_type(/mob/living/carbon/xenomorph/wraith, location, null, delmob)
			if("puppeteer")
				newmob = M.change_mob_type(/mob/living/carbon/xenomorph/puppeteer, location, null, delmob)
			if("behemoth")
				newmob = M.change_mob_type(/mob/living/carbon/xenomorph/behemoth, location, null, delmob)
			if("human")
				newmob = M.change_mob_type(/mob/living/carbon/human, location, null, delmob)
			if("synthetic")
				newmob = M.change_mob_type(/mob/living/carbon/human/species/synthetic, location, null, delmob)
			if("early_synth")
				newmob = M.change_mob_type(/mob/living/carbon/human/species/early_synthetic, location, null, delmob)
			if("sectoid")
				newmob = M.change_mob_type(/mob/living/carbon/human/species/sectoid, location, null, delmob)
			if("vatborn")
				newmob = M.change_mob_type(/mob/living/carbon/human/species/vatborn, location, null, delmob)
			if("vatgrown")
				newmob = M.change_mob_type(/mob/living/carbon/human/species/vatgrown, location, null, delmob)
			if("combat_robot")
				newmob = M.change_mob_type(/mob/living/carbon/human/species/robot, location, null, delmob)
			if("SKELETON")
				newmob = M.change_mob_type(/mob/living/carbon/human/species/skeleton, location, null, delmob)
			if("monkey")
				newmob = M.change_mob_type(/mob/living/carbon/human/species/monkey, location, null, delmob, "Monkey") //todo doublecheck this
			if("moth")
				newmob = M.change_mob_type(/mob/living/carbon/human/species/moth, location, null, delmob, "Moth")
			if("zombie")
				newmob = M.change_mob_type(/mob/living/carbon/human/species/zombie, location, null, delmob, "Zombie")
			if("ai")
				newmob = M.change_mob_type(/mob/living/silicon/ai, location, null, delmob)

		C.holder.show_player_panel(newmob)

		log_admin("[key_name(oldusr)] has transformed [key_name(newmob ? newmob : M)] into [href_list["transform"]].[delmob ? " Old mob deleted." : ""][location ? " Teleported to [AREACOORD(location)]" : ""]")
		message_admins("[delmob ? key_name_admin(oldusr) : ADMIN_TPMONTY(oldusr)] has transformed [newmob ? ADMIN_TPMONTY(newmob) : ADMIN_TPMONTY(M)] into [href_list["transform"]].[delmob ? " Old mob deleted." : ""][location ? " Teleported to new location." : ""]")


	else if(href_list["revive"])
		if(!check_rights(R_ADMIN))
			return

		var/mob/living/L = locate(href_list["revive"]) in GLOB.mob_living_list

		if(!istype(L))
			return

		if(alert("Are you sure you want to rejuvenate [L]?", "Rejuvenate", "Yes", "No") != "Yes")
			return

		L.revive(TRUE)

		log_admin("[key_name(usr)] revived [key_name(L)].")
		message_admins("[ADMIN_TPMONTY(usr)] revived [ADMIN_TPMONTY(L)].")


	else if(href_list["editrightsbrowser"])
		if(!check_rights(R_PERMISSIONS))
			return
		edit_admin_permissions(0)

	else if(href_list["editrightsbrowserlog"])
		if(!check_rights(R_PERMISSIONS))
			return
		edit_admin_permissions(1, href_list["editrightstarget"], href_list["editrightsoperation"], href_list["editrightspage"])

	if(href_list["editrightsbrowsermanage"])
		if(!check_rights(R_PERMISSIONS))
			return
		if(href_list["editrightschange"])
			change_admin_rank(ckey(href_list["editrightschange"]), href_list["editrightschange"], TRUE)
		else if(href_list["editrightsremove"])
			remove_admin(ckey(href_list["editrightsremove"]), href_list["editrightsremove"], TRUE)
		else if(href_list["editrightsremoverank"])
			remove_rank(href_list["editrightsremoverank"])
		edit_admin_permissions(2)

	else if(href_list["editrights"])
		if(!check_rights(R_PERMISSIONS))
			return
		var/close = text2num(href_list["close"])
		edit_rights_topic(href_list, close)


	else if(href_list["spawncookie"])
		if(!check_rights(R_FUN))
			return

		var/mob/M = locate(href_list["spawncookie"])

		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			H.put_in_hands(new /obj/item/reagent_containers/food/snacks/cookie(M))
			H.update_inv_r_hand()
			H.update_inv_l_hand()
		else
			if(isobserver(M))
				if(alert("Are you sure you want to spawn the cookie at observer location [AREACOORD(M.loc)]?", "Confirmation", "Yes", "No") != "Yes")
					return
			var/turf/T = get_turf(M)
			new /obj/item/reagent_containers/food/snacks/cookie(T)

		to_chat(M, span_boldnotice("Your prayers have been answered!! You received the best cookie!"))

		log_admin("[key_name(M)] got their cookie, spawned by [key_name(usr)]")
		message_admins("[ADMIN_TPMONTY(M)] got their cookie, spawned by [ADMIN_TPMONTY(usr)].")

	else if(href_list["spawnfortunecookie"])
		if(!check_rights(R_FUN))
			return

		var/mob/M = locate(href_list["spawnfortunecookie"])

		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			H.put_in_hands(new /obj/item/reagent_containers/food/snacks/fortunecookie(M))
			H.update_inv_r_hand()
			H.update_inv_l_hand()
		else if(isobserver(M))
			if(alert("Are you sure you want to spawn the fortune cookie at observer location [AREACOORD(M.loc)]?", "Confirmation", "Yes", "No") != "Yes")
				return
			var/turf/T = get_turf(M)
			new /obj/item/reagent_containers/food/snacks/fortunecookie(T)
		else if(isxeno(M))
			if(alert("Are you sure you want to tell the Xeno a Xeno tip?", "Confirmation", "Yes", "No") != "Yes")
				return
			to_chat(M, span_tip("[pick(SSstrings.get_list_from_file("tips/xeno"))]"))

		if(isxeno(M))
			to_chat(M, span_boldnotice("Your prayers have been answered!! Hope the advice helped."))
		else
			to_chat(M, span_boldnotice("Your prayers have been answered!! You received the best fortune cookie!"))

		log_admin("[key_name(M)] got their fortune cookie, spawned by [key_name(usr)]")
		message_admins("[ADMIN_TPMONTY(M)] got their fortune cookie, spawned by [ADMIN_TPMONTY(usr)].")

	else if(href_list["adminpopup"])
		if(!check_rights(R_ADMIN))
			return

		var/message = input(owner, "As well as a popup, they'll also be sent a message to reply to. What do you want that to be?", "Message") as text|null
		if(!message)
			to_chat(owner, span_notice("Popup cancelled."))
			return

		var/client/target = locate(href_list["adminpopup"])
		if(!istype(target))
			to_chat(owner, span_notice("The mob doesn't exist anymore!"))
			return

		give_admin_popup(target, owner, message)

	else if(href_list["adminsmite"])
		if(!check_rights(R_ADMIN|R_FUN))
			return

		var/mob/living/carbon/human/H = locate(href_list["adminsmite"]) in GLOB.mob_list
		if(!H || !istype(H))
			to_chat(usr, "This can only be used on instances of type /mob/living/carbon/human")
			return

		usr.client.smite(H)

	else if(href_list["traitor"])
		if(!check_rights(R_ADMIN))
			return

		if(!SSticker.HasRoundStarted())
			alert("The game hasn't started yet!")
			return

		var/mob/M = locate(href_list["traitor"])
		if(!ismob(M))
			var/datum/mind/D = M
			if(!istype(D))
				to_chat(usr, "This can only be used on instances of type /mob and /mind", confidential = TRUE)
				return
			else
				D.traitor_panel()

	else if(href_list["reply"])
		var/mob/living/carbon/human/H = locate(href_list["reply"])

		if(!istype(H))
			return

		var/input = input("Please enter a message to reply to [key_name(H)].", "Outgoing message from TGMC", "") as message|null
		if(!input)
			return

		to_chat(H, span_boldnotice("Please stand by for a message from TGMC:<br/>[input]"))
		var/sound/S = sound('sound/effects/sos-morse-code.ogg', channel = CHANNEL_ADMIN)
		SEND_SOUND(H, S)

		log_admin("[key_name(usr)] replied to [ADMIN_TPMONTY(H)]'s TGMC message with: [input].")
		message_admins("[ADMIN_TPMONTY(usr)] replied to [ADMIN_TPMONTY(H)]'s' TGMC message with: [input]")


	if(href_list["deny"])
		var/mob/M = locate(href_list["deny"])

		if(!istype(M))
			return

		SSticker.mode.distress_cancelled = TRUE
		priority_announce("The distress signal has been blocked, the launch tubes are now recalibrating.", "Distress Beacon")
		log_admin("[key_name(usr)] has denied a distress beacon, requested by [key_name(M)]")
		message_admins("[ADMIN_TPMONTY(usr)] has denied a distress beacon, requested by [ADMIN_TPMONTY(M)]")


	if(href_list["distress"])
		var/mob/M = locate(href_list["distress"])

		if(!istype(M))
			return

		if(!SSticker?.mode || SSticker.mode.waiting_for_candidates)
			return

		var/list/valid_calls = list("Random")
		for(var/datum/emergency_call/E in SSticker.mode.all_calls) //Loop through all potential candidates
			valid_calls.Add(E)

		var/chosen_call = input(usr, "Select a distress to send", "Emergency Response") as null|anything in valid_calls

		if(chosen_call == "Random")
			SSticker.mode.activate_distress()
		else
			SSticker.mode.activate_distress(chosen_call)

		log_admin("[key_name(usr)] has sent a [chosen_call] distress beacon early, requested by [key_name(M)]")
		message_admins("[ADMIN_TPMONTY(usr)] has sent a [chosen_call] distress beacon early, requested by [ADMIN_TPMONTY(M)]")


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

		to_chat(M, span_boldnotice("You have been sent to the Thunderdome!"))

		log_admin("[key_name(usr)] has sent [key_name(M)] to the thunderdome.")
		message_admins("[ADMIN_TPMONTY(usr)] has sent [ADMIN_TPMONTY(M)] to the thunderdome.")


	else if(href_list["gib"])
		if(!check_rights(R_ADMIN))
			return

		var/mob/living/L = locate(href_list["gib"])
		if(!istype(L) || isobserver(L))
			return

		if(alert("Are you sure you want to gib [L]?", "Warning", "Yes", "No") != "Yes")
			return

		log_admin("[key_name(usr)] has gibbed [key_name(L)].")
		message_admins("[ADMIN_TPMONTY(usr)] has gibbed [ADMIN_TPMONTY(L)].")

		L.gib()


	else if(href_list["lobby"])
		if(!check_rights(R_ADMIN))
			return

		var/mob/M = locate(href_list["lobby"])

		if(!M.client)
			to_chat(usr, span_warning("[M] doesn't seem to have an active client."))
			return

		if(alert("Send [key_name(M)] back to Lobby?", "Send to Lobby", "Yes", "No") != "Yes")
			return

		log_admin("[key_name(usr)] has sent [key_name(M)] back to the lobby.")
		message_admins("[ADMIN_TPMONTY(usr)] has sent [key_name_admin(M)] back to the lobby.")

		var/mob/new_player/NP = new()
		M.client.screen.Cut()
		NP.name = M.key
		NP.key = M.key
		if(isobserver(M))
			qdel(M)
		else
			M.ghostize()


	else if(href_list["cryo"])
		if(!check_rights(R_ADMIN))
			return

		var/mob/living/L = locate(href_list["cryo"])
		if(!istype(L))
			return

		if(alert("Cryo [key_name(L)]?", "Cryosleep", "Yes", "No") != "Yes")
			return

		var/client/C = L.client
		if(C && alert("They have a client attached, are you sure?", "Cryosleep", "Yes", "No") != "Yes")
			return

		var/old_name = L.real_name
		L.despawn()

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

		log_admin("[key_name(usr)] has cryo'd [C ? key_name(C) : old_name][lobby ? " sending them to the lobby" : ""].")
		message_admins("[ADMIN_TPMONTY(usr)] has cryo'd [C ? key_name_admin(C) : old_name] [lobby ? " sending them to the lobby" : ""].")


	else if(href_list["jumpto"])
		if(!check_rights(R_ADMIN))
			return

		var/mob/M = locate(href_list["jumpto"])
		if(!istype(M) || M == usr)
			return

		usr.forceMove(M.loc)

		log_admin("[key_name(usr)] has jumped to [key_name(M)]'s mob.")
		message_admins("[ADMIN_TPMONTY(usr)] has jumped to [ADMIN_TPMONTY(M)]'s mob.")


	else if(href_list["getmob"])
		if(!check_rights(R_ADMIN))
			return

		var/mob/M = locate(href_list["getmob"])
		if(!istype(M)  || M == usr)
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
				var/area/A = input("Pick an area.", "Pick an area") as null|anything in GLOB.sorted_areas
				if(!A || !M)
					return
				target = pick(get_area_turfs(A))
			if("Mob")
				var/mob/N = input("Pick a mob.", "Pick a mob") as null|anything in sortList(GLOB.mob_list)
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

		M.forceMove(target)

		log_admin("[key_name(usr)] has sent [key_name(M)]'s mob to [AREACOORD(target)].")
		message_admins("[ADMIN_TPMONTY(usr)] has sent [ADMIN_TPMONTY(M)]'s mob to [ADMIN_VERBOSEJMP(target)].")


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


	else if(href_list["faxmark"])
		if(!check_rights(R_ADMIN|R_MENTOR))
			return

		var/ref = locate(href_list["faxmark"])
		if(!ref)
			return
		var/datum/fax/F = GLOB.faxes[ref]
		if(!F || F.admin || F.marked == usr.client.key)
			return

		if(F.marked)
			switch(alert("This fax has already been marked by [F.marked], do you want to replace them?", "Warning", "Replace", "Unmark", "Cancel"))
				if("Replace")
					F.marked = usr.client.key
					message_staff("[key_name_admin(usr)] has re-marked a fax from [key_name_admin(F.sender)].")
				if("Unmark")
					F.marked = null
					message_staff("[key_name_admin(usr)] has un-marked a fax from [key_name_admin(F.sender)].")
			return

		F.marked = usr.client.key
		message_staff("[key_name_admin(usr)] has marked a fax from [key_name_admin(F.sender)].")


	else if(href_list["faxcreate"] || href_list["faxreply"])
		if(!check_rights(R_ADMIN|R_MENTOR))
			return

		var/mob/sender
		var/subject = "No subject"
		if(href_list["faxreply"])
			var/ref = locate(href_list["faxreply"])
			if(!ref)
				return
			var/datum/fax/F = GLOB.faxes[ref]
			if(!F || F.admin)
				return

			if(F.marked && F.marked != usr.client.key)
				to_chat(usr, "<span class='warning'>This fax has already been marked by [F.marked], please unmark it to be able to proceed.")
				return
			else if(!F.marked)
				F.marked = usr.client.key
				message_staff("[key_name_admin(usr)] marked and started replying to a fax from [key_name_admin(F.sender)].")

			sender = F.sender
			subject = "re: [F.title]"

		var/dep = input("Who do you want to message?", "Fax Message") as null|anything in list(CORPORATE_LIAISON, "Combat Information Center", "Brig", "Research", "Warden")
		if(!dep)
			return

		var/department = input("Which department do you want to reply AS?", "Fax Message") as null|anything in list("TGMC High Command", "TGMC Provost General", "Nanotrasen")
		if(!department)
			return

		var/custom_subject = input("Enter the subject line", "Fax Message", subject) as text|null
		if(custom_subject != "")
			subject = custom_subject
		var/type = input("Do you want to use the pencode, template or type a raw message?", "Fax Message") as null|anything in list("Pencode", "Template", "Raw")
		if(!type)
			return

		var/fax_message
		switch(type)
			if("Pencode")
				var/message = input("Please enter a message to send via secure connection.", "Fax Message", "") as message|null
				if(!message)
					return

				if(check_rights(R_ADMIN, FALSE))
					message = noscript(message)
				else
					message = sanitize(message)
				fax_message = parse_pencode(message)

				if(!fax_message)
					return

			if("Template")
				var/addressed_to

				if(sender) // For the case we might be replying to a fax.
					var/addressed = input("Address it to the sender or custom?", "Fax Message") as null|anything in list("Sender", "Custom")
					if(!addressed)
						return
					if(addressed == "Sender")
						addressed_to = "[sender.real_name]"

				if(!addressed_to)
					addressed_to = input("Who is it addressed to?", "Fax Message", "") as text|null
				var/message_body = input("Please enter a message to send via secure connection.", "Fax Message", "") as message|null
				var/sent_by = input("Enter the name and rank you are sending from.", "Fax Message", "") as text|null

				if(!addressed_to && !message_body && !sent_by)
					return

				addressed_to = sanitize(addressed_to)
				sent_by = sanitize(sent_by)

				if(check_rights(R_ADMIN, FALSE))
					message_body = noscript(message_body)
				else
					message_body = sanitize(message_body)

				message_body = replacetext(message_body, "\n", "<br />") // Lets just always do this one
				fax_message = generate_templated_fax(dep, subject, addressed_to, message_body, sent_by, department)
				if(!fax_message)
					return

			if("Raw")
				var/message = input("Please enter a message to send via secure connection.", "Fax Message", "") as message|null
				if(!message)
					return

				if(check_rights(R_ADMIN, FALSE))
					fax_message = noscript(message)
				else
					fax_message = sanitize(message)

				if(!fax_message)
					return

		usr << browse(fax_message, "window=faxpreview;size=600x600")

		if(alert("Send this fax?", "Confirmation", "Yes", "No") != "Yes")
			usr << browse(null, "window=faxpreview")
			return

		send_fax(usr, null, dep, subject, fax_message, TRUE)
		if(sender)
			log_admin("[key_name(usr)] replied to a fax message from [key_name(sender)].")
			message_staff("[ADMIN_TPMONTY(usr)] replied to a fax message from [ismob(sender) ? ADMIN_TPMONTY(sender) : key_name_admin(sender)].")
		else
			message_staff("[key_name_admin(usr)] sent a new fax - Department: [dep] | Subject: [subject].")


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

		var/dat = "<b>What mode do you wish to play?</b><br>"
		for(var/datum/game_mode/mode AS in config.modes)
			dat += "<a href='?src=[REF(usr.client.holder)];[HrefToken()];changemode=[mode]'>[mode.name]</a><br>"
		dat += "<br>"
		dat += "Now: [GLOB.master_mode]<br>"
		dat += "Next Round: [trim(file2text("data/mode.txt"))]"

		var/datum/browser/browser = new(usr, "change_mode", "<div align='center'>Change Gamemode</div>")
		browser.set_content(dat)
		browser.open(FALSE)


	else if(href_list["changemode"])
		if(!check_rights(R_SERVER))
			return

		var/new_mode = href_list["changemode"]
		if(!new_mode)
			return

		if(SSticker.mode)
			world.save_mode(new_mode)
			log_admin("[key_name(usr)] set the mode for next round to: [new_mode].")
			message_admins("[ADMIN_TPMONTY(usr)] set the mode for next round to: [new_mode].")
		else
			GLOB.master_mode = new_mode
			to_chat(world, span_boldnotice("The mode is now: [GLOB.master_mode]."))
			world.save_mode(GLOB.master_mode)
			log_admin("[key_name(usr)] set the mode to: [GLOB.master_mode].")
			message_admins("[ADMIN_TPMONTY(usr)] set the mode to: [GLOB.master_mode].")

		Topic(usr.client.holder, list("admin_token" = RawHrefToken(TRUE), "modemenu" = TRUE))


	if(href_list["evac_authority"])
		if(!check_rights(R_ADMIN))
			return

		if(!SSevacuation.dest_master)
			SSevacuation.prepare()

		switch(href_list["evac_authority"])
			if("init_evac")
				if(!SSevacuation.initiate_evacuation(TRUE))
					to_chat(usr, span_warning("You are unable to initiate an evacuation right now!"))
					return
				log_admin("[key_name(usr)] called an evacuation.")
				message_admins("[ADMIN_TPMONTY(usr)] called an evacuation.")

			if("cancel_evac")
				if(!SSevacuation.cancel_evacuation())
					to_chat(usr, span_warning("You are unable to cancel an evacuation right now!"))
					return

				log_admin("[key_name(usr)] canceled an evacuation.")
				message_admins("[ADMIN_TPMONTY(usr)] canceled an evacuation.")

			if("toggle_evac")
				SSevacuation.flags_scuttle ^= FLAGS_EVACUATION_DENY
				log_admin("[key_name(src)] has [SSevacuation.flags_scuttle & FLAGS_EVACUATION_DENY ? "forbidden" : "allowed"] ship-wide evacuation.")
				message_admins("[ADMIN_TPMONTY(usr)] has [SSevacuation.flags_scuttle & FLAGS_EVACUATION_DENY ? "forbidden" : "allowed"] ship-wide evacuation.")

			if("force_evac")
				if(!SSevacuation.begin_launch())
					to_chat(usr, span_warning("You are unable to launch the pods directly right now!"))
					return

				log_admin("[key_name(usr)] force-launched the escape pods.")
				message_admins("[ADMIN_TPMONTY(usr)] force-launched the escape pods.")

			if("init_dest")
				if(!SSevacuation.enable_self_destruct(TRUE))
					to_chat(usr, span_warning("You are unable to authorize the self-destruct right now!"))
					return

				log_admin("[key_name(usr)] force-enabled the self-destruct system.")
				message_admins("[ADMIN_TPMONTY(usr)] force-enabled the self-destruct system.")

			if("cancel_dest")
				if(!SSevacuation.cancel_self_destruct(TRUE))
					to_chat(usr, span_warning("You are unable to cancel the self-destruct right now!"))
					return

				log_admin("[key_name(usr)] canceled the self-destruct system.")
				message_admins("[ADMIN_TPMONTY(usr)] canceled the self-destruct system.")

			if("use_dest")
				if(alert("Are you sure you want to destroy the [SSmapping.configs[SHIP_MAP].map_name] right now?", "Self-Destruct", "Yes", "No") != "Yes")
					return

				if(!SSevacuation.initiate_self_destruct(TRUE))
					to_chat(usr, span_warning("You are unable to trigger the self-destruct right now!"))
					return

				log_admin("[key_name(usr)] forced the self-destruct system, destroying the [SSmapping.configs[SHIP_MAP].map_name].")
				message_admins("[ADMIN_TPMONTY(usr)] forced the self-destruct system, destroying the [SSmapping.configs[SHIP_MAP].map_name].")

			if("toggle_dest")
				SSevacuation.flags_scuttle ^= FLAGS_SELF_DESTRUCT_DENY
				log_admin("[key_name(src)] has [SSevacuation.flags_scuttle & FLAGS_SELF_DESTRUCT_DENY ? "forbidden" : "allowed"] the self-destruct system.")
				message_admins("[ADMIN_TPMONTY(usr)] has [SSevacuation.flags_scuttle & FLAGS_SELF_DESTRUCT_DENY ? "forbidden" : "allowed"] the self-destruct system.")


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
			to_chat(usr, span_warning("The path list you sent is empty."))
			return
		if(length(paths) > 5)
			to_chat(usr, span_warning("Select fewer object types, (max 5)."))
			return

		var/list/offset = splittext(href_list["offset"],",")
		var/number = clamp(text2num(href_list["object_count"]), 1, 100)
		var/X = length(offset) > 0 ? text2num(offset[1]) : 0
		var/Y = length(offset) > 1 ? text2num(offset[2]) : 0
		var/Z = length(offset) > 2 ? text2num(offset[3]) : 0
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
					to_chat(usr, "Can only spawn in hand when you're a carbon mob.")
					where = "onfloor"
				target = usr

			if("onfloor", "frompod")
				switch(href_list["offset_type"])
					if("absolute")
						target = locate(0 + X, 0 + Y, 0 + Z)
					if("relative")
						target = locate(loc.x + X, loc.y + Y, loc.z + Z)
			if("inmarked")
				if(!marked_datum)
					to_chat(usr, span_warning("You don't have any object marked. Abandoning spawn."))
					return
				else if(!istype(marked_datum, /atom))
					to_chat(usr, span_warning("The object you have marked cannot be used as a target. Target must be of type /atom."))
					return
				else
					target = marked_datum

		var/obj/structure/closet/supplypod/centcompod/pod

		if(target)
			if(where == "frompod")
				pod = new()

			for(var/path in paths)
				for(var/i in 1 to number)
					if(path in typesof(/turf))
						var/turf/O = target
						var/turf/N = O.ChangeTurf(path)
						if(N && obj_name)
							N.name = obj_name
					else
						var/atom/O
						if(where == "frompod")
							O = new path(pod)
						else
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

		if(pod)
			new /obj/effect/DPtarget(target, pod)

		log_admin("[key_name(usr)] created [number] [english_list(paths)] at [AREACOORD(usr.loc)].")
		message_admins("[ADMIN_TPMONTY(usr)] created [number] [english_list(paths)] at [ADMIN_VERBOSEJMP(usr.loc)].")


	else if(href_list["viewruntime"])
		var/datum/error_viewer/error_viewer = locate(href_list["viewruntime"])
		if(!istype(error_viewer))
			to_chat(usr, span_warning("That runtime viewer no longer exists."))
			return

		if(href_list["viewruntime_backto"])
			error_viewer.show_to(owner, locate(href_list["viewruntime_backto"]), href_list["viewruntime_linear"])
		else
			error_viewer.show_to(owner, null, href_list["viewruntime_linear"])


	else if(href_list["addmessage"])
		if(!check_rights(R_BAN))
			return
		var/target_key = href_list["addmessage"]
		create_message("message", target_key, secret = FALSE)


	else if(href_list["addnote"])
		if(!check_rights(R_BAN))
			return
		var/target_key = href_list["addnote"]
		create_message("note", target_key)


	else if(href_list["addwatch"])
		if(!check_rights(R_BAN))
			return
		var/target_key = href_list["addwatch"]
		create_message("watchlist entry", target_key, secret = TRUE)


	else if(href_list["addmemo"])
		if(!check_rights(R_BAN))
			return
		create_message("memo", secret = TRUE, browse = TRUE)


	else if(href_list["addmessageempty"])
		if(!check_rights(R_BAN))
			return
		create_message("message", secret = FALSE)


	else if(href_list["addnoteempty"])
		if(!check_rights(R_BAN))
			return
		create_message("note")


	else if(href_list["addwatchempty"])
		if(!check_rights(R_BAN))
			return
		create_message("watchlist entry", secret = TRUE)


	else if(href_list["deletemessage"])
		if(!check_rights(R_BAN))
			return
		if(alert("Delete message/note?", "Confirmation", "Yes", "No") != "Yes")
			return
		var/message_id = href_list["deletemessage"]
		delete_message(message_id)


	else if(href_list["deletemessageempty"])
		if(!check_rights(R_BAN))
			return
		if(alert("Delete message/note?", "Confirmation", "Yes", "No") != "Yes")
			return
		var/message_id = href_list["deletemessageempty"]
		delete_message(message_id, browse = TRUE)


	else if(href_list["editmessage"])
		if(!check_rights(R_BAN))
			return
		var/message_id = href_list["editmessage"]
		edit_message(message_id)


	else if(href_list["editmessageempty"])
		if(!check_rights(R_BAN))
			return
		var/message_id = href_list["editmessageempty"]
		edit_message(message_id, browse = TRUE)


	else if(href_list["editmessageexpiry"])
		if(!check_rights(R_BAN))
			return
		var/message_id = href_list["editmessageexpiry"]
		edit_message_expiry(message_id)


	else if(href_list["editmessageexpiryempty"])
		if(!check_rights(R_BAN))
			return
		var/message_id = href_list["editmessageexpiryempty"]
		edit_message_expiry(message_id, browse = TRUE)


	else if(href_list["editmessageseverity"])
		if(!check_rights(R_BAN))
			return
		var/message_id = href_list["editmessageseverity"]
		edit_message_severity(message_id)


	else if(href_list["secretmessage"])
		if(!check_rights(R_BAN))
			return
		var/message_id = href_list["secretmessage"]
		toggle_message_secrecy(message_id)


	else if(href_list["searchmessages"])
		if(!check_rights(R_BAN))
			return
		var/target = href_list["searchmessages"]
		browse_messages(index = target)


	else if(href_list["nonalpha"])
		if(!check_rights(R_BAN))
			return
		var/target = href_list["nonalpha"]
		target = text2num(target)
		browse_messages(index = target)


	else if(href_list["showmessages"])
		if(!check_rights(R_BAN))
			return
		var/target = href_list["showmessages"]
		browse_messages(index = target)


	else if(href_list["showmemo"])
		if(!check_rights(R_BAN))
			return
		browse_messages("memo")


	else if(href_list["showwatch"])
		if(!check_rights(R_BAN))
			return
		browse_messages("watchlist entry")


	else if(href_list["showwatchfilter"])
		if(!check_rights(R_BAN))
			return
		browse_messages("watchlist entry", filter = 1)


	else if(href_list["showmessageckey"])
		if(!check_rights(R_BAN))
			return
		var/target = href_list["showmessageckey"]
		var/agegate = TRUE
		if (href_list["showall"])
			agegate = FALSE
		browse_messages(target_ckey = target, agegate = agegate)


	else if(href_list["showmessageckeylinkless"])
		var/target = href_list["showmessageckeylinkless"]
		browse_messages(target_ckey = target, linkless = TRUE)


	else if(href_list["messageedits"])
		if(!check_rights(R_BAN))
			return
		var/datum/db_query/query_get_message_edits = SSdbcore.NewQuery(
			"SELECT edits FROM [format_table_name("messages")] WHERE id = :message_id",
			list("message_id" = href_list["messageedits"])
		)
		if(!query_get_message_edits.warn_execute())
			qdel(query_get_message_edits)
			return
		if(query_get_message_edits.NextRow())
			var/edit_log = query_get_message_edits.item[1]
			if(!QDELETED(usr))
				var/datum/browser/browser = new(usr, "Note edits", "Note edits")
				browser.set_content(jointext(edit_log, ""))
				browser.open()
		qdel(query_get_message_edits)


	else if(href_list["newbankey"])
		var/player_key = href_list["newbankey"]
		var/player_ip = href_list["newbanip"]
		var/player_cid = href_list["newbancid"]
		usr.client.holder.banpanel(player_key, player_ip, player_cid)


	else if(href_list["intervaltype"]) //check for ban panel, intervaltype is used as it's the only value which will always be present
		if(href_list["roleban_delimiter"])
			usr.client.holder.ban_parse_href(href_list)
		else
			usr.client.holder.ban_parse_href(href_list, TRUE)


	else if(href_list["searchunbankey"] || href_list["searchunbanadminkey"] || href_list["searchunbanip"] || href_list["searchunbancid"])
		var/player_key = href_list["searchunbankey"]
		var/admin_key = href_list["searchunbanadminkey"]
		var/player_ip = href_list["searchunbanip"]
		var/player_cid = href_list["searchunbancid"]
		usr.client.holder.unbanpanel(player_key, admin_key, player_ip, player_cid)


	else if(href_list["unbanpagecount"])
		var/page = href_list["unbanpagecount"]
		var/player_key = href_list["unbankey"]
		var/admin_key = href_list["unbanadminkey"]
		var/player_ip = href_list["unbanip"]
		var/player_cid = href_list["unbancid"]
		usr.client.holder.unbanpanel(player_key, admin_key, player_ip, player_cid, page)


	else if(href_list["editbanid"])
		var/edit_id = href_list["editbanid"]
		var/player_key = href_list["editbankey"]
		var/player_ip = href_list["editbanip"]
		var/player_cid = href_list["editbancid"]
		var/role = href_list["editbanrole"]
		var/duration = href_list["editbanduration"]
		var/applies_to_admins = text2num(href_list["editbanadmins"])
		var/reason = url_decode(href_list["editbanreason"])
		var/page = href_list["editbanpage"]
		var/admin_key = href_list["editbanadminkey"]
		usr.client.holder.banpanel(player_key, player_ip, player_cid, role, duration, applies_to_admins, reason, edit_id, page, admin_key)


	else if(href_list["unbanid"])
		var/ban_id = href_list["unbanid"]
		var/player_key = href_list["unbankey"]
		var/player_ip = href_list["unbanip"]
		var/player_cid = href_list["unbancid"]
		var/role = href_list["unbanrole"]
		var/page = href_list["unbanpage"]
		var/admin_key = href_list["unbanadminkey"]
		usr.client.holder.unban(ban_id, player_key, player_ip, player_cid, role, page, admin_key)
		usr.client.holder.unbanpanel(player_key, admin_key, player_ip, player_cid)


	else if(href_list["unbanlog"])
		var/ban_id = href_list["unbanlog"]
		usr.client.holder.ban_log(ban_id)


	else if(href_list["stickyban"])
		stickyban(href_list["stickyban"], href_list)


	else if(href_list["addjobslot"])
		if(!check_rights(R_ADMIN))
			return

		var/slot = href_list["addjobslot"]

		var/datum/job/job = SSjob.name_occupations[slot]
		if(!(job.job_flags & (JOB_FLAG_LATEJOINABLE|JOB_FLAG_ROUNDSTARTJOINABLE)))
			to_chat(usr, span_warning("Job is not joinable."))
			return
		job.add_job_positions(1)

		usr.client?.holder.job_slots()

		log_admin("[key_name(src)] has added a [slot] job slot.")
		message_admins("[ADMIN_TPMONTY(usr)] has added a [slot] job slot.")


	else if(href_list["filljobslot"])
		if(!check_rights(R_ADMIN))
			return

		var/slot = href_list["filljobslot"]

		var/datum/job/J = SSjob.name_occupations[slot]
		if(J.current_positions >= J.total_positions)
			to_chat(usr, span_warning("Filling would cause an overflow. Please add more slots first."))
			return
		J.occupy_job_positions(1)

		usr.client.holder.job_slots()

		log_admin("[key_name(src)] has filled a [slot] job slot.")
		message_admins("[ADMIN_TPMONTY(usr)] has filled a [slot] job slot.")


	else if(href_list["freejobslot"])
		if(!check_rights(R_ADMIN))
			return

		var/slot = href_list["freejobslot"]

		var/datum/job/J = SSjob.name_occupations[slot]
		if(J.current_positions <= 0)
			to_chat(usr, span_warning("Cannot free more job slots."))
			return
		J.free_job_positions(1)

		usr.client.holder.job_slots()

		log_admin("[key_name(src)] has freed a [slot] job slot.")
		message_admins("[ADMIN_TPMONTY(usr)] has freed a [slot] job slot.")


	else if(href_list["removejobslot"])
		if(!check_rights(R_ADMIN))
			return

		var/slot = href_list["removejobslot"]

		var/datum/job/job = SSjob.name_occupations[slot]
		if(!(job.job_flags & (JOB_FLAG_LATEJOINABLE|JOB_FLAG_ROUNDSTARTJOINABLE)))
			to_chat(usr, span_warning("Job is not joinable."))
			return
		if(job.total_positions <= 0 || job.total_positions <= job.current_positions)
			to_chat(usr, span_warning("Cannot remove more job slots."))
			return
		job.remove_job_positions(1)

		usr.client.holder.job_slots()

		log_admin("[key_name(src)] has removed a [slot] job slot.")
		message_admins("[ADMIN_TPMONTY(usr)] has removed a [slot] job slot.")


	else if(href_list["clearjobslots"])
		if(!check_rights(R_ADMIN))
			return

		var/slot = href_list["clearjobslots"]

		var/datum/job/job = SSjob.name_occupations[slot]
		if(!(job.job_flags & (JOB_FLAG_LATEJOINABLE|JOB_FLAG_ROUNDSTARTJOINABLE)))
			to_chat(usr, span_warning("Job is not joinable."))
			return
		job.set_job_positions(0)

		usr.client.holder.job_slots()

		log_admin("[key_name(src)] has cleared the [slot] job.")
		message_admins("[ADMIN_TPMONTY(usr)] has cleared the [slot] job.")


	else if(href_list["clearalljobslots"])
		if(!check_rights(R_ADMIN))
			return

		for(var/slot in SSjob.name_occupations)
			var/datum/job/job = SSjob.name_occupations[slot]
			if(!(job.job_flags & (JOB_FLAG_LATEJOINABLE|JOB_FLAG_ROUNDSTARTJOINABLE)))
				continue
			job.set_job_positions(0)

		usr.client.holder.job_slots()

		log_admin("[key_name(src)] has cleared all job slots.")
		message_admins("[ADMIN_TPMONTY(usr)] has cleared all job slots.")


	else if(href_list["unlimitjobslot"])
		if(!check_rights(R_ADMIN))
			return

		var/slot = href_list["unlimitjobslot"]

		var/datum/job/job = SSjob.name_occupations[slot]
		if(!(job.job_flags & (JOB_FLAG_LATEJOINABLE|JOB_FLAG_ROUNDSTARTJOINABLE)))
			to_chat(usr, span_warning("Job is not joinable."))
			return
		job.set_job_positions(-1)

		usr.client.holder.job_slots()

		log_admin("[key_name(src)] has unlimited the [slot] job.")
		message_admins("[ADMIN_TPMONTY(usr)] has unlimited the [slot] job.")


	else if(href_list["limitjobslot"])
		if(!check_rights(R_ADMIN))
			return

		var/slot = href_list["limitjobslot"]

		var/datum/job/J = SSjob.name_occupations[slot]
		J.set_job_positions(J.current_positions)

		usr.client.holder.job_slots()

		log_admin("[key_name(src)] has limited the [slot] job.")
		message_admins("[ADMIN_TPMONTY(usr)] has limited the [slot] job.")


	else if(href_list["overridejobsstart"])
		if(!check_rights(R_ADMIN))
			return

		var/override = href_list["overridejobsstart"]
		switch(override)
			if("true")
				SSjob.ssjob_flags |= SSJOB_OVERRIDE_JOBS_START
			if("false")
				SSjob.ssjob_flags &= ~(SSJOB_OVERRIDE_JOBS_START)

		usr.client.holder.job_slots()

		log_admin("[key_name(src)] has set the roundstart job override value to [override].")
		message_admins("[ADMIN_TPMONTY(usr)] has set the roundstart job override value to [override].")


	else if(href_list["rankequip"])
		if(!check_rights(R_FUN))
			return

		var/mob/living/carbon/human/H = locate(href_list["rankequip"]) in GLOB.human_mob_list

		if(!istype(H))
			to_chat(usr, span_warning("Target is no longer valid."))
			return

		usr.client.holder.rank_and_equipment(H)


	else if(href_list["editappearance"])
		if(!check_rights(R_FUN))
			return

		var/mob/living/carbon/human/H = locate(href_list["editappearance"]) in GLOB.human_mob_list

		if(!istype(H))
			to_chat(usr, span_warning("Target is no longer valid."))
			return

		usr.client.holder.edit_appearance(H)


	else if(href_list["sleep"])
		if(!check_rights(R_ADMIN))
			return

		var/mob/living/L = locate(href_list["sleep"]) in GLOB.mob_living_list

		if(!istype(L))
			to_chat(usr, span_warning("Target is no longer valid."))
			return

		usr.client.holder.toggle_sleep(L)


	else if(href_list["offer"])
		if(!check_rights(R_ADMIN))
			return

		var/mob/living/L = locate(href_list["offer"]) in GLOB.mob_living_list

		if(!istype(L))
			to_chat(usr, span_warning("Target is no longer valid."))
			return

		usr.client.holder.offer(L)


	else if(href_list["give"])
		if(!check_rights(R_ADMIN))
			return

		var/mob/living/L = locate(href_list["give"]) in GLOB.mob_living_list

		if(!istype(L))
			to_chat(usr, span_warning("Target is no longer valid."))
			return

		usr.client.holder.give_mob(L)


	else if(href_list["playtime"])
		if(!check_rights(R_ADMIN))
			return

		var/mob/M = locate(href_list["playtime"]) in GLOB.mob_list
		var/client/C = M.client

		if(!istype(C))
			to_chat(usr, span_warning("Target is no longer valid."))
			return

		var/list/body = list()
		body += C.get_exp_report()

		var/datum/browser/popup = new(usr, "playtime_[C.key]", "<div align='center'>Playtime for [C.key]</div>", 550, 615)
		popup.set_content(body.Join())
		popup.open(FALSE)


	else if(href_list["randomname"])
		if(!check_rights(R_FUN))
			return

		var/mob/living/carbon/human/H = locate(href_list["randomname"]) in GLOB.human_mob_list
		if(!istype(H))
			to_chat(usr, span_warning("Target is no longer valid."))
			return

		var/oldname = H.real_name

		H.fully_replace_character_name(H.real_name, H.species.random_name(H.gender))

		log_admin("[key_name(src)] randomized the name of [oldname] -> [key_name(H)].")
		message_admins("[ADMIN_TPMONTY(usr)] randomized the name of [oldname] -> [ADMIN_TPMONTY(H)].")


	else if(href_list["checkcontents"])
		if(!check_rights(R_DEBUG))
			return

		var/mob/living/L = locate(href_list["checkcontents"]) in GLOB.mob_living_list
		if(!istype(L))
			to_chat(usr, span_warning("Target is no longer valid."))
			return

		var/dat

		for(var/i in L.GetAllContents())
			var/atom/A = i
			dat += "[A] [ADMIN_VV(A)]<br>"

		var/datum/browser/popup = new(usr, "contents_[key_name(L)]", "<div align='center'>Contents of [key_name(L)]</div>")
		popup.set_content(dat)
		popup.open(FALSE)

		log_admin("[key_name(usr)] checked the contents of [key_name(L)].")
		message_admins("[ADMIN_TPMONTY(usr)] checked the contents of [ADMIN_TPMONTY(L)].")


	else if(href_list["appearance"])
		if(!check_rights(R_FUN))
			return

		var/mob/living/carbon/human/H = locate(href_list["mob"]) in GLOB.human_mob_list
		if(!istype(H))
			to_chat(usr, span_warning("Target is no longer valid."))
			return

		var/change
		var/previous

		switch(href_list["appearance"])
			if("hairstyle")
				var/list/valid_hairstyles = list()
				for(var/hairstyle in GLOB.hair_styles_list)
					var/datum/sprite_accessory/S = GLOB.hair_styles_list[hairstyle]
					if(!(H.species.name in S.species_allowed))
						continue

					valid_hairstyles += hairstyle
				change = input("Select the hair style.", "Edit Appearance") as null|anything in sortList(valid_hairstyles)
				if(!change || !istype(H))
					return
				previous = H.h_style
				H.h_style = change
			if("haircolor")
				change = input("Select the hair color.", "Edit Appearance") as null|color
				if(!change || !istype(H))
					return
				previous = "#[num2hex(H.r_hair)][num2hex(H.g_hair)][num2hex(H.b_hair)]"
				H.r_hair = hex2num(copytext(change, 2, 4))
				H.g_hair = hex2num(copytext(change, 4, 6))
				H.b_hair = hex2num(copytext(change, 6, 8))
			if("facialhairstyle")
				change = input("Select the facial hair style.", "Edit Appearance") as null|anything in sortList(GLOB.facial_hair_styles_list)
				if(!change || !istype(H))
					return
				previous = H.f_style
				H.f_style = change
			if("facialhaircolor")
				change = input("Select the facial hair color.", "Edit Appearance") as null|color
				if(!change || !istype(H))
					return
				previous = "#[num2hex(H.r_facial)][num2hex(H.g_facial)][num2hex(H.b_facial)]"
				H.r_facial = hex2num(copytext(change, 2, 4))
				H.g_facial = hex2num(copytext(change, 4, 6))
				H.b_facial = hex2num(copytext(change, 6, 8))
			if("eyecolor")
				change = input("Select the eye color.", "Edit Appearance") as null|color
				if(!change || !istype(H))
					return
				previous = "#[num2hex(H.r_eyes)][num2hex(H.g_eyes)][num2hex(H.b_eyes)]"
				H.r_eyes = hex2num(copytext(change, 2, 4))
				H.g_eyes = hex2num(copytext(change, 4, 6))
				H.b_eyes = hex2num(copytext(change, 6, 8))
			if("bodycolor")
				change = input("Select the body color.", "Edit Appearance") as null|color
				if(!change || !istype(H))
					return
				previous = "#[num2hex(H.r_skin)][num2hex(H.g_skin)][num2hex(H.b_skin)]"
				H.r_skin = hex2num(copytext(change, 2, 4))
				H.g_skin = hex2num(copytext(change, 4, 6))
				H.b_skin = hex2num(copytext(change, 6, 8))
			if("gender")
				change = input("Select the gender.", "Edit Appearance") as null|anything in sortList(GLOB.genders)
				if(!change || !istype(H))
					return
				previous = H.gender
				H.gender = change
			if("ethnicity")
				change = input("Select the ethnicity.", "Edit Appearance") as null|anything in sortList(GLOB.ethnicities_list)
				if(!change || !istype(H))
					return
				previous = H.ethnicity
				H.ethnicity = change
			if("species")
				previous = H.species
				change = input("Select the species.", "Edit Appearance") as null|anything in GLOB.all_species
				if(!change || !istype(H))
					return
				H.set_species(change)

		H.update_hair()
		H.update_body()
		H.regenerate_icons()
		usr.client.holder.edit_appearance(H)

		log_admin("[key_name(usr)] updated the [href_list["appearance"]] from [previous] to [change] of [key_name(H)].")
		message_admins("[ADMIN_TPMONTY(usr)] updated the [href_list["appearance"]] from [previous] to [change] of [ADMIN_TPMONTY(H)].")


	else if(href_list["rank"])
		if(!check_rights(R_FUN))
			return

		var/mob/living/carbon/human/H = locate(href_list["mob"]) in GLOB.human_mob_list
		if(!istype(H))
			to_chat(usr, span_warning("Target is no longer valid."))
			return

		var/change
		var/previous
		var/addition

		switch(href_list["rank"])
			if("createmind")
				if(!istype(H) || H.mind)
					return
				H.mind_initialize()
			if("rank")
				change = input("Select a rank.", "Edit Rank") as null|anything in sortList(SSjob.name_occupations)
				if(!change || !istype(H))
					return
				var/datum/job/J = SSjob.GetJob(change)
				previous = H.job?.title
				var/squad_to_insert_into
				if(ismarinejob(J) || issommarinejob(J))
					if(H.assigned_squad)
						squad_to_insert_into = H.assigned_squad
					else
						squad_to_insert_into = pick(SSjob.active_squads[J.faction])
				H.apply_assigned_role_to_spawn(J, H.client, squad_to_insert_into, admin_action = TRUE)
				if(href_list["doequip"])
					H.equip_role_outfit(J)
					addition = ", equipping them"
			if("skills")
				var/list/skilltypes = subtypesof(/datum/skills)
				var/list/skillnames = list()
				for(var/i in skilltypes)
					var/datum/skills/S = i
					skillnames[initial(S.name)] = S
				var/newskillset = input("Select a skillset.", "Edit Rank") as null|anything in sortList(skillnames)
				if(!newskillset)
					return
				var/pickedtype = skillnames[newskillset]
				var/datum/skills/S = pickedtype
				previous = H.skills.name
				change = initial(S.name)
				H.set_skills(getSkillsType(pickedtype))
			if("commstitle")
				change = input("Input a comms title - \[Requisitions (Title)\]", "Edit Rank") as null|text
				if(!change || !istype(H) || !H.mind)
					return
				previous = H.comm_title
				H.comm_title = change
			if("chattitle")
				var/obj/item/card/id/C = locate(href_list["id"]) in GLOB.id_card_list
				change = input("Input a chat title - Title Jane Doe screams!", "Edit Rank") as null|text
				if(isnull(change) || !istype(H) || !istype(C))
					return
				previous = C.paygrade
				C.paygrade = change
				C.update_label()
			if("idtitle")
				var/obj/item/card/id/C = locate(href_list["id"]) in GLOB.id_card_list
				change = input("Input an ID title - Jane Doe (Title)", "Edit Rank") as null|text
				if(isnull(change) || !istype(H) || !istype(C))
					return
				previous = C.assignment
				C.assignment = change
				C.update_label()
			if("idname")
				var/obj/item/card/id/C = locate(href_list["id"]) in GLOB.id_card_list
				change = input("Input an ID name - Jane Doe (Title)", "Edit Rank") as null|text
				if(isnull(change) || !istype(H) || !istype(C))
					return
				previous = C.registered_name
				C.registered_name = change
				C.update_label()
			if("access")
				var/obj/item/card/id/C = locate(href_list["id"]) in GLOB.id_card_list
				change = input("Choose the new access.", "Edit Rank") as null|anything in sortList(SSjob.name_occupations)
				if(!change || !istype(H) || !istype(C))
					return
				var/datum/job/J = SSjob.name_occupations[change]
				previous = get_access_job_name(C)
				C.access = J.access
			if("createid")
				if(!istype(H) || H.wear_id)
					return
				H.equip_to_slot_or_del(new /obj/item/card/id(H), SLOT_WEAR_ID)
			if("squad")
				previous = H.assigned_squad
				change = input("Choose the marine's new squad.", "Change Squad") as null|anything in SSjob.squads
				if(!change || !istype(H))
					return
				if(!ismarinejob(H.job) && !issommarinejob(H.job))
					to_chat(usr, span_warning("Only marine jobs may be part of squads."))
					return
				H.change_squad(change)
			if("equipment")
				var/list/job_paths = subtypesof(/datum/outfit/job)
				var/list/job_outfits = list()
				for(var/path in job_paths)
					var/datum/outfit/O = path
					if(initial(O.can_be_admin_equipped))
						var/outfit_name = initial(O.name)
						job_outfits[outfit_name] = path

				var/list/picker = sortList(job_outfits)
				picker.Insert(1, "{Naked}")

				var/dresscode = input("Select job equipment", "Select Equipment") as null|anything in picker

				if(dresscode != "{Naked}")
					dresscode = job_outfits[dresscode]

				if(!dresscode || !istype(H))
					return

				var/datum/outfit/O
				H.delete_equipment(TRUE)
				if(dresscode != "{Naked}")
					O = new dresscode
					H.equipOutfit(O, FALSE)

				H.regenerate_icons()
				change = istype(O) ?  O.name : dresscode

		usr.client.holder.rank_and_equipment(H)

		if(change)
			log_admin("[key_name(usr)] updated the [href_list["rank"]][previous ? " from [previous]" : ""] to [change][addition] of [key_name(H)].")
			message_admins("[ADMIN_TPMONTY(usr)] updated the [href_list["rank"]][previous ? " from [previous]" : ""] to [change][addition] of [ADMIN_TPMONTY(H)].")
		else
			log_admin("[key_name(usr)] updated the rank: [href_list["rank"]] of [key_name(H)].")
			message_admins("[ADMIN_TPMONTY(usr)] updated the rank: [href_list["rank"]] of [ADMIN_TPMONTY(H)].")

		if(href_list["doset"])
			Topic(usr.client.holder, list("admin_token" = RawHrefToken(TRUE), "rank" = "equipment", "mob" = REF(H)))


	else if(href_list["xeno"])
		if(!check_rights(R_FUN))
			return

		var/mob/living/carbon/xenomorph/X = locate(href_list["mob"]) in GLOB.xeno_mob_list
		if(!istype(X))
			to_chat(usr, span_warning("Target is no longer valid."))
			return

		var/change
		var/previous
		var/old_keyname = key_name(X)

		switch(href_list["xeno"])
			if("hive")
				previous = X.hivenumber

				var/newhive = input("Select a hive.", "Xeno Panel") as null|anything in GLOB.hive_datums
				if(!newhive)
					return

				var/datum/hive_status/S = GLOB.hive_datums[newhive]

				change = S.hivenumber
				if(previous == change)
					return

				if(!istype(X) || X.hivenumber != previous)
					to_chat(usr, span_warning("Target is no longer valid."))
					return

				X.transfer_to_hive(change)

			if("nicknumber")
				previous = X.nicknumber

				change = input("Select a nicknumber.", "Xeno Panel", previous)
				if(!change || change == previous)
					return

				if(!istype(X))
					to_chat(usr, span_warning("Target is no longer valid."))
					return

				X.nicknumber = change
				X.generate_name()

			if("upgrade")
				previous = X.xeno_caste.upgrade

				change = input("Select a new upgrade tier.", "Xeno Panel") as null|anything in (GLOB.xenoupgradetiers - XENO_UPGRADE_BASETYPE - XENO_UPGRADE_INVALID - XENO_UPGRADE_MANIFESTATION)
				if(!change || change == previous)
					return

				if(!istype(X))
					to_chat(usr, span_warning("Target is no longer valid."))
					return

				X.upgrade_xeno(change)
				if(change != XENO_UPGRADE_NORMAL)
					var/datum/xeno_caste/previous_maturity = GLOB.xeno_caste_datums[X.caste_base_type][X.upgrade_prev()]
					X.upgrade_stored = previous_maturity.upgrade_threshold

		DIRECT_OUTPUT(usr, browse(null, "window=xeno_panel_[old_keyname]"))
		usr.client.holder.xeno_panel(X)

		log_admin("[key_name(usr)] changed [href_list["xeno"]] of [X] from [previous] to [change].")
		message_admins("[ADMIN_TPMONTY(usr)] changed [href_list["xeno"]] of [ADMIN_TPMONTY(X)] from [previous] to [change].")
	else if(href_list["adminapproval"])
		var/approval_id = href_list["adminapproval"] // Already text at this point
		if(GLOB.admin_approvals[approval_id] != -1)
			to_chat(usr, span_warning("That approval has already been answered with '[GLOB.admin_approvals[approval_id]]'"))
			return
		GLOB.admin_approvals[approval_id] = href_list["option"]
		log_admin("[key_name(usr)] answered '[href_list["option"]]' to the admin approval ([approval_id]).")
		message_admins("[key_name(usr)] answered '[href_list["option"]]' to the admin approval ([approval_id]).")

	else if(href_list["reloadpolls"])
		GLOB.polls.Cut()
		GLOB.poll_options.Cut()
		load_poll_data()
		poll_list_panel()

	else if(href_list["newpoll"])
		poll_management_panel()

	else if(href_list["editpoll"])
		var/datum/poll_question/poll = locate(href_list["editpoll"]) in GLOB.polls
		poll_management_panel(poll)

	else if(href_list["deletepoll"])
		var/datum/poll_question/poll = locate(href_list["deletepoll"]) in GLOB.polls
		poll.delete_poll()
		poll_list_panel()

	else if(href_list["initializepoll"])
		poll_parse_href(href_list)

	else if(href_list["submitpoll"])
		var/datum/poll_question/poll = locate(href_list["submitpoll"]) in GLOB.polls
		poll_parse_href(href_list, poll)

	else if(href_list["clearpollvotes"])
		var/datum/poll_question/poll = locate(href_list["clearpollvotes"]) in GLOB.polls
		poll.cleaR_DBRANKS_votes()
		poll_management_panel(poll)

	else if(href_list["addpolloption"])
		var/datum/poll_question/poll = locate(href_list["addpolloption"]) in GLOB.polls
		poll_option_panel(poll)

	else if(href_list["editpolloption"])
		var/datum/poll_option/option = locate(href_list["editpolloption"]) in GLOB.poll_options
		var/datum/poll_question/poll = locate(href_list["parentpoll"]) in GLOB.polls
		poll_option_panel(poll, option)

	else if(href_list["deletepolloption"])
		var/datum/poll_option/option = locate(href_list["deletepolloption"]) in GLOB.poll_options
		var/datum/poll_question/poll = option.delete_option()
		poll_management_panel(poll)

	else if(href_list["submitoption"])
		var/datum/poll_option/option = locate(href_list["submitoption"]) in GLOB.poll_options
		var/datum/poll_question/poll = locate(href_list["submitoptionpoll"]) in GLOB.polls
		poll_option_parse_href(href_list, poll, option)

	else if(href_list["cancelob"])
		var/timerid_to_cancel = href_list["cancelob"]
		deltimer(timerid_to_cancel)
		var/logtext = "[key_name(usr)] has cancelled an OB with the timerid [timerid_to_cancel]"
		message_admins(logtext)
		log_admin(logtext)
