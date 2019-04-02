/datum/admins/proc/legacy_unban_panel()
	set category = "Admin"
	set name = "Legacy Unban Panel"

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


/datum/admins/proc/legacy_ban_offline()
	set category = "Admin"
	set name = "Legacy Ban Offline"

	if(!check_rights(R_BAN))
		return

	if(!CONFIG_GET(flag/ban_legacy_system))
		return

	var/key = input("Please input a key:", "Ban") as null|text
	if(!key)
		return

	key = ckey(key)
	var/datum/admins/A = usr.client.holder

	if(key in GLOB.directory)
		to_chat(usr, "<span class='warning'>This player is currently present, please ban them through the player panel.")
		return

	A.Topic("bankey", list("bankey" = key, "admin_token" = RawHrefToken(), "_src_" = A))


/datum/admins/proc/mob_jobban_panel(var/mob/M)
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
	jobs += "<tr align='center' bgcolor='ccccff'><th colspan='[length(JOBS_COMMAND)]'><a href='?src=[ref];jobban=commanddept;mob=[REF(M)]'>Command Positions</a></th></tr><tr align='center'>"
	for(var/jobPos in JOBS_COMMAND)
		if(!jobPos)
			continue
		var/datum/job/job = SSjob.name_occupations[jobPos]
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
	jobs += "<tr align='center' bgcolor='ffbab7'><th colspan='[length(JOBS_POLICE)]'><a href='?src=[ref];jobban=policedept;mob=[REF(M)]'>Police Positions</a></th></tr><tr align='center'>"
	for(var/jobPos in JOBS_POLICE)
		if(!jobPos)
			continue
		var/datum/job/job = SSjob.name_occupations[jobPos]
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
	jobs += "<tr bgcolor='fff5cc'><th colspan='[length(JOBS_ENGINEERING)]'><a href='?src=[ref];jobban=engineeringdept;mob=[REF(M)]'>Engineering Positions</a></th></tr><tr align='center'>"
	for(var/jobPos in JOBS_ENGINEERING)
		if(!jobPos)
			continue
		var/datum/job/job = SSjob.name_occupations[jobPos]

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
	jobs += "<tr bgcolor='fff5cc'><th colspan='[length(JOBS_REQUISITIONS)]'><a href='?src=[ref];jobban=cargodept;mob=[REF(M)]'>Requisition Positions</a></th></tr><tr align='center'>"
	for(var/jobPos in JOBS_REQUISITIONS)
		if(!jobPos)
			continue
		var/datum/job/job = SSjob.name_occupations[jobPos]
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
	jobs += "<tr bgcolor='ffeef0'><th colspan='[length(JOBS_MEDICAL)]'><a href='?src=[ref];jobban=medicaldept;mob=[REF(M)]'>Medical Positions</a></th></tr><tr align='center'>"
	for(var/jobPos in JOBS_MEDICAL)
		if(!jobPos)
			continue
		var/datum/job/job = SSjob.name_occupations[jobPos]
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
	jobs += "<tr bgcolor='fff5cc'><th colspan='[length(JOBS_MARINES)]'><a href='?src=[ref];jobban=marinedept;mob=[REF(M)]'>Marine Positions</a></th></tr><tr align='center'>"
	for(var/jobPos in JOBS_MARINES)
		if(!jobPos)
			continue
		var/datum/job/job = SSjob.name_occupations[jobPos]
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

	jobs += "</tr></table>"

	body = "<body>[jobs]</body>"
	dat = "<tt>[header][body]</tt>"
	usr << browse(dat, "window=jobban;size=800x490")


/datum/admins/proc/legacy_jobban_offline()
	set category = "Admin"
	set name = "Legacy Jobban Offline"

	if(!check_rights(R_BAN))
		return

	if(!SSjob)
		return

	if(!CONFIG_GET(flag/ban_legacy_system))
		return

	var/key = input("Please input a key:", "Jobban") as null|text
	if(!key)
		return

	key = ckey(key)

	if(key in GLOB.directory)
		to_chat(usr, "<span class='warning'>This player is currently present, please jobban them through the player panel.")
		return

	var/ref = "[REF(usr.client.holder)];[HrefToken()]"
	var/dat = ""
	var/header = "<head><title>Job-Ban Panel: [key]</title></head>"
	var/body
	var/jobs = ""

	var/counter = 0

//Command (Blue)
	jobs += "<table cellpadding='1' cellspacing='0' width='100%'>"
	jobs += "<tr align='center' bgcolor='ccccff'><th colspan='[length(JOBS_COMMAND)]'><a href='?src=[ref];jobbankey=commanddept;key=[key]'>Command Positions</a></th></tr><tr align='center'>"
	for(var/jobPos in JOBS_COMMAND)
		if(!jobPos)
			continue
		var/datum/job/job = SSjob.name_occupations[jobPos]
		if(!job)
			continue

		if(jobban_key_isbanned(key, job.title))
			jobs += "<td width='20%'><a href='?src=[ref];jobbankey=[job.title];key=[key]'><font color=red>[oldreplacetext(job.title, " ", "&nbsp")]</font></a></td>"
			counter++
		else
			jobs += "<td width='20%'><a href='?src=[ref];jobbankey=[job.title];key=[key]'>[oldreplacetext(job.title, " ", "&nbsp")]</a></td>"
			counter++

		if(counter >= 6)
			jobs += "</tr><tr>"
			counter = 0
	jobs += "</tr></table>"


//Police (Red)
	jobs += "<table cellpadding='1' cellspacing='0' width='100%'>"
	jobs += "<tr align='center' bgcolor='ffbab7'><th colspan='[length(JOBS_POLICE)]'><a href='?src=[ref];jobbankey=policedept;key=[key]'>Police Positions</a></th></tr><tr align='center'>"
	for(var/jobPos in JOBS_POLICE)
		if(!jobPos)
			continue
		var/datum/job/job = SSjob.name_occupations[jobPos]
		if(!job)
			continue

		if(jobban_key_isbanned(key, job.title))
			jobs += "<td width='20%'><a href='?src=[ref];jobbankey=[job.title];key=[key]'><font color=red>[oldreplacetext(job.title, " ", "&nbsp")]</font></a></td>"
			counter++
		else
			jobs += "<td width='20%'><a href='?src=[ref];jobbankey=[job.title];key=[key]'>[oldreplacetext(job.title, " ", "&nbsp")]</a></td>"
			counter++

		if(counter >= 6)
			jobs += "</tr><tr>"
			counter = 0
	jobs += "</tr></table>"


//Engineering (Yellow)
	counter = 0
	jobs += "<table cellpadding='1' cellspacing='0' width='100%'>"
	jobs += "<tr bgcolor='fff5cc'><th colspan='[length(JOBS_ENGINEERING)]'><a href='?src=[ref];jobbankey=engineeringdept;key=[key]'>Engineering Positions</a></th></tr><tr align='center'>"
	for(var/jobPos in JOBS_ENGINEERING)
		if(!jobPos)
			continue
		var/datum/job/job = SSjob.name_occupations[jobPos]

		if(!job)
			continue

		if(jobban_key_isbanned(key, job.title))
			jobs += "<td width='20%'><a href='?src=[ref];jobbankey=[job.title];key=[key]'><font color=red>[oldreplacetext(job.title, " ", "&nbsp")]</font></a></td>"
			counter++
		else
			jobs += "<td width='20%'><a href='?src=[ref];jobbankey=[job.title];key=[key]'>[oldreplacetext(job.title, " ", "&nbsp")]</a></td>"
			counter++

		if(counter >= 6)
			jobs += "</tr><tr align='center'>"
			counter = 0
	jobs += "</tr></table>"

//Cargo (Yellow)
	counter = 0
	jobs += "<table cellpadding='1' cellspacing='0' width='100%'>"
	jobs += "<tr bgcolor='fff5cc'><th colspan='[length(JOBS_REQUISITIONS)]'><a href='?src=[ref];jobbankey=cargodept;key=[key]'>Requisition Positions</a></th></tr><tr align='center'>"
	for(var/jobPos in JOBS_REQUISITIONS)
		if(!jobPos)
			continue
		var/datum/job/job = SSjob.name_occupations[jobPos]
		if(!job)
			continue

		if(jobban_key_isbanned(key, job.title))
			jobs += "<td width='20%'><a href='?src=[ref];jobbankey=[job.title];key=[key]'><font color=red>[oldreplacetext(job.title, " ", "&nbsp")]</font></a></td>"
			counter++
		else
			jobs += "<td width='20%'><a href='?src=[ref];jobbankey=[job.title];key=[key]'>[oldreplacetext(job.title, " ", "&nbsp")]</a></td>"
			counter++

		if(counter >= 6)
			jobs += "</tr><tr align='center'>"
			counter = 0
	jobs += "</tr></table>"

//Medical (White)
	counter = 0
	jobs += "<table cellpadding='1' cellspacing='0' width='100%'>"
	jobs += "<tr bgcolor='ffeef0'><th colspan='[length(JOBS_MEDICAL)]'><a href='?src=[ref];jobbankey=medicaldept;key=[key]'>Medical Positions</a></th></tr><tr align='center'>"
	for(var/jobPos in JOBS_MEDICAL)
		if(!jobPos)
			continue
		var/datum/job/job = SSjob.name_occupations[jobPos]
		if(!job)
			continue

		if(jobban_key_isbanned(key, job.title))
			jobs += "<td width='20%'><a href='?src=[ref];jobbankey=[job.title];key=[key]'><font color=red>[oldreplacetext(job.title, " ", "&nbsp")]</font></a></td>"
			counter++
		else
			jobs += "<td width='20%'><a href='?src=[ref];jobbankey=[job.title];key=[key]'>[oldreplacetext(job.title, " ", "&nbsp")]</a></td>"
			counter++

		if(counter >= 6)
			jobs += "</tr><tr align='center'>"
			counter = 0
	jobs += "</tr></table>"

//Marines
	counter = 0
	jobs += "<table cellpadding='1' cellspacing='0' width='100%'>"
	jobs += "<tr bgcolor='fff5cc'><th colspan='[length(JOBS_MARINES)]'><a href='?src=[ref];jobbankey=marinedept;key=[key]'>Marine Positions</a></th></tr><tr align='center'>"
	for(var/jobPos in JOBS_MARINES)
		if(!jobPos)
			continue
		var/datum/job/job = SSjob.name_occupations[jobPos]
		if(!job)
			continue

		if(jobban_key_isbanned(key, job.title))
			jobs += "<td width='20%'><a href='?src=[ref];jobbankey=[job.title];key=[key]'><font color=red>[oldreplacetext(job.title, " ", "&nbsp")]</font></a></td>"
			counter++
		else
			jobs += "<td width='20%'><a href='?src=[ref];jobbankey=[job.title];key=[key]'>[oldreplacetext(job.title, " ", "&nbsp")]</a></td>"
			counter++

		if(counter >= 6)
			jobs += "</tr><tr align='center'>"
			counter = 0
	jobs += "</tr></table>"

//Antagonist (Orange)
	var/isbanned_dept = jobban_key_isbanned(key, "Syndicate")
	jobs += "<table cellpadding='1' cellspacing='0' width='100%'>"
	jobs += "<tr bgcolor='ffeeaa'><th colspan='10'><a href='?src=[ref];jobbankey=Syndicate;key=[key]'>Misc Positions</a></th></tr><tr align='center'>"

	//ERT
	if(jobban_key_isbanned(key, "Emergency Response Team") || isbanned_dept)
		jobs += "<td width='20%'><a href='?src=[ref];jobbankey=Emergency Response Team;key=[key]'><font color=red>Emergency Response Team</font></a></td>"
	else
		jobs += "<td width='20%'><a href='?src=[ref];jobbankey=Emergency Response Team;key=[key]'>Emergency Response Team</a></td>"

	//Xenos
	if(jobban_key_isbanned(key, "Alien") || isbanned_dept)
		jobs += "<td width='20%'><a href='?src=[ref];jobbankey=Alien;key=[key]'><font color=red>Alien</font></a></td>"
	else
		jobs += "<td width='20%'><a href='?src=[ref];jobbankey=Alien;key=[key]'>Alien</a></td>"

	//Queen
	if(jobban_key_isbanned(key, "Queen") || isbanned_dept)
		jobs += "<td width='20%'><a href='?src=[ref];jobbankey=Queen;key=[key]'><font color=red>Queen</font></a></td>"
	else
		jobs += "<td width='20%'><a href='?src=[ref];jobbankey=Queen;key=[key]'>Queen</a></td>"

	jobs += "</tr><tr align='center'>"

	//Survivor
	if(jobban_key_isbanned(key, "Survivor") || isbanned_dept)
		jobs += "<td width='20%'><a href='?src=[ref];jobbankey=Survivor;key=[key]'><font color=red>Survivor</font></a></td>"
	else
		jobs += "<td width='20%'><a href='?src=[ref];jobbankey=Survivor;key=[key]'>Survivor</a></td>"

	//Synthetic
	if(jobban_key_isbanned(key, "Synthetic") || isbanned_dept)
		jobs += "<td width='20%'><a href='?src=[ref];jobbankey=Synthetic;key=[key]'><font color=red>Synthetic</font></a></td>"
	else
		jobs += "<td width='20%'><a href='?src=[ref];jobbankey=Synthetic;key=[key]'>Synthetic</a></td>"

	jobs += "</tr></table>"

	body = "<body>[jobs]</body>"
	dat = "<tt>[header][body]</tt>"
	usr << browse(dat, "window=jobban;size=800x490")


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


/proc/LoadBans()
	if(!CONFIG_GET(flag/ban_legacy_system))
		return TRUE

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


/proc/jobban_key_fullban(key, rank, reason)
	if(!key)
		return
	rank = check_jobban_path(rank)
	jobban_keylist[rank][key] = reason


/proc/jobban_client_fullban(ckey, rank)
	if(!ckey || !rank)
		return
	rank = check_jobban_path(rank)
	jobban_keylist[rank][ckey] = "Reason Unspecified"


//returns a reason if M is banned from rank, returns 0 otherwise
/proc/jobban_isbanned(mob/M, rank)
	if(!CONFIG_GET(flag/ban_legacy_system))
		return FALSE

	if(M && rank)
		rank = check_jobban_path(rank)
		if(guest_jobbans(rank))
			if(CONFIG_GET(flag/guest_jobban) && IsGuestKey(M.key))
				return "Guest Job-ban"
		return jobban_keylist[rank][M.ckey]


/proc/jobban_key_isbanned(key, rank)
	if(!CONFIG_GET(flag/ban_legacy_system))
		return FALSE

	if(key && rank)
		rank = check_jobban_path(rank)
		if(guest_jobbans(rank))
			if(CONFIG_GET(flag/guest_jobban) && IsGuestKey(key))
				return "Guest Job-ban"
		return jobban_keylist[rank][key]


/proc/jobban_loadbanfile()
	if(!CONFIG_GET(flag/ban_legacy_system))
		return TRUE

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


/proc/jobban_key_unban(key, rank)
	jobban_remove("[key] - [ckey(rank)]")


/proc/jobban_remove(X)
	var/regex/r1 = new("(.*) - (.*)")
	if(r1.Find(X))
		var/L[] = jobban_keylist[r1.group[2]]
		L.Remove(r1.group[1])
		return TRUE


/datum/admins/proc/legacy_player_notes_show(var/key as text)
	set category = "Admin"
	set name = "Legacy Player Notes Show"

	if(!check_rights(R_BAN))
		return

	if(!CONFIG_GET(flag/ban_legacy_system))
		return

	var/ref = "[REF(usr.client.holder)];[HrefToken()]"
	var/dat = "<html><head><title>Info on [key]</title></head>"
	dat += "<body>"

	key = ckey(key)

	var/savefile/info = new("data/player_saves/[copytext(key, 1, 2)]/[key]/info.sav")
	var/list/infos
	info >> infos
	if(!infos)
		dat += "No information found on the given key.<br>"
	else
		var/update_file = 0
		var/i = 0
		for(var/datum/player_info/I in infos)
			i += 1
			if(!I.timestamp)
				I.timestamp = "Pre-4/3/2012"
				update_file = 1
			if(!I.rank)
				I.rank = "N/A"
				update_file = 1
			dat += "<font color=#008800>[I.content]</font> <i>by [I.author] ([I.rank])</i> on <i><font color=blue>[I.timestamp]</i></font> "
			var/bot = CONFIG_GET(string/server_name) ? "[CONFIG_GET(string/server_name)] Bot" : "Adminbot"
			if(I.author == usr.key || I.author == bot || check_rights(R_PERMISSIONS))
				dat += "<A href='?src=[ref];notes_remove=[key];remove_index=[i]'>Remove</A> "
				dat += "<A href='?src=[ref];notes_edit=[key];edit_index=[i]'>Edit</A> "
			if(I.hidden)
				dat += "<A href='?src=[ref];notes_unhide=[key];unhide_index=[i]'>Unhide</A>"
			else
				dat += "<A href='?src=[ref];notes_hide=[key];hide_index=[i]'>Hide</A>"
			dat += "<br><br>"
		if(update_file) to_chat(info, infos)

	dat += "<br>"
	dat += "<A href='?src=[ref];notes_add=[key]'>Add Comment</A><br>"
	dat += "<A href='?src=[ref];notes_copy=[key]'>Copy Player Notes</A><br>"

	dat += "</body></html>"
	usr << browse(dat, "window=adminplayerinfo;size=480x480")


/datum/admins/proc/legacy_player_notes_copy(var/key as text)
	set category = null
	set name = "Legacy Player Notes Copy"

	if(!check_rights(R_BAN))
		return

	if(!CONFIG_GET(flag/ban_legacy_system))
		return

	var/dat = "<html><head><title>Copying notes for [key]</title></head>"
	dat += "<body>"
	var/savefile/info = new("data/player_saves/[copytext(key, 1, 2)]/[key]/info.sav")
	var/list/infos
	info >> infos
	if(!infos)
		dat += "No information found on the given key.<br>"
	else
		var/i = 0
		for(var/datum/player_info/I in infos)
			i += 1
			if(!I.timestamp)
				I.timestamp = "Pre-4/3/2012"
			if(I.hidden)
				continue
			dat += "<font color=#008800>[I.content]</font> | <i><font color=blue>[I.timestamp]</i></font>"
			dat += "<br><br>"
	dat += "</body></html>"
	// Using regex to remove the note author for bans done in admin/topic.dm
	var/regex/remove_author = new("(?=Banned by).*?(?=\\|)", "g")
	dat = remove_author.Replace(dat, "Banned ")

	usr << browse(dat, "window=notescopy;size=480x480")


/datum/admins/proc/legacy_player_notes_list()
	set category = "Admin"
	set name = "Legacy Player Notes List"

	if(!check_rights(R_BAN))
		return

	if(!CONFIG_GET(flag/ban_legacy_system))
		return

	usr.client.holder.legacy_player_notes_page(1)


/proc/notes_add(var/key, var/note, var/mob/usr)
	if(!check_rights(R_BAN))
		return

	if(!key || !note)
		return

	key = ckey(key)

	//Loading list of notes for this key
	var/savefile/info = new("data/player_saves/[copytext(key, 1, 2)]/[key]/info.sav")
	var/list/infos
	info >> infos
	if(!infos) infos = list()

	//Overly complex timestamp creation
	var/modifyer = "th"
	switch(time2text(world.timeofday, "DD"))
		if("01","21","31")
			modifyer = "st"
		if("02","22",)
			modifyer = "nd"
		if("03","23")
			modifyer = "rd"
	var/day_string = "[time2text(world.timeofday, "DD")][modifyer]"
	if(copytext(day_string, 1, 2) == "0")
		day_string = copytext(day_string,2)
	var/full_date = time2text(world.timeofday, "Day, Month DD of YYYY")
	var/day_loc = findtext(full_date, time2text(world.timeofday, "DD"))
	var/hourminute_string = time2text(world.timeofday, "hh:mm")

	var/datum/player_info/P = new
	if(usr)
		P.author = usr.key
		P.rank = usr.client.holder.rank
	else
		P.author = CONFIG_GET(string/server_name) ? "[CONFIG_GET(string/server_name)] Bot" : "Adminbot"
		P.rank = "Silicon"
	P.content = note
	P.timestamp = "[hourminute_string] [copytext(full_date, 1, day_loc)][day_string][copytext(full_date, day_loc + 2)]"
	P.hidden = FALSE

	infos += P
	to_chat(info, infos)

	log_admin_private("[key_name(usr)] has edited [key]'s notes: [note]")
	message_admins("[ADMIN_TPMONTY(usr)] has edited [key]'s notes: [note]")

	qdel(info)

	//Updating list of keys with notes on them
	var/savefile/note_list = new("data/player_notes.sav")
	var/list/note_keys
	note_list >> note_keys
	if(!note_keys)
		note_keys = list()
	if(!note_keys.Find(key))
		note_keys += key
	to_chat(note_list, note_keys)
	qdel(note_list)


/proc/notes_del(var/key, var/index)
	if(!check_rights(R_BAN))
		return

	key = ckey(key)
	var/savefile/info = new("data/player_saves/[copytext(key, 1, 2)]/[key]/info.sav")
	var/list/infos
	info >> infos
	if(!infos || length(infos) < index)
		return

	var/datum/player_info/item = infos[index]
	infos.Remove(item)

	to_chat(info, infos)
	qdel(info)

	log_admin_private("[key_name(usr)] has deleted [key]'s note: [item.content]")
	message_admins("[ADMIN_TPMONTY(usr)] has deleted [key]'s note: [item.content]")


/proc/notes_hide(var/key, var/index)
	if(!check_rights(R_BAN))
		return

	key = ckey(key)
	var/savefile/info = new("data/player_saves/[copytext(key, 1, 2)]/[key]/info.sav")
	var/list/infos
	info >> infos
	if(!infos || length(infos) < index)
		return

	var/datum/player_info/item = infos[index]
	item.hidden = TRUE

	to_chat(info, infos)
	qdel(info)

	log_admin_private("[key_name(usr)] has hidden [key]'s note: [item.content]")
	message_admins("[ADMIN_TPMONTY(usr)] has hidden [key]'s note: [item.content]")


/proc/notes_unhide(var/key, var/index)
	if(!check_rights(R_BAN))
		return

	key = ckey(key)
	var/savefile/info = new("data/player_saves/[copytext(key, 1, 2)]/[key]/info.sav")
	var/list/infos
	info >> infos
	if(!infos || length(infos) < index)
		return

	var/datum/player_info/item = infos[index]
	item.hidden = FALSE

	to_chat(info, infos)
	qdel(info)

	log_admin_private("[key_name(usr)] has made visible [key]'s note: [item.content]")
	message_admins("[ADMIN_TPMONTY(usr)] has made visible [key]'s note: [item.content]")


/proc/notes_edit(var/key, var/index)
	if(!check_rights(R_BAN))
		return

	key = ckey(key)
	var/savefile/info = new("data/player_saves/[copytext(key, 1, 2)]/[key]/info.sav")
	var/list/infos
	info >> infos
	if(!infos || length(infos) < index)
		return

	var/datum/player_info/item = infos[index]

	var/note = input(usr, "What do you want the note to say?", "Edit Note", item.content) as message|null
	if(!note)
		return

	item.content = note

	to_chat(info, infos)
	qdel(info)

	log_admin_private("[key_name(usr)] has edited [key]'s note: [note]")
	message_admins("[ADMIN_TPMONTY(usr)] has edited [key]'s note: [note]")



/datum/player_info/var/author // admin who authored the information
/datum/player_info/var/rank //rank of admin who made the notes
/datum/player_info/var/content // text content of the information
/datum/player_info/var/timestamp // Because this is bloody annoying
/datum/player_info/var/hidden


#define PLAYER_NOTES_ENTRIES_PER_PAGE 50


/datum/admins/proc/legacy_player_notes_page(page)
	if(!check_rights(R_BAN))
		return

	if(!CONFIG_GET(flag/ban_legacy_system))
		return

	var/ref = "[REF(usr.client.holder)];[HrefToken()]"
	var/dat = "<B>Player notes</B><HR>"
	var/savefile/S = new("data/player_notes.sav")
	var/list/note_keys
	S >> note_keys
	if(!note_keys)
		dat += "No notes found."
	else
		dat += "<table>"
		note_keys = sortList(note_keys)

		// Display the notes on the current page
		var/number_pages = length(note_keys) / PLAYER_NOTES_ENTRIES_PER_PAGE
		// Emulate ceil(why does BYOND not have ceil)
		if(number_pages != round(number_pages))
			number_pages = round(number_pages) + 1
		var/page_index = page - 1
		if(page_index < 0 || page_index >= number_pages)
			return

		var/lower_bound = page_index * PLAYER_NOTES_ENTRIES_PER_PAGE + 1
		var/upper_bound = (page_index + 1) * PLAYER_NOTES_ENTRIES_PER_PAGE
		upper_bound = min(upper_bound, length(note_keys))
		for(var/index = lower_bound, index <= upper_bound, index++)
			var/t = note_keys[index]
			dat += "<tr><td><a href='?src=[ref];notes=show;ckey=[t]'>[t]</a></td></tr>"

		dat += "</table><br>"

		// Display a footer to select different pages
		for(var/index = 1, index <= number_pages, index++)
			if(index == page)
				dat += "<b>"
			dat += "<a href='?src=[ref];notes=list;index=[index]'>[index]</a> "
			if(index == page)
				dat += "</b>"

	usr << browse(dat, "window=player_notes;size=400x400")


/datum/admins/proc/legacy_player_has_info(var/key as text)
	if(!check_rights(R_BAN))
		return

	if(!CONFIG_GET(flag/ban_legacy_system))
		return

	var/savefile/info = new("data/player_saves/[copytext(key, 1, 2)]/[key]/info.sav")
	var/list/infos
	info >> infos
	if(!length(infos))
		return FALSE
	else
		return TRUE


/datum/admins/proc/legacy_transfer_job_bans()
	set category = "Debug"
	set name = "Legacy Transfer Job Bans"

	if(!check_rights(R_BAN) || !check_rights(R_DEBUG) || !SSjob)
		return

	if(!CONFIG_GET(flag/ban_legacy_system))
		return

	var/choice = alert("What would you like to do?", "Legacy job ban management", "Check all job bans", "Transfer one ban type", "Cancel")
	switch(choice)

		if("Check all job bans")
			var/dat = ""
			for(var/R in jobban_keylist)
				for(var/K in jobban_keylist[R])
					var/reason = jobban_key_isbanned(K, R)
					if(!reason)
						continue
					dat += "<tr><td>Key: <B>[K]</B></td><td>Rank: <B>[R]</B></td><td>Reason: <B>[jobban_keylist[R][K]]</B></td></tr>"
			dat += "</table>"
			var/dat_header = "<HR><B>Job Bans:</B>"
			dat_header += "</FONT><HR><table border=1 rules=all frame=void cellspacing=0 cellpadding=3 >[dat]"
			usr << browse(dat_header, "window=unbanp;size=875x400")

		if("Transfer one ban type")
			var/old_job = input(usr, "Type old job to be renamed", "Old job:") as null|text
			if(!old_job)
				to_chat(usr, "<span class='warning'>Error: No old job to replace.</span>")
				return
			if(!(old_job in jobban_keylist))
				to_chat(usr, "<span class='warning'>Error: Selected job has no entries within the legacy job ban database. Consult the existing job bans and try again.</span>")
				return
			var/new_job = input(usr, "Type new job to substitute with", "New job:") as null|text
			if(!new_job)
				to_chat(usr, "<span class='warning'>Error: No new job to replace with.</span>")
				return
			var/counter = 0
			for(var/key in jobban_keylist[old_job])
				var/reason = jobban_key_isbanned(key, old_job)
				if(!reason)
					continue
				jobban_key_unban(key, old_job)
				jobban_key_fullban(key, new_job, reason)
				counter++
			jobban_savebanfile()
			to_chat(usr, "<span class='warning'>[counter] job bans transferred successfully.</span>")
		else
			return


/mob/verb/view_notes()
	set name = "View Notes"
	set category = "OOC"
	set hidden = TRUE

	var/key = usr.key

	var/dat = "<html><head><title>Info on [key]</title></head>"
	dat += "<body>"

	key = ckey(key)

	var/savefile/info = new("data/player_saves/[copytext(key, 1, 2)]/[key]/info.sav")
	var/list/infos
	info >> infos
	if(!infos)
		dat += "No information found on the given key.<br>"
	else
		var/update_file = 0
		var/i = 0
		for(var/datum/player_info/I in infos)
			i += 1
			if(!I.timestamp)
				I.timestamp = "Pre-4/3/2012"
				update_file = 1
			if(!I.rank)
				I.rank = "N/A"
				update_file = 1
			if(!(I.hidden))
				dat += "<font color=#008800>[I.content]</font> <i>by [I.author] ([I.rank])</i> on <i><font color=blue>[I.timestamp]</i></font> "
				dat += "<br><br>"
		if(update_file) to_chat(info, infos)

	dat += "</body></html>"
	usr << browse(dat, "window=adminplayerinfo;size=480x480")


/datum/admins/proc/LegacyTopic(href, href_list)
	if(usr.client != src.owner || !check_rights(NONE))
		log_admin("[key_name(usr)] tried to use the admin panel without authorization.")
		message_admins("[ADMIN_TPMONTY(usr)] tried to use the admin panel without authorization.")
		return

	if(!CheckAdminHref(href, href_list))
		return


	if(href_list["unban"])
		if(!check_rights(R_BAN))
			return

		var/banfolder = href_list["unban"]
		Banlist.cd = "/base/[banfolder]"
		var/key = Banlist["key"]
		if(alert(usr, "Are you sure you want to unban [key]?", "Confirmation", "Yes", "No") != "Yes")
			return

		if(RemoveBan(banfolder))
			usr.client.holder.legacy_unban_panel()
			log_admin("[key_name(usr)] removed [key]'s permaban.")
			message_admins("[ADMIN_TPMONTY(usr)] removed [key]'s permaban.")
		else
			to_chat(usr, "<span class='warning'>Error, ban failed to be removed.</span>")
			usr.client.holder.legacy_unban_panel()


	else if(href_list["permaban"])
		if(!check_rights(R_BAN))
			return

		var/reason
		var/banfolder = href_list["permaban"]
		Banlist.cd = "/base/[banfolder]"
		var/reason2 = Banlist["reason"]

		var/minutes = Banlist["minutes"]

		var/banned_key = Banlist["key"]
		Banlist.cd = "/base"

		var/mins = 0
		if(minutes > ((world.realtime / 10) / 60))
			mins = minutes - ((world.realtime / 10) / 60)
		if(!mins)
			return
		mins = max(5255990,mins) // 10 years
		minutes = ((world.realtime / 10) / 60) + mins
		reason = input(usr, "Reason?", "reason", reason2) as message|null
		if(!reason)
			return

		Banlist.cd = "/base/[banfolder]"
		Banlist["reason"] << sanitize(reason)
		Banlist["temp"] << 0
		Banlist["minutes"] << minutes
		Banlist["bannedby"] << usr.ckey
		Banlist.cd = "/base"
		usr.client.holder.legacy_unban_panel()
		log_admin("[key_name(usr)] upgraded [banned_key]'s ban to a permaban. Reason: [sanitize(reason)]")
		message_admins("[ADMIN_TPMONTY(usr)] upgraded [banned_key]'s ban to a permaban. Reason: [sanitize(reason)]")


	else if(href_list["editban"])
		if(!check_rights(R_BAN))
			return

		var/reason

		var/banfolder = href_list["editban"]
		Banlist.cd = "/base/[banfolder]"
		var/reason2 = Banlist["reason"]
		var/temp = Banlist["temp"]

		var/minutes = Banlist["minutes"]

		var/banned_key = Banlist["key"]
		Banlist.cd = "/base"

		var/duration

		var/mins = 0
		if(minutes > ((world.realtime / 10) / 60))
			mins = minutes - ((world.realtime / 10) / 60)
		mins = input(usr, "How long (in minutes)? \n 1440 = 1 day \n 4320 = 3 days \n 10080 = 7 days", "Ban time", 1440) as num|null
		if(!mins)
			return
		mins = min(525599,mins)
		minutes = ((world.realtime / 10) / 60) + mins
		duration = GetExp(minutes)
		reason = input(usr,"Reason?","reason",reason2) as message|null
		if(!reason)
			return

		Banlist.cd = "/base/[banfolder]"
		Banlist["reason"] << sanitize(reason)
		Banlist["temp"] << temp
		Banlist["minutes"] << minutes
		Banlist["bannedby"] << usr.ckey
		Banlist.cd = "/base"
		usr.client.holder.legacy_unban_panel()

		log_admin("[key_name(usr)] edited [banned_key]'s ban. Reason: [sanitize(reason)] Duration: [duration]")
		message_admins("[ADMIN_TPMONTY(usr)] edited [banned_key]'s ban. Reason: [sanitize(reason)] Duration: [duration]")

	else if(href_list["ban"])
		if(!check_rights(R_BAN))
			return

		var/mob/M = locate(href_list["ban"])
		if(!ismob(M))
			return

		if(!M.ckey)
			return

		var/mob_key = M.ckey
		var/mob_id = M.computer_id
		var/mob_ip = M.lastKnownIP
		var/client/mob_client = M.client
		if(!check_if_greater_rights_than(mob_client))
			return
		var/mins = input("How long (in minutes)? \n 1440 = 1 day \n 4320 = 3 days \n 10080 = 7 days", "Ban time", 1440) as num|null
		if(!mins)
			return
		if(mins >= 525600) mins = 525599
		var/reason = input("Please enter the ban reason.", "Ban Reason", "") as message|null
		if(!reason)
			return
		if(alert("Are you sure you want to ban [key_name(M)] for [reason]?", "Confirmation", "Yes", "No") != "Yes")
			return
		AddBan(mob_key, mob_id, reason, usr.ckey, TRUE, mins, mob_ip)

		to_chat(M, "<span class='danger'>You have been banned by [usr.client.ckey].\nReason: [sanitize(reason)].</span>")
		to_chat(M, "<span class='warning'>This is a temporary ban, it will be removed in [mins] minutes.</span>")
		if(CONFIG_GET(string/banappeals))
			to_chat(M, "<span class='warning'>To try to resolve this matter head to [CONFIG_GET(string/banappeals)]</span>")
		if(mob_client)
			qdel(mob_client)

		log_admin_private("[key_name(usr)] has banned [key_name(M)] | Duration: [mins] minutes | Reason: [sanitize(reason)]")
		notes_add(mob_key, "Banned by [usr.client.holder.fakekey ? "an Administrator" : usr.client.ckey] | Duration: [mins] minutes | Reason: [sanitize(reason)]", usr)
		message_admins("[ADMIN_TPMONTY(usr)] has banned [ADMIN_TPMONTY(M)] | Duration: [mins] minutes| Reason: [sanitize(reason)]")


	else if(href_list["bankey"])
		if(!check_rights(R_BAN))
			return

		var/key = href_list["bankey"]
		if(!key)
			return

		var/mins
		var/reason

		switch(alert(usr, "Permanent or temporary?", "Ban Type", "Permanent", "Temporary", "Cancel"))
			if("Permanent")
				reason = input("Please enter the ban reason.", "Ban Reason") as message|null
				reason = sanitize(reason)
				if(!reason)
					return
				if(alert("Are you sure you want to permanently ban [key] for [reason]?", "Confirmation", "Yes", "No") != "Yes")
					return
				notes_add(key, "Banned by [usr.client.holder.fakekey ? "an Administrator" : usr.client.ckey] | Duration: Permanent | Reason: [reason]", usr)
				AddBan(key, null, reason, usr.ckey, FALSE, 525599, null)

				log_admin_private("[key_name(usr)] has banned [key] | Duration: Permanent | Reason: [reason]")
				message_admins("[ADMIN_TPMONTY(usr)] has banned [key] | Duration: Permanent | Reason: [reason]")
			if("Temporary")
				mins = input("How long (in minutes)? \n 1440 = 1 day \n 4320 = 3 days \n 10080 = 7 days", "Ban time", 1440) as num|null
				if(isnull(mins) || mins < 0)
					return
				if(mins >= 525600)
					mins = 525599
				reason = input("Please enter the ban reason.", "Ban Reason") as message|null
				reason = sanitize(reason)
				if(!reason)
					return
				if(alert("Are you sure you want to ban [key] for [reason] for [mins] minutes?", "Confirmation", "Yes", "No") != "Yes")
					return
				notes_add(key, "Banned by [usr.client.holder.fakekey ? "an Administrator" : usr.client.ckey] | Duration: [mins] minutes | Reason: [reason]", usr)
				AddBan(key, null, reason, usr.ckey, TRUE, mins, null)

				log_admin_private("[key_name(usr)] has banned [key] | Duration: [mins] minutes | Reason: [reason]")
				message_admins("[ADMIN_TPMONTY(usr)] has banned [key] | Duration: [mins] minutes | Reason: [reason]")


	else if(href_list["notes_add"])
		if(!check_rights(R_BAN))
			return

		var/key = href_list["notes_add"]
		var/add = input("Add Player Info") as null|message
		if(!add)
			return

		notes_add(key, add, usr)
		legacy_player_notes_show(key)


	else if(href_list["notes_remove"])
		if(!check_rights(R_BAN))
			return

		var/key = href_list["notes_remove"]
		var/index = text2num(href_list["remove_index"])

		notes_del(key, index)
		legacy_player_notes_show(key)


	else if(href_list["notes_hide"])
		if(!check_rights(R_BAN))
			return

		var/key = href_list["notes_hide"]
		var/index = text2num(href_list["hide_index"])

		notes_hide(key, index)
		legacy_player_notes_show(key)


	else if(href_list["notes_unhide"])
		if(!check_rights(R_BAN))
			return

		var/key = href_list["notes_unhide"]
		var/index = text2num(href_list["unhide_index"])

		notes_unhide(key, index)
		legacy_player_notes_show(key)


	else if(href_list["notes_edit"])
		if(!check_rights(R_BAN))
			return

		var/key = href_list["notes_edit"]
		var/index = text2num(href_list["edit_index"])
		notes_edit(key, index)


	else if(href_list["notes"])
		if(!check_rights(R_BAN))
			return

		var/ckey = href_list["ckey"]
		if(!ckey)
			var/mob/M = locate(href_list["mob"])
			if(ismob(M))
				ckey = M.ckey

		switch(href_list["notes"])
			if("show")
				legacy_player_notes_show(ckey)
			if("list")
				legacy_player_notes_page(text2num(href_list["index"]))


	else if(href_list["notes_copy"])
		if(!check_rights(R_BAN))
			return

		var/key = href_list["notes_copy"]
		legacy_player_notes_copy(key)


	else if(href_list["jobbanpanel"])
		if(!check_rights(R_BAN))
			return

		var/mob/M = locate(href_list["jobbanpanel"])
		if(!ismob(M))
			return

		mob_jobban_panel(M)


	else if(href_list["jobban"])
		if(!check_rights(R_BAN))
			return

		var/mob/M = locate(href_list["mob"])
		if(!ismob(M))
			return

		if(!check_if_greater_rights_than(M.client))
			return

		if(!M.ckey)
			return

		if(!SSjob)
			return

		var/list/joblist = list()
		switch(href_list["jobban"])
			if("commanddept")
				for(var/jobPos in JOBS_COMMAND)
					if(!jobPos)
						continue
					var/datum/job/temp = SSjob.name_occupations[jobPos]
					if(!temp)
						continue
					joblist += temp.title
			if("policedept")
				for(var/jobPos in JOBS_POLICE)
					if(!jobPos)
						continue
					var/datum/job/temp = SSjob.name_occupations[jobPos]
					if(!temp)
						continue
					joblist += temp.title
			if("engineeringdept")
				for(var/jobPos in JOBS_ENGINEERING)
					if(!jobPos)
						continue
					var/datum/job/temp = SSjob.name_occupations[jobPos]
					if(!temp)
						continue
					joblist += temp.title
			if("cargodept")
				for(var/jobPos in JOBS_REQUISITIONS)
					if(!jobPos)
						continue
					var/datum/job/temp = SSjob.name_occupations[jobPos]
					if(!temp)
						continue
					joblist += temp.title
			if("medicaldept")
				for(var/jobPos in JOBS_MEDICAL)
					if(!jobPos)
						continue
					var/datum/job/temp = SSjob.name_occupations[jobPos]
					if(!temp)
						continue
					joblist += temp.title
			if("marinedept")
				for(var/jobPos in JOBS_MARINES)
					if(!jobPos)
						continue
					var/datum/job/temp = SSjob.name_occupations[jobPos]
					if(!temp)
						continue
					joblist += temp.title
			else
				joblist += href_list["jobban"]

		//Create a list of unbanned jobs within joblist
		var/list/notbannedlist = list()
		for(var/job in joblist)
			if(!jobban_isbanned(M, job))
				notbannedlist += job

		if(length(notbannedlist))
			var/reason = input("Please state the reason for the jobban.", "Reason", "") as text|null
			if(reason)
				var/msg
				for(var/job in notbannedlist)
					log_admin_private("[key_name(usr)] jobbanned [key_name(M)] from [job].")
					jobban_fullban(M, job, "[reason]; By [usr.client.ckey] on [time2text(world.realtime)]")
					if(!msg)
						msg = job
					else
						msg += ", [job]"
				notes_add(M.ckey, "Banned  from [msg] - [reason]", usr)
				message_admins("[ADMIN_TPMONTY(usr)] banned [ADMIN_TPMONTY(M)] from [msg].")
				to_chat(M, "<span class='danger'>You have been jobbanned by [usr.client.ckey] from: [msg].</span>")
				to_chat(M, "<span class='warning'>The reason is: [reason]</span>")
				jobban_savebanfile()
			return

		if(length(joblist))
			var/msg
			for(var/job in joblist)
				var/reason = jobban_isbanned(M, job)
				if(!reason)
					continue
				if(alert("Job: '[job]' Reason: '[reason]' Un-jobban?","Please Confirm","Yes","No") != "Yes")
					continue
				log_admin_private("[key_name(usr)] un-jobbanned [key_name(M)] from [job].")
				jobban_unban(M, job)
				if(!msg)
					msg = job
				else
					msg += ", [job]"
			if(msg)
				message_admins("[ADMIN_TPMONTY(usr)] un-jobbanned [ADMIN_TPMONTY(M)] from [msg].")
				to_chat(M, "<span class='danger'>You have been un-jobbanned by [usr.client.ckey] from [msg].</span>")
			jobban_savebanfile()


	else if(href_list["jobbankey"])
		if(!check_rights(R_BAN))
			return

		var/key = href_list["key"]
		if(!key)
			return

		if(!SSjob)
			return

		var/list/joblist = list()
		switch(href_list["jobbankey"])
			if("commanddept")
				for(var/jobPos in JOBS_COMMAND)
					if(!jobPos)
						continue
					var/datum/job/temp = SSjob.name_occupations[jobPos]
					if(!temp)
						continue
					joblist += temp.title
			if("policedept")
				for(var/jobPos in JOBS_POLICE)
					if(!jobPos)
						continue
					var/datum/job/temp = SSjob.name_occupations[jobPos]
					if(!temp)
						continue
					joblist += temp.title
			if("engineeringdept")
				for(var/jobPos in JOBS_ENGINEERING)
					if(!jobPos)
						continue
					var/datum/job/temp = SSjob.name_occupations[jobPos]
					if(!temp)
						continue
					joblist += temp.title
			if("cargodept")
				for(var/jobPos in JOBS_REQUISITIONS)
					if(!jobPos)
						continue
					var/datum/job/temp = SSjob.name_occupations[jobPos]
					if(!temp)
						continue
					joblist += temp.title
			if("medicaldept")
				for(var/jobPos in JOBS_MEDICAL)
					if(!jobPos)
						continue
					var/datum/job/temp = SSjob.name_occupations[jobPos]
					if(!temp)
						continue
					joblist += temp.title
			if("marinedept")
				for(var/jobPos in JOBS_MARINES)
					if(!jobPos)
						continue
					var/datum/job/temp = SSjob.name_occupations[jobPos]
					if(!temp)
						continue
					joblist += temp.title
			else
				joblist += href_list["jobbankey"]

		//Create a list of unbanned jobs within joblist
		var/list/notbannedlist = list()
		for(var/job in joblist)
			if(!jobban_key_isbanned(key, job))
				notbannedlist += job

		if(length(notbannedlist))
			var/reason = input("Please state the reason for the jobban.", "Reason", "") as text|null
			if(reason)
				var/msg
				for(var/job in notbannedlist)
					log_admin_private("[key_name(usr)] jobbanned [key] from [job].")
					jobban_key_fullban(key, job, "[reason]; By [usr.client.ckey] on [time2text(world.realtime)]")
					if(!msg)
						msg = job
					else
						msg += ", [job]"
				notes_add(key, "Banned  from [msg] - [reason]", usr)
				message_admins("[ADMIN_TPMONTY(usr)] banned [key] from [msg].")
				jobban_savebanfile()
			return

		if(length(joblist))
			var/msg
			for(var/job in joblist)
				var/reason = jobban_key_isbanned(key, job)
				if(!reason)
					continue
				if(alert("Job: '[job]' Reason: '[reason]' Un-jobban?","Please Confirm","Yes","No") != "Yes")
					continue
				log_admin_private("[key_name(usr)] un-jobbanned [key] from [job].")
				jobban_key_unban(key, job)
				if(!msg)
					msg = job
				else
					msg += ", [job]"
			if(msg)
				message_admins("[ADMIN_TPMONTY(usr)] un-jobbanned [key] from [msg].")
			jobban_savebanfile()


