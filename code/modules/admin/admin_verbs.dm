/datum/admins/proc/admin_ghost()
	set category = "Admin"
	set name = "Aghost"
	set desc = "Allows you to ghost and re-enter body at will."

	if(!check_rights(R_ADMIN|R_MENTOR))
		return

	var/mob/M = usr

	if(istype(M, /mob/new_player))
		return

	if(istype(M, /mob/dead/observer))
		var/mob/dead/observer/ghost = M
		ghost.can_reenter_corpse = TRUE
		ghost.reenter_corpse()
		return

	usr.client.change_view(world.view)
	var/msg = usr.client.key
	log_admin("[key_name(usr)] admin ghosted.")
	if(M.stat != DEAD)
		message_admins("[ADMIN_TPMONTY(usr)] admin ghosted.")
	M.ghostize(TRUE)
	if(M && !M.key)
		M.key = "@[msg]"


/datum/admins/proc/invisimin()
	set name = "Invisimin"
	set category = "Admin"
	set desc = "Toggles ghost-like invisibility."

	if(!check_rights(R_ADMIN))
		return

	var/mob/M = usr

	if(isobserver(M))
		return

	if(M.invisibility == INVISIBILITY_OBSERVER)
		M.invisibility = initial(M.invisibility)
		M.alpha = max(M.alpha + 100, 255)
		M.add_to_all_mob_huds()
	else
		M.invisibility = INVISIBILITY_OBSERVER
		M.alpha = max(M.alpha - 100, 0)
		M.remove_from_all_mob_huds()

	log_admin("[key_name(usr)] has [(M.invisibility == INVISIBILITY_OBSERVER) ? "enabled" : "disabled"] invisimin.")
	message_admins("[ADMIN_TPMONTY(usr)] has [(M.invisibility == INVISIBILITY_OBSERVER) ? "enabled" : "disabled"] invisimin.")


/datum/admins/proc/stealth_mode()
	set category = "Admin"
	set name = "Stealth Mode"
	set desc = "Allows you to change your ckey for non-admins to see."

	if(!check_rights(R_ADMIN))
		return

	if(usr.client.holder.fakekey)
		usr.client.holder.fakekey = null
	else
		var/new_key = ckeyEx(input("Enter your desired display name.",, usr.client.key) as text|null)
		if(!new_key)
			return
		if(length(new_key) >= 26)
			new_key = copytext(new_key, 1, 26)
		usr.client.holder.fakekey = new_key
		usr.client.create_stealth_key()

	log_admin("[key_name(usr)] has turned stealth mode [usr.client.holder.fakekey ? "on - [usr.client.holder.fakekey]" : "off"].")
	message_admins("[ADMIN_TPMONTY(usr)] has turned stealth mode [usr.client.holder.fakekey ? "on - [usr.client.holder.fakekey]" : "off"].")


/datum/admins/proc/change_key(mob/M in GLOB.alive_mob_list)
	set category = "Admin"
	set name = "Change CKey"
	set desc = "Allows you to properly change the ckey of a mob."

	if(!check_rights(R_ADMIN))
		return

	var/new_ckey = input("Enter new ckey:","CKey") as null|text

	if(!new_ckey)
		return

	M.ghostize(FALSE)
	M.ckey = new_ckey
	if(M.client)
		M.client.change_view(world.view)

	log_admin("[key_name(usr)] changed [M.name] ckey to [new_ckey].")
	message_admins("[ADMIN_TPMONTY(usr)] changed [M.name] ckey to [new_ckey].")


/datum/admins/proc/rejuvenate(mob/living/M as mob in GLOB.mob_living_list)
	set category = "Admin"
	set name = "Rejuvenate"
	set desc = "Revives a mob."

	if(!check_rights(R_ADMIN))
		return

	if(!M || !istype(M))
		return

	M.revive()

	log_admin("[key_name(usr)] revived [key_name(M)].")
	message_admins("[ADMIN_TPMONTY(usr)] revived [ADMIN_TPMONTY(M)].")


/datum/admins/proc/toggle_sleep(var/mob/living/M as mob in GLOB.mob_living_list)
	set category = "Admin"
	set name = "Toggle Sleeping"

	if(!check_rights(R_ADMIN))
		return

	if(M.sleeping > 0)
		M.sleeping = 0
	else
		M.sleeping = 9999999

	log_admin("[key_name(usr)] has [M.sleeping ? "enabled" : "disabled"] sleeping on [key_name(M)].")
	message_admins("[ADMIN_TPMONTY(usr)] has [M.sleeping ? "enabled" : "disabled"] sleeping on [ADMIN_TPMONTY(M)].")


/datum/admins/proc/toggle_sleep_area()
	set category = "Admin"
	set name = "Toggle Sleeping Area"

	if(!check_rights(R_ADMIN))
		return

	switch(alert("Sleep or unsleep everyone?",,"Sleep","Unsleep","Cancel"))
		if("Sleep")
			for(var/mob/living/M in view())
				M.sleeping = 9999999
			log_admin("[key_name(usr)] has slept everyone in view.")
			message_admins("[ADMIN_TPMONTY(usr)] has slept everyone in view.")
		if("Unsleep")
			for(var/mob/living/M in view())
				M.sleeping = 0
			log_admin("[key_name(usr)] has unslept everyone in view.")
			message_admins("[ADMIN_TPMONTY(usr)] has unslept everyone in view.")


/datum/admins/proc/change_squad(var/mob/living/carbon/human/H in GLOB.human_mob_list)
	set category = "Admin"
	set name = "Change Squad"

	if(!check_rights(R_ADMIN))
		return

	if(!istype(H) || !SSticker || !H.mind?.assigned_role)
		return

	if(!(H.mind.assigned_role in JOBS_MARINES))
		return

	var/squad = input("Choose the marine's new squad") as null|anything in SSjob.squads
	if(!squad)
		return

	var/datum/squad/S = SSjob.squads[squad]
	if(!S?.usable)
		return

	var/datum/job/J = SSjob.name_occupations[H.mind.assigned_role]
	var/datum/outfit/job/O = new J.outfit
	O.post_equip(H)

	H.assigned_squad?.remove_marine_from_squad(H)

	S.put_marine_in_squad(H)

	//Crew manifest
	for(var/datum/data/record/t in data_core.general)
		if(t.fields["name"] == H.real_name)
			t.fields["squad"] = S.name
			break

	var/obj/item/card/id/ID = H.wear_id
	ID.assigned_fireteam = 0

	//Headset frequency.
	if(istype(H.wear_ear, /obj/item/device/radio/headset/almayer/marine))
		var/obj/item/device/radio/headset/almayer/marine/E = H.wear_ear
		E.set_frequency(S.radio_freq)
	else
		if(H.wear_ear)
			H.dropItemToGround(H.wear_ear)
		var/obj/item/device/radio/headset/almayer/marine/E = new /obj/item/device/radio/headset/almayer/marine(H)
		H.equip_to_slot_or_del(E, SLOT_EARS)
		E.set_frequency(S.radio_freq)
		H.update_icons()

	H.hud_set_squad()

	log_admin("[key_name(src)] has changed the squad of [key_name(H)] to [S.name].")
	message_admins("[ADMIN_TPMONTY(usr)] has changed the squad of [ADMIN_TPMONTY(H)] to [S.name].")


/datum/admins/proc/direct_control(var/mob/M in GLOB.mob_list)
	set category = "Admin"
	set name = "Take Over"
	set desc = "Rohesie's verb."

	if(!check_rights(R_ADMIN))
		return

	if(istype(usr, /mob/new_player))
		return

	var/replaced = FALSE
	if(M.key)
		if(usr.client.key == copytext(M.key,2))
			var/mob/dead/observer/ghost = usr
			ghost.can_reenter_corpse = TRUE
			ghost.reenter_corpse()
			return
		else if(alert("This mob is being controlled by [M.key], they will be made a ghost. Are you sure?",,"Yes","No") == "Yes")
			M.ghostize()
			replaced = TRUE
		else
			return

	var/log = "[key_name(usr)]"
	var/message = "[ADMIN_TPMONTY(usr)]"
	var/oldkey = "[M.key]"
	M.key = usr.client.key

	M.client.change_view(world.view)

	log_admin("[log] took over [M.name][replaced ? " replacing the previous owner [key_name(oldkey)]" : ""].")
	message_admins("[message] took over [M.name][replaced ? " replacing the previous owner [key_name_admin(oldkey)]" : ""].")


/datum/admins/proc/logs_server()
	set category = "Admin"
	set name = "Get Server Logs"

	if(!check_rights(R_ASAY))
		return

	usr.client.holder.browse_server_logs()


/datum/admins/proc/logs_current()
	set category = "Admin"
	set name = "Get Current Logs"
	set desc = "View/retrieve logfiles for the current round."

	if(!check_rights(R_ASAY))
		return

	usr.client.holder.browse_server_logs("[GLOB.log_directory]/")


/datum/admins/proc/logs_folder()
	set name = "Get Server Logs Folder"
	set desc = "Please use responsibly."
	set category = "Admin"

	if(!check_rights(R_ASAY))
		return

	var/choice = alert("Due to the way BYOND handles files, you WILL need a click macro. This function is also recurive and prone to fucking up, especially if you select the wrong folder. Are you absolutely sure you want to proceed?", "WARNING", "Yes", "No")
	if(choice != "Yes")
		return

	var/path = "data/logs/"
	path = usr.client.holder.browse_folders(path)

	if(path)
		usr.client.holder.recursive_download(path)


/datum/admins/proc/browse_server_logs(path = "data/logs/")
	if(!check_rights(R_ADMIN))
		return

	path = browse_files(path)
	if(!path)
		return

	switch(alert("View (in game), Open (in your system's text editor), Download", path, "View", "Open", "Download"))
		if("View")
			usr << browse("<pre style='word-wrap: break-word;'>[html_encode(file2text(file(path)))]</pre>", list2params(list("window" = "viewfile.[path]")))
		if("Open")
			usr << run(file(path))
		if("Download")
			usr << ftp(file(path))

	log_admin("[key_name(usr)] accessed file: [path].")
	message_admins("[ADMIN_TPMONTY(usr)] accessed file: [path].")


/datum/admins/proc/recursive_download(var/folder)
	if(!check_rights(R_ADMIN))
		return

	var/files = flist(folder)
	for(var/next in files)
		if(copytext(next, -1, 0) == "/")
			to_chat(usr, "Going deeper: [folder][next]")
			usr.client.holder.recursive_download(folder + next)
		else
			to_chat(usr, "Downloading: [folder][next]")
			var/fil = replacetext("[folder][next]", "/", "_")
			spawn(5)
				usr << ftp(file(folder + next), fil)


/datum/admins/proc/browse_folders(root = "data/logs/", max_iterations = 100)
	if(!check_rights(R_ADMIN))
		return

	var/path = root
	for(var/i = 0, i < max_iterations, i++)
		var/list/choices = flist(path)
		if(path != root)
			choices.Insert(1, "/")
		var/choice = input("Choose a folder to access:", "Download", null) as null|anything in choices
		switch(choice)
			if(null)
				return FALSE
			if("/")
				path = root
				continue
		path += choice

		if(copytext(path, -1, 0) != "/")		//didn't choose a directory, no need to iterate again
			return FALSE
		else
			var/choice2 = alert("Is this the folder you want to download?:",, "Yes", "No")
			switch(choice2)
				if("Yes")
					break
				if("No")
					continue
	return path


/datum/admins/proc/browse_files(root="data/logs/", max_iterations = 20 , list/valid_extensions = list("txt","log","htm", "html"))
	if(!check_rights(R_ADMIN))
		return

	var/path = root
	for(var/i = 0, i < max_iterations, i++)
		var/list/choices = flist(path)
		if(path != root)
			choices.Insert(1, "/")
		var/choice = input("Choose a file to access:", "Download", null) as null|anything in choices
		switch(choice)
			if(null)
				return
			if("/")
				path = root
				continue
		path += choice
		if(copytext(path, -1, 0) != "/")		//didn't choose a directory, no need to iterate again
			break
	var/extensions
	for(var/i in valid_extensions)
		if(extensions)
			extensions += "|"
		extensions += "[i]"
	var/regex/valid_ext = new("\\.([extensions])$", "i")
	if(!fexists(path) || !(valid_ext.Find(path)))
		return FALSE

	return path


/datum/admins/proc/show_individual_logging_panel(mob/M, source = LOGSRC_CLIENT, type = INDIVIDUAL_ATTACK_LOG)
	if(!check_rights(R_ADMIN))
		return

	if(!M || !ismob(M))
		return

	var/ntype = text2num(type)

	var/dat = ""
	if(M.client)
		dat += "<center><p>Client</p></center>"
		dat += "<center>"
		dat += individual_logging_panel_link(M, INDIVIDUAL_ATTACK_LOG, LOGSRC_CLIENT, "Attack Log", source, ntype)
		dat += " | "
		dat += individual_logging_panel_link(M, INDIVIDUAL_SAY_LOG, LOGSRC_CLIENT, "Say Log", source, ntype)
		dat += " | "
		dat += individual_logging_panel_link(M, INDIVIDUAL_EMOTE_LOG, LOGSRC_CLIENT, "Emote Log", source, ntype)
		dat += " | "
		dat += individual_logging_panel_link(M, INDIVIDUAL_COMMS_LOG, LOGSRC_CLIENT, "Comms Log", source, ntype)
		dat += " | "
		dat += individual_logging_panel_link(M, INDIVIDUAL_OOC_LOG, LOGSRC_CLIENT, "OOC Log", source, ntype)
		dat += " | "
		dat += individual_logging_panel_link(M, INDIVIDUAL_SHOW_ALL_LOG, LOGSRC_CLIENT, "Show All", source, ntype)
		dat += "</center>"
	else
		dat += "<p> No client attached to mob </p>"

	dat += "<hr style='background:#000000; border:0; height:1px'>"
	dat += "<center><p>Mob</p></center>"

	dat += "<center>"
	dat += individual_logging_panel_link(M, INDIVIDUAL_ATTACK_LOG, LOGSRC_MOB, "Attack Log", source, ntype)
	dat += " | "
	dat += individual_logging_panel_link(M, INDIVIDUAL_SAY_LOG, LOGSRC_MOB, "Say Log", source, ntype)
	dat += " | "
	dat += individual_logging_panel_link(M, INDIVIDUAL_EMOTE_LOG, LOGSRC_MOB, "Emote Log", source, ntype)
	dat += " | "
	dat += individual_logging_panel_link(M, INDIVIDUAL_COMMS_LOG, LOGSRC_MOB, "Comms Log", source, ntype)
	dat += " | "
	dat += individual_logging_panel_link(M, INDIVIDUAL_OOC_LOG, LOGSRC_MOB, "OOC Log", source, ntype)
	dat += " | "
	dat += individual_logging_panel_link(M, INDIVIDUAL_SHOW_ALL_LOG, LOGSRC_MOB, "Show All", source, ntype)
	dat += "</center>"

	dat += "<hr style='background:#000000; border:0; height:1px'>"

	var/log_source = M.logging;
	if(source == LOGSRC_CLIENT && M.client)
		log_source = M.client.player_details.logging

	for(var/log_type in log_source)
		var/nlog_type = text2num(log_type)
		if(nlog_type & ntype)
			var/list/reversed = log_source[log_type]
			if(islist(reversed))
				reversed = reverseRange(reversed.Copy())
				for(var/entry in reversed)
					dat += "<font size=2px><b>[entry]</b><br>[reversed[entry]]</font><br>"
			dat += "<hr>"

	usr << browse(dat, "window=invidual_logging_[key_name(M)];size=600x480")


/datum/admins/proc/individual_logging_panel_link(mob/M, log_type, log_src, label, selected_src, selected_type)
	if(!check_rights(R_ADMIN))
		return

	var/slabel = label
	if(selected_type == log_type && selected_src == log_src)
		slabel = "<b>\[[label]\]</b>"

	return "<a href='?src=[REF(usr.client.holder)];[HrefToken()];individuallog=[REF(M)];log_type=[log_type];log_src=[log_src]'>[slabel]</a>"


/datum/admins/proc/asay(msg as text)
	set category = "Admin"
	set name = "asay"
	set hidden = TRUE

	if(!check_rights(R_ASAY))
		return

	msg = noscript(msg)

	if(!msg)
		return

	log_admin_private_asay("[key_name(usr)]: [msg]")

	var/color = "adminsay"
	if(check_rights(R_PERMISSIONS, FALSE))
		color = "headminsay"

	msg = "<span class='[color]'><span class='prefix'>ADMIN:</span> [ADMIN_TPMONTY(usr)]: <span class='message'>[msg]</span></span>"
	for(var/client/C in GLOB.admins)
		if(check_other_rights(C, R_ASAY, FALSE))
			to_chat(C, msg)


/datum/admins/proc/msay(msg as text)
	set category = "Admin"
	set name = "msay"
	set hidden = TRUE

	if(!check_rights(R_ADMIN|R_MENTOR))
		return

	if(!check_rights(R_ADMIN, FALSE))
		msg = copytext(sanitize(msg), 1, MAX_MESSAGE_LEN)
	else
		msg = noscript(msg)

	if(!msg)
		return

	log_admin_private_msay("[key_name(usr)]: [msg]")

	var/color = "mod"
	if(check_rights(R_PERMISSIONS, FALSE))
		color = "headminmod"
	else if(check_rights(R_ADMIN, FALSE))
		color = "adminmod"

	for(var/client/C in GLOB.admins)
		if(check_other_rights(C, R_ADMIN, FALSE))
			to_chat(C, "<span class='[color]'><span class='prefix'>[usr.client.holder.rank.name]:</span> [ADMIN_TPMONTY(usr)]: <span class='message'>[msg]</span></span>")
		else if(is_mentor(C) && usr.stat == DEAD)
			to_chat(C, "<span class='[color]'><span class='prefix'>[usr.client.holder.rank.name]:</span> [key_name_admin(usr, TRUE, TRUE, FALSE)] [ADMIN_JMP(usr)] [ADMIN_FLW(usr)]: <span class='message'>[msg]</span></span>")
		else if(is_mentor(C))
			to_chat(C, "<span class='[color]'><span class='prefix'>[usr.client.holder.rank.name]:</span> [key_name_admin(usr, TRUE, FALSE, FALSE)] [ADMIN_JMP(usr)] [ADMIN_FLW(usr)]: <span class='message'>[msg]</span></span>")


/datum/admins/proc/dsay(msg as text)
	set category = "Admin"
	set name = "dsay"
	set hidden = TRUE

	if(!check_rights(R_ADMIN|R_MENTOR))
		return

	if(is_mentor(src) && usr.stat != DEAD)
		to_chat(usr, "<span class='warning'>You must be an observer to use dsay.</span>")
		return

	if(usr.client.prefs.muted & MUTE_DEADCHAT)
		to_chat(usr, "<span class='warning'>You cannot send DSAY messages (muted).</span>")
		return

	if(!(usr.client.prefs.toggles_chat & CHAT_DEAD))
		to_chat(usr, "<span class='warning'>You have deadchat muted.</span>")
		return

	if(usr.client.handle_spam_prevention(msg, MUTE_DEADCHAT))
		return

	msg = noscript(msg)

	if(!msg)
		return

	log_dsay("[key_name(usr)]: [msg]")
	msg = "<span class='game deadsay'><span class='prefix'>DEAD:</span> <span class='name'>([usr.client.holder.fakekey ? "" : usr.client.holder.rank.name]) [usr.client.holder.fakekey ? "Administrator" : usr.key]</span> says, \"<span class='message'>[msg]</span>\"</span>"

	for(var/client/C in GLOB.clients)
		if(istype(C.mob, /mob/new_player))
			continue

		if(check_other_rights(C, R_ADMIN, FALSE) && (C.prefs.toggles_chat & CHAT_DEAD))
			to_chat(C, msg)

		else if(C.mob.stat == DEAD && (C.prefs.toggles_chat & CHAT_DEAD))
			to_chat(C, msg)


/mob/proc/on_mob_jump()
	return


/mob/dead/observer/on_mob_jump()
	unfollow()


/datum/admins/proc/jump_area(var/area/A in return_sorted_areas())
	set category = "Admin"
	set name = "Jump to Area"

	if(!check_rights(R_ADMIN))
		return

	var/mob/M = usr
	var/target = pick(get_area_turfs(A))
	M.on_mob_jump()
	M.forceMove(target)

	log_admin("[key_name(usr)] jumped to [AREACOORD(M)].")
	if(!isobserver(M))
		message_admins("[ADMIN_TPMONTY(usr)] jumped to [ADMIN_VERBOSEJMP(M)].")


/datum/admins/proc/jump_turf(var/turf/T in GLOB.turfs)
	set category = "Admin"
	set name = "Jump to Turf"

	if(!check_rights(R_ADMIN))
		return

	if(!T)
		return

	var/mob/M = usr
	M.on_mob_jump()
	M.forceMove(T)

	log_admin("[key_name(M)] jumped to turf [AREACOORD(T)].")
	if(!isobserver(M))
		message_admins("[ADMIN_TPMONTY(M)] jumped to turf [ADMIN_VERBOSEJMP(T)].")


/datum/admins/proc/jump_coord(tx as num, ty as num, tz as num)
	set category = "Admin"
	set name = "Jump to Coordinate"

	if(!check_rights(R_ADMIN) && is_mentor(src))
		return

	var/mob/M = usr
	M.on_mob_jump()
	M.x = tx
	M.y = ty
	M.z = tz
	var/turf/T = get_turf(M)
	M.forceMove(T)

	log_admin("[key_name(M)] jumped to coordinate [AREACOORD(T)].")
	if(!isobserver(M))
		message_admins("[ADMIN_TPMONTY(M)] jumped to coordinate [ADMIN_VERBOSEJMP(T)].")


/datum/admins/proc/jump_mob()
	set category = "Admin"
	set name = "Jump to Mob"

	if(!check_rights(R_ADMIN))
		return

	var/selection = input("Please, select a mob.", "Jump to Mob") as null|anything in sortmobs(GLOB.mob_list)
	if(!selection)
		return

	var/mob/M = selection
	var/mob/N = usr
	var/turf/T = get_turf(M)

	N.on_mob_jump()
	N.forceMove(T)

	log_admin("[key_name(N)] jumped to [key_name(M)]'s mob [AREACOORD(T)]")
	if(!isobserver(N))
		message_admins("[ADMIN_TPMONTY(N)] jumped to [ADMIN_TPMONTY(T)].")


/datum/admins/proc/jump_key()
	set category = "Admin"
	set name = "Jump to Key"

	if(!check_rights(R_ADMIN))
		return

	var/selection = input("Please, select a key.", "Jump to Key") as null|anything in sortKey(GLOB.clients)
	if(!selection)
		return

	var/mob/M = selection:mob
	if(!M)
		return

	var/mob/N = usr
	var/turf/T = get_turf(M)

	N.on_mob_jump()
	N.forceMove(T)

	log_admin("[key_name(usr)] jumped to [key_name(M)]'s key [AREACOORD(T)].")
	if(!isobserver(N))
		message_admins("[ADMIN_TPMONTY(usr)] jumped to [ADMIN_TPMONTY(T)].")


/datum/admins/proc/get_mob()
	set category = "Admin"
	set name = "Get Mob"

	if(!check_rights(R_ADMIN))
		return

	var/selection = input("Please, select a mob.", "Get Mob") as null|anything in sortmobs(GLOB.mob_list)
	if(!selection)
		return

	var/mob/M = selection
	var/mob/N = usr
	var/turf/T = get_turf(N)

	M.on_mob_jump()
	M.forceMove(T)

	log_admin("[key_name(usr)] teleported [key_name(M)]'s mob to themselves [AREACOORD(M.loc)].")
	message_admins("[ADMIN_TPMONTY(usr)] teleported [ADMIN_TPMONTY(M)]'s mob to themselves.")


/datum/admins/proc/get_key()
	set category = "Admin"
	set name = "Get Key"
	set desc = "Teleport mob based on the client's ckey."

	if(!check_rights(R_ADMIN))
		return

	var/list/keys = list()
	for(var/mob/M in GLOB.player_list)
		keys += M.client

	var/selection = input("Please, select a key.", "Get Key") as null|anything in sortKey(keys)
	if(!selection)
		return

	var/mob/M = selection:mob

	M.on_mob_jump()
	M.loc = get_turf(usr)

	log_admin("[key_name(usr)] teleported [key_name(M)]'s key to themselves [AREACOORD(M.loc)].")
	message_admins("[ADMIN_TPMONTY(usr)] teleported [ADMIN_TPMONTY(M)]'s key to themselves.")


/datum/admins/proc/send_mob()
	set category = "Admin"
	set name = "Send Mob"

	if(!check_rights(R_ADMIN))
		return

	var/selection = input("Please, select a mob!", "Send Mob", null, null) as null|anything in sortmobs(GLOB.mob_list)
	if(!selection)
		return

	var/mob/M = selection
	var/atom/target


	switch(input("Where do you want to send it to?", "Send Mob") as null|anything in list("Area", "Mob", "Key"))
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

	M.on_mob_jump()
	M.forceMove(target)

	log_admin("[key_name(usr)] teleported [key_name(M)] to [AREACOORD(M.loc)].")
	message_admins("[ADMIN_TPMONTY(usr)] teleported [ADMIN_TPMONTY(M)] to [ADMIN_VERBOSEJMP(M.loc)].")


/datum/admins/proc/send_key()
	set category = "Admin"
	set name = "Send Key"

	if(!check_rights(R_ADMIN))
		return

	var/selection = input("Please, select a key!", "Send Key") as null|anything in sortKey(GLOB.clients)
	if(!selection)
		return

	var/mob/M = selection:mob
	var/atom/target


	switch(input("Where do you want to send it to?", "Send Key") as null|anything in list("Area", "Mob", "Key"))
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

	M.on_mob_jump()
	M.forceMove(target)

	log_admin("[key_name(usr)] teleported [key_name(M)] to [AREACOORD(M.loc)].")
	message_admins("[ADMIN_TPMONTY(usr)] teleported [ADMIN_TPMONTY(M)] to [ADMIN_VERBOSEJMP(M.loc)].")


#define IRCREPLYCOUNT 2
/client/proc/private_message_context(var/mob/M in GLOB.mob_list)
	set category = null
	set name = "Private Message Mob"

	if(!check_rights(R_ADMIN, FALSE) && !is_mentor(src))
		return

	if(!istype(M))
		return

	private_message(M.client, null)


/client/proc/private_message_panel()
	set category = "Admin"
	set name = "Private Message"

	if(!check_rights(R_ADMIN, FALSE) && !is_mentor(src))
		return

	var/list/client/targets[0]
	for(var/client/T)
		if(T.mob)
			if(isnewplayer(T.mob))
				targets["[T] - (New Player)"] = T
			else if(isobserver(T.mob))
				targets["[T.mob.name](Ghost) - [T]"] = T
			else
				targets["[T.mob.real_name](as [T.mob.name]) - [T]"] = T
		else
			targets["[T] - (No Mob)"] = T

	var/target = input("Who do you want to PM?", "Private Message", null) as null|anything in sortList(targets)
	if(!target)
		return

	private_message(targets[target], null)


/client/proc/ticket_reply(whom)
	if(prefs.muted & MUTE_ADMINHELP)
		to_chat(src, "<span class='warning'>Error: You are unable to use admin PMs (muted).</span>")
		return

	var/client/C
	if(istext(whom))
		if(cmptext(copytext(whom,1,2),"@"))
			whom = find_stealth_key(whom)
		C = GLOB.directory[whom]
	else if(istype(whom, /client))
		C = whom

	if(!C)
		if(holder)
			to_chat(src, "<span class='warning'>Error: Client not found.</span>")
		return

	var/datum/admin_help/AH = C.current_ticket

	if(AH.tier == TICKET_ADMIN && !check_rights(R_ADMIN, FALSE))
		return

	if(AH && !AH.marked)
		AH.marked = usr.client
		if(AH.tier == TICKET_MENTOR)
			message_staff("[key_name_admin(src)] has marked and started replying to [key_name_admin(C, FALSE, FALSE)]'s ticket.")
		else if(AH.tier == TICKET_ADMIN)
			if(!check_rights(R_ADMIN, FALSE))
				return
			message_admins("[key_name_admin(src)] has marked and started replying to [key_name_admin(C, FALSE, FALSE)]'s ticket.")

	else if(AH && AH.marked != usr.client)
		to_chat(usr, "<span class='warning'>This ticket has already been marked by [AH.marked], click the mark button to replace them.</span>")
		return
	var/msg = input("Message:", "Private message to [key_name(C, FALSE, FALSE)]") as message|null
	if(!msg)
		if(AH)
			if(AH.tier == TICKET_MENTOR)
				message_staff("[key_name_admin(src)] has cancelled their reply to [key_name_admin(C, FALSE, FALSE)]'s ticket. Ticket has been unmarked.")
			else if(AH.tier == TICKET_ADMIN)
				message_admins("[key_name_admin(src)] has cancelled their reply to [key_name_admin(C, FALSE, FALSE)]'s ticket. Ticket has been unmarked")
			AH.marked = null
		return

	private_message(whom, msg)


/client/proc/private_message(whom, msg)
	if(prefs.muted & MUTE_ADMINHELP)
		to_chat(src, "<span class='warning'>You are unable to use admin PMs (muted).</span>")
		return

	if(!holder && !current_ticket)
		to_chat(src, "<span class='warning'>You can no longer reply to this ticket, please open another one by using the Adminhelp verb if need be.</span>")
		to_chat(src, "<span class='notice'>Message: [msg]</span>")
		return

	var/client/recipient
	var/irc = FALSE
	if(istext(whom))
		if(cmptext(copytext(whom, 1, 2),"@"))
			whom = find_stealth_key(whom)
		if(whom == "IRCKEY")
			irc = TRUE
		else
			recipient = GLOB.directory[whom]

	else if(istype(whom, /client))
		recipient = whom
		if(!recipient)
			if(holder)
				to_chat(src, "<span class='warning'>Error: Client not found.</span>")
				if(msg)
					to_chat(src, msg)
				return
			else if(msg) // you want to continue if there's no message instead of returning now
				current_ticket.MessageNoRecipient(msg)
				return

	//get message text, limit it's length.and clean/escape html
	if(!msg)
		msg = input("Message:", "Private message to [key_name(recipient, FALSE, FALSE)]") as message|null
		msg = trim(msg)
		if(!msg)
			return

		if(prefs.muted & MUTE_ADMINHELP)
			to_chat(src, "<span class='warning'>You are unable to use admin PMs (muted).</span>")
			return

		if(!recipient)
			if(holder)
				to_chat(src, "<span class='warning'>Error: Client not found.</span>")
			else
				current_ticket.MessageNoRecipient(msg)
			return

	if(handle_spam_prevention(msg, MUTE_ADMINHELP))
		return

	//clean the message if it's not sent by a high-rank admin
	if(!check_rights(R_SERVER|R_DEBUG, FALSE) || irc)//no sending html to the poor bots
		msg = trim(sanitize(copytext(msg, 1, MAX_MESSAGE_LEN)))
		if(!msg)
			return

	var/rawmsg = msg

	var/keywordparsedmsg = keywords_lookup(msg)

	if(irc)
		to_chat(src, "<font color='blue'>PM to-<b>Staff</b>: <span class='linkify'>[rawmsg]</span></font>")
		var/datum/admin_help/AH = admin_ticket_log(src, "<font color='red'>Reply PM from-<b>[key_name(src, TRUE, TRUE)] to <i>IRC</i>: [keywordparsedmsg]</font>")
		send2irc("[AH ? "#[AH.id] " : ""]Reply: [ckey]", sanitizediscord(rawmsg))
	else
		if(check_other_rights(recipient, R_ADMIN, FALSE) || is_mentor(recipient))
			if(check_rights(R_ADMIN, FALSE) || is_mentor(src)) //Both are staff
				if(!current_ticket && !recipient.current_ticket)
					if(check_other_rights(recipient, R_ADMIN, FALSE) && check_rights(R_ADMIN, FALSE))
						new /datum/admin_help(msg, recipient, TRUE, TICKET_ADMIN)
					else
						new /datum/admin_help(msg, recipient, TRUE, TICKET_MENTOR)
				to_chat(recipient, "<font size='3' color='red'>Staff PM from-<b>[key_name(src, recipient, TRUE)]</b>: <span class='linkify'>[keywordparsedmsg]</span></font>")
				to_chat(src, "<font size='3' color='blue'>Staff PM to-<b>[key_name(recipient, src, TRUE)]</b>: <span class='linkify'>[keywordparsedmsg]</span></font>")

				var/interaction_message = "<font color='purple'>PM from-<b>[key_name(src, recipient, TRUE)]</b> to-<b>[key_name(recipient, src, TRUE)]</b>: [keywordparsedmsg]</font>"
				admin_ticket_log(src, interaction_message)
				if(recipient != src)
					admin_ticket_log(recipient, interaction_message)

			else //Recipient is a staff member, sender is not.
				var/replymsg = "<font size='3' color='red'>Reply PM from-<b>[key_name(src, recipient, TRUE)]</b>: <span class='linkify'>[keywordparsedmsg]</span></font>"
				admin_ticket_log(src, replymsg)
				to_chat(recipient, replymsg)
				to_chat(src, "<font color='blue'>PM to-<b>Staff</b>: <span class='linkify'>[msg]</span></font>")

			//Play the bwoink if enabled.
			if(recipient.prefs.toggles_sound & SOUND_ADMINHELP)
				SEND_SOUND(recipient, sound('sound/effects/adminhelp.ogg'))

		else  //PM sender is mentor/admin, recipient is not -> big red text
			if(check_rights(R_ADMIN, FALSE) || is_mentor(src))
				if(!recipient.current_ticket)
					if(check_rights(R_ADMIN, FALSE))
						new /datum/admin_help(msg, recipient, TRUE, TICKET_ADMIN)
					else if(is_mentor(src))
						new /datum/admin_help(msg, recipient, TRUE, TICKET_MENTOR)

				if(check_rights(R_ADMIN, FALSE))
					to_chat(recipient, "<font color='red' size='4'><b>-- Private Message --</b></font>")
					to_chat(recipient, "<font color='red'>[holder.fakekey ? "Administrator" : holder.rank.name] PM from-<b>[key_name(src, recipient, FALSE)]</b>: <span class='linkify'>[msg]</span></font>")
					to_chat(recipient, "<font color='red'><i>Click on the staff member's name to reply.</i></font>")
					to_chat(src, "<font color='blue'><b>[holder.fakekey ? "Administrator" : holder.rank.name] PM</b> to-<b>[key_name(recipient, src, TRUE)]</b>: <span class='linkify'>[msg]</span></font>")
					SEND_SOUND(recipient, sound('sound/effects/adminhelp.ogg'))
				else if(is_mentor(src))
					to_chat(recipient, "<font color='red' size='2'><b>-- Mentor Message --</b></font>")
					to_chat(recipient, "<font color='red'>[holder.rank.name] PM from-<b>[key_name(src, recipient, FALSE)]</b>: <span class='linkify'>[msg]</span></font>")
					to_chat(recipient, "<font color='red'><i>Click on the mentor's name to reply.</i></font>")
					to_chat(src, "<font color='blue'><b>[holder.rank.name] PM</b> to-<b>[key_name(recipient, src, TRUE)]</b>: <span class='linkify'>[msg]</span></font>")
					SEND_SOUND(recipient, sound('sound/effects/mentorhelp.ogg'))

				admin_ticket_log(recipient, "<font color='blue'>PM From [key_name_admin(src)]: [keywordparsedmsg]</font>")


			else		//neither are admins
				to_chat(src, "<span class='warning'>Error: Non-staff to non-staff communication is disabled.</span>")
				return

	if(irc)
		log_admin_private("PM: [key_name(src)]->IRC: [rawmsg]")
		for(var/client/X in GLOB.admins)
			if(check_other_rights(X, R_ADMIN, FALSE) || is_mentor(X))
				to_chat(X, "<font color='blue'><B>PM: [key_name(src, X, FALSE)]-&gt;IRC:</B> [keywordparsedmsg]</font>")
	else
		log_admin_private("PM: [key_name(src)]->[key_name(recipient)]: [rawmsg]")
		//Admins PMs go to admins, mentor PMs go to mentors and admins
		if(check_rights(R_ADMIN, FALSE))
			for(var/client/X in GLOB.admins)
				if(X.key == key || X.key == recipient.key)
					continue
				if(check_other_rights(X, R_ADMIN, FALSE))
					to_chat(X, "<font color='blue'><B>Admin PM: [key_name(src, X, FALSE)]-&gt;[key_name(recipient, X, FALSE)]:</B> [keywordparsedmsg]</font>")
		else if(is_mentor(src))
			for(var/client/X in GLOB.admins)
				if(X.key == key || X.key == recipient.key)
					continue
				if(check_other_rights(X, R_ADMIN, FALSE) || is_mentor(X))
					to_chat(X, "<font color='blue'><B>Mentor PM: [key_name(src, X, FALSE)]-&gt;[key_name(recipient, X, FALSE)]:</B> [keywordparsedmsg]</font>")
		else //Admins get all messages, mentors only mentor responses
			var/datum/admin_help/AH = src.current_ticket
			for(var/client/X in GLOB.admins)
				if(X.key == key || X.key == recipient.key)
					continue
				if(check_other_rights(X, R_ADMIN, FALSE))
					to_chat(X, "<font color='blue'><B>PM: [key_name(src, X, FALSE)]-&gt;[key_name(recipient, X, FALSE)]:</B> [keywordparsedmsg]</font>")
			if(AH && AH.tier == TICKET_MENTOR)
				for(var/client/X in GLOB.admins)
					if(X.key == key || X.key == recipient.key)
						continue
					if(is_mentor(X))
						to_chat(X, "<font color='blue'><B>PM: [key_name(src, X, FALSE)]-&gt;[key_name(recipient, X, FALSE)]:</B> [keywordparsedmsg]</font>")

#define IRC_AHELP_USAGE "Usage: ticket <close|resolve|icissue|reject|reopen \[ticket #\]|list>"
/proc/IrcPm(target,msg,sender)
	target = ckey(target)
	var/client/C = GLOB.directory[target]

	var/datum/admin_help/ticket = C ? C.current_ticket : GLOB.ahelp_tickets.CKey2ActiveTicket(target)
	var/compliant_msg = trim(lowertext(msg))
	var/irc_tagged = "[sender](IRC)"
	var/list/splits = splittext(compliant_msg, " ")
	if(splits.len && splits[1] == "ticket")
		if(splits.len < 2)
			return IRC_AHELP_USAGE
		switch(splits[2])
			if("close")
				if(ticket)
					ticket.Close(irc_tagged)
					return "Ticket #[ticket.id] successfully closed"
			if("resolve")
				if(ticket)
					ticket.Resolve(irc_tagged)
					return "Ticket #[ticket.id] successfully resolved"
			if("icissue")
				if(ticket)
					ticket.ICIssue(irc_tagged)
					return "Ticket #[ticket.id] successfully marked as IC issue"
			if("reject")
				if(ticket)
					ticket.Reject(irc_tagged)
					return "Ticket #[ticket.id] successfully rejected"
			if("reopen")
				if(ticket)
					return "Error: [target] already has ticket #[ticket.id] open"
				var/fail = splits.len < 3 ? null : -1
				if(!isnull(fail))
					fail = text2num(splits[3])
				if(isnull(fail))
					return "Error: No/Invalid ticket id specified. [IRC_AHELP_USAGE]"
				var/datum/admin_help/AH = GLOB.ahelp_tickets.TicketByID(fail)
				if(!AH)
					return "Error: Ticket #[fail] not found"
				if(AH.initiator_ckey != target)
					return "Error: Ticket #[fail] belongs to [AH.initiator_ckey]"
				AH.Reopen()
				return "Ticket #[ticket.id] successfully reopened"
			if("list")
				var/list/tickets = GLOB.ahelp_tickets.TicketsByCKey(target)
				if(!tickets.len)
					return "None"
				. = ""
				for(var/I in tickets)
					var/datum/admin_help/AH = I
					if(.)
						. += ", "
					if(AH == ticket)
						. += "Active: "
					. += "#[AH.id]"
				return
			else
				return IRC_AHELP_USAGE
		return "Error: Ticket could not be found"

	var/static/stealthkey
	var/adminname = "Administrator"

	if(!C)
		return "Error: No client"

	if(!stealthkey)
		stealthkey = GenIrcStealthKey()

	msg = sanitize(copytext(msg,1,MAX_MESSAGE_LEN))
	if(!msg)
		return "Error: No message"

	message_admins("IRC message from [sender] to [key_name_admin(C)] : [msg]")
	log_admin_private("IRC PM: [sender] -> [key_name(C)] : [msg]")

	to_chat(C, "<font color='red' size='4'><b>-- Administrator private message --</b></font>")
	to_chat(C, "<font color='red'>Admin PM from-<b><a href='?priv_msg=[stealthkey]'>[adminname]</A></b>: [msg]</font>")
	to_chat(C, "<font color='red'><i>Click on the administrator's name to reply.</i></font>")

	admin_ticket_log(C, "<font color='blue'>PM From [irc_tagged]: [msg]</font>")

	//always play non-admin recipients the adminhelp sound
	SEND_SOUND(C, 'sound/effects/adminhelp.ogg')

	return "Message Successful"


/proc/GenIrcStealthKey()
	var/num = (rand(0,1000))
	var/i = 0
	while(i == 0)
		i = 1
		for(var/P in GLOB.stealthminID)
			if(num == GLOB.stealthminID[P])
				num++
				i = 0
	var/stealth = "@[num2text(num)]"
	GLOB.stealthminID["IRCKEY"] = stealth
	return	stealth

#undef IRCREPLYCOUNT


/datum/admins/proc/get_all_humans()
	if(!check_rights(R_ADMIN))
		return

	for(var/client/C in GLOB.clients)
		if(isobserver(C.mob) || C.mob.stat == DEAD)
			continue
		if(ishuman(C.mob))
			C.mob.loc = get_turf(usr)


/datum/admins/proc/get_all_xenos()
	if(!check_rights(R_ADMIN))
		return

	for(var/client/C in GLOB.clients)
		if(isobserver(C.mob) || C.mob.stat == DEAD)
			continue
		if(isxeno(C.mob))
			C.mob.loc = get_turf(usr)


/datum/admins/proc/get_all()
	if(!check_rights(R_ADMIN))
		return

	for(var/client/C in GLOB.clients)
		if(isobserver(C.mob) || C.mob.stat == DEAD)
			continue
		C.mob.loc = get_turf(usr)


/datum/admins/proc/rejuv_all()
	if(!check_rights(R_ADMIN))
		return

	for(var/client/C in GLOB.clients)
		if(!isliving(C.mob))
			continue
		var/mob/living/M = C.mob
		M.revive()


/datum/admins/proc/remove_from_tank()
	set category = "Admin"
	set name = "Remove All From Tank"

	if(!check_rights(R_ADMIN))
		return

	for(var/obj/vehicle/multitile/root/cm_armored/CA in view())
		CA.remove_all_players()

		log_admin("[key_name(usr)] forcibly removed all players from [CA].")
		message_admins("[ADMIN_TPMONTY(usr)] forcibly removed all players from [CA].")


/datum/admins/proc/local_message(msg as text)
	set category = "Admin"
	set name = "Local Message"

	if(!check_rights(R_ADMIN))
		return

	msg = noscript(msg)

	if(!msg)
		return

	var/message = "<font color='#6699CC'><span class='ooc'><span class='prefix'>LOOC:</span> [usr.client.holder.fakekey ? "Administrator" : usr.client.key]: <span class='message'>[msg]</span></span></font>"

	usr.visible_message(message, message, message)


	log_admin("[key_name(usr)] has used local message to say: [msg]")
	message_admins("[ADMIN_TPMONTY(usr)] has used local message to say: [msg]")