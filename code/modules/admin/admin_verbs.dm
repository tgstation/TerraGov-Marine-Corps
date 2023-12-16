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
		ghost.reenter_corpse()
		return

	var/mob/dead/observer/ghost = M.ghostize(TRUE, TRUE)

	log_admin("[key_name(ghost)] admin ghosted at [AREACOORD(ghost)].")
	if(M.stat != DEAD)
		message_admins("[ADMIN_TPMONTY(ghost)] admin ghosted.")


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

	M.client.holder.invisimined = !M.client.holder.invisimined

	log_admin("[key_name(M)] has [(M.invisibility == INVISIBILITY_MAXIMUM) ? "enabled" : "disabled"] invisimin.")
	if(!check_rights(R_DBRANKS))
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
		var/new_key = ckeyEx(stripped_input(usr, "Enter your desired display name.", "Stealth Mode", M.client.key, 26))
		if(!new_key)
			return
		if(length(new_key) >= 26)
			new_key = copytext(new_key, 1, 26)
		M.client.holder.fakekey = new_key
		M.client.create_stealth_key()

	log_admin("[key_name(M)] has turned stealth mode [M.client.holder.fakekey ? "on - [M.client.holder.fakekey]" : "off"].")
	if(!check_rights(R_DBRANKS))
		message_admins("[ADMIN_TPMONTY(M)] has turned stealth mode [M.client.holder.fakekey ? "on - [M.client.holder.fakekey]" : "off"].")

/// Will apply on every xeno a multiplicative buff on health, regen and damage.
/datum/admins/proc/set_xeno_stat_buffs()
	set category = "Debug"
	set name = "Set Xeno Buffs"
	set desc = "Allows you to change stats for all xenos. It is a multiplicator buff, so input 100 to put everything back to normal"

	if(!check_rights(R_FUN))
		return

	var/multiplicator_buff_wanted = tgui_input_number(usr, "Input the factor in percentage that will multiply xeno stat", "100 is normal stat, 200 is doubling health, regen and melee attack")

	if(!multiplicator_buff_wanted)
		return
	GLOB.xeno_stat_multiplicator_buff = (multiplicator_buff_wanted / 100)
	SSmonitor.is_automatic_balance_on = FALSE
	SSmonitor.apply_balance_changes()

	var/logging = "[usr.ckey] has multiplied all health, melee damage and regen of xeno by [multiplicator_buff_wanted]%"
	log_admin(logging)
	message_admins(logging)


/datum/admins/proc/give_mob(mob/living/given_living in GLOB.mob_living_list)
	set category = null
	set name = "Give Mob"

	if(!check_rights(R_ADMIN))
		return

	var/mob/mob_received = usr.client.holder.apicker("Who do you want to give it to:", "Give Mob", list(APICKER_CLIENT, APICKER_MOB))
	if(!istype(mob_received))
		return

	if(isliving(mob_received) && mob_received.client)
		if(alert("[key_name(mob_received)] is already playing, do you want to proceed?", "Give Mob", "Yes", "No") != "Yes")
			return
		else
			mob_received.ghostize()

	if(!istype(given_living))
		to_chat(usr, span_warning("Target is no longer valid."))
		return

	log_admin("[key_name(usr)] gave [key_name(given_living)] to [key_name(mob_received)].")
	message_admins("[ADMIN_TPMONTY(usr)] gave [ADMIN_TPMONTY(given_living)] to [ADMIN_TPMONTY(mob_received)].")

	given_living.take_over(mob_received, TRUE)


/datum/admins/proc/give_mob_panel()
	set category = "Admin"
	set name = "Give  Mob"

	if(!check_rights(R_ADMIN))
		return

	var/mob/living/given_living = usr.client.holder.apicker("Who do you want to give:", "Give Mob", list(APICKER_CLIENT, APICKER_LIVING))
	if(!istype(given_living))
		return

	var/mob/mob_received = usr.client.holder.apicker("Who do you want to give it to:", "Give Mob", list(APICKER_CLIENT, APICKER_MOB))
	if(!istype(mob_received))
		return

	if(isliving(mob_received) && mob_received.client && alert("[key_name(mob_received)] is already playing, do you want to proceed?", "Give Mob", "Yes", "No") != "Yes")
		return

	if(!istype(given_living))
		to_chat(usr, span_warning("Target is no longer valid."))
		return

	log_admin("[key_name(usr)] gave [key_name(given_living)] to [key_name(mob_received)].")
	message_admins("[ADMIN_TPMONTY(usr)] gave [ADMIN_TPMONTY(given_living)] to [ADMIN_TPMONTY(mob_received)].")

	given_living.take_over(mob_received, TRUE)


/datum/admins/proc/rejuvenate(mob/living/L in GLOB.mob_living_list)
	set category = null
	set name = "Rejuvenate"

	if(!check_rights(R_ADMIN))
		return

	if(alert("Are you sure you want to rejuvenate [key_name(L)]?", "Rejuvenate", "Yes", "No") != "Yes")
		return

	if(!istype(L))
		to_chat(usr, span_warning("Target is no longer valid."))
		return

	L.revive(TRUE)

	log_admin("[key_name(usr)] revived [key_name(L)].")
	message_admins("[ADMIN_TPMONTY(usr)] revived [ADMIN_TPMONTY(L)].")


/datum/admins/proc/rejuvenate_panel()
	set category = "Admin"
	set name = "Rejuvenate Mob"

	if(!check_rights(R_ADMIN))
		return

	var/mob/living/L = usr.client.holder.apicker("Rejuvenate by:", "Rejuvenate", list(APICKER_CLIENT, APICKER_MOB))
	if(!istype(L))
		return

	if(alert("Are you sure you want to rejuvenate [key_name(L)]?", "Rejuvenate", "Yes", "No") != "Yes")
		return

	if(!istype(L))
		to_chat(usr, span_warning("Target is no longer valid."))
		return

	L.revive(TRUE)

	log_admin("[key_name(usr)] revived [key_name(L)].")
	message_admins("[ADMIN_TPMONTY(usr)] revived [ADMIN_TPMONTY(L)].")


/datum/admins/proc/toggle_sleep(mob/living/L in GLOB.mob_living_list)
	set category = null
	set name = "Toggle Sleeping"

	if(!check_rights(R_ADMIN))
		return

	if(L.IsAdminSleeping())
		L.ToggleAdminSleep()
	else if(alert("Are you sure you want to sleep [key_name(L)]?", "Toggle Sleeping", "Yes", "No") != "Yes")
		return
	else if(!istype(L))
		to_chat(usr, span_warning("Target is no longer valid."))
		return
	else
		L.ToggleAdminSleep()

	log_admin("[key_name(usr)] has [L.IsAdminSleeping() ? "enabled" : "disabled"] sleeping on [key_name(L)].")
	message_admins("[ADMIN_TPMONTY(usr)] has [L.IsAdminSleeping() ? "enabled" : "disabled"] sleeping on [ADMIN_TPMONTY(L)].")


/datum/admins/proc/toggle_sleep_panel()
	set category = "Admin"
	set name = "Toggle Sleeping Mob"

	if(!check_rights(R_ADMIN))
		return

	var/mob/living/L = usr.client.holder.apicker("Toggle sleeping by:", "Toggle Sleeping", list(APICKER_CLIENT, APICKER_MOB))
	if(!istype(L))
		return

	L.ToggleAdminSleep()

	log_admin("[key_name(usr)] has [L.IsAdminSleeping() ? "enabled" : "disabled"] sleeping on [key_name(L)].")
	message_admins("[ADMIN_TPMONTY(usr)] has [L.IsAdminSleeping() ? "enabled" : "disabled"] sleeping on [ADMIN_TPMONTY(L)].")


/datum/admins/proc/toggle_sleep_area()
	set category = "Admin"
	set name = "Toggle Sleeping Area"

	if(!check_rights(R_ADMIN))
		return

	switch(alert("Sleep or unsleep everyone?", "Toggle Sleeping Area", "Sleep", "Unsleep", "Cancel"))
		if("Sleep")
			for(var/mob/living/L in view())
				L.SetAdminSleep()
			log_admin("[key_name(usr)] has slept everyone in view.")
			message_admins("[ADMIN_TPMONTY(usr)] has slept everyone in view.")
		if("Unsleep")
			for(var/mob/living/L in view())
				L.SetAdminSleep(remove = TRUE)
			log_admin("[key_name(usr)] has unslept everyone in view.")
			message_admins("[ADMIN_TPMONTY(usr)] has unslept everyone in view.")

/datum/admins/proc/logs_server()
	set category = "Admin"
	set name = "Get Server Logs"

	if(!check_rights(R_LOG))
		return

	usr.client.holder.browse_server_logs()


/datum/admins/proc/logs_current()
	set category = "Admin"
	set name = "Get Current Logs"
	set desc = "View/retrieve logfiles for the current round."

	if(!check_rights(R_LOG))
		return

	usr.client.holder.browse_server_logs("[GLOB.log_directory]/")


/datum/admins/proc/logs_folder()
	set category = "Admin"
	set name = "Get Server Logs Folder"
	set desc = "Please use responsibly."

	if(!check_rights(R_LOG))
		return

	if(alert("Due to the way BYOND handles files, you WILL need a click macro. This function is also recurive and prone to fucking up, especially if you select the wrong folder. Are you absolutely sure you want to proceed?", "WARNING", "Yes", "No") != "Yes")
		return

	var/path = usr.client.holder.browse_folders()
	if(!path)
		return

	usr.client.holder.recursive_download(path)


/datum/admins/proc/browse_server_logs(path = "data/logs/")
	if(!check_rights(R_LOG))
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
	if(!check_rights(R_LOG))
		return

	var/files = flist(folder)
	for(var/next in files)
		if(copytext(next, -1, 0) == "/")
			to_chat(usr, "Going deeper: [folder][next]")
			usr.client.holder.recursive_download(folder + next)
		else
			log_admin("[key_name(usr)] accessed file: [folder][next].")
			to_chat(usr, "Downloading: [folder][next]")
			var/fil = replacetext("[folder][next]", "/", "_")
			usr << ftp(file(folder + next), fil)


/datum/admins/proc/browse_folders(root = "data/logs/", max_iterations = 100)
	if(!check_rights(R_ADMIN))
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


/datum/admins/proc/browse_files(root = "data/logs/", max_iterations = 20, list/valid_extensions = list("txt", "log", "htm", "html", "json"))
	if(!check_rights(R_LOG))
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
		if(copytext_char(path, -1) != "/")		//didn't choose a directory, no need to iterate again
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
	if(!check_rights(R_LOG))
		return

	if(!istype(M))
		return

	var/ntype = text2num(type)

	var/dat = ""
	if(M.client)
		dat += "<center><p>Client</p></center>"
		dat += "<center>"
		dat += individual_logging_panel_link(M, INDIVIDUAL_GAME_LOG, LOGSRC_CLIENT, "Game Log", source, ntype)
		dat += " | "
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
	dat += individual_logging_panel_link(M, INDIVIDUAL_GAME_LOG, LOGSRC_MOB, "Game Log", source, ntype)
	dat += " | "
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

	if(!msg)
		return

	if(!check_rights(R_ASAY))
		return

	msg = emoji_parse(copytext_char(sanitize(msg), 1, MAX_MESSAGE_LEN))

	var/list/pinged_admin_clients = check_admin_pings(msg, TRUE)
	if(length(pinged_admin_clients) && pinged_admin_clients[ADMINSAY_PING_UNDERLINE_NAME_INDEX])
		msg = pinged_admin_clients[ADMINSAY_PING_UNDERLINE_NAME_INDEX]
		pinged_admin_clients -= ADMINSAY_PING_UNDERLINE_NAME_INDEX

	for(var/iter_ckey in pinged_admin_clients)
		var/client/iter_admin_client = pinged_admin_clients[iter_ckey]
		if(!iter_admin_client?.holder)
			continue
		window_flash(iter_admin_client)
		SEND_SOUND(iter_admin_client.mob, sound('sound/misc/bloop.ogg'))

	mob.log_talk(msg, LOG_ASAY)

	var/color = "asay"
	if(check_other_rights(src, R_DBRANKS, FALSE))
		color = "headminasay"

	msg = "<span class='[color]'>[span_prefix("ADMIN:")] [ADMIN_TPMONTY(mob)]: <span class='message linkify'>[msg]</span></span>"
	for(var/client/C in GLOB.admins)
		if(check_other_rights(C, R_ASAY, FALSE))
			to_chat(C,
				type = MESSAGE_TYPE_ADMINCHAT,
				html = msg)


/client/proc/get_msay()
	var/msg = input(src, null, "msay \"text\"") as text|null
	msay(msg)


/client/proc/msay(msg as text)
	set category = "Admin"
	set name = "msay"
	set hidden = TRUE

	if(!check_rights(R_ADMIN|R_MENTOR))
		return

	msg = emoji_parse(copytext_char(sanitize(msg), 1, MAX_MESSAGE_LEN))

	if(!msg)
		return

	mob.log_talk(msg, LOG_MSAY)

	var/color = "msay"
	if(check_other_rights(src, R_DBRANKS, FALSE))
		color = "adminmsay"
	else if(check_other_rights(src, R_ADMIN, FALSE))
		color = "headminmsay"

	for(var/client/C in GLOB.admins)
		if(check_other_rights(C, R_ADMIN, FALSE))
			to_chat(C,
				type = MESSAGE_TYPE_MENTORCHAT,
				html = "<span class='[color]'>[span_prefix("[holder.rank.name]:")] [ADMIN_TPMONTY(mob)]: <span class='message linkify'>[msg]</span></span>")
		else if(is_mentor(C) && mob.stat == DEAD)
			to_chat(C,
				type = MESSAGE_TYPE_MENTORCHAT,
				html = "<span class='[color]'>[span_prefix("[holder.rank.name]:")] [key_name_admin(src, TRUE, TRUE, FALSE)] [ADMIN_JMP(mob)] [ADMIN_FLW(mob)]: <span class='message linkify'>[msg]</span></span>")
		else if(is_mentor(C))
			to_chat(C,
				type = MESSAGE_TYPE_MENTORCHAT,
				html = "<span class='[color]'>[span_prefix("[holder.rank.name]:")] [key_name_admin(src, TRUE, FALSE, FALSE)] [ADMIN_JMP(mob)] [ADMIN_FLW(mob)]: <span class='message linkify'>[msg]</span></span>")

	var/list/pinged_admin_clients = check_admin_pings(msg)
	if(length(pinged_admin_clients) && pinged_admin_clients[ADMINSAY_PING_UNDERLINE_NAME_INDEX])
		msg = pinged_admin_clients[ADMINSAY_PING_UNDERLINE_NAME_INDEX]
		pinged_admin_clients -= ADMINSAY_PING_UNDERLINE_NAME_INDEX

	for(var/iter_ckey in pinged_admin_clients)
		var/client/iter_admin_client = pinged_admin_clients[iter_ckey]
		if(!iter_admin_client?.holder)
			continue
		window_flash(iter_admin_client)
		SEND_SOUND(iter_admin_client.mob, sound('sound/misc/bloop.ogg'))

/client/proc/get_dsay()
	var/msg = input(src, null, "dsay \"text\"") as text|null
	dsay(msg)


/client/proc/dsay(msg as text)
	set category = "Admin"
	set name = "dsay"
	set hidden = TRUE


	if(!check_rights(R_ADMIN|R_MENTOR))
		return

	msg = copytext_char(sanitize(msg), 1, MAX_MESSAGE_LEN)

	if(!msg)
		return

	if(is_mentor(src) && mob.stat != DEAD)
		to_chat(src, span_warning("You must be an observer to use dsay."))
		return

	if(!(prefs.toggles_chat & CHAT_DEAD))
		to_chat(src, span_warning("You have deadchat muted."))
		return

	if(handle_spam_prevention(msg, MUTE_DEADCHAT))
		return

	mob.log_talk(msg, LOG_DSAY)
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

	var/atom/A = usr.client.holder.apicker("Jump to:", "Jump", list(APICKER_AREA, APICKER_TURF, APICKER_COORDS, APICKER_MOB, APICKER_CLIENT))
	if(!istype(A))
		return

	var/turf/T = get_turf(A)
	usr.forceMove(T)

	log_admin("[key_name(usr)] jumped to [A] at [AREACOORD(T)].")
	if(!isobserver(N))
		message_admins("[ADMIN_TPMONTY(usr)] jumped to [A] at [ADMIN_TPMONTY(T)].")


/datum/admins/proc/get_mob()
	set category = "Admin"
	set name = "Get Mob"

	if(!check_rights(R_ADMIN))
		return

	var/mob/N = usr

	if(isnewplayer(N))
		return

	var/mob/M = usr.client.holder.apicker("Get by:", "Get Mob", list(APICKER_CLIENT, APICKER_MOB))
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

	var/mob/M = usr.client.holder.apicker("Send by:", "Send Mob", list(APICKER_CLIENT, APICKER_MOB))
	if(!istype(M))
		return

	var/atom/target = usr.client.holder.apicker("Where do you want to send it to?", "Send Mob", list(APICKER_AREA, APICKER_MOB, APICKER_CLIENT))
	if(!istype(target) || !istype(M))
		return

	var/turf/T = get_turf(target)

	M.forceMove(T)

	log_admin("[key_name(usr)] teleported [key_name(M)] to [AREACOORD(T)].")
	message_admins("[ADMIN_TPMONTY(usr)] teleported [ADMIN_TPMONTY(M)] to [ADMIN_VERBOSEJMP(T)].")


/datum/admins/proc/jump_area(area/A in GLOB.sorted_areas)
	set category = null
	set name = "Jump to Area"

	if(!check_rights(R_ADMIN))
		return

	var/mob/M = usr
	var/turf/T = pick(get_area_turfs(A))
	M.forceMove(T)

	log_admin("[key_name(usr)] jumped to [AREACOORD(M)].")
	if(!isobserver(M))
		message_admins("[ADMIN_TPMONTY(usr)] jumped to [ADMIN_VERBOSEJMP(M)].")


/datum/admins/proc/jump_turf(turf/T as turf)
	set category = null
	set name = "Jump to Turf"

	if(!check_rights(R_ADMIN))
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
	var/turf/T = locate(tx, ty, tz)
	if(!istype(T))
		return
	M.forceMove(T)

	log_admin("[key_name(M)] jumped to coordinate [AREACOORD(T)].")
	if(!isobserver(M))
		message_admins("[ADMIN_TPMONTY(M)] jumped to coordinate [ADMIN_VERBOSEJMP(T)].")


/datum/admins/proc/jump_mob()
	set category = null
	set name = "Jump to Mob"

	if(!check_rights(R_ADMIN))
		return

	var/mob/M = input("Please, select a mob.", "Jump to Mob") as null|anything in sortNames(GLOB.mob_list)
	if(!istype(M))
		return

	var/mob/N = usr
	var/turf/T = get_turf(M)

	N.forceMove(T)
	N.update_parallax_contents()

	log_admin("[key_name(N)] jumped to [key_name(M)]'s mob [AREACOORD(T)]")
	if(!isobserver(N))
		message_admins("[ADMIN_TPMONTY(N)] jumped to [ADMIN_TPMONTY(T)].")


/datum/admins/proc/jump_key()
	set category = null
	set name = "Jump to Key"

	if(!check_rights(R_ADMIN))
		return

	var/client/C = input("Please, select a key.", "Jump to Key") as null|anything in sortKey(GLOB.clients)
	if(!C?.mob)
		return

	var/mob/M = C.mob
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

	private_message(M.client, null)


/client/proc/private_message_panel()
	set category = "Admin"
	set name = "Private Message Mob"

	if(!check_rights(R_ADMIN|R_MENTOR))
		return

	var/mob/picked = holder.apicker("Select target:", "Private Message", list(APICKER_MOB, APICKER_CLIENT))
	if(!istype(picked))
		return

	private_message(picked.client, null)


/client/proc/ticket_reply(whom)
	if(prefs.muted & MUTE_ADMINHELP)
		to_chat(src,
			type = MESSAGE_TYPE_ADMINPM,
			html = span_warning("Error: You are unable to use admin PMs (muted)."))
		return

	var/client/C
	if(istext(whom))
		if(whom[1] == "@")
			whom = find_stealth_key(whom)
		C = GLOB.directory[whom]
	else if(istype(whom, /client))
		C = whom

	if(!C)
		if(holder)
			to_chat(src, span_warning("Error: Client not found."))
		return

	var/datum/admin_help/AH = C.current_ticket

	if(AH?.tier == TICKET_ADMIN && !check_rights(R_ADMINTICKET, FALSE))
		return
	if(AH && !AH.marked)
		AH.marked = usr.client.key
		if(AH.tier == TICKET_MENTOR)
			message_staff("[key_name_admin(src)] has marked and started replying to [key_name_admin(C, FALSE, FALSE)]'s ticket.")
		else if(AH.tier == TICKET_ADMIN)
			if(!check_rights(R_ADMINTICKET, FALSE))
				return
			message_admins("[key_name_admin(src)] has marked and started replying to [key_name_admin(C, FALSE, FALSE)]'s ticket.")

	else if(AH && AH.marked != usr.client.key)
		to_chat(usr, span_warning("This ticket has already been marked by [AH.marked], click the mark button to replace them."))
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
		to_chat(src,
			type = MESSAGE_TYPE_ADMINPM,
			html = span_warning("You are unable to use admin PMs (muted)."))
		return

	if(!holder && !current_ticket)
		to_chat(src,
			type = MESSAGE_TYPE_ADMINPM,
			html = span_warning("You can no longer reply to this ticket, please open another one by using the Adminhelp verb if need be."))
		if(msg)
			to_chat(src,
				type = MESSAGE_TYPE_ADMINPM,
				html = span_notice("Message: [msg]"))
		return

	var/client/recipient
	var/external = FALSE
	if(istext(whom))
		if(whom[1] == "@")
			whom = find_stealth_key(whom)
		if(whom == "IRCKEY")
			external = TRUE
		else
			recipient = GLOB.directory[whom]

	else if(istype(whom, /client))
		recipient = whom



	if(external)
		if(!externalreplyamount)	//to prevent people from spamming irc/discord
			return

		if(!msg)
			msg = input(src, "Message:", "Private message to Administrator") as message|null

		if(!msg)
			return

		if(holder)
			to_chat(src,
				type = MESSAGE_TYPE_ADMINPM,
				html = span_danger("Error: Use the admin IRC/Discord channel."))
			return

	else
		if(!recipient)
			if(holder)
				to_chat(src,
					type = MESSAGE_TYPE_ADMINPM,
					html = span_warning("Error: Client not found."))
				if(msg)
					to_chat(src,
						type = MESSAGE_TYPE_ADMINPM,
						html = msg)
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
				to_chat(src,
					type = MESSAGE_TYPE_ADMINPM,
					html = span_warning("You are unable to use admin PMs (muted)."))
				return

			if(!recipient && !external)
				if(holder)
					to_chat(src,
						type = MESSAGE_TYPE_ADMINPM,
						html = "<br>[span_boldnotice("Client not found. Here's your message, copy-paste it if needed:")]")
					to_chat(src,
						type = MESSAGE_TYPE_ADMINPM,
						html = "[span_notice("[msg]")]<br>")
				else
					current_ticket.MessageNoRecipient(msg)
				return

	if(handle_spam_prevention(msg, MUTE_ADMINHELP, MESSAGE_FLAG_MENTOR|MESSAGE_FLAG_ADMIN))
		return

	//clean the message if it's not sent by a high-rank admin
	if(!check_rights(R_SERVER|R_DEBUG, FALSE) || external)//no sending html to the poor bots
		msg = sanitize(copytext_char(msg, 1, MAX_MESSAGE_LEN))
		if(!msg)
			return

	var/rawmsg = msg

	var/keywordparsedmsg = keywords_lookup(msg)

	if(external)
		to_chat(src,
			type = MESSAGE_TYPE_ADMINPM,
			html = "[span_notice("PM to-<b>Staff</b>: <span class='linkify'>[rawmsg]")]</font>")
		var/datum/admin_help/AH = admin_ticket_log(src, "<font color='#ff8c8c'>Reply PM from-<b>[key_name(src, TRUE, TRUE)] to <i>External</i>: [keywordparsedmsg]</font>")
		externalreplyamount--
		send2adminchat("[AH ? "#[AH.id] " : ""]Reply: [ckey]", sanitizediscord(rawmsg))
	else
		if(check_other_rights(recipient, R_ADMINTICKET, FALSE) || is_mentor(recipient))
			if(check_rights(R_ADMINTICKET, FALSE) || is_mentor(src)) //Both are staff
				if(!current_ticket && !recipient.current_ticket)
					if(check_other_rights(recipient, R_ADMINTICKET, FALSE) || check_rights(R_ADMINTICKET, FALSE))
						new /datum/admin_help(msg, recipient, TRUE, TICKET_ADMIN)
					else
						new /datum/admin_help(msg, recipient, TRUE, TICKET_MENTOR)

				to_chat(recipient,
					type = MESSAGE_TYPE_ADMINPM,
					html = "<font size='3' span class='staffpmin'>Staff PM from-<b>[key_name(src, recipient, TRUE)]</b>: [span_linkify("[keywordparsedmsg]")]</span>")
				to_chat(src,
					type = MESSAGE_TYPE_ADMINPM,
					html = "<font size='3' span class='staffpmout'>Staff PM to-<b>[key_name(recipient, src, TRUE)]</b>: [span_linkify("[keywordparsedmsg]")]</span>")

				window_flash(recipient, TRUE)
				window_flash(src, TRUE)

				var/interaction_message = "<font color='#cea7f1'>PM from-<b>[key_name(src, recipient, TRUE)]</b> to-<b>[key_name(recipient, src, TRUE)]</b>: [keywordparsedmsg]</font>"
				admin_ticket_log(src, interaction_message)
				if(recipient != src)
					admin_ticket_log(recipient, interaction_message)

			else //Recipient is a staff member, sender is not.
				SEND_SIGNAL(current_ticket, COMSIG_ADMIN_HELP_REPLIED)
				admin_ticket_log(src, "<font color='#ff8c8c'>Reply PM from-<b>[key_name(src, recipient, TRUE)]</b>: [span_linkify("[keywordparsedmsg]")]</font>")
				to_chat(recipient,
					type = MESSAGE_TYPE_ADMINPM,
					html = "<font size='3' span class='staffpmin'>Staff PM from-<b>[key_name(src, recipient, TRUE)]</b>: [span_linkify("[keywordparsedmsg]")]</span>")
				to_chat(src,
					type = MESSAGE_TYPE_ADMINPM,
					html = span_notice("PM to-<b>Staff</b>: [span_linkify("[msg]")]"))
				window_flash(recipient, TRUE)

			//Play the bwoink if enabled.
			if(recipient.prefs.toggles_sound & SOUND_ADMINHELP)
				SEND_SOUND(recipient, sound('sound/effects/adminhelp.ogg', channel = CHANNEL_ADMIN))

		else  //PM sender is mentor/admin, recipient is not -> big red text
			if(check_rights(R_ADMINTICKET, FALSE) || is_mentor(src))
				if(!recipient.current_ticket)
					if(check_rights(R_ADMINTICKET, FALSE))
						new /datum/admin_help(msg, recipient, TRUE, TICKET_ADMIN)
					else if(is_mentor(src))
						new /datum/admin_help(msg, recipient, TRUE, TICKET_MENTOR)

				if(check_rights(R_ADMINTICKET, FALSE))
					to_chat(recipient,
						type = MESSAGE_TYPE_ADMINPM,
						html = "<font color='red' size='4'><b>-- Private Message --</b></font>")
					to_chat(recipient,
						type = MESSAGE_TYPE_ADMINPM,
						html = "<font color='red'>[holder.fakekey ? "Administrator" : holder.rank.name] PM from-<b>[key_name(src, recipient, FALSE)]</b>: [span_linkify("[msg]")]</font>")
					to_chat(recipient,
						type = MESSAGE_TYPE_ADMINPM,
						html = "<font color='red'><i>Click on the staff member's name to reply.</i></font>")
					to_chat(src,
						type = MESSAGE_TYPE_ADMINPM,
						html = span_notice("<b>[holder.fakekey ? "Administrator" : holder.rank.name] PM</b> to-<b>[key_name(recipient, src, TRUE)]</b>: [span_linkify("[msg]")]"))
					SEND_SOUND(recipient, sound('sound/effects/adminhelp.ogg', channel = CHANNEL_ADMIN))
					window_flash(recipient, TRUE)
				else if(is_mentor(src))
					to_chat(recipient,
						type = MESSAGE_TYPE_ADMINPM,
						html = "<font color='blue' size='2'><b>-- Mentor Message --</b></font>")
					to_chat(recipient,
						type = MESSAGE_TYPE_ADMINPM,
						html = span_notice("[holder.rank.name] PM from-<b>[key_name(src, recipient, FALSE)]</b>: [span_linkify("[msg]")]"))
					to_chat(recipient,
						type = MESSAGE_TYPE_ADMINPM,
						html = span_notice("<i>Click on the mentor's name to reply.</i>"))
					to_chat(src,
						type = MESSAGE_TYPE_ADMINPM,
						html = span_notice("<b>[holder.rank.name] PM</b> to-<b>[key_name(recipient, src, TRUE)]</b>: [span_linkify("[msg]")]"))
					SEND_SOUND(recipient, sound('sound/effects/mentorhelp.ogg', channel = CHANNEL_ADMIN))
					window_flash(recipient)

				admin_ticket_log(recipient, "<font color='#a7f2ef'>PM From [key_name_admin(src)]: [keywordparsedmsg]</font>")


			else		//neither are admins
				to_chat(src,
					type = MESSAGE_TYPE_ADMINPM,
					html = span_warning("Error: Non-staff to non-staff communication is disabled."))
				return

	if(external)
		log_admin_private("PM: [key_name(src)]->External: [rawmsg]")
		for(var/client/X in GLOB.admins)
			if(check_other_rights(X, R_ADMINTICKET, FALSE))
				to_chat(X,
					type = MESSAGE_TYPE_ADMINPM,
					html = span_notice("<B>PM: [key_name(src, X, FALSE)]-&gt;External:</B> [keywordparsedmsg]"))
	else
		log_admin_private("PM: [key_name(src)]->[key_name(recipient)]: [rawmsg]")
		//Admins PMs go to admins, mentor PMs go to mentors and admins
		if(check_rights(R_ADMINTICKET, FALSE))
			for(var/client/X in GLOB.admins)
				if(X.key == key || X.key == recipient.key)
					continue
				if(check_other_rights(X, R_ADMINTICKET, FALSE))
					to_chat(X,
						type = MESSAGE_TYPE_ADMINPM,
						html = span_notice("<B>Admin PM: [key_name(src, X, FALSE)]-&gt;[key_name(recipient, X, FALSE)]:</B> [keywordparsedmsg]"))
		else if(is_mentor(src))
			for(var/client/X in GLOB.admins)
				if(X.key == key || X.key == recipient.key)
					continue
				if(check_other_rights(X, R_ADMINTICKET, FALSE) || is_mentor(X))
					to_chat(X,
					type = MESSAGE_TYPE_ADMINPM,
					html = span_notice("<B>Mentor PM: [key_name(src, X, FALSE)]-&gt;[key_name(recipient, X, FALSE)]:</B> [keywordparsedmsg]"))
		else //Admins get all messages, mentors only mentor responses
			var/datum/admin_help/AH = src.current_ticket
			for(var/client/X in GLOB.admins)
				if(X.key == key || X.key == recipient.key)
					continue
				if(check_other_rights(X, R_ADMINTICKET, FALSE))
					to_chat(X,
						type = MESSAGE_TYPE_ADMINPM,
						html = span_notice("<B>PM: [key_name(src, X, FALSE)]-&gt;[key_name(recipient, X, FALSE)]:</B> [keywordparsedmsg]"))
			if(AH?.tier == TICKET_MENTOR)
				for(var/client/X in GLOB.admins)
					if(X.key == key || X.key == recipient.key)
						continue
					if(is_mentor(X))
						to_chat(X,
						type = MESSAGE_TYPE_ADMINPM,
						html = span_notice("<B>PM: [key_name(src, X, FALSE)]-&gt;[key_name(recipient, X, FALSE)]:</B> [keywordparsedmsg]"))


/proc/TgsPm(target, msg, sender)
	target = ckey(target)
	var/client/C = GLOB.directory[target]

	var/datum/admin_help/ticket = C ? C.current_ticket : GLOB.ahelp_tickets.CKey2ActiveTicket(target)
	var/compliant_msg = trim(lowertext(msg))
	var/tgs_tagged = "[sender](TGS/External)"
	var/list/splits = splittext(compliant_msg, " ")
	if(length(splits) && splits[1] == "ticket")
		if(length(splits) < 2)
			return IRC_AHELP_USAGE
		switch(splits[2])
			if("close")
				if(ticket)
					ticket.Close(FALSE, TRUE)
					ticket.AddInteraction("<font color='#ff8c8c'>External interaction by: [tgs_tagged].</font>")
					message_admins("External interaction by: [tgs_tagged]")
					return "Ticket #[ticket.id] successfully closed"
			if("resolve")
				if(ticket)
					ticket.Resolve(FALSE, TRUE)
					ticket.AddInteraction("<font color='#ff8c8c'>External interaction by: [tgs_tagged].</font>")
					message_admins("External interaction by: [tgs_tagged]")
					return "Ticket #[ticket.id] successfully resolved"
			if("icissue")
				if(ticket)
					ticket.ICIssue(TRUE)
					ticket.AddInteraction("<font color='#ff8c8c'>External interaction by: [tgs_tagged].</font>")
					message_admins("External interaction by: [tgs_tagged]")
					return "Ticket #[ticket.id] successfully marked as IC issue"
			if("reject")
				if(ticket)
					ticket.Reject(TRUE)
					ticket.AddInteraction("<font color='#ff8c8c'>External interaction by: [tgs_tagged].</font>")
					message_admins("External interaction by: [tgs_tagged]")
					return "Ticket #[ticket.id] successfully rejected"
			if("tier")
				if(ticket)
					ticket.Tier(TRUE)
					ticket.AddInteraction("<font color='#ff8c8c'>External interaction by: [sender].</font>")
					message_admins("External interaction by: [tgs_tagged]")
					var/ticket_type = (ticket.tier == TICKET_ADMIN) ? "an admin" : "a mentor"
					return "Ticket #[ticket.id] successfully tiered as [ticket_type] ticket"
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
				AH.AddInteraction("<font color='#ff8c8c'>External interaction by: [tgs_tagged].</font>")
				message_admins("External interaction by: [tgs_tagged]")
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
		stealthkey = GenTgsStealthKey()

	msg = sanitize(copytext_char(msg, 1, MAX_MESSAGE_LEN))
	if(!msg)
		return "Error: No message"

	log_admin_private("External PM: [tgs_tagged] -> [key_name(C)] : [msg]")
	message_admins("External PM: [tgs_tagged] -> [key_name_admin(C, FALSE, FALSE)] : [msg]")

	to_chat(C,
		type = MESSAGE_TYPE_ADMINPM,
		html = "<font color='red' size='4'><b>-- Administrator private message --</b></font>")
	to_chat(C,
		type = MESSAGE_TYPE_ADMINPM,
		html = "<font color='red'>Admin PM from-<b><a href='?priv_msg=[stealthkey]'>[adminname]</A></b>: [msg]</font>")
	to_chat(C,
		type = MESSAGE_TYPE_ADMINPM,
		html = "<font color='red'><i>Click on the administrator's name to reply.</i></font>")

	admin_ticket_log(C, "<font color='#a7f2ef'>PM From [tgs_tagged]: [msg]</font>")

	//always play non-admin recipients the adminhelp sound
	SEND_SOUND(C, sound('sound/effects/adminhelp.ogg', channel = CHANNEL_ADMIN))

	C.externalreplyamount = EXTERNALREPLYCOUNT

	return "Message Successful"


/datum/admins/proc/remove_from_tank()
	set category = "Admin"
	set name = "Remove From Tank"

	if(!check_rights(R_ADMIN))
		return

	for(var/obj/vehicle/multitile/root/cm_armored/CA AS in GLOB.tank_list)
		CA.remove_all_players()

		log_admin("[key_name(usr)] forcibly removed all players from [CA].")
		message_admins("[ADMIN_TPMONTY(usr)] forcibly removed all players from [CA].")

/// Admin verb to delete a squad completely
/datum/admins/proc/delete_squad()
	set category = "Admin"
	set name = "Delete a squad"

	if(!check_rights(R_ADMIN))
		return
	var/id_to_del = input("Choose the marine's new squad.", "Change Squad") as null|anything in SSjob.squads
	if(!id_to_del)
		return
	qdel(SSjob.squads[id_to_del])
	var/msg = "[key_name(usr)] has deleted a squad. ID:[id_to_del]."
	message_admins(msg)
	log_admin(msg)

/datum/admins/proc/job_slots()
	set category = "Admin"
	set name = "Job Slots"

	if(!check_rights(R_ADMIN))
		return

	var/datum/browser/browser = new(usr, "jobmanagement", "Manage Free Slots", 700)
	var/list/dat = list()
	var/count = 0

	if(!SSjob.initialized)
		return

	dat += "<table>"
	if(SSjob.initialized && (!SSticker.HasRoundStarted()))
		if(SSjob.ssjob_flags & SSJOB_OVERRIDE_JOBS_START)
			dat += "<A href='?src=[REF(usr.client.holder)];[HrefToken()];overridejobsstart=false'>Do Not Override Game Mode Settings</A> (game mode settings deal with job scaling and roundstart-only jobs cleanup, which will require manual editing if used while overriden)"
		else
			dat += "<A href='?src=[REF(usr.client.holder)];[HrefToken()];overridejobsstart=true'>Override Game Mode Settings</A> (if not selected, changes will be erased at roundstart)"
		dat += "<br /><hr />" // Add a clear new line
	dat += "<A href='?src=[REF(usr.client.holder)];[HrefToken()];clearalljobslots=1'>Remove all job slots</A><br />"
	for(var/j in SSjob.joinable_occupations)
		var/datum/job/job = j
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
			dat += "<A href='?src=[REF(usr.client.holder)];[HrefToken()];clearjobslots=[job.title]'>Remove all</A> | "
			dat += "<A href='?src=[REF(usr.client.holder)];[HrefToken()];unlimitjobslot=[job.title]'>Unlimit</A></td>"
		else
			dat += "<A href='?src=[REF(usr.client.holder)];[HrefToken()];limitjobslot=[job.title]'>Limit</A></td>"

	browser.height = min(100 + count * 25, 700)
	browser.set_content(dat.Join())
	browser.open()


/datum/admins/proc/mcdb()
	set category = "Admin"
	set name = "Open MCDB"

	if(!CONFIG_GET(string/dburl))
		to_chat(usr, span_warning("Database URL not set."))
		return

	if(alert("This will open the MCDB in your browser. Are you sure?", "MCDB", "Yes", "No") != "Yes")
		return

	DIRECT_OUTPUT(usr, link(CONFIG_GET(string/dburl)))


/datum/admins/proc/check_fingerprints(atom/A)
	set category = null
	set name = "Check Fingerprints"

	if(!check_rights(R_ADMIN))
		return

	var/dat = "<br>"

	if(!A.fingerprints)
		dat += "No fingerprints detected."

	for(var/i in A.fingerprints)
		dat += "[i] - [A.fingerprints[i]]<br>"

	var/datum/browser/browser = new(usr, "fingerprints_[A]", "Fingerprints on [A]")
	browser.set_content(dat)
	browser.open(FALSE)


/client/proc/get_togglebuildmode()
	set name = "Toggle Build Mode"
	set category = "Admin.Fun"
	if(!check_rights(R_SPAWN))
		return
	togglebuildmode(mob)

/client/proc/toggle_admin_tads()
	set category = "Admin.Fun"
	set name = "Toggle Tadpole Restrictions"

	if(!check_rights(R_FUN))
		return

	if(SSticker.mode.enable_fun_tads)
		message_admins("[ADMIN_TPMONTY(usr)] toggled Tadpole restrictions off.")
		log_admin("[key_name(usr)] toggled Tadpole restrictions off.")
		SSticker.mode.enable_fun_tads = FALSE
	else
		SSticker.mode.enable_fun_tads = TRUE
		message_admins("[ADMIN_TPMONTY(usr)] toggled Tadpole restrictions on.")
		log_admin("[key_name(usr)] toggled Tadpole restrictions on.")

//returns TRUE to let the dragdrop code know we are trapping this event
//returns FALSE if we don't plan to trap the event
/datum/admins/proc/cmd_ghost_drag(mob/dead/observer/frommob, mob/tomob)

	//this is the exact two check rights checks required to edit a ckey with vv.
	if (!check_rights(R_VAREDIT,0) || !check_rights(R_SPAWN|R_DEBUG,0))
		return FALSE

	if (!frommob.ckey)
		return FALSE

	var/question = ""
	if (tomob.ckey)
		question = "This mob already has a user ([tomob.key]) in control of it! "
	question += "Are you sure you want to place [frommob.name]([frommob.key]) in control of [tomob.name]?"

	var/ask = alert(question, "Place ghost in control of mob?", "Yes", "No")
	if (ask != "Yes")
		return TRUE

	if (!frommob || !tomob) //make sure the mobs don't go away while we waited for a response
		return TRUE

	// Disassociates observer mind from the body mind
	if(tomob.client)
		tomob.ghostize(FALSE)
	else
		for(var/mob/dead/observer/ghost in GLOB.dead_mob_list)
			if(tomob.mind == ghost.mind)
				ghost.mind = null

	message_admins(span_adminnotice("[key_name_admin(usr)] has put [frommob.key] in control of [tomob.name]."))
	log_admin("[key_name(usr)] stuffed [frommob.key] into [tomob.name].")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Ghost Drag Control")

	tomob.ckey = frommob.ckey
	tomob.client?.init_verbs()
	qdel(frommob)

	return TRUE

/client/proc/mass_replace()
	set name = "Mass replace atom"
	set category = "Admin.Fun"
	if(!check_rights(R_SPAWN))
		return
	var/to_replace = pick_closest_path(input("Pick a movable atom path to be replaced", "Enter path as text") as text)
	var/to_place = pick_closest_path(input("Pick atom path to replace with", "Enter path as text") as text)
	var/current_caller = GLOB.AdminProcCaller
	var/ckey = usr ? usr.client.ckey : GLOB.AdminProcCaller
	if(!ckey)
		CRASH("mass replace with no ckey")

	if(current_caller && current_caller != ckey)
		if(!GLOB.AdminProcCallSpamPrevention[ckey])
			to_chat(usr, span_adminnotice("Another set of admin called procs are still running, your proc will be run after theirs finish."))
			GLOB.AdminProcCallSpamPrevention[ckey] = TRUE
			UNTIL(!GLOB.AdminProcCaller)
			to_chat(usr, span_adminnotice("Running your proc"))
			GLOB.AdminProcCallSpamPrevention -= ckey
		else
			UNTIL(!GLOB.AdminProcCaller)

	var/logging = "[ckey] is replacing all [to_replace] in world with [to_place]"
	log_admin(logging)
	message_admins(logging)
	GLOB.AdminProcCaller = ckey	//if this runtimes, too bad for you
	var/replaced = 0
	for(var/atom/movable/thing in world)
		if(istype(thing, to_replace))
			new to_place (thing.loc)
			qdel(thing)
			replaced++
	GLOB.AdminProcCaller = null
	var/afterlogging = "[replaced] amounts of atoms replaced"
	log_admin(afterlogging)
	message_admins(afterlogging)

/client/proc/smite(mob/living/target as mob) //select a living mob as a target and smite them with a choice with a selection from global smites
	set category = "Admin"
	set name = "Smite"

	var/punishment = input("Choose a punishment", "DIVINE SMITING") as null|anything in GLOB.smites //Choose a smite if any exist from global smites

	if(QDELETED(target) || !punishment)
		return

	var/smite_path = GLOB.smites[punishment]
	var/datum/smite/smite = new smite_path
	var/configuration_success = smite.configure(usr)
	if (configuration_success == FALSE)
		return
	smite.effect(src, target)

/client/proc/punish_log(whom, punishment) //log and push to chat the smite victim and punishing admin
	var/msg = "[key_name_admin(src)] punished [key_name_admin(whom)] with [punishment]."
	message_admins(msg)
	admin_ticket_log(whom, msg)
	log_admin("[key_name(src)] punished [key_name(whom)] with [punishment].")

/client/proc/show_traitor_panel(mob/target_mob in GLOB.mob_list)
	set category = "Admin"
	set name = "Show Objective Panel"
	var/datum/mind/target_mind = target_mob.mind
	if(!target_mind)
		to_chat(usr, "This mob has no mind!", confidential = TRUE)
		return
	if(!istype(target_mob) && !istype(target_mind))
		to_chat(usr, "This can only be used on instances of type /mob and /mind", confidential = TRUE)
		return
	target_mind.traitor_panel()
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Objective Panel") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/validate_objectives()
	set category = "Debug"
	set name = "Check All Objectives Completion"
	for(var/datum/antagonist/A in GLOB.antagonists)
		if(!A.owner)
			continue

		to_chat(usr,"[A.owner.key]")
		to_chat(usr,"[A.owner.name]")
		to_chat(usr,"[A.type]")
		to_chat(usr,"[A.name]")

		if(length(A.objectives))
			for(var/datum/objective/O in A.objectives)
				var/result = O.check_completion() ? "SUCCESS" : "FAIL"
				to_chat(usr,"--------------------------------")
				to_chat(usr,"[O.type]")
				to_chat(usr,"---------------------------------")
				to_chat(usr,"[O.explanation_text] = [result]")
				to_chat(usr,"----------------------------------")
