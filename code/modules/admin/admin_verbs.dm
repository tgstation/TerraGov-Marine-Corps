/datum/admins/proc/admin_ghost()
	set category = "Admin"
	set name = "Aghost"
	set desc = "Allows you to ghost and re-enter body at will."

	if(!check_rights(R_ADMIN|R_MENTOR))
		return

	var/mob/M = usr

	if(isnewplayer(M))
		return

	if(isobserver(M))
		var/mob/dead/observer/ghost = M
		ghost.can_reenter_corpse = TRUE
		ghost.reenter_corpse()
		return

	var/oldkey = M.key

	M.ghostize(TRUE)
	M.key = "@[oldkey]"

	log_admin("[key_name(usr)] admin ghosted at [AREACOORD(usr)].")
	if(M.stat != DEAD)
		message_admins("[ADMIN_TPMONTY(usr)] admin ghosted.")


/datum/admins/proc/invisimin()
	set name = "Invisimin"
	set category = "Admin"
	set desc = "Toggles ghost-like invisibility."

	if(!check_rights(R_ADMIN))
		return

	var/mob/M = usr

	if(M.invisibility == INVISIBILITY_MAXIMUM)
		M.invisibility = initial(M.invisibility)
		M.alpha = initial(M.alpha)
		M.add_to_all_mob_huds()
		M.name = M.real_name
	else
		M.invisibility = INVISIBILITY_MAXIMUM
		M.alpha = 0
		M.remove_from_all_mob_huds()
		M.name = null

	log_admin("[key_name(M)] has [(M.invisibility == INVISIBILITY_MAXIMUM) ? "enabled" : "disabled"] invisimin.")
	message_admins("[ADMIN_TPMONTY(M)] has [(M.invisibility == INVISIBILITY_MAXIMUM) ? "enabled" : "disabled"] invisimin.")


/datum/admins/proc/stealth_mode()
	set category = "Admin"
	set name = "Stealth Mode"
	set desc = "Allows you to change your ckey for non-admins to see."

	if(!check_rights(R_ADMIN))
		return

	var/mob/M = usr

	if(M.client.holder.fakekey)
		M.client.holder.fakekey = null
	else
		var/new_key = ckeyEx(input("Enter your desired display name.", "Stealth Mode", M.client.key) as text|null)
		if(!new_key)
			return
		if(length(new_key) >= 26)
			new_key = copytext(new_key, 1, 26)
		M.client.holder.fakekey = new_key
		M.client.create_stealth_key()

	log_admin("[key_name(M)] has turned stealth mode [M.client.holder.fakekey ? "on - [M.client.holder.fakekey]" : "off"].")
	message_admins("[ADMIN_TPMONTY(M)] has turned stealth mode [M.client.holder.fakekey ? "on - [M.client.holder.fakekey]" : "off"].")


/datum/admins/proc/give_mob(mob/living/LGIVE in GLOB.mob_living_list)
	set category = null
	set name = "Give Mob"

	if(!check_rights(R_ADMIN))
		return

	var/mob/MREC
	switch(input("Who do you want to give it to:", "Give Mob") as null|anything in list("Key", "Mob"))
		if("Key")
			var/client/C = input("Please, select a key.", "Give Mob") as null|anything in sortKey(GLOB.clients)
			if(!C)
				return
			MREC = C.mob
		if("Mob")
			var/mob/N = input("Please, select a mob.", "Give Mob") as null|anything in sortNames(GLOB.mob_list)
			if(!N)
				return
			MREC = N

	if(isliving(MREC) && MREC.client && alert("[key_name(MREC)] is already playing, do you want to proceed?", "Give Mob", "Yes", "No") != "Yes")
		return

	if(!istype(LGIVE))
		to_chat(usr, "<span class='warning'>Target is no longer valid.</span>")
		return

	log_admin("[key_name(usr)] gave [key_name(LGIVE)] to [key_name(MREC)].")
	message_admins("[ADMIN_TPMONTY(usr)] gave [ADMIN_TPMONTY(LGIVE)] to [ADMIN_TPMONTY(MREC)].")

	LGIVE.take_over(MREC, TRUE)


/datum/admins/proc/give_mob_panel()
	set category = "Admin"
	set name = "Give  Mob"

	if(!check_rights(R_ADMIN))
		return

	var/mob/living/LGIVE
	switch(input("Who do you want to give:", "Give Mob") as null|anything in list("Key", "Mob"))
		if("Key")
			var/client/C = input("Please, select a key.", "Give Mob") as null|anything in sortKey(GLOB.clients)
			if(!isliving(C?.mob))
				return
			LGIVE = C.mob
		if("Mob")
			var/mob/N = input("Please, select a mob.", "Give Mob") as null|anything in sortNames(GLOB.mob_living_list)
			if(!N)
				return
			LGIVE = N
		else
			return

	var/mob/NREC
	switch(input("Who do you want to give it to:", "Give Mob") as null|anything in list("Key", "Mob"))
		if("Key")
			var/client/C = input("Please, select a key.", "Give Mob") as null|anything in sortKey(GLOB.clients)
			if(!C)
				return
			NREC = C.mob
		if("Mob")
			var/mob/M = input("Please, select a mob.", "Give Mob") as null|anything in sortNames(GLOB.mob_list)
			if(!M)
				return
			NREC = M
		else
			return

	if(isliving(NREC) && NREC.client && alert("[key_name(NREC)] is already playing, do you want to proceed?", "Give Mob", "Yes", "No") != "Yes")
		return

	if(!istype(LGIVE))
		to_chat(usr, "<span class='warning'>Target is no longer valid.</span>")
		return

	log_admin("[key_name(usr)] gave [key_name(LGIVE)] to [key_name(NREC)].")
	message_admins("[ADMIN_TPMONTY(usr)] gave [ADMIN_TPMONTY(LGIVE)] to [ADMIN_TPMONTY(NREC)].")

	LGIVE.take_over(NREC, TRUE)


/datum/admins/proc/rejuvenate(mob/living/L in GLOB.mob_living_list)
	set category = null
	set name = "Rejuvenate"

	if(!check_rights(R_ADMIN))
		return

	if(!istype(L))
		return

	if(alert("Are you sure you want to rejuvenate [key_name(L)]?", "Rejuvenate", "Yes", "No") != "Yes")
		return

	L.revive()

	log_admin("[key_name(usr)] revived [key_name(L)].")
	message_admins("[ADMIN_TPMONTY(usr)] revived [ADMIN_TPMONTY(L)].")


/datum/admins/proc/rejuvenate_panel()
	set category = "Admin"
	set name = "Rejuvenate Mob"

	if(!check_rights(R_ADMIN))
		return

	var/mob/living/L
	switch(input("Rejuvenate by:", "Rejuvenate") as null|anything in list("Key", "Mob"))
		if("Key")
			var/client/C = input("Please, select a key.", "Rejuvenate") as null|anything in sortKey(GLOB.clients)
			if(!C)
				return
			if(!isliving(C.mob))
				to_chat(usr, "<span class='warning'>Target is no longer valid.</span>")
				return
			L = C.mob
		if("Mob")
			var/mob/N = input("Please, select a mob.", "Rejuvenate") as null|anything in sortNames(GLOB.mob_living_list)
			if(!N)
				return
			L = N
		else
			return

	if(!istype(L))
		to_chat(usr, "<span class='warning'>Target is no longer valid.</span>")
		return

	if(alert("Are you sure you want to rejuvenate [key_name(L)]?", "Rejuvenate", "Yes", "No") != "Yes")
		return

	L.revive()

	log_admin("[key_name(usr)] revived [key_name(L)].")
	message_admins("[ADMIN_TPMONTY(usr)] revived [ADMIN_TPMONTY(L)].")


/datum/admins/proc/toggle_sleep(mob/living/L in GLOB.mob_living_list)
	set category = null
	set name = "Toggle Sleeping"

	if(!check_rights(R_ADMIN))
		return

	if(L.sleeping > 0)
		L.sleeping = 0
	else if(alert("Are you sure you want to sleep [key_name(L)]?", "Toggle Sleeping", "Yes", "No") != "Yes")
		return
	else
		L.sleeping = 9999999

	log_admin("[key_name(usr)] has [L.sleeping ? "enabled" : "disabled"] sleeping on [key_name(L)].")
	message_admins("[ADMIN_TPMONTY(usr)] has [L.sleeping ? "enabled" : "disabled"] sleeping on [ADMIN_TPMONTY(L)].")


/datum/admins/proc/toggle_sleep_panel()
	set category = "Admin"
	set name = "Toggle Sleeping Mob"

	if(!check_rights(R_ADMIN))
		return

	var/mob/living/L
	switch(input("Toggle sleeping by:", "Toggle Sleeping") as null|anything in list("Key", "Mob"))
		if("Key")
			var/client/C = input("Please, select a key.", "Toggle Sleeping") as null|anything in sortKey(GLOB.clients)
			if(!C)
				return
			if(!isliving(C.mob))
				to_chat(usr, "<span class='warning'>Target is no longer valid.</span>")
				return
			L = C.mob
		if("Mob")
			var/mob/living/N = input("Please, select a mob.", "Toggle Sleeping") as null|anything in sortNames(GLOB.mob_living_list)
			if(!N)
				return
			L = N
		else
			return

	if(!istype(L))
		to_chat(usr, "<span class='warning'>Target is no longer valid.</span>")
		return

	if(L.sleeping > 0)
		L.sleeping = 0
	else
		L.sleeping = 9999999

	log_admin("[key_name(usr)] has [L.sleeping ? "enabled" : "disabled"] sleeping on [key_name(L)].")
	message_admins("[ADMIN_TPMONTY(usr)] has [L.sleeping ? "enabled" : "disabled"] sleeping on [ADMIN_TPMONTY(L)].")


/datum/admins/proc/toggle_sleep_area()
	set category = "Admin"
	set name = "Toggle Sleeping Area"

	if(!check_rights(R_ADMIN))
		return

	switch(alert("Sleep or unsleep everyone?", , "Sleep", "Unsleep", "Cancel"))
		if("Sleep")
			for(var/mob/living/L in view())
				L.sleeping = 9999999
			log_admin("[key_name(usr)] has slept everyone in view.")
			message_admins("[ADMIN_TPMONTY(usr)] has slept everyone in view.")
		if("Unsleep")
			for(var/mob/living/L in view())
				L.sleeping = 0
			log_admin("[key_name(usr)] has unslept everyone in view.")
			message_admins("[ADMIN_TPMONTY(usr)] has unslept everyone in view.")


/datum/admins/proc/direct_control(mob/living/L in GLOB.mob_living_list)
	set category = "Admin"
	set name = "Take Over"
	set desc = "Rohesie's verb."

	if(!check_rights(R_ADMIN))
		return

	if(isnewplayer(usr))
		return

	var/replaced = FALSE
	if(L.key)
		if(isobserver(usr) && usr.client.key == copytext(L.key, 2))
			var/mob/dead/observer/ghost = usr
			ghost.can_reenter_corpse = TRUE
			ghost.reenter_corpse()
			return
		else if(alert("This mob is being controlled by [L.key], they will be made a ghost. Are you sure?", "Take Over", "Yes", "No") != "Yes")
			return

		L.ghostize()
		replaced = TRUE

	var/log = "[key_name(usr)]"
	var/log2 = "[key_name(L)]"
	var/message = "[key_name_admin(usr)]"
	var/message2 = ADMIN_TPMONTY(L)

	L.take_over(usr, TRUE)

	log_admin("[log] took over [log2][replaced ? " replacing the previous owner" : ""].")
	message_admins("[message] took over [message2][replaced ? " replacing the previous owner" : ""].")


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
	set category = "Admin"
	set name = "Get Server Logs Folder"
	set desc = "Please use responsibly."

	if(!check_rights(R_ASAY))
		return

	if(alert("Due to the way BYOND handles files, you WILL need a click macro. This function is also recurive and prone to fucking up, especially if you select the wrong folder. Are you absolutely sure you want to proceed?", "WARNING", "Yes", "No") != "Yes")
		return

	var/path = usr.client.holder.browse_folders()
	if(!path)
		return
	
	usr.client.holder.recursive_download(path)


/datum/admins/proc/browse_server_logs(path = "data/logs/")
	if(!check_rights(R_ASAY))
		return

	path = browse_files(path)
	if(!path)
		return

	switch(input("View (in game), Open (in your system's text editor), Download", path) as null|anything in list("View", "Open", "Download"))
		if("View")
			usr << browse("<pre style='word-wrap: break-word;'>[html_encode(file2text(file(path)))]</pre>", list2params(list("window" = "viewfile.[path]")))
		if("Open")
			usr << run(file(path))
		if("Download")
			usr << ftp(file(path))
		else
			return

	log_admin("[key_name(usr)] accessed file: [path].")
	message_admins("[ADMIN_TPMONTY(usr)] accessed file: [path].")


/datum/admins/proc/recursive_download(folder)
	if(!check_rights(R_ASAY))
		return

	var/files = flist(folder)
	for(var/next in files)
		if(copytext(next, -1, 0) == "/")
			to_chat(usr, "Going deeper: [folder][next]")
			usr.client.holder.recursive_download(folder + next)
		else
			to_chat(usr, "Downloading: [folder][next]")
			var/fil = replacetext("[folder][next]", "/", "_")
			usr << ftp(file(folder + next), fil)


/datum/admins/proc/browse_folders(root = "data/logs/", max_iterations = 100)
	if(!check_rights(R_ASAY))
		return

	var/path = root
	for(var/i = 0, i < max_iterations, i++)
		var/list/choices = flist(path)
		if(path != root)
			choices.Insert(1, "/")
		var/choice = input("Choose a folder to access:", "Server Logs") as null|anything in choices
		switch(choice)
			if(null)
				return FALSE
			if("/")
				path = root
				continue
		path += choice

		if(copytext(path, -1, 0) != "/")		//didn't choose a directory, no need to iterate again
			return FALSE

		switch(alert("Is this the folder you want to download?:", "Server Logs", "Yes", "No", "Cancel"))
			if("Yes")
				break
			if("No")
				continue
			if("Cancel")
				return FALSE

	return path


/datum/admins/proc/browse_files(root = "data/logs/", max_iterations = 20, list/valid_extensions = list("txt", "log", "htm", "html"))
	if(!check_rights(R_ASAY))
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

	if(!istype(M))
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

	dat += "<hr style='background:#FFFFFF; border:0; height:1px'>"
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

	dat += "<hr style='background:#FFFFFF; border:0; height:1px'>"

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
					dat += "<font size=2px>[entry]<br>[reversed[entry]]</font><br>"
			dat += "<hr>"

	var/datum/browser/browser = new(usr, "invidual_logging_[key_name(M)]", "<div align='center'>Logs</div>", 700, 550)
	browser.set_content(dat)
	browser.open(FALSE)


/datum/admins/proc/individual_logging_panel_link(mob/M, log_type, log_src, label, selected_src, selected_type)
	if(!check_rights(R_ADMIN))
		return

	var/slabel = label
	if(selected_type == log_type && selected_src == log_src)
		slabel = "<b><font color='#ff8c8c'>\[[label]\]</font></b>"

	return "<a href='?src=[REF(usr.client.holder)];[HrefToken()];individuallog=[REF(M)];log_type=[log_type];log_src=[log_src]'>[slabel]</a>"


/client/proc/get_asay()
	var/msg = input(src, null, "asay \"text\"") as text|null
	asay(msg)


/client/proc/asay(msg as text)
	set category = "Admin"
	set name = "asay"
	set hidden = TRUE

	if(!check_rights(R_ASAY))
		return

	msg = noscript(msg)

	if(!msg)
		return

	log_admin_private_asay("[key_name(src)]: [msg]")

	var/color = "adminsay"
	if(check_other_rights(src, R_DBRANKS, FALSE))
		color = "headminsay"

	msg = "<span class='[color]'><span class='prefix'>ADMIN:</span> [ADMIN_TPMONTY(mob)]: <span class='message'>[msg]</span></span>"
	for(var/client/C in GLOB.admins)
		if(check_other_rights(C, R_ASAY, FALSE))
			to_chat(C, msg)


/client/proc/get_msay()
	var/msg = input(src, null, "msay \"text\"") as text|null
	msay(msg)


/client/proc/msay(msg as text)
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

	log_admin_private_msay("[key_name(src)]: [msg]")

	var/color = "mod"
	if(check_other_rights(src, R_DBRANKS, FALSE))
		color = "headminmod"
	else if(check_other_rights(src, R_ADMIN, FALSE))
		color = "adminmod"

	for(var/client/C in GLOB.admins)
		if(check_other_rights(C, R_ADMIN, FALSE))
			to_chat(C, "<span class='[color]'><span class='prefix'>[holder.rank.name]:</span> [ADMIN_TPMONTY(mob)]: <span class='message'>[msg]</span></span>")
		else if(is_mentor(C) && mob.stat == DEAD)
			to_chat(C, "<span class='[color]'><span class='prefix'>[holder.rank.name]:</span> [key_name_admin(src, TRUE, TRUE, FALSE)] [ADMIN_JMP(mob)] [ADMIN_FLW(mob)]: <span class='message'>[msg]</span></span>")
		else if(is_mentor(C))
			to_chat(C, "<span class='[color]'><span class='prefix'>[holder.rank.name]:</span> [key_name_admin(src, TRUE, FALSE, FALSE)] [ADMIN_JMP(mob)] [ADMIN_FLW(mob)]: <span class='message'>[msg]</span></span>")


/client/proc/get_dsay()
	var/msg = input(src, null, "dsay \"text\"") as text|null
	dsay(msg)


/client/proc/dsay(msg as text)
	set category = "Admin"
	set name = "dsay"
	set hidden = TRUE

	if(!check_rights(R_ADMIN|R_MENTOR))
		return

	if(is_mentor(src) && mob.stat != DEAD)
		to_chat(src, "<span class='warning'>You must be an observer to use dsay.</span>")
		return

	if(!(prefs.toggles_chat & CHAT_DEAD))
		to_chat(src, "<span class='warning'>You have deadchat muted.</span>")
		return

	if(handle_spam_prevention(msg, MUTE_DEADCHAT))
		return

	msg = noscript(msg)

	if(!msg)
		return

	log_dsay("[key_name(src)]: [msg]")
	msg = "<span class='game deadsay'><span class='prefix'>DEAD:</span> <span class='name'>[holder.fakekey ? "" : "([holder.rank.name]) "][holder.fakekey ? "Administrator" : key]</span> says, \"<span class='message'>[msg]</span>\"</span>"

	for(var/i in GLOB.clients)
		var/client/C = i
		if(istype(C.mob, /mob/new_player))
			continue

		if(check_other_rights(C, R_ADMIN, FALSE) && (C.prefs.toggles_chat & CHAT_DEAD))
			to_chat(C, msg)

		else if(C.mob.stat == DEAD && (C.prefs.toggles_chat & CHAT_DEAD))
			to_chat(C, msg)


/datum/admins/proc/jump()
	set category = "Admin"
	set name = "Jump"

	if(!check_rights(R_ADMIN))
		return

	var/mob/N = usr

	if(isnewplayer(N))
		return

	var/turf/target
	var/selection = input("Jump to:", "Jump") as null|anything in list("Area", "Turf", "Coords", "Mob", "Key")
	switch(selection)
		if("Area")
			var/area/A = input("Area", "Jump") as null|anything in GLOB.sorted_areas
			target = pick(get_area_turfs(A))
		if("Turf")
			var/turf/T = input("Turf", "Jump") as null|anything in GLOB.turfs
			target = T
		if("Coords")
			var/tx = input("X", "Jump") as null|num
			var/ty = input("Y", "Jump") as null|num
			var/tz = input("Z", "Jump") as null|num
			target = locate(tx, ty, tz)
		if("Mob")
			var/mob/M = input("Mob", "Jump") as null|anything in sortNames(GLOB.mob_list)
			target = get_turf(M)
		if("Key")
			var/client/C = input("Mob", "Jump") as null|anything in sortKey(GLOB.clients)
			target = get_turf(C.mob)
		else
			return

	if(!istype(target))
		return

	N.forceMove(target)

	log_admin("[key_name(usr)] jumped to [selection] at [AREACOORD(target)].")
	if(!isobserver(N))
		message_admins("[ADMIN_TPMONTY(usr)] jumped to [selection] at [ADMIN_TPMONTY(target)].")


/datum/admins/proc/get_mob()
	set category = "Admin"
	set name = "Get Mob"

	if(!check_rights(R_ADMIN))
		return

	var/mob/N = usr

	if(isnewplayer(N))
		return

	var/mob/M
	switch(input("Get by:", "Get") as null|anything in list("Key", "Mob"))
		if("Key")
			var/client/C = input("Please, select a key.", "Get Key") as null|anything in sortKey(GLOB.clients)
			if(!C)
				return
			M = C.mob
		if("Mob")
			var/mob/W = input("Please, select a mob.", "Get Mob") as null|anything in sortNames(GLOB.mob_list)
			if(!W)
				return
			M = W
		else
			return

	if(!istype(M))
		return

	var/turf/T = get_turf(N)

	M.forceMove(T)

	log_admin("[key_name(usr)] teleported [key_name(M)] to themselves [AREACOORD(M.loc)].")
	message_admins("[ADMIN_TPMONTY(usr)] teleported [ADMIN_TPMONTY(M)] to themselves.")


/datum/admins/proc/send_mob()
	set category = "Admin"
	set name = "Send Mob"

	if(!check_rights(R_ADMIN))
		return

	var/mob/M
	switch(input("Send by:", "Send Mob") as null|anything in list("Key", "Mob"))
		if("Key")
			var/client/C = input("Please, select a key.", "Send Mob") as null|anything in sortKey(GLOB.clients)
			if(!C)
				return
			M = C.mob
		if("Mob")
			var/mob/N = input("Please, select a mob.", "Send Mob") as null|anything in sortNames(GLOB.mob_list)
			if(!N)
				return
			M = N

	if(!istype(M))
		return

	var/turf/target
	switch(input("Where do you want to send it to?", "Send Mob") as null|anything in list("Area", "Mob", "Key"))
		if("Area")
			var/area/A = input("Pick an area.", "Send Mob") as null|anything in GLOB.sorted_areas
			if(!A)
				return
			target = pick(get_area_turfs(A))
		if("Mob")
			var/mob/N = input("Pick a mob.", "Send Mob") as null|anything in sortNames(GLOB.mob_list)
			if(!N)
				return
			target = get_turf(N.loc)
		if("Key")
			var/client/C = input("Pick a key.", "Send Mob") as null|anything in sortKey(GLOB.clients)
			if(!C)
				return
			target = get_turf(C.mob.loc)

	if(!istype(M))
		return

	M.forceMove(target)

	log_admin("[key_name(usr)] teleported [key_name(M)] to [AREACOORD(target)].")
	message_admins("[ADMIN_TPMONTY(usr)] teleported [ADMIN_TPMONTY(M)] to [ADMIN_VERBOSEJMP(target)].")


/datum/admins/proc/jump_area(area/A in GLOB.sorted_areas)
	set category = null
	set name = "Jump to Area"

	if(!check_rights(R_ADMIN))
		return

	var/mob/M = usr
	var/target = pick(get_area_turfs(A))
	M.forceMove(target)

	log_admin("[key_name(usr)] jumped to [AREACOORD(M)].")
	if(!isobserver(M))
		message_admins("[ADMIN_TPMONTY(usr)] jumped to [ADMIN_VERBOSEJMP(M)].")


/datum/admins/proc/jump_turf(turf/T in GLOB.turfs)
	set category = null
	set name = "Jump to Turf"

	if(!check_rights(R_ADMIN))
		return

	if(!T)
		return

	var/mob/M = usr
	M.forceMove(T)

	log_admin("[key_name(M)] jumped to turf [AREACOORD(T)].")
	if(!isobserver(M))
		message_admins("[ADMIN_TPMONTY(M)] jumped to turf [ADMIN_VERBOSEJMP(T)].")


/datum/admins/proc/jump_coord(tx as num, ty as num, tz as num)
	set category = null
	set name = "Jump to Coordinate"

	if(!check_rights(R_ADMIN))
		return

	var/mob/M = usr
	M.x = tx
	M.y = ty
	M.z = tz
	var/turf/T = get_turf(M)
	M.forceMove(T)

	log_admin("[key_name(M)] jumped to coordinate [AREACOORD(T)].")
	if(!isobserver(M))
		message_admins("[ADMIN_TPMONTY(M)] jumped to coordinate [ADMIN_VERBOSEJMP(T)].")


/datum/admins/proc/jump_mob()
	set category = null
	set name = "Jump to Mob"

	if(!check_rights(R_ADMIN))
		return

	var/selection = input("Please, select a mob.", "Jump to Mob") as null|anything in sortNames(GLOB.mob_list)
	if(!selection)
		return

	var/mob/M = selection
	var/mob/N = usr
	var/turf/T = get_turf(M)

	N.forceMove(T)

	log_admin("[key_name(N)] jumped to [key_name(M)]'s mob [AREACOORD(T)]")
	if(!isobserver(N))
		message_admins("[ADMIN_TPMONTY(N)] jumped to [ADMIN_TPMONTY(T)].")


/datum/admins/proc/jump_key()
	set category = null
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

	N.forceMove(T)

	log_admin("[key_name(usr)] jumped to [key_name(M)]'s key [AREACOORD(T)].")
	if(!isobserver(N))
		message_admins("[ADMIN_TPMONTY(usr)] jumped to [ADMIN_TPMONTY(T)].")


/client/proc/private_message_context(mob/M in GLOB.player_list)
	set category = null
	set name = "Private Message"

	if(!check_rights(R_ADMIN|R_MENTOR))
		return

	if(!istype(M))
		return

	private_message(M.client, null)


/client/proc/private_message_panel()
	set category = "Admin"
	set name = "Private Message Mob"

	if(!check_rights(R_ADMIN|R_MENTOR))
		return

	var/client/target
	switch(input("Select target:", "Private Message") as null|anything in list("Mob", "Key"))
		if("Mob")
			var/mob/M = input("Pick a mob.", "Private Message") as null|anything in sortNames(GLOB.player_list)
			if(!M)
				return
			target = M.client
		if("Key")
			var/client/C = input("Pick a key.", "Private Message") as null|anything in sortKey(GLOB.clients)
			if(!C)
				return
			target = C

	if(!istype(target))
		return

	private_message(target, null)


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

	if(AH && AH.tier == TICKET_ADMIN && !check_rights(R_ADMINTICKET, FALSE))
		return

	if(AH && !AH.marked)
		AH.marked = usr.client
		if(AH.tier == TICKET_MENTOR)
			message_staff("[key_name_admin(src)] has marked and started replying to [key_name_admin(C, FALSE, FALSE)]'s ticket.")
		else if(AH.tier == TICKET_ADMIN)
			if(!check_rights(R_ADMINTICKET, FALSE))
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
		


	if(irc)
		if(!ircreplyamount)	//to prevent people from spamming irc
			return

		if(!msg)
			msg = input(src, "Message:", "Private message to Administrator") as message|null

		if(!msg)
			return

		if(holder)
			to_chat(src, "<span class='danger'>Use the admin IRC channel.</span>")
			return

	else
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

			if(!recipient && !irc)
				if(holder)
					to_chat(src, "<br><span class='boldnotice'>Client not found. Here's your message, copy-paste it if needed:</span>")
					to_chat(src, "<span class='notice'>[msg]</span><br>")
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
		var/datum/admin_help/AH = admin_ticket_log(src, "<font color='#ff8c8c'>Reply PM from-<b>[key_name(src, TRUE, TRUE)] to <i>IRC</i>: [keywordparsedmsg]</font>")
		ircreplyamount--
		send2irc("[AH ? "#[AH.id] " : ""]Reply: [ckey]", sanitizediscord(rawmsg))
	else
		if(check_other_rights(recipient, R_ADMINTICKET, FALSE) || is_mentor(recipient))
			if(check_rights(R_ADMINTICKET, FALSE) || is_mentor(src)) //Both are staff
				if(!current_ticket && !recipient.current_ticket)
					if(check_other_rights(recipient, R_ADMINTICKET, FALSE) || check_rights(R_ADMINTICKET, FALSE))
						new /datum/admin_help(msg, recipient, TRUE, TICKET_ADMIN)
					else
						new /datum/admin_help(msg, recipient, TRUE, TICKET_MENTOR)
				to_chat(recipient, "<font size='3' color='red'>Staff PM from-<b>[key_name(src, recipient, TRUE)]</b>: <span class='linkify'>[keywordparsedmsg]</span></font>")
				to_chat(src, "<font size='3' color='blue'>Staff PM to-<b>[key_name(recipient, src, TRUE)]</b>: <span class='linkify'>[keywordparsedmsg]</span></font>")

				window_flash(recipient, TRUE)
				window_flash(src, TRUE)

				var/interaction_message = "<font color='#cea7f1'>PM from-<b>[key_name(src, recipient, TRUE)]</b> to-<b>[key_name(recipient, src, TRUE)]</b>: [keywordparsedmsg]</font>"
				admin_ticket_log(src, interaction_message)
				if(recipient != src)
					admin_ticket_log(recipient, interaction_message)

			else //Recipient is a staff member, sender is not.
				admin_ticket_log(src, "<font color='#ff8c8c'>Reply PM from-<b>[key_name(src, recipient, TRUE)]</b>: <span class='linkify'>[keywordparsedmsg]</span></font>")
				to_chat(recipient, "<font size='3' color='red'>Reply PM from-<b>[key_name(src, recipient, TRUE)]</b>: <span class='linkify'>[keywordparsedmsg]</span></font>")
				window_flash(recipient, TRUE)
				to_chat(src, "<font color='blue'>PM to-<b>Staff</b>: <span class='linkify'>[msg]</span></font>")

			//Play the bwoink if enabled.
			if(recipient.prefs.toggles_sound & SOUND_ADMINHELP)
				SEND_SOUND(recipient, sound('sound/effects/adminhelp.ogg'))

		else  //PM sender is mentor/admin, recipient is not -> big red text
			if(check_rights(R_ADMINTICKET, FALSE) || is_mentor(src))
				if(!recipient.current_ticket)
					if(check_rights(R_ADMINTICKET, FALSE))
						new /datum/admin_help(msg, recipient, TRUE, TICKET_ADMIN)
					else if(is_mentor(src))
						new /datum/admin_help(msg, recipient, TRUE, TICKET_MENTOR)

				if(check_rights(R_ADMINTICKET, FALSE))
					to_chat(recipient, "<font color='red' size='4'><b>-- Private Message --</b></font>")
					to_chat(recipient, "<font color='red'>[holder.fakekey ? "Administrator" : holder.rank.name] PM from-<b>[key_name(src, recipient, FALSE)]</b>: <span class='linkify'>[msg]</span></font>")
					to_chat(recipient, "<font color='red'><i>Click on the staff member's name to reply.</i></font>")
					to_chat(src, "<font color='blue'><b>[holder.fakekey ? "Administrator" : holder.rank.name] PM</b> to-<b>[key_name(recipient, src, TRUE)]</b>: <span class='linkify'>[msg]</span></font>")
					SEND_SOUND(recipient, sound('sound/effects/adminhelp.ogg'))
					window_flash(recipient, TRUE)
				else if(is_mentor(src))
					to_chat(recipient, "<font color='blue' size='2'><b>-- Mentor Message --</b></font>")
					to_chat(recipient, "<font color='blue'>[holder.rank.name] PM from-<b>[key_name(src, recipient, FALSE)]</b>: <span class='linkify'>[msg]</span></font>")
					to_chat(recipient, "<font color='blue'><i>Click on the mentor's name to reply.</i></font>")
					to_chat(src, "<font color='blue'><b>[holder.rank.name] PM</b> to-<b>[key_name(recipient, src, TRUE)]</b>: <span class='linkify'>[msg]</span></font>")
					SEND_SOUND(recipient, sound('sound/effects/mentorhelp.ogg'))
					window_flash(recipient)

				admin_ticket_log(recipient, "<font color='#a7f2ef'>PM From [key_name_admin(src)]: [keywordparsedmsg]</font>")


			else		//neither are admins
				to_chat(src, "<span class='warning'>Error: Non-staff to non-staff communication is disabled.</span>")
				return

	if(irc)
		log_admin_private("PM: [key_name(src)]->IRC: [rawmsg]")
		for(var/client/X in GLOB.admins)
			if(check_other_rights(X, R_ADMINTICKET, FALSE))
				to_chat(X, "<font color='blue'><B>PM: [key_name(src, X, FALSE)]-&gt;IRC:</B> [keywordparsedmsg]</font>")
	else
		log_admin_private("PM: [key_name(src)]->[key_name(recipient)]: [rawmsg]")
		//Admins PMs go to admins, mentor PMs go to mentors and admins
		if(check_rights(R_ADMINTICKET, FALSE))
			for(var/client/X in GLOB.admins)
				if(X.key == key || X.key == recipient.key)
					continue
				if(check_other_rights(X, R_ADMINTICKET, FALSE))
					to_chat(X, "<font color='blue'><B>Admin PM: [key_name(src, X, FALSE)]-&gt;[key_name(recipient, X, FALSE)]:</B> [keywordparsedmsg]</font>")
		else if(is_mentor(src))
			for(var/client/X in GLOB.admins)
				if(X.key == key || X.key == recipient.key)
					continue
				if(check_other_rights(X, R_ADMINTICKET, FALSE) || is_mentor(X))
					to_chat(X, "<font color='blue'><B>Mentor PM: [key_name(src, X, FALSE)]-&gt;[key_name(recipient, X, FALSE)]:</B> [keywordparsedmsg]</font>")
		else //Admins get all messages, mentors only mentor responses
			var/datum/admin_help/AH = src.current_ticket
			for(var/client/X in GLOB.admins)
				if(X.key == key || X.key == recipient.key)
					continue
				if(check_other_rights(X, R_ADMINTICKET, FALSE))
					to_chat(X, "<font color='blue'><B>PM: [key_name(src, X, FALSE)]-&gt;[key_name(recipient, X, FALSE)]:</B> [keywordparsedmsg]</font>")
			if(AH?.tier == TICKET_MENTOR)
				for(var/client/X in GLOB.admins)
					if(X.key == key || X.key == recipient.key)
						continue
					if(is_mentor(X))
						to_chat(X, "<font color='blue'><B>PM: [key_name(src, X, FALSE)]-&gt;[key_name(recipient, X, FALSE)]:</B> [keywordparsedmsg]</font>")


/proc/IrcPm(target, msg, sender)
	target = ckey(target)
	var/client/C = GLOB.directory[target]

	var/datum/admin_help/ticket = C ? C.current_ticket : GLOB.ahelp_tickets.CKey2ActiveTicket(target)
	var/compliant_msg = trim(lowertext(msg))
	var/irc_tagged = "[sender](IRC)"
	var/list/splits = splittext(compliant_msg, " ")
	if(length(splits) && splits[1] == "ticket")
		if(length(splits) < 2)
			return IRC_AHELP_USAGE
		switch(splits[2])
			if("close")
				if(ticket)
					ticket.Close(FALSE, TRUE)
					ticket.AddInteraction("<font color='#ff8c8c'>IRC interaction by: [irc_tagged].</font>")
					message_admins("IRC interaction by: [irc_tagged]")
					return "Ticket #[ticket.id] successfully closed"
			if("resolve")
				if(ticket)
					ticket.Resolve(FALSE, TRUE)
					ticket.AddInteraction("<font color='#ff8c8c'>IRC interaction by: [irc_tagged].</font>")
					message_admins("IRC interaction by: [irc_tagged]")
					return "Ticket #[ticket.id] successfully resolved"
			if("icissue")
				if(ticket)
					ticket.ICIssue(TRUE)
					ticket.AddInteraction("<font color='#ff8c8c'>IRC interaction by: [irc_tagged].</font>")
					message_admins("IRC interaction by: [irc_tagged]")
					return "Ticket #[ticket.id] successfully marked as IC issue"
			if("reject")
				if(ticket)
					ticket.Reject(TRUE)
					ticket.AddInteraction("<font color='#ff8c8c'>IRC interaction by: [irc_tagged].</font>")
					message_admins("IRC interaction by: [irc_tagged]")
					return "Ticket #[ticket.id] successfully rejected"
			if("tier")
				if(ticket)
					ticket.Tier(TRUE)
					ticket.AddInteraction("<font color='#ff8c8c'>IRC interaction by: [sender].</font>")
					message_admins("IRC interaction by: [irc_tagged]")
					return "Ticket #[ticket.id] successfully tiered"
			if("reopen")
				if(ticket)
					return "Error: [target] already has ticket #[ticket.id] open"
				if(length(splits) < 3)
					return "Error: No ticket id specified. [IRC_AHELP_USAGE]"
				var/id = text2num(splits[3])
				if(isnull(id))
					return "Error: Invalid ticket id specified. [IRC_AHELP_USAGE]"
				var/datum/admin_help/AH = GLOB.ahelp_tickets.TicketByID(id)
				if(!AH)
					return "Error: Ticket #[id] not found"
				if(AH.initiator_ckey != target)
					return "Error: Ticket #[id] belongs to [AH.initiator_ckey]"
				AH.Reopen(TRUE)
				AH.AddInteraction("<font color='#ff8c8c'>IRC interaction by: [irc_tagged].</font>")
				message_admins("IRC interaction by: [irc_tagged]")
				return "Ticket #[id] successfully reopened"
			if("list")
				var/list/tickets = GLOB.ahelp_tickets.TicketsByCKey(target)
				if(!length(tickets))
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

	msg = sanitize(copytext(msg, 1, MAX_MESSAGE_LEN))
	if(!msg)
		return "Error: No message"

	log_admin_private("IRC PM: [irc_tagged] -> [key_name(C)] : [msg]")
	message_admins("IRC PM: [irc_tagged] -> [key_name_admin(C, FALSE, FALSE)] : [msg]")

	to_chat(C, "<font color='red' size='4'><b>-- Administrator private message --</b></font>")
	to_chat(C, "<font color='red'>Admin PM from-<b><a href='?priv_msg=[stealthkey]'>[adminname]</A></b>: [msg]</font>")
	to_chat(C, "<font color='red'><i>Click on the administrator's name to reply.</i></font>")

	admin_ticket_log(C, "<font color='#a7f2ef'>PM From [irc_tagged]: [msg]</font>")

	//always play non-admin recipients the adminhelp sound
	SEND_SOUND(C, 'sound/effects/adminhelp.ogg')

	C.ircreplyamount = IRCREPLYCOUNT

	return "Message Successful"


/datum/admins/proc/get_all_humans()
	if(!check_rights(R_ADMIN))
		return

	for(var/i in GLOB.alive_human_list)
		var/mob/living/carbon/human/H = i
		if(!H.client)
			continue
		H.forceMove(get_turf(usr))


/datum/admins/proc/get_all_xenos()
	if(!check_rights(R_ADMIN))
		return

	for(var/i in GLOB.alive_xeno_list)
		var/mob/living/carbon/xenomorph/X = i
		if(!X.client)
			continue
		X.forceMove(get_turf(usr))


/datum/admins/proc/get_all()
	if(!check_rights(R_ADMIN))
		return

	for(var/i in GLOB.alive_mob_list)
		var/mob/living/L = i
		if(!L.client)
			continue
		L.forceMove(get_turf(usr))


/datum/admins/proc/rejuv_all()
	if(!check_rights(R_ADMIN))
		return

	for(var/i in GLOB.mob_living_list)
		var/mob/living/L = i
		if(!L.client)
			continue
		L.revive()


/datum/admins/proc/remove_from_tank()
	set category = "Admin"
	set name = "Remove From Tank"

	if(!check_rights(R_ADMIN))
		return

	for(var/obj/vehicle/multitile/root/cm_armored/CA in GLOB.object_list)
		CA.remove_all_players()

		log_admin("[key_name(usr)] forcibly removed all players from [CA].")
		message_admins("[ADMIN_TPMONTY(usr)] forcibly removed all players from [CA].")


/datum/admins/proc/job_slots()
	set category = "Admin"
	set name = "Job Slots"

	if(!check_rights(R_ADMIN))
		return

	var/datum/browser/browser = new(usr, "jobmanagement", "Manage Free Slots", 600)
	var/list/dat = list()
	var/count = 0

	if(!SSjob.initialized)
		return

	dat += "<table>"

	for(var/j in SSjob.occupations)
		var/datum/job/job = j
		if(!(job.title in JOBS_REGULAR_ALL))
			continue
		count++
		var/J_title = html_encode(job.title)
		var/J_opPos = html_encode(job.total_positions - (job.total_positions - job.current_positions))
		var/J_totPos = html_encode(job.total_positions)
		dat += "<tr><td>[J_title]:</td> <td>[J_opPos]/[job.total_positions < 0 ? " (unlimited)" : J_totPos]"

		dat += "</td>"
		dat += "<td>"
		if(job.total_positions >= 0)
			dat += "<A href='?src=[REF(usr.client.holder)];[HrefToken()];filljobslot=[job.title]'>Fill</A> | "
			dat += "<A href='?src=[REF(usr.client.holder)];[HrefToken()];freejobslot=[job.title]'>Free</A> | "
			dat += "<A href='?src=[REF(usr.client.holder)];[HrefToken()];addjobslot=[job.title]'>Add</A> | "
			dat += "<A href='?src=[REF(usr.client.holder)];[HrefToken()];removejobslot=[job.title]'>Remove</A> | "
			dat += "<A href='?src=[REF(usr.client.holder)];[HrefToken()];unlimitjobslot=[job.title]'>Unlimit</A></td>"
		else
			dat += "<A href='?src=[REF(usr.client.holder)];[HrefToken()];limitjobslot=[job.title]'>Limit</A></td>"

	browser.height = min(100 + count * 20, 650)
	browser.set_content(dat.Join())
	browser.open()


/datum/admins/proc/mcdb()
	set category = "Admin"
	set name = "Open MCDB"

	if(!CONFIG_GET(string/dburl))
		to_chat(usr, "<span class='warning'>Database URL not set.</span>")
		return

	if(alert("This will open the MCDB in your browser. Are you sure?", "MCDB", "Yes", "No") != "Yes")
		return

	usr << link(CONFIG_GET(string/dburl))


/datum/admins/proc/check_fingerprints(atom/A)
	set category = null
	set name = "Check Fingerprints"

	if(!check_rights(R_ADMIN))
		return

	var/dat

	if(!A.fingerprints)
		dat += "No fingerprints detected."

	for(var/i in A.fingerprints)
		dat += "[i] - [A.fingerprints[i]]<br>"

	var/datum/browser/browser = new(usr, "fingerprints_[A]", "Fingerprints on [A]")
	browser.set_content(dat)
	browser.open(FALSE)