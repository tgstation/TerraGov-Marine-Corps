world/IsBanned(key,address,computer_id)
	//Guest Checking
	if(!guests_allowed && IsGuestKey(key))
		log_access("Failed Login: [key] - Guests not allowed")
		message_admins("<span class='notice'> Failed Login: [key] - Guests not allowed</span>")
		return list("reason"="guest", "desc"="\nReason: Guests not allowed. Please sign in with a byond account.")

	if(CONFIG_GET(flag/ban_legacy_system))

		//Ban Checking
		. = CheckBan( ckey(key), computer_id, address )
		if(.)
			log_access("Failed Login: [key] [computer_id] [address] - Banned [.["reason"]]")
			message_admins("<span class='notice'> Failed Login: [key] id:[computer_id] ip:[address] - Banned [.["reason"]]</span>")
			return .

		return ..()	//default pager ban stuff

	else

		var/ckeytext = ckey(key)

		if(!establish_db_connection())
			stack_trace("Ban database connection failure. Key [ckeytext] not checked")
			log_sql("Ban database connection failure. Key [ckeytext] not checked")
			return

		var/failedcid = 1
		var/failedip = 1

		var/ipquery = ""
		var/cidquery = ""
		if(address)
			failedip = 0
			ipquery = " OR ip = '[address]' "

		if(computer_id)
			failedcid = 0
			cidquery = " OR computerid = '[computer_id]' "

		var/DBQuery/query = dbcon.NewQuery("SELECT ckey, ip, computerid, a_ckey, reason, expiration_time, duration, bantime, bantype FROM erro_ban WHERE (ckey = '[ckeytext]' [ipquery] [cidquery]) AND (bantype = 'PERMABAN'  OR (bantype = 'TEMPBAN' AND expiration_time > Now())) AND isnull(unbanned)")

		query.Execute()

		while(query.NextRow())
			var/pckey = query.item[1]
			//var/pip = query.item[2]
			//var/pcid = query.item[3]
			var/ackey = query.item[4]
			var/reason = query.item[5]
			var/expiration = query.item[6]
			var/duration = query.item[7]
			var/bantime = query.item[8]
			var/bantype = query.item[9]

			var/expires = ""
			if(text2num(duration) > 0)
				expires = " The ban is for [duration] minutes and expires on [expiration] (server time)."

			var/desc = "\nReason: You, or another user of this computer or connection ([pckey]) is banned from playing here. The ban reason is:\n[reason]\nThis ban was applied by [ackey] on [bantime], [expires]"

			return list("reason"="[bantype]", "desc"="[desc]")

		if (failedcid)
			message_admins("[key] has logged in with a blank computer id in the ban check.")
		if (failedip)
			message_admins("[key] has logged in with a blank ip in the ban check.")
		return ..()	//default pager ban stuff


/datum/admins/proc/DB_ban_record(var/bantype, var/mob/banned_mob, var/duration = -1, var/reason, var/job = "", var/rounds = 0, var/banckey = null)
	if(!check_rights(R_BAN))
		return

	establish_db_connection()
	if(!dbcon.IsConnected())
		return

	var/serverip = "[world.internet_address]:[world.port]"
	var/bantype_pass = 0
	var/bantype_str
	switch(bantype)
		if(BANTYPE_PERMA)
			bantype_str = "PERMABAN"
			duration = -1
			bantype_pass = 1
		if(BANTYPE_TEMP)
			bantype_str = "TEMPBAN"
			bantype_pass = 1
		if(BANTYPE_JOB_PERMA)
			bantype_str = "JOB_PERMABAN"
			duration = -1
			bantype_pass = 1
		if(BANTYPE_JOB_TEMP)
			bantype_str = "JOB_TEMPBAN"
			bantype_pass = 1

	if(!bantype_pass)
		return
	if(!istext(reason))
		return
	if(!isnum(duration))
		return

	var/ckey
	var/computerid
	var/ip

	if(ismob(banned_mob))
		ckey = banned_mob.ckey
		if(banned_mob.client)
			computerid = banned_mob.client.computer_id
			ip = banned_mob.client.address
	else if(banckey)
		ckey = ckey(banckey)

	var/DBQuery/query = dbcon.NewQuery("SELECT id FROM erro_player WHERE ckey = '[ckey]'")
	query.Execute()
	var/validckey = 0
	if(query.NextRow())
		validckey = 1
	if(!validckey)
		if(!banned_mob || (banned_mob && !IsGuestKey(banned_mob.key)))
			message_admins("<font color='red'>[key_name_admin(usr)] attempted to ban [ckey], but [ckey] has not been seen yet. Please only ban actual players.</font>",1)
			return

	var/a_ckey
	var/a_computerid
	var/a_ip

	if(src.owner && istype(src.owner, /client))
		a_ckey = src.owner:ckey
		a_computerid = src.owner:computer_id
		a_ip = src.owner:address

	var/who
	for(var/client/C in clients)
		if(!who)
			who = "[C]"
		else
			who += ", [C]"

	var/adminwho
	for(var/client/C in admins)
		if(!adminwho)
			adminwho = "[C]"
		else
			adminwho += ", [C]"

	reason = sql_sanitize_text(reason)

	var/sql = "INSERT INTO erro_ban (`id`,`bantime`,`serverip`,`bantype`,`reason`,`job`,`duration`,`rounds`,`expiration_time`,`ckey`,`computerid`,`ip`,`a_ckey`,`a_computerid`,`a_ip`,`who`,`adminwho`,`edits`,`unbanned`,`unbanned_datetime`,`unbanned_ckey`,`unbanned_computerid`,`unbanned_ip`) VALUES (null, Now(), '[serverip]', '[bantype_str]', '[reason]', '[job]', [(duration)?"[duration]":"0"], [(rounds)?"[rounds]":"0"], Now() + INTERVAL [(duration>0) ? duration : 0] MINUTES, '[ckey]', '[computerid]', '[ip]', '[a_ckey]', '[a_computerid]', '[a_ip]', '[who]', '[adminwho]', '', null, null, null, null, null)"
	var/DBQuery/query_insert = dbcon.NewQuery(sql)
	query_insert.Execute()
	to_chat(usr, "<span class='notice'>Ban saved to database.</span>")
	message_admins("[key_name_admin(usr)] has added a [bantype_str] for [ckey] [(job)?"([job])":""] [(duration > 0)?"([duration] minutes)":""] with the reason: \"[reason]\" to the ban database.",1)



/datum/admins/proc/DB_ban_unban(var/ckey, var/bantype, var/job = "")
	if(!check_rights(R_BAN))
		return

	var/bantype_str
	if(bantype)
		var/bantype_pass = 0
		switch(bantype)
			if(BANTYPE_PERMA)
				bantype_str = "PERMABAN"
				bantype_pass = 1
			if(BANTYPE_TEMP)
				bantype_str = "TEMPBAN"
				bantype_pass = 1
			if(BANTYPE_JOB_PERMA)
				bantype_str = "JOB_PERMABAN"
				bantype_pass = 1
			if(BANTYPE_JOB_TEMP)
				bantype_str = "JOB_TEMPBAN"
				bantype_pass = 1
			if(BANTYPE_ANY_FULLBAN)
				bantype_str = "ANY"
				bantype_pass = 1
		if( !bantype_pass ) return

	var/bantype_sql
	if(bantype_str == "ANY")
		bantype_sql = "(bantype = 'PERMABAN' OR (bantype = 'TEMPBAN' AND expiration_time > Now() ) )"
	else
		bantype_sql = "bantype = '[bantype_str]'"

	var/sql = "SELECT id FROM erro_ban WHERE ckey = '[ckey]' AND [bantype_sql] AND (unbanned is null OR unbanned = false)"
	if(job)
		sql += " AND job = '[job]'"

	establish_db_connection()
	if(!dbcon.IsConnected())
		return

	var/ban_id
	var/ban_number = 0 //failsafe

	var/DBQuery/query = dbcon.NewQuery(sql)
	query.Execute()
	while(query.NextRow())
		ban_id = query.item[1]
		ban_number++;

	if(ban_number == 0)
		to_chat(usr, "<span class='warning'>Database update failed due to no bans fitting the search criteria. If this is not a legacy ban you should contact the database admin.</span>")
		return

	if(ban_number > 1)
		to_chat(usr, "<span class='warning'>Database update failed due to multiple bans fitting the search criteria. Note down the ckey, job and current time and contact the database admin.</span>")
		return

	if(istext(ban_id))
		ban_id = text2num(ban_id)
	if(!isnum(ban_id))
		to_chat(usr, "<span class='warning'>Database update failed due to a ban ID mismatch. Contact the database admin.</span>")
		return

	DB_ban_unban_by_id(ban_id)

/datum/admins/proc/DB_ban_edit(var/banid = null, var/param = null)
	if(!check_rights(R_BAN))
		return

	if(!isnum(banid) || !istext(param))
		to_chat(usr, "Cancelled")
		return

	var/DBQuery/query = dbcon.NewQuery("SELECT ckey, duration, reason FROM erro_ban WHERE id = [banid]")
	query.Execute()

	var/eckey = usr.ckey	//Editing admin ckey
	var/pckey				//(banned) Player ckey
	var/duration			//Old duration
	var/reason				//Old reason

	if(query.NextRow())
		pckey = query.item[1]
		duration = query.item[2]
		reason = query.item[3]
	else
		to_chat(usr, "Invalid ban id. Contact the database admin")
		return

	reason = sql_sanitize_text(reason)
	var/value

	switch(param)
		if("reason")
			if(!value)
				value = input("Insert the new reason for [pckey]'s ban", "New Reason", "[reason]", null) as null|text
				value = sql_sanitize_text(value)
				if(!value)
					to_chat(usr, "Cancelled")
					return

			var/DBQuery/update_query = dbcon.NewQuery("UPDATE erro_ban SET reason = '[value]', edits = CONCAT(edits,'- [eckey] changed ban reason from <cite><b>\\\"[reason]\\\"</b></cite> to <cite><b>\\\"[value]\\\"</b></cite><BR>') WHERE id = [banid]")
			update_query.Execute()
			message_admins("[key_name_admin(usr)] has edited a ban for [pckey]'s reason from [reason] to [sanitize(value)]",1)
		if("duration")
			if(!value)
				value = input("Insert the new duration (in minutes) for [pckey]'s ban", "New Duration", "[duration]", null) as null|num
				if(!isnum(value) || !value)
					to_chat(usr, "Cancelled")
					return

			var/DBQuery/update_query = dbcon.NewQuery("UPDATE erro_ban SET duration = [value], edits = CONCAT(edits,'- [eckey] changed ban duration from [duration] to [value]<br>'), expiration_time = DATE_ADD(bantime, INTERVAL [value] MINUTE) WHERE id = [banid]")
			message_admins("[key_name_admin(usr)] has edited a ban for [pckey]'s duration from [duration] to [value]",1)
			update_query.Execute()
		if("unban")
			if(alert("Unban [pckey]?", "Unban?", "Yes", "No") == "Yes")
				DB_ban_unban_by_id(banid)
				return
			else
				to_chat(usr, "Cancelled")
				return
		else
			to_chat(usr, "Cancelled")
			return

/datum/admins/proc/DB_ban_unban_by_id(var/id)
	if(!check_rights(R_BAN))
		return

	var/sql = "SELECT ckey FROM erro_ban WHERE id = [id]"

	establish_db_connection()
	if(!dbcon.IsConnected())
		return

	var/ban_number = 0 //failsafe

	var/pckey
	var/DBQuery/query = dbcon.NewQuery(sql)
	query.Execute()
	while(query.NextRow())
		pckey = query.item[1]
		ban_number++;

	if(ban_number == 0)
		to_chat(usr, "<span class='warning'>Database update failed due to a ban id not being present in the database.</span>")
		return

	if(ban_number > 1)
		to_chat(usr, "<span class='warning'>Database update failed due to multiple bans having the same ID. Contact the database admin.</span>")
		return

	if(!src.owner || !istype(src.owner, /client))
		return

	var/unban_ckey = src.owner:ckey
	var/unban_computerid = src.owner:computer_id
	var/unban_ip = src.owner:address

	var/sql_update = "UPDATE erro_ban SET unbanned = 1, unbanned_datetime = Now(), unbanned_ckey = '[unban_ckey]', unbanned_computerid = '[unban_computerid]', unbanned_ip = '[unban_ip]' WHERE id = [id]"
	message_admins("[key_name_admin(usr)] has lifted [pckey]'s ban.",1)

	var/DBQuery/query_update = dbcon.NewQuery(sql_update)
	query_update.Execute()


/client/proc/DB_ban_panel(var/playerckey = null, var/adminckey = null)
	if(!check_rights(R_BAN))
		return

	establish_db_connection()
	if(!dbcon.IsConnected())
		to_chat(usr, "<span class='warning'>Failed to establish database connection</span>")
		return

	var/output = "<div align='center'><table width='90%'><tr>"

	output += "<td width='35%' align='center'>"
	output += "<h1>Banning panel</h1>"
	output += "</td>"

	output += "<td width='65%' align='center' bgcolor='#f9f9f9'>"

	output += "<form method='GET' action='?src=\ref[src]'><b>Add custom ban:</b> (ONLY use this if you can't ban through any other method)"
	output += "<input type='hidden' name='src' value='\ref[src]'>"
	output += "<table width='100%'><tr>"
	output += "<td><b>Ban type:</b><select name='dbbanaddtype'>"
	output += "<option value=''>--</option>"
	output += "<option value='[BANTYPE_PERMA]'>PERMABAN</option>"
	output += "<option value='[BANTYPE_TEMP]'>TEMPBAN</option>"
	output += "<option value='[BANTYPE_JOB_PERMA]'>JOB PERMABAN</option>"
	output += "<option value='[BANTYPE_JOB_TEMP]'>JOB TEMPBAN</option>"
	output += "</select></td>"
	output += "<td><b>Ckey:</b> <input type='text' name='dbbanaddckey'></td></tr>"
	output += "<tr><td><b>Duration:</b> <input type='text' name='dbbaddduration'></td>"
	output += "<td><b>Job:</b><select name='dbbanaddjob'>"
	output += "<option value=''>--</option>"
	for(var/j in get_all_jobs_titles())
		output += "<option value='[j]'>[j]</option>"
	for(var/j in list("traitor","changeling","operative","revolutionary","cultist","wizard"))
		output += "<option value='[j]'>[j]</option>"
	output += "</select></td></tr></table>"
	output += "<b>Reason:<br></b><textarea name='dbbanreason' cols='50'></textarea><br>"
	output += "<input type='submit' value='Add ban'>"
	output += "</form>"

	output += "</td>"
	output += "</tr>"
	output += "</table>"

	output += "<form method='GET' action='?src=\ref[src]'><b>Search:</b> "
	output += "<input type='hidden' name='src' value='\ref[src]'>"
	output += "<b>Ckey:</b> <input type='text' name='dbsearchckey' value='[playerckey]'>"
	output += "<b>Admin ckey:</b> <input type='text' name='dbsearchadmin' value='[adminckey]'>"
	output += "<input type='submit' value='search'>"
	output += "</form>"
	output += "Please note that all jobban bans or unbans are in-effect the following round."

	if(adminckey || playerckey)

		var/blcolor = "#ffeeee" //banned light
		var/bdcolor = "#ffdddd" //banned dark
		var/ulcolor = "#eeffee" //unbanned light
		var/udcolor = "#ddffdd" //unbanned dark

		output += "<table width='90%' bgcolor='#e3e3e3' cellpadding='5' cellspacing='0' align='center'>"
		output += "<tr>"
		output += "<th width='25%'><b>TYPE</b></th>"
		output += "<th width='20%'><b>CKEY</b></th>"
		output += "<th width='20%'><b>TIME APPLIED</b></th>"
		output += "<th width='20%'><b>ADMIN</b></th>"
		output += "<th width='15%'><b>OPTIONS</b></th>"
		output += "</tr>"

		adminckey = ckey(adminckey)
		playerckey = ckey(playerckey)
		var/adminsearch = ""
		var/playersearch = ""
		if(adminckey)
			adminsearch = "AND a_ckey = '[adminckey]' "
		if(playerckey)
			playersearch = "AND ckey = '[playerckey]' "

		var/DBQuery/select_query = dbcon.NewQuery("SELECT id, bantime, bantype, reason, job, duration, expiration_time, ckey, a_ckey, unbanned, unbanned_ckey, unbanned_datetime, edits FROM erro_ban WHERE 1 [playersearch] [adminsearch] ORDER BY bantime DESC")
		select_query.Execute()

		while(select_query.NextRow())
			var/banid = select_query.item[1]
			var/bantime = select_query.item[2]
			var/bantype  = select_query.item[3]
			var/reason = select_query.item[4]
			var/job = select_query.item[5]
			var/duration = select_query.item[6]
			var/expiration = select_query.item[7]
			var/ckey = select_query.item[8]
			var/ackey = select_query.item[9]
			var/unbanned = select_query.item[10]
			var/unbanckey = select_query.item[11]
			var/unbantime = select_query.item[12]
			var/edits = select_query.item[13]

			var/lcolor = blcolor
			var/dcolor = bdcolor
			if(unbanned)
				lcolor = ulcolor
				dcolor = udcolor

			var/typedesc =""
			switch(bantype)
				if("PERMABAN")
					typedesc = "<font color='red'><b>PERMABAN</b></font>"
				if("TEMPBAN")
					typedesc = "<b>TEMPBAN</b><br><font size='2'>([duration] minutes [(unbanned) ? "" : "(<a href=\"byond://?src=\ref[src];dbbanedit=duration;dbbanid=[banid]\">Edit</a>))"]<br>Expires [expiration]</font>"
				if("JOB_PERMABAN")
					typedesc = "<b>JOBBAN</b><br><font size='2'>([job])"
				if("JOB_TEMPBAN")
					typedesc = "<b>TEMP JOBBAN</b><br><font size='2'>([job])<br>([duration] minutes<br>Expires [expiration]"

			output += "<tr bgcolor='[dcolor]'>"
			output += "<td align='center'>[typedesc]</td>"
			output += "<td align='center'><b>[ckey]</b></td>"
			output += "<td align='center'>[bantime]</td>"
			output += "<td align='center'><b>[ackey]</b></td>"
			output += "<td align='center'>[(unbanned) ? "" : "<b><a href=\"byond://?src=\ref[src];dbbanedit=unban;dbbanid=[banid]\">Unban</a></b>"]</td>"
			output += "</tr>"
			output += "<tr bgcolor='[lcolor]'>"
			output += "<td align='center' colspan='5'><b>Reason: [(unbanned) ? "" : "(<a href=\"byond://?src=\ref[src];dbbanedit=reason;dbbanid=[banid]\">Edit</a>)"]</b> <cite>\"[reason]\"</cite></td>"
			output += "</tr>"
			if(edits)
				output += "<tr bgcolor='[dcolor]'>"
				output += "<td align='center' colspan='5'><b>EDITS</b></td>"
				output += "</tr>"
				output += "<tr bgcolor='[lcolor]'>"
				output += "<td align='center' colspan='5'><font size='2'>[edits]</font></td>"
				output += "</tr>"
			if(unbanned)
				output += "<tr bgcolor='[dcolor]'>"
				output += "<td align='center' colspan='5' bgcolor=''><b>UNBANNED by admin [unbanckey] on [unbantime]</b></td>"
				output += "</tr>"
			output += "<tr>"
			output += "<td colspan='5' bgcolor='white'>&nbsp</td>"
			output += "</tr>"

		output += "</table></div>"

	usr << browse(output,"window=lookupbans;size=900x500")


var/savefile/Banlist

/proc/CheckBan(var/ckey, var/id, var/address)
	if(!Banlist)		// if Banlist cannot be located for some reason
		LoadBans()		// try to load the bans
		if(!Banlist)	// uh oh, can't find bans!
			return FALSE	// ABORT ABORT ABORT

	. = list()
	var/appeal
	if(CONFIG_GET(string/banappeals))
		appeal = "\nFor more information on your ban, or to appeal, head to <a href='[CONFIG_GET(string/banappeals)]'>[CONFIG_GET(string/banappeals)]</a>"
	Banlist.cd = "/base"
	if( "[ckey][id]" in Banlist.dir )
		Banlist.cd = "[ckey][id]"
		if (Banlist["temp"])
			if (!GetExp(Banlist["minutes"]))
				ClearTempbans()
				return 0
			else
				.["desc"] = "\nReason: [Banlist["reason"]]\nExpires: [GetExp(Banlist["minutes"])]\nBy: [Banlist["bannedby"]][appeal]"
		else
			Banlist.cd	= "/base/[ckey][id]"
			.["desc"]	= "\nReason: [Banlist["reason"]]\nExpires: <B>PERMENANT</B>\nBy: [Banlist["bannedby"]][appeal]"
		.["reason"]	= "ckey/id"
		return .
	else
		for (var/A in Banlist.dir)
			Banlist.cd = "/base/[A]"
			var/matches
			if(ckey == Banlist["key"])
				matches += "ckey"
			if(id == Banlist["id"])
				if(matches)
					matches += "/"
				matches += "id"
			if(address == Banlist["ip"])
				if(matches)
					matches += "/"
				matches += "ip"

			if(matches)
				if(Banlist["temp"])
					if (!GetExp(Banlist["minutes"]))
						ClearTempbans()
						return 0
					else
						.["desc"] = "\nReason: [Banlist["reason"]]\nExpires: [GetExp(Banlist["minutes"])]\nBy: [Banlist["bannedby"]][appeal]"
				else
					.["desc"] = "\nReason: [Banlist["reason"]]\nExpires: <B>PERMENANT</B>\nBy: [Banlist["bannedby"]][appeal]"
				.["reason"] = matches
				return .
	return 0

/hook/startup/proc/loadBans()
	return LoadBans()

/proc/LoadBans()

	Banlist = new("data/banlist.bdb")
	log_admin("Loading Banlist")

	if (!length(Banlist.dir)) log_admin("Banlist is empty.")

	if (!Banlist.dir.Find("base"))
		log_admin("Banlist missing base dir.")
		Banlist.dir.Add("base")
		Banlist.cd = "/base"
	else if (Banlist.dir.Find("base"))
		Banlist.cd = "/base"

	ClearTempbans()
	return 1

/proc/ClearTempbans()

	Banlist.cd = "/base"
	for (var/A in Banlist.dir)
		Banlist.cd = "/base/[A]"
		if (!Banlist["key"] || !Banlist["id"])
			RemoveBan(A)
			log_admin("Invalid Ban.")
			message_admins("Invalid Ban.")
			continue

		if (!Banlist["temp"]) continue
		if ((world.realtime / 10) / 60 >= Banlist["minutes"]) RemoveBan(A)

	return 1


/proc/AddBan(ckey, computerid, reason, bannedby, temp, minutes, address)

	var/bantimestamp

	if (temp)
		bantimestamp = (world.realtime / 10) / 60 + minutes

	Banlist.cd = "/base"
	if ( Banlist.dir.Find("[ckey][computerid]") )
		to_chat(usr, text("<span class='warning'> Ban already exists.</span>"))
		return 0
	else
		Banlist.dir.Add("[ckey][computerid]")
		Banlist.cd = "/base/[ckey][computerid]"
		Banlist["key"] << ckey
		Banlist["id"] << computerid
		Banlist["ip"] << address
		Banlist["reason"] << reason
		Banlist["bannedby"] << bannedby
		Banlist["temp"] << temp
		if (temp)
			Banlist["minutes"] << bantimestamp
	return 1

/proc/RemoveBan(foldername)
	var/key
	var/id

	Banlist.cd = "/base/[foldername]"
	Banlist["key"] >> key
	Banlist["id"] >> id
	Banlist.cd = "/base"

	if (!Banlist.dir.Remove(foldername)) return 0

	if(!usr)
		log_admin("Ban Expired: [key]")
		message_admins("Ban Expired: [key]")
	else
		ban_unban_log_save("[key_name_admin(usr)] unbanned [key]")
		log_admin("[key_name_admin(usr)] unbanned [key]")
		message_admins("[key_name_admin(usr)] unbanned: [key]")
		feedback_inc("ban_unban",1)
		usr.client.holder.DB_ban_unban( ckey(key), BANTYPE_ANY_FULLBAN)
	for (var/A in Banlist.dir)
		Banlist.cd = "/base/[A]"
		if (key == Banlist["key"] /*|| id == Banlist["id"]*/)
			Banlist.cd = "/base"
			Banlist.dir.Remove(A)
			continue

	return 1

/proc/GetExp(minutes as num)
	var/exp = minutes - (world.realtime / 10) / 60
	if (exp <= 0)
		return 0
	else
		var/timeleftstring
		if (exp >= 1440) //1440 = 1 day in minutes
			timeleftstring = "[round(exp / 1440, 0.1)] Days"
		else if (exp >= 60) //60 = 1 hour in minutes
			timeleftstring = "[round(exp / 60, 0.1)] Hours"
		else
			timeleftstring = "[exp] Minutes"
		return timeleftstring

/datum/admins/proc/unbanpanel()
	var/count = 0
	var/dat
	//var/dat = "<HR><B>Unban Player:</B> <span class='notice'>(U) = Unban , (E) = Edit Ban<span class='green'> (Total<HR><table border=1 rules=all frame=void cellspacing=0 cellpadding=3 ></span>"
	Banlist.cd = "/base"
	for (var/A in Banlist.dir)
		count++
		Banlist.cd = "/base/[A]"
		var/ref		= "\ref[src]"
		var/key		= Banlist["key"]
		var/id		= Banlist["id"]
		var/ip		= Banlist["ip"]
		var/reason	= Banlist["reason"]
		var/by		= Banlist["bannedby"]
		var/expiry
		if(Banlist["temp"])
			expiry = GetExp(Banlist["minutes"])
			if(!expiry)		expiry = "Removal Pending"
		else				expiry = "Permaban"
		var/unban_link = "<A href='?src=[ref];unbanf=[key][id]'>(U)</A><A href='?src=[ref];unbane=[key][id]'>(E)</A>"
		var/perma_links = ""
		if(!Banlist["temp"])
			unban_link = ""
			perma_links = "<A href='?src=[ref];unbanf=[key][id]'>(L)</A>"
		else
			perma_links = "<A href='?src=[ref];unbanupgradeperma=[key][id]'>(P)</A>"
		if(!check_rights(R_BAN))
			perma_links = ""

		dat += "<tr><td>[unban_link][perma_links] Key: <B>[key]</B></td><td>ComputerID: <B>[id]</B></td><td>IP: <B>[ip]</B></td><td> [expiry]</td><td>(By: [by])</td><td>(Reason: [reason])</td></tr>"

	dat += "</table>"
	var/dat_header = "<HR><B>Bans:</B> <FONT COLOR=blue>(U) = Unban , (E) = Edit Ban"
	if(!check_rights(R_BAN))
		dat_header += ", (P) = Upgrade to Perma, (L) = Lift Permaban"
	dat_header += "</FONT> - <FONT COLOR=green>([count] Bans)</FONT><HR><table border=1 rules=all frame=void cellspacing=0 cellpadding=3 >[dat]"
	usr << browse(dat_header, "window=unbanp;size=875x400")


var/jobban_runonce			// Updates legacy bans with new info
var/jobban_keylist[0]		//to store the keys & ranks

/proc/check_jobban_path(X)
	. = ckey(X)
	if(!islist(jobban_keylist[.])) //If it's not a list, we're in trouble.
		jobban_keylist[.] = list()

/proc/jobban_fullban(mob/M, rank, reason)
	if (!M || !M.ckey) return
	rank = check_jobban_path(rank)
	jobban_keylist[rank][M.ckey] = reason

/proc/jobban_client_fullban(ckey, rank)
	if (!ckey || !rank) return
	rank = check_jobban_path(rank)
	jobban_keylist[rank][ckey] = "Reason Unspecified"

//returns a reason if M is banned from rank, returns 0 otherwise
/proc/jobban_isbanned(mob/M, rank)
	if(M && rank)
		rank = check_jobban_path(rank)
		if(guest_jobbans(rank))
			if(CONFIG_GET(flag/guest_jobban) && IsGuestKey(M.key))
				return "Guest Job-ban"
			if(CONFIG_GET(flag/usewhitelist) && !check_whitelist(M))
				return "Whitelisted Job"
		return jobban_keylist[rank][M.ckey]

/hook/startup/proc/loadJobBans()
	jobban_loadbanfile()
	return TRUE

/proc/jobban_loadbanfile()
	if(CONFIG_GET(flag/ban_legacy_system))
		var/savefile/S = new("data/job_new.ban")
		S["new_bans"] >> jobban_keylist
		log_admin("Loading jobban_rank")
		S["runonce"] >> jobban_runonce

		if(!length(jobban_keylist))
			jobban_keylist=list()
			log_admin("jobban_keylist was empty")
	else
		if(!establish_db_connection())
			stack_trace("Database connection failed. Reverting to the legacy ban system.")
			log_sql("Database connection failed. Reverting to the legacy ban system.")
			CONFIG_SET(flag/ban_legacy_system, TRUE)
			jobban_loadbanfile()
			return

		//Job permabans
		var/DBQuery/query = dbcon.NewQuery("SELECT ckey, job FROM erro_ban WHERE bantype = 'JOB_PERMABAN' AND isnull(unbanned)")
		query.Execute()

		while(query.NextRow())
			var/ckey = query.item[1]
			var/job = query.item[2]

			jobban_keylist[job][ckey] = "Reason Unspecified"

		//Job tempbans
		var/DBQuery/query1 = dbcon.NewQuery("SELECT ckey, job FROM erro_ban WHERE bantype = 'JOB_TEMPBAN' AND isnull(unbanned) AND expiration_time > Now()")
		query1.Execute()

		while(query1.NextRow())
			var/ckey = query1.item[1]
			var/job = query1.item[2]

			jobban_keylist[job][ckey] = "Reason Unspecified"

/proc/jobban_savebanfile()
	var/savefile/S=new("data/job_new.ban")
	S["new_bans"] << jobban_keylist

/proc/jobban_unban(mob/M, rank)
	jobban_remove("[M.ckey] - [ckey(rank)]")

/proc/ban_unban_log_save(var/formatted_log)
	text2file(formatted_log,"data/ban_unban_log.txt")

/proc/jobban_remove(X)
	var/regex/r1 = new("(.*) - (.*)")
	if(r1.Find(X))
		var/L[] = jobban_keylist[r1.group[2]]
		L.Remove(r1.group[1])
		return 1

/client/proc/unban_panel()
	set name = "Unban Panel"
	set category = "Admin"
	if(holder)
		if(CONFIG_GET(flag/ban_legacy_system))
			holder.unbanpanel()
		else
			DB_ban_panel()
