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

	//Predator
	if(jobban_isbanned(M, "Predator") || isbanned_dept)
		jobs += "<td width='20%'><a href='?src=[ref];jobban=Predator;mob=[REF(M)]'><font color=red>Predator</font></a></td>"
	else
		jobs += "<td width='20%'><a href='?src=[ref];jobban=Predator;mob=[REF(M)]'>Predator</a></td>"


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

	//Predator
	if(jobban_key_isbanned(key, "Predator") || isbanned_dept)
		jobs += "<td width='20%'><a href='?src=[ref];jobbankey=Predator;key=[key]'><font color=red>Predator</font></a></td>"
	else
		jobs += "<td width='20%'><a href='?src=[ref];jobbankey=Predator;key=[key]'>Predator</a></td>"


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


/hook/startup/proc/loadBans()
	if(!CONFIG_GET(flag/ban_legacy_system))
		return TRUE
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
			if(CONFIG_GET(flag/usewhitelist) && !check_whitelist(M))
				return "Whitelisted Job"
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


/hook/startup/proc/loadJobBans()
	if(!CONFIG_GET(flag/ban_legacy_system))
		return TRUE

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


/*
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
*/