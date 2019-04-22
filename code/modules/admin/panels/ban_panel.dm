/client/proc/mute(client/C, mute_type, force = FALSE)
	if(IsAdminAdvancedProcCall())
		return

	if(!force && (!check_if_greater_rights_than(C) || !check_rights(R_BAN, FALSE)))
		return

	if(!C?.prefs)
		return

	var/muteunmute
	var/mute_string

	switch(mute_type)
		if(MUTE_IC)
			mute_string = "IC"
		if(MUTE_OOC)
			mute_string = "OOC"
		if(MUTE_LOOC)
			mute_string = "LOOC"
		if(MUTE_PRAY)
			mute_string = "pray"
		if(MUTE_ADMINHELP)
			mute_string = "adminhelps and PMs"
		if(MUTE_DEADCHAT)
			mute_string = "deadchat"
		if(MUTE_ALL)
			mute_string = "everything"
		else
			return

	if(C.prefs.muted & mute_type)
		muteunmute = "unmuted"
		C.prefs.muted &= ~mute_type
	else
		muteunmute = "muted"
		C.prefs.muted |= mute_type

	to_chat(C, "<span class='boldannounce'>You have been [muteunmute] from [mute_string].</span>")

	if(!force)
		log_admin_private("[key_name(usr)] has [muteunmute] [key_name(C)] from [mute_string].")
		message_admins("[ADMIN_TPMONTY(usr)] has [muteunmute] [ADMIN_TPMONTY(C.mob)] from [mute_string].")

	usr.client.holder.show_player_panel(C.mob)


//checks client ban cache or DB ban table if ckey is banned from one or more roles
//doesn't return any details, use only for if statements
/proc/is_banned_from(player_ckey, roles)
	if(!player_ckey)
		return
	var/client/C = GLOB.directory[player_ckey]
	if(C)
		if(!C.ban_cache)
			build_ban_cache(C)
		if(islist(roles))
			for(var/R in roles)
				if(R in C.ban_cache)
					return TRUE //they're banned from at least one role, no need to keep checking
		else if(roles in C.ban_cache)
			return TRUE
	else
		player_ckey = sanitizeSQL(player_ckey)
		var/admin_where
		if(GLOB.admin_datums[player_ckey] || GLOB.deadmins[player_ckey])
			admin_where = " AND applies_to_admins = 1"
		var/sql_roles
		if(islist(roles))
			sql_roles = jointext(roles, "', '")
		else
			sql_roles = roles
		sql_roles = sanitizeSQL(sql_roles)
		var/datum/DBQuery/query_check_ban = SSdbcore.NewQuery("SELECT 1 FROM [format_table_name("ban")] WHERE ckey = '[player_ckey]' AND role IN ('[sql_roles]') AND unbanned_datetime IS NULL AND (expiration_time IS NULL OR expiration_time > NOW())[admin_where]")
		if(!query_check_ban.warn_execute())
			qdel(query_check_ban)
			return
		if(query_check_ban.NextRow())
			qdel(query_check_ban)
			return TRUE
		qdel(query_check_ban)


//checks DB ban table if a ckey, ip and/or cid is banned from a specific role
//returns an associative nested list of each matching row's ban id, bantime, ban round id, expiration time, ban duration, applies to admins, reason, key, ip, cid and banning admin's key in that order
/proc/is_banned_from_with_details(player_ckey, player_ip, player_cid, role)
	if(!player_ckey && !player_ip && !player_cid)
		return
	role = sanitizeSQL(role)
	var/list/where_list = list()
	if(player_ckey)
		player_ckey = sanitizeSQL(player_ckey)
		where_list += "ckey = '[player_ckey]'"
	if(player_ip)
		player_ip = sanitizeSQL(player_ip)
		where_list += "ip = INET_ATON('[player_ip]')"
	if(player_cid)
		player_cid = sanitizeSQL(player_cid)
		where_list += "computerid = '[player_cid]'"
	var/where = "([where_list.Join(" OR ")])"
	var/datum/DBQuery/query_check_ban = SSdbcore.NewQuery("SELECT id, bantime, round_id, expiration_time, TIMESTAMPDIFF(MINUTE, bantime, expiration_time), applies_to_admins, reason, IFNULL((SELECT byond_key FROM [format_table_name("player")] WHERE [format_table_name("player")].ckey = [format_table_name("ban")].ckey), ckey), INET_NTOA(ip), computerid, IFNULL((SELECT byond_key FROM [format_table_name("player")] WHERE [format_table_name("player")].ckey = [format_table_name("ban")].a_ckey), a_ckey) FROM [format_table_name("ban")] WHERE role = '[role]' AND [where] AND unbanned_datetime IS NULL AND (expiration_time IS NULL OR expiration_time > NOW()) ORDER BY bantime DESC")
	if(!query_check_ban.warn_execute())
		qdel(query_check_ban)
		return
	. = list()
	while(query_check_ban.NextRow())
		. += list(list("id" = query_check_ban.item[1], "bantime" = query_check_ban.item[2], "round_id" = query_check_ban.item[3], "expiration_time" = query_check_ban.item[4], "duration" = query_check_ban.item[5], "applies_to_admins" = query_check_ban.item[6], "reason" = query_check_ban.item[7], "key" = query_check_ban.item[8], "ip" = query_check_ban.item[9], "computerid" = query_check_ban.item[10], "admin_key" = query_check_ban.item[11]))
	qdel(query_check_ban)


/proc/build_ban_cache(client/C)
	if(!SSdbcore.Connect())
		return
	if(C && istype(C))
		C.ban_cache = list()
		var/player_key = sanitizeSQL(C.ckey)
		var/is_admin = FALSE
		if(GLOB.admin_datums[C.ckey] || GLOB.deadmins[C.ckey])
			is_admin = TRUE
		var/datum/DBQuery/query_build_ban_cache = SSdbcore.NewQuery("SELECT role, applies_to_admins FROM [format_table_name("ban")] WHERE ckey = '[player_key]' AND unbanned_datetime IS NULL AND (expiration_time IS NULL OR expiration_time > NOW())")
		if(!query_build_ban_cache.warn_execute())
			qdel(query_build_ban_cache)
			return
		while(query_build_ban_cache.NextRow())
			if(is_admin && !text2num(query_build_ban_cache.item[2]))
				continue
			C.ban_cache[query_build_ban_cache.item[1]] = TRUE
		qdel(query_build_ban_cache)


/datum/admins/proc/ban_panel()
	set name = "Ban Panel"
	set category = "Admin"

	if(!check_rights(R_BAN))
		return

	usr.client.holder.banpanel()


/datum/admins/proc/banpanel(player_key, player_ip, player_cid, role, duration = 1440, applies_to_admins, reason, edit_id, page, admin_key)
	if(!check_rights(R_BAN))
		return

	var/panel_height = 620
	if(edit_id)
		panel_height = 240
	var/datum/browser/panel = new(usr.client.mob, "banpanel", "Ban Panel", 910, panel_height)
	panel.add_stylesheet("banpanelcss", 'html/admin/banpanel.css')
	var/list/output = list("<form method='get' action='?src=[REF(usr.client.holder)];[HrefToken()]'>[HrefTokenFormField()]")
	output += {"<input type='hidden' name='src' value='[REF(usr.client.holder)];[HrefToken()]'>
	<label class='inputlabel checkbox'>Key:
	<input type='checkbox' id='keycheck' name='keycheck' value='1'[player_key ? " checked": ""]>
	<div class='inputbox'></div></label>
	<input type='text' name='keytext' size='26' value='[player_key]'>
	<label class='inputlabel checkbox'>IP:
	<input type='checkbox' id='ipcheck' name='ipcheck' value='1'[isnull(duration) ? " checked" : ""]>
	<div class='inputbox'></div></label>
	<input type='text' name='iptext' size='18' value='[player_ip]'>
	<label class='inputlabel checkbox'>CID:
	<input type='checkbox' id='cidcheck' name='cidcheck' value='1' checked>
	<div class='inputbox'></div></label>
	<input type='text' name='cidtext' size='14' value='[player_cid]'>
	<br>
	<label class='inputlabel checkbox'>Use IP and CID from last connection of key
	<input type='checkbox' id='lastconn' name='lastconn' value='1' [(isnull(duration) && !player_ip) || (!player_cid) ? " checked": ""]>
	<div class='inputbox'></div></label>
	<label class='inputlabel checkbox'>Applies to Admins
	<input type='checkbox' id='applyadmins' name='applyadmins' value='1'[applies_to_admins ? " checked": ""]>
	<div class='inputbox'></div></label>
	<input type='submit' value='Submit'>
	<br>
	<div class='row'>
		<div class='column left'>
			Duration type
			<br>
			<label class='inputlabel radio'>Permanent
			<input type='radio' id='permanent' name='radioduration' value='permanent'[isnull(duration) ? " checked" : ""]>
			<div class='inputbox'></div></label>
			<br>
			<label class='inputlabel radio'>Temporary
			<input type='radio' id='temporary' name='radioduration' value='temporary'[duration ? " checked" : ""]>
			<div class='inputbox'></div></label>
			<input type='text' name='duration' size='7' value='[duration]'>
			<div class="select">
				<select name='intervaltype'>
					<option value='SECOND'>Seconds</option>
					<option value='MINUTE' selected>Minutes</option>
					<option value='HOUR'>Hours</option>
					<option value='DAY'>Days</option>
					<option value='WEEK'>Weeks</option>
					<option value='MONTH'>Months</option>
					<option value='YEAR'>Years</option>
				</select>
			</div>
		</div>
		<div class='column middle'>
			Ban type
			<br>
			<label class='inputlabel radio'>Server
			<input type='radio' id='server' name='radioban' value='server'[role == "Server" ? " checked" : ""][edit_id ? " disabled" : ""]>
			<div class='inputbox'></div></label>
			<br>
			<label class='inputlabel radio'>Role
			<input type='radio' id='role' name='radioban' value='role'[role == "Server" ? "" : " checked"][edit_id ? " disabled" : ""]>
			<div class='inputbox'></div></label>
		</div>
		<div class='column right'>
			Severity
			<br>
			<label class='inputlabel radio'>None
			<input type='radio' id='none' name='radioseverity' value='none'[edit_id ? " disabled" : ""]>
			<div class='inputbox'></div></label>
			<label class='inputlabel radio'>Medium
			<input type='radio' id='medium' name='radioseverity' value='medium'[edit_id ? " disabled" : ""]>
			<div class='inputbox'></div></label>
			<br>
			<label class='inputlabel radio'>Minor
			<input type='radio' id='minor' name='radioseverity' value='minor'[edit_id ? " disabled" : ""]>
			<div class='inputbox'></div></label>
			<label class='inputlabel radio'>High
			<input type='radio' id='high' name='radioseverity' value='high'[edit_id ? " disabled" : ""]>
			<div class='inputbox'></div></label>
		</div>
		<div class='column'>
			Reason
			<br>
			<textarea class='reason' name='reason'>[reason]</textarea>
		</div>
	</div>
	"}
	if(edit_id)
		output += {"<label class='inputlabel checkbox'>Mirror edits to matching bans
		<input type='checkbox' id='mirroredit' name='mirroredit' value='1'>
		<div class='inputbox'></div></label>
		<input type='hidden' name='editid' value='[edit_id]'>
		<input type='hidden' name='oldkey' value='[player_key]'>
		<input type='hidden' name='oldip' value='[player_ip]'>
		<input type='hidden' name='oldcid' value='[player_cid]'>
		<input type='hidden' name='oldapplies' value='[applies_to_admins]'>
		<input type='hidden' name='oldduration' value='[duration]'>
		<input type='hidden' name='oldreason' value='[reason]'>
		<input type='hidden' name='page' value='[page]'>
		<input type='hidden' name='adminkey' value='[admin_key]'>
		<br>
		When ticked, edits here will also affect bans created with matching ckey, IP, CID and time. Use this to edit all role bans which were made at the same time.
		"}
	else
		output += "<input type='hidden' name='roleban_delimiter' value='1'>"
		//there's not always a client to use the bancache of so to avoid many individual queries from using is_banned_form we'll build a cache to use here
		var/banned_from = list()
		if(player_key)
			var/player_ckey = sanitizeSQL(ckey(player_key))
			var/datum/DBQuery/query_get_banned_roles = SSdbcore.NewQuery("SELECT role FROM [format_table_name("ban")] WHERE ckey = '[player_ckey]' AND role <> 'server' AND unbanned_datetime IS NULL AND (expiration_time IS NULL OR expiration_time > NOW())")
			if(!query_get_banned_roles.warn_execute())
				qdel(query_get_banned_roles)
				return
			while(query_get_banned_roles.NextRow())
				banned_from += query_get_banned_roles.item[1]
			qdel(query_get_banned_roles)
		var/break_counter = 0
		output += "<div class='row'><div class='column'><label class='rolegroup command'><input type='checkbox' name='Command' class='hidden'>Command</label><div class='content'>"
		//all heads are listed twice so have a javascript call to toggle both their checkboxes when one is pressed
		//for simplicity this also includes the captain even though it doesn't do anything
		for(var/job in JOBS_OFFICERS)
			if(break_counter > 0 && (break_counter % 3 == 0))
				output += "<br>"
			output += {"<label class='inputlabel checkbox'>[job]
						<input type='checkbox' id='[job]_com' name='[job]' class='Command' value='1'>
						<div class='inputbox[(job in banned_from) ? " banned" : ""]'></div></label>
			"}
			break_counter++
		output += "</div></div>"
		//standard departments all have identical handling
		var/list/job_lists = list("Police" = JOBS_POLICE,
							"Engineering" = JOBS_ENGINEERING,
							"Medical" = JOBS_MEDICAL,
							"Requisitions" = JOBS_REQUISITIONS,
							"Marines" = JOBS_MARINES)
		for(var/department in job_lists)
			//the first element is the department head so they need the same javascript call as above
			output += "<div class='column'><label class='rolegroup [ckey(department)]'><input type='checkbox' name='[department]' class='hidden'>[department]</label><div class='content'>"
			output += {"<label class='inputlabel checkbox'>[job_lists[department][1]]
						<input type='checkbox' id='[job_lists[department][1]]_dep' name='[job_lists[department][1]]' class='[department]' value='1'>
						<div class='inputbox[(job_lists[department][1] in banned_from) ? " banned" : ""]'></div></label>
			"}
			break_counter = 1
			for(var/job in job_lists[department] - job_lists[department][1]) //skip the first element since it's already been done
				if(break_counter % 3 == 0)
					output += "<br>"
				output += {"<label class='inputlabel checkbox'>[job]
							<input type='checkbox' name='[job]' class='[department]' value='1'>
							<div class='inputbox[(job in banned_from) ? " banned" : ""]'></div></label>
				"}
				break_counter++
			output += "</div></div>"
		//departments/groups that don't have command staff would throw a javascript error since there's no corresponding reference for toggle_head()
		var/list/headless_job_lists = list("Abstract" = list("Appearance", "Emote", "OOC", "LOOC"))
		for(var/department in headless_job_lists)
			output += "<div class='column'><label class='rolegroup [ckey(department)]'><input type='checkbox' name='[department]' class='hidden'>[department]</label><div class='content'>"
			break_counter = 0
			for(var/job in headless_job_lists[department])
				if(break_counter > 0 && (break_counter % 3 == 0))
					output += "<br>"
				output += {"<label class='inputlabel checkbox'>[job]
							<input type='checkbox' name='[job]' class='[department]' value='1'>
							<div class='inputbox[(job in banned_from) ? " banned" : ""]'></div></label>
				"}
				break_counter++
			output += "</div></div>"
		var/list/long_job_lists = list("Role Positions" = list(ROLE_XENOMORPH, ROLE_XENO_QUEEN, ROLE_SURVIVOR, ROLE_ERT))
		for(var/department in long_job_lists)
			output += "<div class='column'><label class='rolegroup long [ckey(department)]'><input type='checkbox' name='[department]' class='hidden'>[department]</label><div class='content'>"
			break_counter = 0
			for(var/job in long_job_lists[department])
				if(break_counter > 0 && (break_counter % 10 == 0))
					output += "<br>"
				output += {"<label class='inputlabel checkbox'>[job]
							<input type='checkbox' name='[job]' class='[department]' value='1'>
							<div class='inputbox[(job in banned_from) ? " banned" : ""]'></div></label>
				"}
				break_counter++
			output += "</div></div>"
		output += "</div>"
	output += "</form>"
	panel.set_content(jointext(output, ""))
	panel.open()


/datum/admins/proc/ban_parse_href(list/href_list)
	if(!check_rights(R_BAN))
		return

	if(!SSdbcore.Connect())
		to_chat(usr, "<span class='danger'>Failed to establish database connection.</span>")
		return

	var/list/error_state = list()
	var/player_key
	var/ip_check = FALSE
	var/player_ip
	var/cid_check = FALSE
	var/player_cid
	var/use_last_connection = FALSE
	var/applies_to_admins = FALSE
	var/duration
	var/interval
	var/severity
	var/reason
	var/mirror_edit
	var/edit_id
	var/old_key
	var/old_ip
	var/old_cid
	var/old_applies
	var/page
	var/admin_key
	var/list/changes = list()
	var/list/roles_to_ban = list()
	if(href_list["keycheck"])
		player_key = href_list["keytext"]
		if(!player_key)
			error_state += "Key was ticked but none was provided."
	if(href_list["ipcheck"])
		ip_check = TRUE
	if(href_list["cidcheck"])
		cid_check = TRUE
	if(href_list["lastconn"])
		if(player_key)
			use_last_connection = TRUE
	else
		if(ip_check)
			player_ip = href_list["iptext"]
			if(!player_ip && !use_last_connection)
				error_state += "IP was ticked but none was provided."
		if(cid_check)
			player_cid = href_list["cidtext"]
			if(!player_cid && !use_last_connection)
				error_state += "CID was ticked but none was provided."
	if(!use_last_connection && !player_ip && !player_cid && !player_key)
		error_state += "At least a key, IP or CID must be provided."
	if(use_last_connection && !ip_check && !cid_check)
		error_state += "Use last connection was ticked, but neither IP nor CID was."
	if(href_list["applyadmins"])
		applies_to_admins = TRUE
	switch(href_list["radioduration"])
		if("permanent")
			duration = null
		if("temporary")
			duration = href_list["duration"]
			interval = href_list["intervaltype"]
			if(!duration)
				error_state += "Temporary ban was selected but no duration was provided."
		else
			error_state += "No duration was selected."
	reason = href_list["reason"]
	if(!reason)
		error_state += "No reason was provided."
	if(href_list["editid"])
		edit_id = href_list["editid"]
		if(href_list["mirroredit"])
			mirror_edit = TRUE
		old_key = href_list["oldkey"]
		old_ip = href_list["oldip"]
		old_cid = href_list["oldcid"]
		page = href_list["page"]
		admin_key = href_list["adminkey"]
		if(player_key != old_key)
			changes += list("Key" = "[old_key] to [player_key]")
		if(player_ip != old_ip)
			changes += list("IP" = "[old_ip] to [player_ip]")
		if(player_cid != old_cid)
			changes += list("CID" = "[old_cid] to [player_cid]")
		old_applies = text2num(href_list["oldapplies"])
		if(applies_to_admins != old_applies)
			changes += list("Applies to admins" = "[old_applies] to [applies_to_admins]")
		if(duration != href_list["oldduration"])
			changes += list("Duration" = "[href_list["oldduration"]] MINUTE to [duration] [interval]")
		if(reason != href_list["oldreason"])
			changes += list("Reason" = "[href_list["oldreason"]]<br>to<br>[reason]")
		if(!length(changes))
			error_state += "No changes were detected."
	else
		severity = href_list["radioseverity"]
		if(!severity)
			error_state += "No severity was selected."
		switch(href_list["radioban"])
			if("server")
				roles_to_ban += "Server"
			if("role")
				href_list.Remove("Command", "Police", "Engineering", "Medical", "Marines", "Requisitions", "Silicon", "Abstract", "Antagonist Positions") //remove the role banner hidden input values
				if(href_list[length(href_list)] == "roleban_delimiter")
					error_state += "Role ban was selected but no roles to ban were selected."
				else
					var/delimiter_pos = href_list.Find("roleban_delimiter")
					href_list.Cut(1, delimiter_pos + 1)//remove every list element before and including roleban_delimiter so we have a list of only the roles to ban
					for(var/key in href_list) //flatten into a list of only unique keys
						roles_to_ban |= key
			else
				error_state += "No ban type was selected."
	if(length(error_state))
		to_chat(usr, "<span class='danger'>Ban not [edit_id ? "edited" : "created"] because the following errors were present:\n[error_state.Join("\n")]</span>")
		return
	if(edit_id)
		edit_ban(edit_id, player_key, ip_check, player_ip, cid_check, player_cid, use_last_connection, applies_to_admins, duration, interval, reason, mirror_edit, old_key, old_ip, old_cid, old_applies, page, admin_key, changes)
	else
		create_ban(player_key, ip_check, player_ip, cid_check, player_cid, use_last_connection, applies_to_admins, duration, interval, severity, reason, roles_to_ban)


/datum/admins/proc/create_ban(player_key, ip_check, player_ip, cid_check, player_cid, use_last_connection, applies_to_admins, duration, interval, severity, reason, list/roles_to_ban)
	if(!check_rights(R_BAN))
		return
	if(!SSdbcore.Connect())
		to_chat(usr, "<span class='danger'>Failed to establish database connection.</span>")
		return
	var/player_ckey = sanitizeSQL(ckey(player_key))
	player_ip = sanitizeSQL(player_ip)
	player_cid = sanitizeSQL(player_cid)
	if(player_ckey)
		var/datum/DBQuery/query_create_ban_get_player = SSdbcore.NewQuery("SELECT byond_key, INET_NTOA(ip), computerid FROM [format_table_name("player")] WHERE ckey = '[player_ckey]'")
		if(!query_create_ban_get_player.warn_execute())
			qdel(query_create_ban_get_player)
			return
		if(query_create_ban_get_player.NextRow())
			player_key = query_create_ban_get_player.item[1]
			if(use_last_connection)
				if(ip_check)
					player_ip = query_create_ban_get_player.item[2]
				if(cid_check)
					player_cid = query_create_ban_get_player.item[3]
		else
			if(use_last_connection)
				if(alert(usr, "[player_key]/([player_ckey]) has not been seen before, unable to use IP and CID from last connection. Are you sure you want to create a ban for them?", "Unknown key", "Yes", "No", "Cancel") != "Yes")
					qdel(query_create_ban_get_player)
					return
			else
				if(alert(usr, "[player_key]/([player_ckey]) has not been seen before, are you sure you want to create a ban for them?", "Unknown key", "Yes", "No", "Cancel") != "Yes")
					qdel(query_create_ban_get_player)
					return
		qdel(query_create_ban_get_player)
	var/admin_ckey = sanitizeSQL(usr.client.ckey)
	if(applies_to_admins)
		var/datum/DBQuery/query_check_adminban_count = SSdbcore.NewQuery("SELECT COUNT(DISTINCT bantime) FROM [format_table_name("ban")] WHERE a_ckey = '[admin_ckey]' AND applies_to_admins = 1 AND unbanned_datetime IS NULL AND (expiration_time IS NULL OR expiration_time > NOW())")
		if(!query_check_adminban_count.warn_execute()) //count distinct bantime to treat rolebans made at the same time as one ban
			qdel(query_check_adminban_count)
			return
		if(query_check_adminban_count.NextRow())
			var/adminban_count = text2num(query_check_adminban_count.item[1])
			var/max_adminbans = 0
			if(check_rights(R_PERMISSIONS, FALSE))
				max_adminbans = MAX_ADMINBANS_PER_ADMIN
			if(R_DBRANKS && (R_DBRANKS & rank.can_edit_rights)) //edit rights are a more effective way to check hierarchical rank since many non-headmins have R_PERMISSIONS now
				max_adminbans = MAX_ADMINBANS_PER_HEADMIN
			if(adminban_count >= max_adminbans)
				to_chat(usr, "<span class='danger'>You've already logged [max_adminbans] admin ban(s) or more. Do not abuse this function!</span>")
				qdel(query_check_adminban_count)
				return
		qdel(query_check_adminban_count)
	var/admin_ip = sanitizeSQL(usr.client.address)
	var/admin_cid = sanitizeSQL(usr.client.computer_id)
	duration = text2num(duration)
	if(interval)
		interval = sanitizeSQL(interval)
	else
		interval = "MINUTE"
	var/time_message = "[duration] [lowertext(interval)]" //no DisplayTimeText because our duration is of variable interval type
	if(duration > 1) //pluralize the interval if necessary
		time_message += "s"
	var/note_reason = "Banned from [roles_to_ban[1] == "Server" ? "the server" : " Roles: [roles_to_ban.Join(", ")]"] [isnull(duration) ? "permanently" : "for [time_message]"] - [reason]"
	reason = sanitizeSQL(reason)
	var/list/clients_online = GLOB.clients.Copy()
	var/list/admins_online = list()
	for(var/client/C in clients_online)
		if(C.holder) //deadmins aren't included since they wouldn't show up on adminwho
			admins_online += C
	var/who = clients_online.Join(", ")
	var/adminwho = admins_online.Join(", ")
	var/kn = key_name(usr)
	var/kna = ADMIN_TPMONTY(usr)
	var/sql_ban
	for(var/role in roles_to_ban)
		sql_ban += list(list("bantime" = "NOW()",
		"server_ip" = "INET_ATON(IF('[world.internet_address]' LIKE '', '0', '[world.internet_address]'))",
		"server_port" = sanitizeSQL(world.port),
		"round_id" = sanitizeSQL(GLOB.round_id),
		"role" = "'[sanitizeSQL(role)]'",
		"expiration_time" = "IF('[duration]' LIKE '', NULL, NOW() + INTERVAL [duration ? "[duration]" : "0"] [interval])",
		"applies_to_admins" = sanitizeSQL(applies_to_admins),
		"reason" = "'[reason]'",
		"ckey" = "IF('[player_ckey]' LIKE '', NULL, '[player_ckey]')",
		"ip" = "INET_ATON(IF('[player_ip]' LIKE '', NULL, '[player_ip]'))",
		"computerid" = "IF('[player_cid]' LIKE '', NULL, '[player_cid]')",
		"a_ckey" = "'[admin_ckey]'",
		"a_ip" = "INET_ATON(IF('[admin_ip]' LIKE '', NULL, '[admin_ip]'))",
		"a_computerid" = "'[admin_cid]'",
		"who" = "'[who]'",
		"adminwho" = "'[adminwho]'"
		))
	if(!SSdbcore.MassInsert(format_table_name("ban"), sql_ban, warn = 1))
		return
	var/target = ban_target_string(player_key, player_ip, player_cid)
	var/msg = "has created a [isnull(duration) ? "permanent" : "temporary [time_message]"] [applies_to_admins ? "admin " : ""][roles_to_ban[1] == "Server" ? "server ban" : "role ban from [length(roles_to_ban)] roles"] for [target]."
	log_admin_private("[kn] [msg][roles_to_ban[1] == "Server" ? "" : " Roles: [roles_to_ban.Join(", ")]"] Reason: [reason]")
	message_admins("[kna] [msg][roles_to_ban[1] == "Server" ? "" : " Roles: [roles_to_ban.Join("\n")]"]\nReason: [reason]")
	if(applies_to_admins)
		send2irc("BAN ALERT","[kn] [msg]")
	if(player_ckey)
		create_message("note", player_ckey, admin_ckey, note_reason, null, null, 0, 0, null, 0, severity)
	var/client/C = GLOB.directory[player_ckey]
	var/datum/admin_help/AH = admin_ticket_log(player_ckey, "[kn] [msg][roles_to_ban[1] == "Server" ? "" : " Roles: [roles_to_ban.Join(", ")]"] Reason: [reason]")
	var/appeal_url = "No ban appeal url set!"
	appeal_url = CONFIG_GET(string/banappeals)
	var/is_admin = FALSE
	if(C)
		build_ban_cache(C)
		to_chat(C, "<span class='boldannounce'>You have been [applies_to_admins ? "admin " : ""]banned by [usr.client.key] from [roles_to_ban[1] == "Server" ? "the server" : " Roles: [roles_to_ban.Join(", ")]"].\nReason: [reason]</span><br><span class='danger'>This ban is [isnull(duration) ? "permanent." : "temporary, it will be removed in [time_message]."] The round ID is [GLOB.round_id].</span><br><span class='danger'>To appeal this ban go to [appeal_url]</span>")
		if(GLOB.admin_datums[C.ckey] || GLOB.deadmins[C.ckey])
			is_admin = TRUE
		if(roles_to_ban[1] == "Server" && (!is_admin || (is_admin && applies_to_admins)))
			qdel(C)
	if(roles_to_ban[1] == "Server" && AH)
		AH.Resolve()
	for(var/client/i in GLOB.clients - C)
		if(i.address == player_ip || i.computer_id == player_cid)
			build_ban_cache(i)
			to_chat(i, "<span class='boldannounce'>You have been [applies_to_admins ? "admin " : ""]banned by [usr.client.key] from [roles_to_ban[1] == "Server" ? "the server" : " Roles: [roles_to_ban.Join(", ")]"].\nReason: [reason]</span><br><span class='danger'>This ban is [isnull(duration) ? "permanent." : "temporary, it will be removed in [time_message]."] The round ID is [GLOB.round_id].</span><br><span class='danger'>To appeal this ban go to [appeal_url]</span>")
			if(GLOB.admin_datums[i.ckey] || GLOB.deadmins[i.ckey])
				is_admin = TRUE
			if(roles_to_ban[1] == "Server" && (!is_admin || (is_admin && applies_to_admins)))
				qdel(i)


/datum/admins/proc/unban_panel()
	set name = "Unban Panel"
	set category = "Admin"

	if(!check_rights(R_BAN))
		return

	usr.client.holder.unbanpanel()


/datum/admins/proc/unbanpanel(player_key, admin_key, player_ip, player_cid, page = 0)
	if(!check_rights(R_BAN))
		return

	if(!SSdbcore.Connect())
		to_chat(usr, "<span class='danger'>Failed to establish database connection.</span>")
		return

	var/datum/browser/panel = new(usr.client.mob, "unbanpanel", "Unban Panel", 850, 600)
	panel.add_stylesheet("unbanpanelcss", 'html/admin/unbanpanel.css')
	var/list/output = list("<div class='searchbar'>")
	output += {"<form method='get' action='?src=[REF(usr.client.holder)];[HrefToken()]'>[HrefTokenFormField()]
	<input type='hidden' name='src' value='[REF(usr.client.holder)];[HrefToken()]'>
	Key:<input type='text' name='searchunbankey' size='18' value='[player_key]'>
	Admin Key:<input type='text' name='searchunbanadminkey' size='18' value='[admin_key]'>
	IP:<input type='text' name='searchunbanip' size='12' value='[player_ip]'>
	CID:<input type='text' name='searchunbancid' size='10' value='[player_cid]'>
	<input type='submit' value='Search'>
	</form>
	</div>
	<div class='main'>
	"}
	if(player_key || admin_key || player_ip || player_cid)
		var/list/searchlist = list()
		if(player_key)
			searchlist += "ckey = '[sanitizeSQL(ckey(player_key))]'"
		if(admin_key)
			searchlist += "a_ckey = '[sanitizeSQL(ckey(admin_key))]'"
		if(player_ip)
			searchlist += "ip = INET_ATON('[sanitizeSQL(player_ip)]')"
		if(player_cid)
			searchlist += "computerid = '[sanitizeSQL(player_cid)]'"
		var/search = searchlist.Join(" AND ")
		var/bancount = 0
		var/bansperpage = 10
		page = text2num(page)
		var/datum/DBQuery/query_unban_count_bans = SSdbcore.NewQuery("SELECT COUNT(id) FROM [format_table_name("ban")] WHERE [search]")
		if(!query_unban_count_bans.warn_execute())
			qdel(query_unban_count_bans)
			return
		if(query_unban_count_bans.NextRow())
			bancount = text2num(query_unban_count_bans.item[1])
		qdel(query_unban_count_bans)
		if(bancount > bansperpage)
			output += "<b>Page: </b>"
			var/pagecount = 1
			var/list/pagelist = list()
			while(bancount > 0)
				pagelist += "<a href='?src=[REF(usr.client.holder)];[HrefToken()];unbanpagecount=[pagecount - 1];unbankey=[player_key];unbanadminkey=[admin_key];unbanip=[player_ip];unbancid=[player_cid]'>[pagecount == page ? "<b>\[[pagecount]\]</b>" : "\[[pagecount]\]"]</a>"
				bancount -= bansperpage
				pagecount++
			output += pagelist.Join(" | ")
		var/limit = " LIMIT [bansperpage * page], [bansperpage]"
		var/datum/DBQuery/query_unban_search_bans = SSdbcore.NewQuery({"SELECT id, bantime, round_id, role, expiration_time, TIMESTAMPDIFF(MINUTE, bantime, expiration_time), IF(expiration_time < NOW(), 1, NULL), applies_to_admins, reason, IFNULL((SELECT byond_key FROM [format_table_name("player")] WHERE [format_table_name("player")].ckey = [format_table_name("ban")].ckey), ckey), INET_NTOA(ip), computerid, IFNULL((SELECT byond_key FROM [format_table_name("player")] WHERE [format_table_name("player")].ckey = [format_table_name("ban")].a_ckey), a_ckey), IF(edits IS NOT NULL, 1, NULL), unbanned_datetime, IFNULL((SELECT byond_key FROM [format_table_name("player")] WHERE [format_table_name("player")].ckey = [format_table_name("ban")].unbanned_ckey), unbanned_ckey), unbanned_round_id FROM [format_table_name("ban")] WHERE [search] ORDER BY id DESC[limit]"})
		if(!query_unban_search_bans.warn_execute())
			qdel(query_unban_search_bans)
			return
		while(query_unban_search_bans.NextRow())
			var/ban_id = query_unban_search_bans.item[1]
			var/ban_datetime = query_unban_search_bans.item[2]
			var/ban_round_id  = query_unban_search_bans.item[3]
			var/role = query_unban_search_bans.item[4]
			//make the href for unban here so only the search parameters are passed
			var/unban_href = "<a href='?src=[REF(usr.client.holder)];[HrefToken()];unbanid=[ban_id];unbankey=[player_key];unbanadminkey=[admin_key];unbanip=[player_ip];unbancid=[player_cid];unbanrole=[role];unbanpage=[page]'>Unban</a>"
			var/expiration_time = query_unban_search_bans.item[5]
			//we don't cast duration as num because if the duration is large enough to be converted to scientific notation by byond then the + character gets lost when passed through href causing SQL to interpret '4.321e 007' as '4'
			var/duration = query_unban_search_bans.item[6]
			var/expired = query_unban_search_bans.item[7]
			var/applies_to_admins = text2num(query_unban_search_bans.item[8])
			var/reason = query_unban_search_bans.item[9]
			player_key = query_unban_search_bans.item[10]
			player_ip = query_unban_search_bans.item[11]
			player_cid = query_unban_search_bans.item[12]
			admin_key = query_unban_search_bans.item[13]
			var/edits = query_unban_search_bans.item[14]
			var/unban_datetime = query_unban_search_bans.item[15]
			var/unban_key = query_unban_search_bans.item[16]
			var/unban_round_id = query_unban_search_bans.item[17]
			var/target = ban_target_string(player_key, player_ip, player_cid)
			output += "<div class='banbox'><div class='header [unban_datetime ? "unbanned" : "banned"]'><b>[target]</b>[applies_to_admins ? " <b>ADMIN</b>" : ""] banned by <b>[admin_key]</b> from <b>[role]</b> on <b>[ban_datetime]</b> during round <b>#[ban_round_id]</b>.<br>"
			if(!expiration_time)
				output += "<b>Permanent ban</b>."
			else
				output += "Duration of <b>[DisplayTimeText(text2num(duration) MINUTES)]</b>, <b>[expired ? "expired" : "expires"]</b> on <b>[expiration_time]</b>."
			if(unban_datetime)
				output += "<br>Unbanned by <b>[unban_key]</b> on <b>[unban_datetime]</b> during round <b>#[unban_round_id]</b>."
			output += "</div><div class='container'><div class='reason'>[reason]</div><div class='edit'>"
			if(!expired && !unban_datetime)
				output += "<a href='?src=[REF(usr.client.holder)];[HrefToken()];editbanid=[ban_id];editbankey=[player_key];editbanip=[player_ip];editbancid=[player_cid];editbanrole=[role];editbanduration=[duration];editbanadmins=[applies_to_admins];editbanreason=[url_encode(reason)];editbanpage=[page];editbanadminkey=[admin_key]'>Edit</a><br>[unban_href]"
			if(edits)
				output += "<br><a href='?src=[REF(usr.client.holder)];[HrefToken()];unbanlog=[ban_id]'>Edit log</a>"
			output += "</div></div></div>"
		qdel(query_unban_search_bans)
		output += "</div>"
	panel.set_content(jointext(output, ""))
	panel.open()


/datum/admins/proc/unban(ban_id, player_key, player_ip, player_cid, role, page, admin_key)
	if(!check_rights(R_BAN))
		return
	if(!SSdbcore.Connect())
		to_chat(usr, "<span class='danger'>Failed to establish database connection.</span>")
		return
	var/target = ban_target_string(player_key, player_ip, player_cid)
	if(alert(usr, "Please confirm unban of [target] from [role].", "Unban confirmation", "Yes", "No") == "No")
		return
	ban_id = sanitizeSQL(ban_id)
	var/admin_ckey = sanitizeSQL(usr.client.ckey)
	var/admin_ip = sanitizeSQL(usr.client.address)
	var/admin_cid = sanitizeSQL(usr.client.computer_id)
	var/kn = key_name(usr)
	var/kna = ADMIN_TPMONTY(usr)
	var/datum/DBQuery/query_unban = SSdbcore.NewQuery("UPDATE [format_table_name("ban")] SET unbanned_datetime = NOW(), unbanned_ckey = '[admin_ckey]', unbanned_ip = INET_ATON('[admin_ip]'), unbanned_computerid = '[admin_cid]', unbanned_round_id = '[GLOB.round_id]' WHERE id = [ban_id]")
	if(!query_unban.warn_execute())
		qdel(query_unban)
		return
	qdel(query_unban)
	log_admin_private("[kn] has unbanned [target] from [role].")
	message_admins("[kna] has unbanned [target] from [role].")
	var/client/C = GLOB.directory[player_key]
	if(C)
		build_ban_cache(C)
		to_chat(C, "<span class='boldannounce'>[usr.client.key] has removed a ban from [role] for your key.")
	for(var/client/i in GLOB.clients - C)
		if(i.address == player_ip || i.computer_id == player_cid)
			build_ban_cache(i)
			to_chat(i, "<span class='boldannounce'>[usr.client.key] has removed a ban from [role] for your IP or CID.")
	usr.client.holder.unban_panel(player_key, admin_key, player_ip, player_cid, page)


/datum/admins/proc/edit_ban(ban_id, player_key, ip_check, player_ip, cid_check, player_cid, use_last_connection, applies_to_admins, duration, interval, reason, mirror_edit, old_key, old_ip, old_cid, old_applies, admin_key, page, list/changes)
	if(!check_rights(R_BAN))
		return
	if(!SSdbcore.Connect())
		to_chat(usr, "<span class='danger'>Failed to establish database connection.</span>")
		return
	ban_id = sanitizeSQL(ban_id)
	var/player_ckey = sanitizeSQL(ckey(player_key))
	player_ip = sanitizeSQL(player_ip)
	player_cid = sanitizeSQL(player_cid)
	var/bantime
	if(player_ckey)
		var/datum/DBQuery/query_edit_ban_get_player = SSdbcore.NewQuery("SELECT byond_key, (SELECT bantime FROM [format_table_name("ban")] WHERE id = [ban_id]), ip, computerid FROM [format_table_name("player")] WHERE ckey = '[player_ckey]'")
		if(!query_edit_ban_get_player.warn_execute())
			qdel(query_edit_ban_get_player)
			return
		if(query_edit_ban_get_player.NextRow())
			player_key = query_edit_ban_get_player.item[1]
			bantime = query_edit_ban_get_player.item[2]
			if(use_last_connection)
				if(ip_check)
					player_ip = query_edit_ban_get_player.item[3]
				if(cid_check)
					player_cid = query_edit_ban_get_player.item[4]
		else
			if(alert(usr, "[player_key]/([player_ckey]) has not been seen before, unable to use IP and CID from last connection. Are you sure you want to edit a ban for them?", "Unknown key", "Yes", "No", "Cancel") != "Yes")
				qdel(query_edit_ban_get_player)
				return
			else
				if(alert(usr, "[player_key]/([player_ckey]) has not been seen before, are you sure you want to edit a ban for them?", "Unknown key", "Yes", "No", "Cancel") != "Yes")
					qdel(query_edit_ban_get_player)
					return
		qdel(query_edit_ban_get_player)
	if(applies_to_admins && (applies_to_admins != old_applies))
		var/admin_ckey = sanitizeSQL(usr.client.ckey)
		var/datum/DBQuery/query_check_adminban_count = SSdbcore.NewQuery("SELECT COUNT(DISTINCT bantime) FROM [format_table_name("ban")] WHERE a_ckey = '[admin_ckey]' AND applies_to_admins = 1 AND unbanned_datetime IS NULL AND (expiration_time IS NULL OR expiration_time > NOW())")
		if(!query_check_adminban_count.warn_execute()) //count distinct bantime to treat rolebans made at the same time as one ban
			qdel(query_check_adminban_count)
			return
		if(query_check_adminban_count.NextRow())
			var/adminban_count = text2num(query_check_adminban_count.item[1])
			var/max_adminbans = MAX_ADMINBANS_PER_ADMIN
			if(R_EVERYTHING && !(R_EVERYTHING & rank.can_edit_rights)) //edit rights are a more effective way to check hierarchical rank since many non-headmins have R_PERMISSIONS now
				max_adminbans = MAX_ADMINBANS_PER_HEADMIN
			if(adminban_count >= max_adminbans)
				to_chat(usr, "<span class='danger'>You've already logged [max_adminbans] admin ban(s) or more. Do not abuse this function!</span>")
				qdel(query_check_adminban_count)
				return
		qdel(query_check_adminban_count)
	applies_to_admins = sanitizeSQL(applies_to_admins)
	duration = sanitizeSQL(duration)
	if(interval)
		interval = sanitizeSQL(interval)
	else
		interval = "MINUTE"
	reason = sanitizeSQL(reason)
	var/kn = key_name(usr)
	var/kna = ADMIN_TPMONTY(usr)
	var/list/changes_text= list()
	var/list/changes_keys = list()
	for(var/i in changes)
		changes_text += "[sanitizeSQL(i)]: [sanitizeSQL(changes[i])]"
		changes_keys += i
	var/where = "id = [sanitizeSQL(ban_id)]"
	if(text2num(mirror_edit))
		var/list/wherelist = list("bantime = '[bantime]'")
		if(old_key)
			wherelist += "ckey = '[sanitizeSQL(ckey(old_key))]'"
		if(old_ip)
			old_ip = sanitizeSQL(old_ip)
			wherelist += "ip = INET_ATON(IF('[old_ip]' LIKE '', NULL, '[old_ip]'))"
		if(old_cid)
			wherelist += "computerid = '[sanitizeSQL(old_cid)]'"
		where = wherelist.Join(" AND ")
	var/datum/DBQuery/query_edit_ban = SSdbcore.NewQuery("UPDATE [format_table_name("ban")] SET expiration_time = IF('[duration]' LIKE '', NULL, bantime + INTERVAL [duration ? "[duration]" : "0"] [interval]), applies_to_admins = [applies_to_admins], reason = '[reason]', ckey = IF('[player_ckey]' LIKE '', NULL, '[player_ckey]'), ip = INET_ATON(IF('[player_ip]' LIKE '', NULL, '[player_ip]')), computerid = IF('[player_cid]' LIKE '', NULL, '[player_cid]'), edits = CONCAT(IFNULL(edits,''),'[sanitizeSQL(usr.client.key)] edited the following [jointext(changes_text, ", ")]<hr>') WHERE [where]")
	if(!query_edit_ban.warn_execute())
		qdel(query_edit_ban)
		return
	qdel(query_edit_ban)
	var/changes_keys_text = jointext(changes_keys, ", ")
	log_admin_private("[kn] has edited the [changes_keys_text] of a ban for [old_key ? "[old_key]" : "[old_ip]-[old_cid]"].") //if a ban doesn't have a key it must have an ip and/or a cid to have reached this point normally
	message_admins("[kna] has edited the [changes_keys_text] of a ban for [old_key ? "[old_key]" : "[old_ip]-[old_cid]"].")
	if(changes["Applies to admins"])
		send2irc("BAN ALERT","[kn] has edited a ban for [old_key ? "[old_key]" : "[old_ip]-[old_cid]"] to [applies_to_admins ? "" : "not"]affect admins")
	var/client/C = GLOB.directory[old_key]
	if(C)
		build_ban_cache(C)
		to_chat(C, "<span class='boldannounce'>[usr.client.key] has edited the [changes_keys_text] of a ban for your key.")
	for(var/client/i in GLOB.clients - C)
		if(i.address == old_ip || i.computer_id == old_cid)
			build_ban_cache(i)
			to_chat(i, "<span class='boldannounce'>[usr.client.key] has edited the [changes_keys_text] of a ban for your IP or CID.")
	usr.client.holder.unban_panel(player_key, null, null, null, page)


/datum/admins/proc/ban_log(ban_id)
	if(!check_rights(R_BAN))
		return
	if(!SSdbcore.Connect())
		to_chat(usr, "<span class='danger'>Failed to establish database connection.</span>")
		return
	ban_id = sanitizeSQL(ban_id)
	var/datum/DBQuery/query_get_ban_edits = SSdbcore.NewQuery("SELECT edits FROM [format_table_name("ban")] WHERE id = '[ban_id]'")
	if(!query_get_ban_edits.warn_execute())
		qdel(query_get_ban_edits)
		return
	if(query_get_ban_edits.NextRow())
		var/edits = query_get_ban_edits.item[1]
		var/datum/browser/edit_log = new(usr.client.mob, "baneditlog", "Ban edit log")
		edit_log.set_content(edits)
		edit_log.open()
	qdel(query_get_ban_edits)


/datum/admins/proc/ban_target_string(player_key, player_ip, player_cid)
	. = list()
	if(player_key)
		. += player_key
	else
		if(player_ip)
			. += player_ip
		else
			. += "NULL"
		if(player_cid)
			. += player_cid
		else
			. += "NULL"
	. = jointext(., "/")


/datum/admins/proc/stickyban(action, data)
	if(!check_rights(R_BAN))
		return

	switch(action)
		if("show")
			sticky_ban_panel()
		if("add")
			var/list/ban = list()
			var/ckey
			ban["admin"] = usr.key
			ban["type"] = list("sticky")
			ban["reason"] = "(InGameBan)([usr.key])" //this will be displayed in dd only

			if(data["ckey"])
				ckey = ckey(data["ckey"])
			else
				ckey = input(usr,"Ckey","Ckey","") as text|null
				if(!ckey)
					return
				ckey = ckey(ckey)
			ban["ckey"] = ckey

			if(get_stickyban_from_ckey(ckey))
				to_chat(usr, "<span class='warning'>Error: Can not add a stickyban: User already has a current sticky ban</span>")

			if(data["reason"])
				ban["message"] = data["reason"]
			else
				var/reason = input(usr, "Reason", "Reason", "Ban Evasion") as text|null
				if(!reason)
					return
				ban["message"] = "[reason]"

			world.SetConfig("ban",ckey,list2stickyban(ban))

			log_admin_private("[key_name(usr)] has stickybanned [ckey].\nReason: [ban["message"]]")
			message_admins("[ADMIN_TPMONTY(usr)] has stickybanned [ckey].\nReason: [ban["message"]]")

		if("remove")
			if(!data["ckey"])
				return
			var/ckey = data["ckey"]

			var/ban = get_stickyban_from_ckey(ckey)
			if(!ban)
				to_chat(usr, "<span class='warning'>Error: No sticky ban for [ckey] found!</span>")
				return
			if(alert("Are you sure you want to remove the sticky ban on [ckey]?","Are you sure","Yes","No") == "No")
				return
			if(!get_stickyban_from_ckey(ckey))
				to_chat(usr, "<span class='warning'>Error: The ban disappeared.</span>")
				return
			world.SetConfig("ban",ckey, null)

			log_admin_private("[key_name(usr)] removed [ckey]'s stickyban.")
			message_admins("[ADMIN_TPMONTY(usr)] removed [ckey]'s stickyban.")

		if("remove_alt")
			if(!data["ckey"])
				return
			var/ckey = data["ckey"]
			if(!data["alt"])
				return
			var/alt = ckey(data["alt"])
			var/ban = get_stickyban_from_ckey(ckey)
			if(!ban)
				to_chat(usr, "<span class='warning'>Error: No sticky ban for [ckey] found!</span>")
				return

			var/found = 0
			//we have to do it this way because byond keeps the case in its sticky ban matches WHY!!!
			for (var/key in ban["keys"])
				if (ckey(key) == alt)
					found = 1
					break

			if(!found)
				to_chat(usr, "<span class='warning'>Error: [alt] is not linked to [ckey]'s sticky ban!</span>")
				return

			if(alert("Are you sure you want to disassociate [alt] from [ckey]'s sticky ban? \nNote: Nothing stops byond from re-linking them","Are you sure","Yes","No") == "No")
				return

			ban = get_stickyban_from_ckey(ckey)
			if(!ban)
				to_chat(usr, "<span class='warning'>Error: The ban disappeared.</span>")
				return

			found = 0
			for(var/key in ban["keys"])
				if(ckey(key) == alt)
					ban["keys"] -= key
					found = 1
					break

			if(!found)
				to_chat(usr, "<span class='warning'>Error: [alt] link to [ckey]'s sticky ban disappeared.</span>")
				return

			world.SetConfig("ban",ckey,list2stickyban(ban))

			log_admin_private("[key_name(usr)] has disassociated [alt] from [ckey]'s sticky ban.")
			message_admins("[ADMIN_TPMONTY(usr)] has disassociated [alt] from [ckey]'s sticky ban.")

		if("edit")
			if(!data["ckey"])
				return
			var/ckey = data["ckey"]
			var/ban = get_stickyban_from_ckey(ckey)
			if(!ban)
				to_chat(usr, "<span class='warning'>Error: No sticky ban for [ckey] found!</span>")
				return
			var/oldreason = ban["message"]
			var/reason = input(usr,"Reason","Reason","[ban["message"]]") as text|null
			if(!reason || reason == oldreason)
				return
			//we have to do this again incase something changed while we waited for input
			ban = get_stickyban_from_ckey(ckey)
			if(!ban)
				to_chat(usr, "<span class='warning'>Error: The ban disappeared.</span>")
				return
			ban["message"] = "[reason]"

			world.SetConfig("ban",ckey,list2stickyban(ban))

			log_admin_private("[key_name(usr)] has edited [ckey]'s sticky ban reason from [oldreason] to [reason]")
			message_admins("[ADMIN_TPMONTY(usr)] has edited [ckey]'s sticky ban reason from [oldreason] to [reason]")

		if("revert")
			if(!data["ckey"])
				return
			var/ckey = data["ckey"]
			if(alert("Are you sure you want to revert the sticky ban on [ckey] to its state at round start?","Are you sure","Yes","No") == "No")
				return
			var/ban = get_stickyban_from_ckey(ckey)
			if(!ban)
				to_chat(usr, "<span class='warning'>Error: No sticky ban for [ckey] found!</span>")
				return
			var/cached_ban = SSstickyban.cache[ckey]
			if(!cached_ban)
				to_chat(usr, "<span class='warning'>Error: No cached sticky ban for [ckey] found!</span>")
			world.SetConfig("ban",ckey,null)

			log_admin_private("[key_name(usr)] has reverted [ckey]'s sticky ban to its state at round start.")
			message_admins("[ADMIN_TPMONTY(usr)] has reverted [ckey]'s sticky ban to its state at round start.")
			//revert is mostly used when shit goes rouge, so we have to set it to null
			//and wait a byond tick before assigning it to ensure byond clears its shit.
			sleep(world.tick_lag)
			world.SetConfig("ban",ckey,list2stickyban(cached_ban))


/datum/admins/proc/stickyban_gethtml(ckey, ban)
	. = {"
		<a href='?src=[REF(usr.client.holder)];[HrefToken()];stickyban=remove&ckey=[ckey]'>Remove</a>
		<a href='?src=[REF(usr.client.holder)];[HrefToken()];stickyban=revert&ckey=[ckey]'>Revert</a>
		<b>[ckey]</b>
		<br />"
		[ban["message"]] <b><a href='?src=[REF(usr.client.holder)];[HrefToken()];stickyban=edit&ckey=[ckey]'>Edit</a></b><br />
	"}
	if (ban["admin"])
		. += "[ban["admin"]]<br />"
	else
		. += "LEGACY<br />"
	. += "Caught keys<br />\n<ol>"
	for (var/key in ban["keys"])
		if (ckey(key) == ckey)
			continue
		. += "<li><a href='?src=[REF(usr.client.holder)];[HrefToken()];stickyban=remove_alt&ckey=[ckey]&alt=[ckey(key)]'>Remove</a>[key]</li>"
	. += "</ol>\n"


/proc/get_stickyban_from_ckey(var/ckey)
	if (!ckey)
		return null
	ckey = ckey(ckey)
	. = null
	for (var/key in world.GetConfig("ban"))
		if (ckey(key) == ckey)
			. = stickyban2list(world.GetConfig("ban",key))
			break

/proc/stickyban2list(var/ban)
	if (!ban)
		return null
	. = params2list(ban)
	if (.["keys"])
		var/keys = splittext(.["keys"], ",")
		var/ckeys = list()
		for (var/key in keys)
			var/ckey = ckey(key)
			ckeys[ckey] = ckey //to make searching faster.
		.["keys"] = ckeys
	.["type"] = splittext(.["type"], ",")
	.["IP"] = splittext(.["IP"], ",")
	.["computer_id"] = splittext(.["computer_id"], ",")


/proc/list2stickyban(var/list/ban)
	if (!ban || !islist(ban))
		return null
	. = ban.Copy()
	if (.["keys"])
		.["keys"] = jointext(.["keys"], ",")
	if (.["type"])
		.["type"] = jointext(.["type"], ",")

	//internal tracking only, shouldn't be stored
	. -= "existing_user_matches_this_round"
	. -= "admin_matches_this_round"
	. -= "matches_this_round"
	. -= "reverting"

	//storing these can sometimes cause sticky bans to start matching everybody
	//	and isn't even needed for sticky ban matching, as the hub tracks these separately
	. -= "IP"
	. -= "computer_id"

	. = list2params(.)


/datum/admins/proc/sticky_ban_panel()
	set name = "Sticky Ban Panel"
	set category = "Admin"

	if(!check_rights(R_BAN))
		return

	var/list/bans = sortList(world.GetConfig("ban"))
	var/banhtml = ""
	for(var/key in bans)
		var/ckey = ckey(key)
		var/ban = stickyban2list(world.GetConfig("ban",key))
		banhtml += "<br /><hr />\n"
		banhtml += usr.client.holder.stickyban_gethtml(ckey,ban)

	var/html = "<a href='?src=[REF(usr.client.holder)];[HrefToken()];stickyban=add'>Add</a><br>[banhtml]"

	var/datum/browser/browser = new(usr, "stickybans", "<div align='center'>Sticky Bans</div>", 700, 400)
	browser.set_content(html)
	browser.open()


//Blocks an attempt to connect before even creating our client datum thing.
/world/IsBanned(key, address, computer_id, type, real_bans_only = FALSE)
	if(!key || !address || !computer_id)
		if(real_bans_only)
			return FALSE
		log_access("Failed Login (invalid data): [key] [address]-[computer_id]")
		return list("reason"="invalid login data", "desc"="Error: Could not check ban status, Please try again. Error message: Your computer provided invalid or blank information to the server on connection (byond username, IP, and Computer ID.) Provided information for reference: Username:'[key]' IP:'[address]' Computer ID:'[computer_id]'. (If you continue to get this error, please restart byond or contact byond support.)")

	if(text2num(computer_id) == 2147483647) //this cid causes stickybans to go haywire
		log_access("Failed Login (invalid cid): [key] [address]-[computer_id]")
		return list("reason"="invalid login data", "desc"="Error: Could not check ban status, Please try again. Error message: Your computer provided an invalid Computer ID.)")
	var/admin = FALSE
	var/ckey = ckey(key)
	if(GLOB.admin_datums[ckey] || GLOB.deadmins[ckey])
		admin = TRUE

	//Guest Checking
	if(!real_bans_only && IsGuestKey(key))
		if(CONFIG_GET(flag/guest_ban))
			log_access("Failed Login: [key] - Guests not allowed")
			return list("reason"="guest", "desc"="\nReason: Guests not allowed. Please sign in with a byond account.")

	if(CONFIG_GET(flag/sql_enabled))
		if(!SSdbcore.Connect())
			var/msg = "Ban database connection failure. Key [ckey] not checked"
			log_world(msg)
			message_admins(msg)
		else
			var/list/ban_details = is_banned_from_with_details(ckey, address, computer_id, "Server")
			for(var/i in ban_details)
				if(admin)
					if(text2num(i["applies_to_admins"]))
						var/msg = "Admin [key] is admin banned, and has been disallowed access."
						log_admin(msg)
						message_admins(msg)
					else
						var/msg = "Admin [key] has been allowed to bypass a matching non-admin ban on [i["key"]] [i["ip"]]-[i["computerid"]]."
						log_admin(msg)
						message_admins(msg)
						addclientmessage(ckey,"<span class='adminnotice'>Admin [key] has been allowed to bypass a matching non-admin ban on [i["key"]] [i["ip"]]-[i["computerid"]].</span>")
						continue
				var/expires = "This is a permanent ban."
				if(i["expiration_time"])
					expires = " The ban is for [DisplayTimeText(text2num(i["duration"]) MINUTES)] and expires on [i["expiration_time"]] (server time)."
				var/desc = {"You, or another user of this computer or connection ([i["key"]]) is banned from playing here.
				The ban reason is: [i["reason"]]
				This ban (BanID #[i["id"]]) was applied by [i["admin_key"]] on [i["bantime"]] during round ID [i["round_id"]].
				[expires]"}
				log_access("Failed Login: [key] [computer_id] [address] - Banned (#[i["id"]])")
				return list("reason"="Banned","desc"="[desc]")
	var/list/ban = ..()	//default pager ban stuff
	if(ban)
		var/bannedckey = "ERROR"
		if(ban["ckey"])
			bannedckey = ban["ckey"]

		var/newmatch = FALSE
		var/client/C = GLOB.directory[ckey]
		var/cachedban = SSstickyban.cache[bannedckey]

		//rogue ban in the process of being reverted.
		if(cachedban && cachedban["reverting"])
			return null

		if(cachedban && ckey != bannedckey)
			newmatch = TRUE
			if(cachedban["keys"])
				if(cachedban["keys"][ckey])
					newmatch = FALSE
			if(cachedban["matches_this_round"][ckey])
				newmatch = FALSE

		if(newmatch && cachedban)
			var/list/newmatches = cachedban["matches_this_round"]
			var/list/newmatches_connected = cachedban["existing_user_matches_this_round"]
			var/list/newmatches_admin = cachedban["admin_matches_this_round"]

			newmatches[ckey] = ckey
			if(C)
				newmatches_connected[ckey] = ckey
			if(admin)
				newmatches_admin[ckey] = ckey

			if(\
				length(newmatches) > STICKYBAN_MAX_MATCHES || \
				length(newmatches_connected) > STICKYBAN_MAX_EXISTING_USER_MATCHES || \
				length(newmatches_admin) > STICKYBAN_MAX_ADMIN_MATCHES \
				)
				if (cachedban["reverting"])
					return null
				cachedban["reverting"] = TRUE

				world.SetConfig("ban", bannedckey, null)

				log_game("Stickyban on [bannedckey] detected as rogue, reverting to its roundstart state")
				message_admins("Stickyban on [bannedckey] detected as rogue, reverting to its roundstart state")
				//do not convert to timer.
				spawn(5)
					world.SetConfig("ban", bannedckey, null)
					sleep(1)
					world.SetConfig("ban", bannedckey, null)
					cachedban["matches_this_round"] = list()
					cachedban["existing_user_matches_this_round"] = list()
					cachedban["admin_matches_this_round"] = list()
					cachedban -= "reverting"
					world.SetConfig("ban", bannedckey, list2stickyban(cachedban))
				return null

		//byond will not trigger isbanned() for "global" host bans,
		//ie, ones where the "apply to this game only" checkbox is not checked (defaults to not checked)
		//So it's safe to let admins walk thru host/sticky bans here
		if(admin)
			log_admin("The admin [key] has been allowed to bypass a matching host/sticky ban on [bannedckey]")
			message_admins("<span class='adminnotice'>The admin [key] has been allowed to bypass a matching host/sticky ban on [bannedckey]</span>")
			addclientmessage(ckey,"<span class='adminnotice'>You have been allowed to bypass a matching host/sticky ban on [bannedckey]</span>")
			return null

		if(C) //user is already connected!.
			to_chat(C, "You are about to get disconnected for matching a sticky ban after you connected. If this turns out to be the ban evasion detection system going haywire, we will automatically detect this and revert the matches. if you feel that this is the case, please wait EXACTLY 6 seconds then reconnect using file -> reconnect to see if the match was reversed.")

		var/desc = "\nReason:(StickyBan) You, or another user of this computer or connection ([bannedckey]) is banned from playing here. The ban reason is:\n[ban["message"]]\nThis ban was applied by [ban["admin"]]\nThis is a BanEvasion Detection System ban, if you think this ban is a mistake, please wait EXACTLY 6 seconds, then try again before filing an appeal.\n"
		. = list("reason" = "Stickyban", "desc" = desc)
		log_access("Failed Login: [key] [computer_id] [address] - StickyBanned [ban["message"]] Target Username: [bannedckey] Placed by [ban["admin"]]")

	return .


#undef STICKYBAN_MAX_MATCHES
#undef STICKYBAN_MAX_EXISTING_USER_MATCHES
#undef STICKYBAN_MAX_ADMIN_MATCHES
