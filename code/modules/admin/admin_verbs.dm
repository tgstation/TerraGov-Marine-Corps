/datum/admins/proc/admin_ghost()
	set category = "Admin"
	set name = "Aghost"
	set desc = "Allows you to ghost and re-enter body at will."

	if(!check_rights(R_ADMIN) || !is_mentor())
		return

	if(!owner?.mob)
		return

	var/mob/M = owner.mob

	if(istype(M, /mob/new_player))
		return

	if(istype(M, /mob/dead/observer))
		var/mob/dead/observer/ghost = M
		ghost.can_reenter_corpse = TRUE
		ghost.reenter_corpse()
	else
		M.ghostize(TRUE)
		if(M && !M.key)
			M.key = "@[usr.key]"
			if(M.client)
				M.client.change_view(world.view)

		message_admins("[key_name(usr)] admin ghosted.")
		log_admin("[key_name(usr)] admin ghosted.")


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
	message_admins("[key_name_admin(usr)] has [(M.invisibility == INVISIBILITY_OBSERVER) ? "enabled" : "disabled"] invisimin.")


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
	message_admins("[key_name_admin(usr)] has turned stealth mode [fakekey ? "on" : "off"]")


/datum/admins/proc/deadmin_self()
	set name = "De-Admin Self"
	set category = "Admin"
	set desc = "Temporarily removes your admin powers."

	if(alert("Do you really want to de-admin temporarily?", , "Yes", "No") == "No")
		return

	verbs += /datum/admins/proc/readmin_self
	deadmin_self()

	log_admin("[key_name(usr)] deadmined themselves.")
	message_admins("[key_name_admin(usr)] deadmined themselves.")


/datum/admins/proc/readmin_self()
	set name = "Re-admin Self"
	set category = "Admin"
	set desc = "Gives you your powers back."

	verbs -= /datum/admins/proc/readmin_self
	readmin_self()

	log_admin("[key_name(usr)] readmined themselves.")
	message_admins("[key_name_admin(usr)] readmined themselves.")


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
	message_admins("[key_name_admin(usr)] has made a [role] slot free.")


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
	message_admins("[key_name_admin(usr)] checked job slots.")


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
	message_admins("[key_name_admin(usr)] changed [M.name] ckey to [new_ckey].")


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
	message_admins("[key_name_admin(usr)] revived [key_name_admin(M)].")


/datum/admins/proc/toggle_sleep(var/mob/living/M as mob in mob_list)
	set category = "Admin"
	set name = "Toggle Sleeping"

	if(!check_rights(R_ADMIN))
		return

	if(M.sleeping > 0)
		M.sleeping = 0
	else
		M.sleeping = 9999999

	log_admin("[key_name(usr)] toggled sleeping on [key_name(M)].")
	message_admins("[key_name_admin(usr)] toggled sleeping on [key_name_admin(M)].")


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
			message_admins("[key_name_admin(usr)] has unslept everyone in view.")


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
	message_admins("[key_name_admin(usr)] has changed the squad of [key_name_admin(H)] to [S.name].")


/datum/admins/proc/direct_control(var/mob/M in mob_list)
	set category = "Admin"
	set name = "Take Over"
	set desc = "Rohesie's verb."

	if(!check_rights(R_ADMIN))
		return

	if(M.gc_destroyed)
		return

	if(M.ckey)
		if(alert("This mob is being controlled by [M.ckey], they will be made a ghost. Are you sure?",,"Yes","No") == "Yes")
			M.ghostize()
		else
			return

	var/mob/adminmob = owner.mob
	M.ckey = owner.ckey

	if(M.client)
		M.client.change_view(world.view)

	if(isobserver(adminmob))
		qdel(adminmob)

	log_admin("[key_name(usr)] took over [key_name(M)].")
	message_admins("[key_name_admin(usr)] took over [key_name_admin(M)].")


/datum/admins/proc/getserverlogs()
	set category = "Admin"
	set name = "Get Server Logs"

	if(!check_rights(R_ADMIN))
		return

	browseserverlogs()


/datum/admins/proc/getcurrentlogs()
	set category = "Admin"
	set name = "Get Current Logs"
	set desc = "View/retrieve logfiles for the current round."

	if(!check_rights(R_ADMIN))
		return

	browseserverlogs("[GLOB.log_directory]/")


/datum/admins/proc/getfolderlogs()
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

	path = browse_files(path)
	if(!path)
		return

	if(file_spam_check())
		return

	message_admins("[key_name_admin(src)] accessed file: [path]")
	switch(alert("View (in game), Open (in your system's text editor), or Download?", path, "View", "Open", "Download"))
		if ("View")
			src << browse("<pre style='word-wrap: break-word;'>[html_encode(file2text(file(path)))]</pre>", list2params(list("window" = "viewfile.[path]")))
		if ("Open")
			src << run(file(path))
		if ("Download")
			src << ftp(file(path))
		else
			return
	to_chat(src, "Attempting to send [path], this may take a fair few minutes if the file is very large.")


/datum/admins/proc/recursive_download(var/folder)
	var/files = flist(folder)
	for(var/next in files)
		if(copytext(next, -1, 0) == "/")
			to_chat(src, "Going deeper [folder][next]")
			recursive_download(folder + next)
		else
			to_chat(src, "Downloading [folder][next]")
			var/fil = replacetext("[folder][next]", "/", "_")
			sleep(5)
			src << ftp(file(folder + next), fil)


/datum/admins/browse_folders(root = "data/logs/", max_iterations = 100)
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


/proc/show_individual_logging_panel(mob/M, source = LOGSRC_CLIENT, type = INDIVIDUAL_ATTACK_LOG)
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


/proc/individual_logging_panel_link(mob/M, log_type, log_src, label, selected_src, selected_type)
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
		for(var/client/C in admins)
			if(check_rights(R_ASAY))
				to_chat(C, msg)


/datum/admins/proc/msay(msg as text)
	set category = "Admin"
	set name = "msay"
	set hidden = TRUE

	if(!check_rights(R_ADMIN) && !is_mentor())
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

	for(var/client/C in admins)
		if(check_rights(R_ADMIN))
			to_chat(C, "<span class='[color]'><span class='prefix'>[rank]</span> [key_name_admin(src)] [ADMIN_TPMONTY(src)]: <span class='message'>[msg]</span></span>")
		else if(is_mentor() && owner.mob.stat == DEAD)
			to_chat(C, "<span class='[color]'><span class='prefix'>[rank]</span> [key_name_admin(src, TRUE, TRUE, FALSE)] [ADMIN_JMP(src)] [ADMIN_FLW(src)]: <span class='message'>[msg]</span></span>")
		else
			to_chat(C, "<span class='[color]'><span class='prefix'>[rank]</span> [key_name_admin(src, TRUE, FALSE, FALSE)] [ADMIN_JMP(src)] [ADMIN_FLW(src)]: <span class='message'>[msg]</span></span>")


/datum/admins/proc/dsay(msg as text)
	set category = "Admin"
	set name = "dsay"
	set hidden = TRUE

	if(!check_rights(R_ADMIN) && !is_mentor())
		return

	if(!(holder.rights & (R_ADMIN)) && mob.stat != DEAD)
		to_chat(usr, "You must be an observer to use dsay.")
		return

	if(owner.prefs.muted & MUTE_DEADCHAT)
		to_chat(usr, "<span class='warning'>You cannot send DSAY messages (muted).</span>")
		return

	if(!(owner.prefs.toggles_chat & CHAT_DEAD))
		to_chat(usr, "<span class='warning'>You have deadchat muted.</span>")
		return

	if(handle_spam_prevention(msg, MUTE_DEADCHAT))
		return

	msg = copytext(sanitize(msg), 1, MAX_MESSAGE_LEN)

	if(!msg)
		return

	log_dsay("[key_name(usr)]: [msg]")

	var/rendered = "<span class='game deadsay'><span class='prefix'>DEAD:</span> <span class='name'>[rank]([src.holder.fakekey ? pick("BADMIN", "hornigranny", "TLF", "scaredforshadows", "KSI", "Silnazi", "HerpEs", "BJ69", "SpoofedEdd", "Uhangay", "Wario90900", "Regarity", "MissPhareon", "LastFish", "unMportant", "Deurpyn", "Fatbeaver") : src.key])</span> says, <span class='message'>\"[msg]\"</span></span>"

	for(var/client/C in clients)
		if(istype(C.mob, /mob/new_player))
			continue

		if(check_other_rights(C, R_ADMIN) && (C.prefs.toggles_chat & CHAT_DEAD))
			to_chat(M, rendered)

		else if(C.mob.stat == DEAD && (C.prefs.toggles_chat & CHAT_DEAD))
			to_chat(M, rendered)


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
	if(!istype(usr, /mob/dead/observer))
		message_admins("[ADMIN_TPMONTY(usr)] jumped to [ADMIN_VERBOSEJMP(A)].")


/datum/admins/proc/jump_turf(var/turf/T in turfs)
	set category = "Admin"
	set name = "Jump to Turf"

	if(!check_rights(R_ADMIN))
		return

	var/mob/M = owner.mob
	M.on_mob_jump()
	M.forceMove(T)

	log_admin("[key_name(usr)] jumped to [AREACOORD(M.loc)].")
	if(!istype(M, /mob/dead/observer))
		message_admins("[ADMIN_TPMONTY(usr)] jumped to [ADMIN_VERBOSEJMP(M.loc)].")


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

	log_admin("[key_name(usr)] jumped to [AREACOORD(M.loc)].")
	if(!istype(usr, /mob/dead/observer))
		message_admins("[ADMIN_TPMONTY(usr)] jumped to [ADMIN_VERBOSEJMP(M.loc)].")


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
		message_admins("[key_name_admin(usr)] jumped to [ADMIN_TPMONTY(M)].")


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


//allows right clicking mobs to send an admin PM to their client, forwards the selected mob's client to cmd_admin_pm
/client/proc/cmd_admin_pm_context(mob/M as mob in mob_list)
	set category = null
	set name = "Admin PM Mob"
	if(!holder)
		to_chat(src, "<font color='red'>Error: Admin-PM-Context: Only administrators may use this command.</font>")
		return
	if( !ismob(M) || !M.client )	return
	cmd_admin_pm(M.client,null)
	feedback_add_details("admin_verb","APMM") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

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
			if(istype(T.mob, /mob/new_player))
				targets["(New Player) - [T]"] = T
			else if(istype(T.mob, /mob/dead/observer))
				targets["[T.mob.name](Ghost) - [T]"] = T
			else
				targets["[T.mob.real_name](as [T.mob.name]) - [T]"] = T
		else
			targets["(No Mob) - [T]"] = T
	var/list/sorted = sortList(targets)
	var/target = input(src,"To whom shall we send a message?","Admin PM",null) in sorted|null
	cmd_admin_pm(targets[target],null)
	feedback_add_details("admin_verb","APM") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


//takes input from cmd_admin_pm_context, cmd_admin_pm_panel or /client/Topic and sends them a PM.
//Fetching a message if needed. src is the sender and C is the target client

/client/proc/cmd_admin_pm(var/client/C, var/msg = null)
	if(prefs.muted & MUTE_ADMINHELP)
		to_chat(src, "<font color='red'>Error: Private-Message: You are unable to use PMs (muted).</font>")
		return

	if(!istype(C,/client))
		if(holder)	to_chat(src, "<font color='red'>Error: Private-Message: Client not found.</font>")
		else		to_chat(src, "<font color='red'>Error: Private-Message: Client not found. They may have lost connection, so try using an adminhelp!</font>")
		return

	//get message text, limit it's length.and clean/escape html
	if(!msg)
		msg = input(src,"Message:", "Private message to [key_name(C, 0, holder ? 1 : 0)]") as message|null

		if(!msg)	return
		if(!C)
			if(holder)	to_chat(src, "<font color='red'>Error: Admin-PM: Client not found.</font>")
			else		to_chat(src, "<font color='red'>Error: Private-Message: Client not found. They may have lost connection, so try using an adminhelp!</font>")
			return

	if (src.handle_spam_prevention(msg,MUTE_ADMINHELP))
		return

	//clean the message if it's not sent by a high-rank admin
	if(!check_rights(R_SERVER|R_DEBUG,0))
		msg = sanitize(copytext(msg,1,MAX_MESSAGE_LEN))
		if(!msg)	return

	var/recieve_color = "purple"
	var/send_pm_type = " "
	var/recieve_pm_type = "Player"


	if(holder)
		//PMs sent from admins and mods display their rank
		if(holder)
			recieve_color = "#009900"
			send_pm_type = holder.rank + " "
			if(!C.holder && holder && holder.fakekey)
				recieve_pm_type = "Admin"
			else
				recieve_pm_type = holder.rank

	else if(!C.holder)
		to_chat(src, "<font color='red'>Error: Admin-PM: Non-admin to non-admin PM communication is forbidden.</font>")
		return

	var/recieve_message = ""

	if(holder && !C.holder)
		recieve_message = "<font color='[recieve_color]'><b>-- Click the [recieve_pm_type]'s name to reply --</b></font>\n"
		if(C.adminhelped)
			to_chat(C, recieve_message)
			C.adminhelped = 0

		//AdminPM popup for ApocStation and anybody else who wants to use it. Set it with POPUP_ADMIN_PM in config.txt ~Carn
		if(CONFIG_GET(flag/popup_admin_pm))
			spawn(0)	//so we don't hold the caller proc up
				var/sender = src
				var/sendername = key
				var/reply = input(C, msg,"[recieve_pm_type] PM from-[sendername]", "") as text|null		//show message and await a reply
				if(C && reply)
					if(sender)
						C.cmd_admin_pm(sender,reply)										//sender is still about, let's reply to them
					else
						adminhelp(reply)													//sender has left, adminhelp instead
				return

	recieve_message = "<br><br><font color='[recieve_color]'><b>[recieve_pm_type] PM from [get_options_bar(src, C.holder ? 1 : 0, C.holder ? 1 : 0, 1)]: <font color='#DA6200'>[msg]</b></font><br>"
	to_chat(C, recieve_message)
	to_chat(src, "<br><br><font color='#009900'><b>[send_pm_type]PM to [get_options_bar(C, holder ? 1 : 0, holder ? 1 : 0, 1)]: <font color='#DA6200'>[msg]</b></font><br>")

	//play the recieving admin the adminhelp sound (if they have them enabled)
	//non-admins shouldn't be able to disable this
	if(C.prefs && C.prefs.toggles_sound & SOUND_ADMINHELP)
		C << 'sound/effects/adminhelp-reply.ogg'

	log_admin("PM: [key_name(src)]->[key_name(C)]: [msg]")

	//we don't use message_admins here because the sender/receiver might get it too
	for(var/client/X in admins)
		//check client/X is an admin and isn't the sender or recipient
		if(X == C || X == src)
			continue
		if(X.key!=key && X.key!=C.key && (X.holder.rights & R_ADMIN))
			to_chat(X, "<B><font color='blue'>PM: [key_name(src, X, 0)]-&gt;[key_name(C, X, 0)]:</B> <span class='notice'> [msg]</font></span>")
