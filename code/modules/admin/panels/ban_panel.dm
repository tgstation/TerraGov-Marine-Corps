/datum/admins/proc/unban_panel()
	set category = "Admin"
	set name = "Unban Panel"

	if(!check_rights(R_BAN))
		return

	if(!CONFIG_GET(flag/ban_legacy_system))
		return

	var/ref = "[REF(usr.client.holder)];[HrefToken()]"

	var/count = 0
	var/dat
	Banlist.cd = "/base"
	for(var/A in Banlist.dir)
		count++
		Banlist.cd = "/base/[A]"
		var/key		= Banlist["key"]
		var/id		= Banlist["id"]
		var/ip		= Banlist["ip"]
		var/reason	= Banlist["reason"]
		var/by		= Banlist["bannedby"]
		var/expiry
		if(Banlist["temp"])
			expiry = GetExp(Banlist["minutes"])
			if(!expiry)
				expiry = "Removal Pending"
		else
			expiry = "Permaban"
		var/unban_link = "<a href='?src=[ref];unban=[key][id]'>(U)</A><A href='?src=[ref];editban=[key][id]'>(E)</a>"
		var/perma_links = ""
		if(!Banlist["temp"])
			unban_link = ""
			perma_links = "<a href='?src=[ref];unban=[key][id]'>(L)</a>"
		else
			perma_links = "<a href='?src=[ref];permaban=[key][id]'>(P)</a>"

		dat += "<tr><td>[unban_link][perma_links] Key: <B>[key]</B></td><td>ComputerID: <B>[id]</B></td><td>IP: <B>[ip]</B></td><td> [expiry]</td><td>(By: [by])</td><td>(Reason: [reason])</td></tr>"

	dat += "</table>"
	var/dat_header = "<HR><B>Bans:</B> <FONT COLOR=blue>(U) = Unban , (E) = Edit Ban, (P) = Upgrade to Permaban, (L) = Lift Permaban"
	dat_header += "</FONT> - <FONT COLOR=green>([count] Bans)</FONT><HR><table border=1 rules=all frame=void cellspacing=0 cellpadding=3 >[dat]"
	usr << browse(dat_header, "window=unbanp;size=875x400")


/datum/admins/proc/jobban_panel(var/mob/M)
	if(!check_rights(R_BAN))
		return

	if(!check_if_greater_rights_than(M.client))
		return

	if(!ismob(M))
		return

	if(!M.ckey)
		return

	if(!SSjob)
		return

	var/ref = "[REF(usr.client.holder)];[HrefToken()]"
	var/dat = ""
	var/header = "<head><title>Job-Ban Panel: [key_name(M)]</title></head>"
	var/body
	var/jobs = ""

	var/counter = 0

//Command (Blue)
	jobs += "<table cellpadding='1' cellspacing='0' width='100%'>"
	jobs += "<tr align='center' bgcolor='ccccff'><th colspan='[length(ROLES_COMMAND)]'><a href='?src=[ref];jobban=commanddept;mob=[REF(M)]'>Command Positions</a></th></tr><tr align='center'>"
	for(var/jobPos in ROLES_COMMAND)
		if(!jobPos)
			continue
		var/datum/job/job = SSjob.roles_by_name[jobPos]
		if(!job)
			continue

		if(jobban_isbanned(M, job.title))
			jobs += "<td width='20%'><a href='?src=[ref];jobban=[job.title];mob=[REF(M)]'><font color=red>[oldreplacetext(job.title, " ", "&nbsp")]</font></a></td>"
			counter++
		else
			jobs += "<td width='20%'><a href='?src=[ref];jobban=[job.title];mob=[REF(M)]'>[oldreplacetext(job.title, " ", "&nbsp")]</a></td>"
			counter++

		if(counter >= 6)
			jobs += "</tr><tr>"
			counter = 0
	jobs += "</tr></table>"


//Police (Red)
	jobs += "<table cellpadding='1' cellspacing='0' width='100%'>"
	jobs += "<tr align='center' bgcolor='ffbab7'><th colspan='[length(ROLES_POLICE)]'><a href='?src=[ref];jobban=policedept;mob=[REF(M)]'>Police Positions</a></th></tr><tr align='center'>"
	for(var/jobPos in ROLES_POLICE)
		if(!jobPos)
			continue
		var/datum/job/job = SSjob.roles_by_name[jobPos]
		if(!job)
			continue

		if(jobban_isbanned(M, job.title))
			jobs += "<td width='20%'><a href='?src=[ref];jobban=[job.title];mob=[REF(M)]'><font color=red>[oldreplacetext(job.title, " ", "&nbsp")]</font></a></td>"
			counter++
		else
			jobs += "<td width='20%'><a href='?src=[ref];jobban=[job.title];mob=[REF(M)]'>[oldreplacetext(job.title, " ", "&nbsp")]</a></td>"
			counter++

		if(counter >= 6)
			jobs += "</tr><tr>"
			counter = 0
	jobs += "</tr></table>"


//Engineering (Yellow)
	counter = 0
	jobs += "<table cellpadding='1' cellspacing='0' width='100%'>"
	jobs += "<tr bgcolor='fff5cc'><th colspan='[length(ROLES_ENGINEERING)]'><a href='?src=[ref];jobban=engineeringdept;mob=[REF(M)]'>Engineering Positions</a></th></tr><tr align='center'>"
	for(var/jobPos in ROLES_ENGINEERING)
		if(!jobPos)
			continue
		var/datum/job/job = SSjob.roles_by_name[jobPos]

		if(!job)
			continue

		if(jobban_isbanned(M, job.title))
			jobs += "<td width='20%'><a href='?src=[ref];jobban=[job.title];mob=[REF(M)]'><font color=red>[oldreplacetext(job.title, " ", "&nbsp")]</font></a></td>"
			counter++
		else
			jobs += "<td width='20%'><a href='?src=[ref];jobban=[job.title];mob=[REF(M)]'>[oldreplacetext(job.title, " ", "&nbsp")]</a></td>"
			counter++

		if(counter >= 6)
			jobs += "</tr><tr align='center'>"
			counter = 0
	jobs += "</tr></table>"

//Cargo (Yellow)
	counter = 0
	jobs += "<table cellpadding='1' cellspacing='0' width='100%'>"
	jobs += "<tr bgcolor='fff5cc'><th colspan='[length(ROLES_REQUISITION)]'><a href='?src=[ref];jobban=cargodept;mob=[REF(M)]'>Requisition Positions</a></th></tr><tr align='center'>"
	for(var/jobPos in ROLES_REQUISITION)
		if(!jobPos)
			continue
		var/datum/job/job = SSjob.roles_by_name[jobPos]
		if(!job)
			continue

		if(jobban_isbanned(M, job.title))
			jobs += "<td width='20%'><a href='?src=[ref];jobban=[job.title];mob=[REF(M)]'><font color=red>[oldreplacetext(job.title, " ", "&nbsp")]</font></a></td>"
			counter++
		else
			jobs += "<td width='20%'><a href='?src=[ref];jobban=[job.title];mob=[REF(M)]'>[oldreplacetext(job.title, " ", "&nbsp")]</a></td>"
			counter++

		if(counter >= 6)
			jobs += "</tr><tr align='center'>"
			counter = 0
	jobs += "</tr></table>"

//Medical (White)
	counter = 0
	jobs += "<table cellpadding='1' cellspacing='0' width='100%'>"
	jobs += "<tr bgcolor='ffeef0'><th colspan='[length(ROLES_MEDICAL)]'><a href='?src=[ref];jobban=medicaldept;mob=[REF(M)]'>Medical Positions</a></th></tr><tr align='center'>"
	for(var/jobPos in ROLES_MEDICAL)
		if(!jobPos)
			continue
		var/datum/job/job = SSjob.roles_by_name[jobPos]
		if(!job)
			continue

		if(jobban_isbanned(M, job.title))
			jobs += "<td width='20%'><a href='?src=[ref];jobban=[job.title];mob=[REF(M)]'><font color=red>[oldreplacetext(job.title, " ", "&nbsp")]</font></a></td>"
			counter++
		else
			jobs += "<td width='20%'><a href='?src=[ref];jobban=[job.title];mob=[REF(M)]'>[oldreplacetext(job.title, " ", "&nbsp")]</a></td>"
			counter++

		if(counter >= 6)
			jobs += "</tr><tr align='center'>"
			counter = 0
	jobs += "</tr></table>"

//Marines
	counter = 0
	jobs += "<table cellpadding='1' cellspacing='0' width='100%'>"
	jobs += "<tr bgcolor='fff5cc'><th colspan='[length(ROLES_MARINES)]'><a href='?src=[ref];jobban=marinedept;mob=[REF(M)]'>Marine Positions</a></th></tr><tr align='center'>"
	for(var/jobPos in ROLES_MARINES)
		if(!jobPos)
			continue
		var/datum/job/job = SSjob.roles_by_name[jobPos]
		if(!job)
			continue

		if(jobban_isbanned(M, job.title))
			jobs += "<td width='20%'><a href='?src=[ref];jobban=[job.title];mob=[REF(M)]'><font color=red>[oldreplacetext(job.title, " ", "&nbsp")]</font></a></td>"
			counter++
		else
			jobs += "<td width='20%'><a href='?src=[ref];jobban=[job.title];mob=[REF(M)]'>[oldreplacetext(job.title, " ", "&nbsp")]</a></td>"
			counter++

		if(counter >= 6)
			jobs += "</tr><tr align='center'>"
			counter = 0
	jobs += "</tr></table>"

//Antagonist (Orange)
	var/isbanned_dept = jobban_isbanned(M, "Syndicate")
	jobs += "<table cellpadding='1' cellspacing='0' width='100%'>"
	jobs += "<tr bgcolor='ffeeaa'><th colspan='10'><a href='?src=[ref];jobban=Syndicate;mob=[REF(M)]'>Misc Positions</a></th></tr><tr align='center'>"

	//ERT
	if(jobban_isbanned(M, "Emergency Response Team") || isbanned_dept)
		jobs += "<td width='20%'><a href='?src=[ref];jobban=Emergency Response Team;mob=[REF(M)]'><font color=red>Emergency Response Team</font></a></td>"
	else
		jobs += "<td width='20%'><a href='?src=[ref];jobban=Emergency Response Team;mob=[REF(M)]'>Emergency Response Team</a></td>"

	//Xenos
	if(jobban_isbanned(M, "Alien") || isbanned_dept)
		jobs += "<td width='20%'><a href='?src=[ref];jobban=Alien;mob=[REF(M)]'><font color=red>Alien</font></a></td>"
	else
		jobs += "<td width='20%'><a href='?src=[ref];jobban=Alien;mob=[REF(M)]'>Alien</a></td>"

	//Queen
	if(jobban_isbanned(M, "Queen") || isbanned_dept)
		jobs += "<td width='20%'><a href='?src=[ref];jobban=Queen;mob=[REF(M)]'><font color=red>Queen</font></a></td>"
	else
		jobs += "<td width='20%'><a href='?src=[ref];jobban=Queen;mob=[REF(M)]'>Queen</a></td>"

	jobs += "</tr><tr align='center'>"

	//Survivor
	if(jobban_isbanned(M, "Survivor") || isbanned_dept)
		jobs += "<td width='20%'><a href='?src=[ref];jobban=Survivor;mob=[REF(M)]'><font color=red>Survivor</font></a></td>"
	else
		jobs += "<td width='20%'><a href='?src=[ref];jobban=Survivor;mob=[REF(M)]'>Survivor</a></td>"

	//Synthetic
	if(jobban_isbanned(M, "Synthetic") || isbanned_dept)
		jobs += "<td width='20%'><a href='?src=[ref];jobban=Synthetic;mob=[REF(M)]'><font color=red>Synthetic</font></a></td>"
	else
		jobs += "<td width='20%'><a href='?src=[ref];jobban=Synthetic;mob=[REF(M)]'>Synthetic</a></td>"

	//Predator
	if(jobban_isbanned(M, "Predator") || isbanned_dept)
		jobs += "<td width='20%'><a href='?src=[ref];jobban=Predator;mob=[REF(M)]'><font color=red>Predator</font></a></td>"
	else
		jobs += "<td width='20%'><a href='?src=[ref];jobban=Predator;mob=[REF(M)]'>Predator</a></td>"


	jobs += "</tr></table>"

	body = "<body>[jobs]</body>"
	dat = "<tt>[header][body]</tt>"
	usr << browse(dat, "window=jobban;size=800x490")


/client/proc/mute(var/client/C, mute_type, force = FALSE)
	if(!force)
		if(!check_if_greater_rights_than(C) && !check_rights(R_BAN, FALSE))
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

	C.prefs.load_preferences()

	if(C.prefs.muted & mute_type)
		muteunmute = "unmuted"
		C.prefs.muted &= ~mute_type
	else
		muteunmute = "muted"
		C.prefs.muted |= mute_type

	C.prefs.save_preferences()

	to_chat(C, "<span clas='danger'>You have been [muteunmute] from [mute_string].</span>")

	if(!force)
		log_admin_private("[key_name(usr)] has [muteunmute] [key_name(C)] from [mute_string].")
		message_admins("[ADMIN_TPMONTY(usr)] has [muteunmute] [ADMIN_TPMONTY(C.mob)] from [mute_string].")


/world/IsBanned(key,address,computer_id)
	//Guest Checking
	if(!guests_allowed && IsGuestKey(key))
		log_access("Failed Login: [key] - Guests not allowed.")
		message_admins("Failed Login: [key] - Guests not allowed.")
		return list("reason"="guest", "desc"="Reason: Guests not allowed. Please sign in with a byond account.")

	if(!CONFIG_GET(flag/ban_legacy_system))
		return

	//Ban Checking
	. = CheckBan(ckey(key), computer_id, address)
	if(.)
		log_access("Failed Login: [key] CID:[computer_id] IP:[address] - Banned [.["reason"]]")
		message_admins("Failed Login: [key] CID:[computer_id] IP:[address] - Banned [.["reason"]]</span>")
		return .

	return ..()	//default pager ban stuff


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
	if("[ckey][id]" in Banlist.dir)
		Banlist.cd = "[ckey][id]"
		if(Banlist["temp"])
			if(!GetExp(Banlist["minutes"]))
				ClearTempbans()
				return FALSE
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
					if(!GetExp(Banlist["minutes"]))
						ClearTempbans()
						return FALSE
					else
						.["desc"] = "\nReason: [Banlist["reason"]]\nExpires: [GetExp(Banlist["minutes"])]\nBy: [Banlist["bannedby"]][appeal]"
				else
					.["desc"] = "\nReason: [Banlist["reason"]]\nExpires: <B>PERMENANT</B>\nBy: [Banlist["bannedby"]][appeal]"
				.["reason"] = matches
				return .
	return FALSE


/hook/startup/proc/loadBans()
	return LoadBans()


/proc/LoadBans()
	Banlist = new("data/banlist.bdb")
	log_admin_private("Loading Banlist.")

	if(!length(Banlist.dir))
		log_admin_private("Banlist is empty.")

	if(!Banlist.dir.Find("base"))
		log_admin_private("Banlist missing base dir.")
		Banlist.dir.Add("base")
		Banlist.cd = "/base"
	else if(Banlist.dir.Find("base"))
		Banlist.cd = "/base"

	ClearTempbans()
	return TRUE


/proc/ClearTempbans()
	Banlist.cd = "/base"
	for(var/A in Banlist.dir)
		Banlist.cd = "/base/[A]"
		if(!Banlist["key"] && !Banlist["id"])
			RemoveBan(A)
			log_admin_private("Invalid Ban.")
			message_admins("Invalid Ban.")
			continue
		if(!Banlist["temp"])
			continue
		if((world.realtime / 10) / 60 >= Banlist["minutes"])
			RemoveBan(A)
	return TRUE


/proc/AddBan(ckey, computerid, reason, bannedby, temp, minutes, address)
	var/bantimestamp
	if(temp)
		bantimestamp = (world.realtime / 10) / 60 + minutes

	Banlist.cd = "/base"
	if(Banlist.dir.Find("[ckey][computerid]"))
		to_chat(usr, "<span class='warning'>Ban already exists.</span>")
		return FALSE
	else
		Banlist.dir.Add("[ckey][computerid]")
		Banlist.cd = "/base/[ckey][computerid]"
		Banlist["key"] << ckey
		Banlist["id"] << computerid
		Banlist["ip"] << address
		Banlist["reason"] << reason
		Banlist["bannedby"] << bannedby
		Banlist["temp"] << temp
		if(temp)
			Banlist["minutes"] << bantimestamp
	return TRUE


/proc/RemoveBan(foldername)
	var/key
	var/id

	Banlist.cd = "/base/[foldername]"
	Banlist["key"] >> key
	Banlist["id"] >> id
	Banlist.cd = "/base"

	if(!Banlist.dir.Remove(foldername))
		return FALSE

	for(var/A in Banlist.dir)
		Banlist.cd = "/base/[A]"
		if(key == Banlist["key"] /*|| id == Banlist["id"]*/)
			Banlist.cd = "/base"
			Banlist.dir.Remove(A)
			continue

	if(!usr)
		log_admin_private("Ban: Expired: [key].")
		message_admins("Ban expired: [key].")

	return TRUE


/proc/GetExp(minutes as num)
	var/exp = minutes - (world.realtime / 10) / 60
	if(exp <= 0)
		return 0
	else
		var/timeleftstring
		if(exp >= 1440) //1440 = 1 day in minutes
			timeleftstring = "[round(exp / 1440, 0.1)] Days"
		else if(exp >= 60) //60 = 1 hour in minutes
			timeleftstring = "[round(exp / 60, 0.1)] Hours"
		else
			timeleftstring = "[exp] Minutes"
		return timeleftstring


var/jobban_runonce			// Updates legacy bans with new info
var/jobban_keylist[0]		//to store the keys & ranks


/proc/check_jobban_path(X)
	. = ckey(X)
	if(!islist(jobban_keylist[.])) //If it's not a list, we're in trouble.
		jobban_keylist[.] = list()


/proc/jobban_fullban(mob/M, rank, reason)
	if(!M || !M.ckey)
		return
	rank = check_jobban_path(rank)
	jobban_keylist[rank][M.ckey] = reason


/proc/jobban_client_fullban(ckey, rank)
	if(!ckey || !rank)
		return
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
	if(!CONFIG_GET(flag/ban_legacy_system))
		return

	var/savefile/S = new("data/job_new.ban")
	S["new_bans"] >> jobban_keylist
	S["runonce"] >> jobban_runonce

	if(!length(jobban_keylist))
		jobban_keylist = list()
		log_admin_private("Jobban keylist was empty.")


/proc/jobban_savebanfile()
	var/savefile/S = new("data/job_new.ban")
	S["new_bans"] << jobban_keylist


/proc/jobban_unban(mob/M, rank)
	jobban_remove("[M.ckey] - [ckey(rank)]")


/proc/jobban_remove(X)
	var/regex/r1 = new("(.*) - (.*)")
	if(r1.Find(X))
		var/L[] = jobban_keylist[r1.group[2]]
		L.Remove(r1.group[1])
		return TRUE