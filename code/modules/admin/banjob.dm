/*
Rank is stripped down with ckey() in order to remove any capitals or spaces, so those do not matter.
If the system encounters a rank that it doesn't recognize, it will automatically add it to the list.
As such, ranks shouldn't really change to maintain consistency. You can see some older bans list
stuff like sulacochiefmedicalofficer, to where now they list it as chiefmedicalofficer. The system
won't recognize the older one, as an example.

//DEBUG
/mob/verb/list_all_jobbans()
	set name = "list all jobbans"
	set category = "DEBUG"

	for(var/s in jobban_keylist)
		to_chat(world, s)

/mob/verb/reload_jobbans()
	set name = "reload jobbans"
	set category = "DEBUG"

	jobban_loadbanfile()

/mob/verb/loadNewBans()
	set name = "Load New Bans"
	set desc = "Transfer the old jobban list to the new system and file"
	set category = "DEBUG"

	var/list/banned_jobs = list()

	var/savefile/S1 = new("data/job_full.ban")
	var/savefile/S2 = new("data/job_new.ban")
	var/regex/r1 = new("(.*) - (.*) ## (.*)")
	var/regex/r2 = new("(.*) - (.*)")
	var/ckey
	var/title
	var/reason
	var/L[] = new
	S1["keys[0]"] >> L

	for(var/s in L)
		ckey = ""
		title = ""
		reason = ""
		if(r1.Find(s))
			ckey = r1.group[1] //ckey already has ckey() applied.
			title = ckey(r1.group[2]) //Strip all capitals, spaces, etc from the title.
			reason = r1.group[3]
		else if(r2.Find(s))
			ckey = r2.group[1]
			title = r2.group[2]

		if(!banned_jobs.Find(title))
			banned_jobs[title] = list()
			to_chat(world, "New job found in list [title]")

		if(!reason) banned_jobs[title][ckey] = "Reason Unspecified"
		else banned_jobs[title][ckey] = reason

	S2["new_bans"] << banned_jobs
	jobban_savebanfile()
	jobban_loadbanfile()

*/

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
			if(config.guest_jobban && IsGuestKey(M.key))
				return "Guest Job-ban"
			if(config.usewhitelist && !check_whitelist(M))
				return "Whitelisted Job"
		return jobban_keylist[rank][M.ckey]

/hook/startup/proc/loadJobBans()
	jobban_loadbanfile()
	return 1

/proc/jobban_loadbanfile()
	if(config.ban_legacy_system)
		var/savefile/S=new("data/job_new.ban")
		S["new_bans"] >> jobban_keylist
		log_admin("Loading jobban_rank")
		S["runonce"] >> jobban_runonce

		if (!length(jobban_keylist))
			jobban_keylist=list()
			log_admin("jobban_keylist was empty")
	else
		if(!establish_db_connection())
			error("Database connection failed. Reverting to the legacy ban system.")
			log_misc("Database connection failed. Reverting to the legacy ban system.")
			config.ban_legacy_system = 1
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
