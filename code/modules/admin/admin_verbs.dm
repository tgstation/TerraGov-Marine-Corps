/datum/admins/proc/admin_ghost()
	set category = "Admin"
	set name = "Aghost"
	set desc = "Allows you to ghost and re-enter body at will."

	if(!check_rights(R_ADMIN) && !is_mentor(owner))
		return

	if(!owner?.mob)
		return

	var/mob/M = owner.mob

	if(istype(M, /mob/new_player))
		return
	else if(istype(M, /mob/dead/observer))
		var/mob/dead/observer/ghost = M
		ghost.can_reenter_corpse = TRUE
		ghost.reenter_corpse()
	else
		M.ghostize(TRUE)
		owner.change_view(world.view)
		if(M && !M.key)
			M.key = "@[owner.key]"


		log_admin("[key_name(usr)] admin ghosted.")
		message_admins("[ADMIN_TPMONTY(usr)] admin ghosted.")


/datum/admins/proc/invisimin()
	set name = "Invisimin"
	set category = "Admin"
	set desc = "Toggles ghost-like invisibility."

	if(!check_rights(R_ADMIN))
		return

	if(!owner?.mob)
		return

	var/mob/M = owner.mob

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

	if(fakekey)
		fakekey = null
	else
		var/new_key = ckeyEx(input("Enter your desired display name.",, owner.key) as text|null)
		if(!new_key)
			return
		if(length(new_key) >= 26)
			new_key = copytext(new_key, 1, 26)
		fakekey = new_key

	log_admin("[key_name(usr)] has turned stealth mode [fakekey ? "on" : "off"].")
	message_admins("[ADMIN_TPMONTY(usr)] has turned stealth mode [fakekey ? "on" : "off"].")


/datum/admins/proc/jobs_free()
	set name = "Job Slots - Free"
	set category = "Admin"
	set desc = "Allows you to free a job slot."

	if(!check_rights(R_ADMIN))
		return

	var/list/roles = list()
	var/datum/job/J
	for(var/r in RoleAuthority.roles_for_mode) //All the roles in the game.
		J = RoleAuthority.roles_for_mode[r]
		if(J.total_positions != -1 && J.get_total_positions(1) <= J.current_positions)
			roles += r

	if(!roles.len)
		to_chat(usr, "<span class='warning'>There are no fully staffed roles.</span>")
		return

	var/role = input("Please select role slot to free", "Free role slot") as null|anything in roles
	RoleAuthority.free_role(RoleAuthority.roles_for_mode[role])

	log_admin("[key_name(usr)] has made a [role] slot free.")
	message_admins("[ADMIN_TPMONTY(usr)] has made a [role] slot free.")


/datum/admins/proc/jobs_list()
	set category = "Admin"
	set name = "Job Slots - List"
	set desc = "Lists all roles and their current status."

	if(!check_rights(R_ADMIN))
		return

	if(!RoleAuthority)
		return

	var/datum/job/J
	var/i
	for(i in RoleAuthority.roles_by_name)
		J = RoleAuthority.roles_by_name[i]
		if(J.flags_startup_parameters & ROLE_ADD_TO_MODE)
			to_chat(src, "[J.title]: [J.get_total_positions(1)] / [J.current_positions]")

	log_admin("[key_name(usr)] checked job slots.")
	message_admins("[ADMIN_TPMONTY(usr)] checked job slots.")


/datum/admins/proc/change_key(mob/M in living_mob_list)
	set category = "Admin"
	set name = "Change CKey"
	set desc = "Allows you to properly change the ckey of a mob."

	if(!check_rights(R_ADMIN))
		return

	if(M.gc_destroyed)
		return

	var/new_ckey = input("Enter new ckey:","CKey") as null|text

	if(!new_ckey)
		return

	M.ghostize(FALSE)
	M.ckey = new_ckey
	if(M.client)
		M.client.change_view(world.view)

	log_admin("[key_name(usr)] changed [M.name] ckey to [new_ckey].")
	message_admins("[ADMIN_TPMONTY(usr)] changed [ADMIN_TPMONTY(M)] ckey to [new_ckey].")


/datum/admins/proc/rejuvenate(mob/living/M as mob in mob_list)
	set category = "Admin"
	set name = "Rejuvenate"
	set desc = "Revives a mob."

	if(!check_rights(R_ADMIN))
		return

	if(!M || !istype(M))
		return

	M.revive()

	log_admin("[key_name(usr)] revived [key_name(M)].")
	message_admins("[ADMIN_TPMONTY(usr)] revived [key_name_admin(M)].")


/datum/admins/proc/toggle_sleep(var/mob/living/M as mob in mob_list)
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
			message_admins("[key_name_admin(usr)] has slept everyone in view.")
		if("Unsleep")
			for(var/mob/living/M in view())
				M.sleeping = 0
			log_admin("[key_name(usr)] has unslept everyone in view.")
			message_admins("[ADMIN_TPMONTY(usr)]has unslept everyone in view.")


/datum/admins/proc/change_squad(var/mob/living/carbon/human/H in mob_list)
	set category = "Admin"
	set name = "Change Squad"

	if(!check_rights(R_ADMIN))
		return

	if(!istype(H) || !ticker || !H.mind?.assigned_role)
		return

	if(!(H.mind.assigned_role in list("Squad Marine", "Squad Engineer", "Squad Medic", "Squad Smartgunner", "Squad Specialist", "Squad Leader")))
		return

	var/datum/squad/S = input(usr, "Choose the marine's new squad") as null|anything in RoleAuthority.squads

	if(!S)
		return

	H.set_everything(H.mind.assigned_role)

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
			qdel(H.wear_ear)
			H.update_icons()
		H.wear_ear = new /obj/item/device/radio/headset/almayer/marine
		var/obj/item/device/radio/headset/almayer/marine/E = H.wear_ear
		E.set_frequency(S.radio_freq)
		H.update_icons()

	H.hud_set_squad()

	log_admin("[key_name(src)] has changed the squad of [key_name(H)] to [S.name].")
	message_admins("[ADMIN_TPMONTY(usr)] has changed the squad of [ADMIN_TPMONTY(H)] to [S.name].")


/datum/admins/proc/direct_control(var/mob/M in mob_list)
	set category = "Admin"
	set name = "Take Over"
	set desc = "Rohesie's verb."

	if(!check_rights(R_ADMIN))
		return

	var/replaced = FALSE
	if(M.ckey)
		if(alert("This mob is being controlled by [M.ckey], they will be made a ghost. Are you sure?",,"Yes","No") == "Yes")
			M.ghostize()
			replaced = TRUE
		else
			return

	var/mob/adminmob = owner.mob
	M.ckey = owner.ckey

	if(M.client)
		M.client.change_view(world.view)

	if(isobserver(adminmob))
		qdel(adminmob)

	log_admin("[key_name(usr)] took over [M.name][replaced ? " replacing the previous owner" : ""].")
	message_admins("[ADMIN_TPMONTY(usr)] took over [M.name][replaced ? " replacing the previous owner" : ""]..")


/datum/admins/proc/logs_server()
	set category = "Admin"
	set name = "Get Server Logs"

	if(!check_rights(R_ADMIN))
		return

	browseserverlogs()


/datum/admins/proc/logs_current()
	set category = "Admin"
	set name = "Get Current Logs"
	set desc = "View/retrieve logfiles for the current round."

	if(!check_rights(R_ADMIN))
		return

	browseserverlogs("[GLOB.log_directory]/")


/datum/admins/proc/logs_folder()
	set name = "Get Server Logs Folder"
	set desc = "Please use responsibly."
	set category = "Admin"

	if(!check_rights(R_ADMIN))
		return

	var/choice = alert(src, "Due to the way BYOND handles files, you WILL need a click macro. This function is also recurive and prone to fucking up, especially if you select the wrong folder. Are you absolutely sure you want to proceed?", "WARNING", "Yes", "No")
	if(choice != "Yes")
		return

	var/path = "data/logs/"
	path = browse_folders(path)

	if(path)
		recursive_download(path)


/datum/admins/proc/browseserverlogs(path = "data/logs/")
	if(!check_rights(R_ADMIN))
		return

	path = browse_folders(path)
	if(!path)
		return

	switch(alert("View (in game), Open (in your system's text editor), Download", path, "View", "Open", "Download"))
		if("View")
			src << browse("<pre style='word-wrap: break-word;'>[html_encode(file2text(file(path)))]</pre>", list2params(list("window" = "viewfile.[path]")))
		if("Open")
			src << run(file(path))
		if("Download")
			src << ftp(file(path))

	log_admin("[key_name(usr)] accessed file: [path].")
	message_admins("[ADMIN_TPMONTY(usr)] accessed file: [path].")


/datum/admins/proc/recursive_download(var/folder)
	if(!check_rights(R_ADMIN))
		return

	var/files = flist(folder)
	for(var/next in files)
		if(copytext(next, -1, 0) == "/")
			to_chat(src, "Going deeper: [folder][next]")
			recursive_download(folder + next)
		else
			to_chat(src, "Downloading: [folder][next]")
			var/fil = replacetext("[folder][next]", "/", "_")
			spawn(5)
				src << ftp(file(folder + next), fil)


/datum/admins/proc/browse_folders(root = "data/logs/", max_iterations = 100)
	var/path = root
	for(var/i = 0, i < max_iterations, i++)
		var/list/choices = flist(path)
		if(path != root)
			choices.Insert(1, "/")
		var/choice = input(src, "Choose a folder to access:", "Download", null) as null|anything in choices
		switch(choice)
			if(null)
				return FALSE
			if("/")
				path = root
				continue
		path += choice
		if(copytext(path, -1, 0) != "/")
			continue
		else
			var/choice2 = alert(src, "Is this the folder you want to download?:",, "Yes", "No")
			switch(choice2)
				if("Yes")
					break
				if("No")
					continue
	return path


/datum/admins/proc/show_individual_logging_panel(mob/M, source = LOGSRC_CLIENT, type = INDIVIDUAL_ATTACK_LOG)
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
	var/slabel = label
	if(selected_type == log_type && selected_src == log_src)
		slabel = "<b>\[[label]\]</b>"

	return "<a href='?_src_=holder;individuallog=\ref[M];log_type=[log_type];log_src=[log_src]'>[slabel]</a>"


/datum/admins/proc/asay(msg as text)
	set category = "Admin"
	set name = "asay"
	set hidden = TRUE

	if(!check_rights(R_ASAY))
		return

	if(!msg)
		return

	log_admin_private_asay("[key_name(usr)]: [msg]")

	var/color = "adminsay"
	if(check_rights(R_EVERYTHING))
		color = "headminsay"

	if(check_rights(R_ADMIN))
		msg = "<span class='[color]'><span class='prefix'>ADMIN:</span> [ADMIN_TPMONTY(usr)]: <span class='message'>[msg]</span></span>"
		for(var/client/C in GLOB.admins)
			if(check_other_rights(C, R_ASAY))
				to_chat(C, msg)


/datum/admins/proc/msay(msg as text)
	set category = "Admin"
	set name = "msay"
	set hidden = TRUE

	if(!check_rights(R_ADMIN) && !is_mentor(owner))
		return

	msg = copytext(sanitize(msg), 1, MAX_MESSAGE_LEN)

	if(!msg)
		return

	log_admin_private_msay("[key_name(usr)]: [msg]")

	var/color = "mod"
	if(check_rights(R_EVERYTHING))
		color = "headminmod"
	else if(check_rights(R_ADMIN))
		color = "adminmod"

	for(var/client/C in GLOB.admins)
		if(check_other_rights(C, R_ADMIN))
			to_chat(C, "<span class='[color]'><span class='prefix'>[rank]</span> [ADMIN_TPMONTY(C.mob)]: <span class='message'>[msg]</span></span>")
		else if(is_mentor(C) && owner.mob.stat == DEAD)
			to_chat(C, "<span class='[color]'><span class='prefix'>[rank]</span> [key_name_admin(C, TRUE, TRUE, FALSE)] [ADMIN_JMP(C.mob)] [ADMIN_FLW(C.mob)]: <span class='message'>[msg]</span></span>")
		else
			to_chat(C, "<span class='[color]'><span class='prefix'>[rank]</span> [key_name_admin(C, TRUE, FALSE, FALSE)] [ADMIN_JMP(C.mob)] [ADMIN_FLW(C.mob)]: <span class='message'>[msg]</span></span>")


/datum/admins/proc/dsay(msg as text)
	set category = "Admin"
	set name = "dsay"
	set hidden = TRUE

	if(!check_rights(R_ADMIN) && !is_mentor(owner))
		return

	if(is_mentor(owner) && owner.mob.stat != DEAD)
		to_chat(usr, "<span class='warning'>You must be an observer to use dsay.</span>")
		return

	if(owner.prefs.muted & MUTE_DEADCHAT)
		to_chat(usr, "<span class='warning'>You cannot send DSAY messages (muted).</span>")
		return

	if(!(owner.prefs.toggles_chat & CHAT_DEAD))
		to_chat(usr, "<span class='warning'>You have deadchat muted.</span>")
		return

	if(owner.handle_spam_prevention(msg, MUTE_DEADCHAT))
		return

	msg = copytext(sanitize(msg), 1, MAX_MESSAGE_LEN)

	if(!msg)
		return

	log_dsay("[key_name(usr)]: [msg]")
	msg = "<span class='game deadsay'><span class='prefix'>DEAD:</span> <span class='name'>([rank]) [fakekey ? fakekey : owner.key]</span> says, <span class='message'>[msg]</span></span>"

	for(var/client/C in clients)
		if(istype(C.mob, /mob/new_player))
			continue

		if(check_other_rights(C, R_ADMIN) && (C.prefs.toggles_chat & CHAT_DEAD))
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

	var/mob/M = owner.mob
	M.on_mob_jump()
	M.forceMove(pick(get_area_turfs(A)))

	log_admin("[key_name(usr)] jumped to [AREACOORD(A)].")
	if(!istype(M, /mob/dead/observer))
		message_admins("[ADMIN_TPMONTY(usr)] jumped to [ADMIN_VERBOSEJMP(A)].")


/datum/admins/proc/jump_turf(var/turf/T in turfs)
	set category = "Admin"
	set name = "Jump to Turf"

	if(!check_rights(R_ADMIN))
		return

	var/mob/M = owner.mob
	M.on_mob_jump()
	M.forceMove(T)

	log_admin("[key_name(usr)] jumped to area [AREACOORD(M.loc)].")
	if(!istype(M, /mob/dead/observer))
		message_admins("[ADMIN_TPMONTY(usr)] jumped to area [ADMIN_VERBOSEJMP(M.loc)].")


/datum/admins/proc/jump_coord(tx as num, ty as num, tz as num)
	set category = "Admin"
	set name = "Jump to Coordinate"

	if(!check_rights(R_ADMIN))
		return

	var/mob/M = owner.mob
	M.on_mob_jump()
	M.x = tx
	M.y = ty
	M.z = tz
	M.forceMove(M.loc)

	log_admin("[key_name(usr)] jumped to coordinate [AREACOORD(M.loc)].")
	if(!istype(usr, /mob/dead/observer))
		message_admins("[ADMIN_TPMONTY(usr)] jumped to coordinate [ADMIN_VERBOSEJMP(M.loc)].")


/datum/admins/proc/jump_mob(var/mob/M in mob_list)
	set category = "Admin"
	set name = "Jump to Mob"

	if(!check_rights(R_ADMIN))
		return

	var/mob/N = owner.mob
	var/turf/T = get_turf(M)

	N.on_mob_jump()
	N.forceMove(T)

	log_admin("[key_name(usr)] jumped to [key_name(M)]'s mob [AREACOORD(M.loc)]")
	if(!istype(N, /mob/dead/observer))
		message_admins("[ADMIN_TPMONTY(usr)] jumped to [ADMIN_TPMONTY(M)].")


/datum/admins/proc/jump_key()
	set category = "Admin"
	set name = "Jump to Key"

	if(!check_rights(R_ADMIN))
		return

	var/list/keys = list()
	for(var/mob/M in player_list)
		keys += M.client

	var/selection = input("Please, select a player!", "Admin Jumping", null, null) as null|anything in sortKey(keys)
	if(!selection)
		return

	var/mob/M = selection:mob
	var/mob/N = owner.mob

	N.on_mob_jump()
	N.loc = M.loc

	log_admin("[key_name(usr)] jumped to [key_name(M)]'s key [AREACOORD(M.loc)].")
	if(!istype(N, /mob/dead/observer))
		message_admins("[ADMIN_TPMONTY(usr)] jumped to [ADMIN_TPMONTY(M)]")


/datum/admins/proc/get_mob(var/mob/M in mob_list)
	set category = "Admin"
	set name = "Get Mob"

	if(!check_rights(R_ADMIN))
		return

	M.on_mob_jump()
	M.loc = get_turf(usr)

	log_admin("[key_name(usr)] teleported [key_name(M)]'s mob to themselves [AREACOORD(M.loc)].")
	message_admins("[ADMIN_TPMONTY(usr)] teleported [ADMIN_TPMONTY(M)]'s mob to themselves.")


/datum/admins/proc/get_key()
	set category = "Admin"
	set name = "Get Key"
	set desc = "Teleport mob based on the client's ckey."

	if(!check_rights(R_ADMIN))
		return

	var/list/keys = list()
	for(var/mob/M in player_list)
		keys += M.client

	var/selection = input("Please, select a player!", "Admin Jumping", null, null) as null|anything in sortKey(keys)
	if(!selection)
		return

	var/mob/M = selection:mob
	if(!M)
		return

	M.on_mob_jump()
	M.loc = get_turf(usr)

	log_admin("[key_name(usr)] teleported [key_name(M)]'s key to themselves [AREACOORD(M.loc)].")
	message_admins("[ADMIN_TPMONTY(usr)] teleported [ADMIN_TPMONTY(M)]'s key to themselves.")


/datum/admins/proc/send_mob(var/mob/M in sortmobs())
	set category = "Admin"
	set name = "Send Mob"

	if(!check_rights(R_ADMIN))
		return

	var/area/A = input(usr, "Pick an area.", "Pick an area") as null|anything in return_sorted_areas()
	if(!A || !M)
		return

	M.on_mob_jump()
	M.loc = pick(get_area_turfs(A))

	log_admin("[key_name(usr)] teleported [key_name(M)] to [AREACOORD(M.loc)].")
	message_admins("[ADMIN_TPMONTY(usr)] teleported [ADMIN_TPMONTY(M)] to [ADMIN_VERBOSEJMP(M.loc)].")


#define IRCREPLYCOUNT 2
/client/proc/cmd_admin_pm_context(mob/M in GLOB.mob_list)
	set category = null
	set name = "Admin PM Mob"

	if(!check_rights(R_ADMIN) && !is_mentor(src))
		return

	if(!ismob(M) || !M.client )
		return
	cmd_admin_pm(M.client, null)

//shows a list of clients we could send PMs to, then forwards our choice to cmd_admin_pm
/client/proc/cmd_admin_pm_panel()
	set category = "Admin"
	set name = "Admin PM"
	if(!holder)
		to_chat(src, "<font color='red'>Error: Admin-PM-Panel: Only administrators may use this command.</font>")
		return
	var/list/client/targets[0]
	for(var/client/T)
		if(T.mob)
			if(isnewplayer(T.mob))
				targets["(New Player) - [T]"] = T
			else if(isobserver(T.mob))
				targets["[T.mob.name](Ghost) - [T]"] = T
			else
				targets["[T.mob.real_name](as [T.mob.name]) - [T]"] = T
		else
			targets["(No Mob) - [T]"] = T
	var/target = input(src,"To whom shall we send a message?","Admin PM",null) as null|anything in sortList(targets)
	cmd_admin_pm(targets[target],null)


/client/proc/cmd_ahelp_reply(whom)
	if(prefs.muted & MUTE_ADMINHELP)
		to_chat(src, "<font color='red'>Error: Admin-PM: You are unable to use admin PM-s (muted).</font>")
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
			to_chat(src, "<font color='red'>Error: Admin-PM: Client not found.</font>")
		return

	var/datum/admin_help/AH = C.current_ticket

	if(AH)
		message_admins("[key_name_admin(src)] has started replying to [key_name_admin(C, 0, 0)]'s admin help.")
	var/msg = input(src,"Message:", "Private message to [key_name(C, 0, 0)]") as message|null
	if (!msg)
		message_admins("[key_name_admin(src)] has cancelled their reply to [key_name_admin(C, 0, 0)]'s admin help.")
		return
	cmd_admin_pm(whom, msg)

//takes input from cmd_admin_pm_context, cmd_admin_pm_panel or /client/Topic and sends them a PM.
//Fetching a message if needed. src is the sender and C is the target client
/client/proc/cmd_admin_pm(whom, msg)
	if(prefs.muted & MUTE_ADMINHELP)
		to_chat(src, "<font color='red'>Error: Admin-PM: You are unable to use admin PM-s (muted).</font>")
		return

	if(!holder && !current_ticket)	//no ticket? https://www.youtube.com/watch?v=iHSPf6x1Fdo
		to_chat(src, "<font color='red'>You can no longer reply to this ticket, please open another one by using the Adminhelp verb if need be.</font>")
		to_chat(src, "<font color='blue'>Message: [msg]</font>")
		return

	var/client/recipient
	var/irc = 0
	if(istext(whom))
		if(cmptext(copytext(whom,1,2),"@"))
			whom = find_stealth_key(whom)
		if(whom == "IRCKEY")
			irc = 1
		else
			recipient = GLOB.directory[whom]
	else if(istype(whom, /client))
		recipient = whom

		if(!recipient)
			if(holder)
				to_chat(src, "<font color='red'>Error: Admin-PM: Client not found.</font>")
				if(msg)
					to_chat(src, msg)
				return
			else if(msg) // you want to continue if there's no message instead of returning now
				current_ticket.MessageNoRecipient(msg)
				return

	//get message text, limit it's length.and clean/escape html
	if(!msg)
		msg = input(src,"Message:", "Private message to [key_name(recipient, 0, 0)]") as message|null
		msg = trim(msg)
		if(!msg)
			return

		if(prefs.muted & MUTE_ADMINHELP)
			to_chat(src, "<font color='red'>Error: Admin-PM: You are unable to use admin PM-s (muted).</font>")
			return

		if(!recipient)
			if(holder)
				to_chat(src, "<font color='red'>Error: Admin-PM: Client not found.</font>")
			else
				current_ticket.MessageNoRecipient(msg)
			return

	if(handle_spam_prevention(msg,MUTE_ADMINHELP))
		return

	//clean the message if it's not sent by a high-rank admin
	if(!check_rights(R_SERVER|R_DEBUG,0)||irc)//no sending html to the poor bots
		msg = trim(sanitize(copytext(msg,1,MAX_MESSAGE_LEN)))
		if(!msg)
			return

	var/rawmsg = msg

	var/keywordparsedmsg = keywords_lookup(msg)

	if(irc)
		to_chat(src, "<font color='blue'>PM to-<b>Admins</b>: <span class='linkify'>[rawmsg]</span></font>")
		var/datum/admin_help/AH = admin_ticket_log(src, "<font color='red'>Reply PM from-<b>[key_name(src, TRUE, TRUE)] to <i>IRC</i>: [keywordparsedmsg]</font>")
		send2irc("[AH ? "#[AH.id] " : ""]Reply: [ckey]", rawmsg)
	else
		if(recipient.holder)
			if(holder)	//both are admins
				to_chat(recipient, "<font color='red'>Admin PM from-<b>[key_name(src, recipient, 1)]</b>: <span class='linkify'>[keywordparsedmsg]</span></font>")
				to_chat(src, "<font color='blue'>Admin PM to-<b>[key_name(recipient, src, 1)]</b>: <span class='linkify'>[keywordparsedmsg]</span></font>")

				//omg this is dumb, just fill in both their tickets
				var/interaction_message = "<font color='purple'>PM from-<b>[key_name(src, recipient, 1)]</b> to-<b>[key_name(recipient, src, 1)]</b>: [keywordparsedmsg]</font>"
				admin_ticket_log(src, interaction_message)
				if(recipient != src)	//reeee
					admin_ticket_log(recipient, interaction_message)

			else		//recipient is an admin but sender is not
				var/replymsg = "<font color='red'>Reply PM from-<b>[key_name(src, recipient, 1)]</b>: <span class='linkify'>[keywordparsedmsg]</span></font>"
				admin_ticket_log(src, replymsg)
				to_chat(recipient, replymsg)
				to_chat(src, "<font color='blue'>PM to-<b>Admins</b>: <span class='linkify'>[msg]</span></font>")

			//play the receiving admin the adminhelp sound (if they have them enabled)
			if(recipient.prefs.toggles_sound & SOUND_ADMINHELP)
				SEND_SOUND(recipient, sound('sound/effects/adminhelp.ogg'))

		else
			if(holder)	//sender is an admin but recipient is not. Do BIG RED TEXT
				if(!recipient.current_ticket)
					new /datum/admin_help(msg, recipient, TRUE)

				to_chat(recipient, "<font color='red' size='4'><b>-- Administrator private message --</b></font>")
				to_chat(recipient, "<font color='red'>Admin PM from-<b>[key_name(src, recipient, 0)]</b>: <span class='linkify'>[msg]</span></font>")
				to_chat(recipient, "<font color='red'><i>Click on the administrator's name to reply.</i></font>")
				to_chat(src, "<font color='blue'>Admin PM to-<b>[key_name(recipient, src, 1)]</b>: <span class='linkify'>[msg]</span></font>")

				admin_ticket_log(recipient, "<font color='blue'>PM From [key_name_admin(src)]: [keywordparsedmsg]</font>")

				//always play non-admin recipients the adminhelp sound
				SEND_SOUND(recipient, sound('sound/effects/adminhelp.ogg'))

				//AdminPM popup for ApocStation and anybody else who wants to use it. Set it with POPUP_ADMIN_PM in config.txt ~Carn
				if(CONFIG_GET(flag/popup_admin_pm))
					spawn()	//so we don't hold the caller proc up
						var/sender = src
						var/sendername = key
						var/reply = input(recipient, msg,"Admin PM from-[sendername]", "") as message|null		//show message and await a reply
						if(recipient && reply)
							if(sender)
								recipient.cmd_admin_pm(sender,reply)										//sender is still about, let's reply to them
							else
								adminhelp(reply)													//sender has left, adminhelp instead
						return

			else		//neither are admins
				to_chat(src, "<font color='red'>Error: Admin-PM: Non-admin to non-admin PM communication is forbidden.</font>")
				return

	if(irc)
		log_admin_private("PM: [key_name(src)]->IRC: [rawmsg]")
		for(var/client/X in GLOB.admins)
			to_chat(X, "<font color='blue'><B>PM: [key_name(src, X, 0)]-&gt;IRC:</B> [keywordparsedmsg]</font>")
	else
		log_admin_private("PM: [key_name(src)]->[key_name(recipient)]: [rawmsg]")
		//we don't use message_admins here because the sender/receiver might get it too
		for(var/client/X in GLOB.admins)
			if(X.key!=key && X.key!=recipient.key)	//check client/X is an admin and isn't the sender or recipient
				to_chat(X, "<font color='blue'><B>PM: [key_name(src, X, 0)]-&gt;[key_name(recipient, X, 0)]:</B> [keywordparsedmsg]</font>" )



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