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
	return 1

/proc/jobban_loadbanfile()
	if(CONFIG_GET(flag/ban_legacy_system))
		var/savefile/S=new("data/job_new.ban")
		S["new_bans"] >> jobban_keylist
		log_admin("Loading jobban_rank")
		S["runonce"] >> jobban_runonce

		if (!length(jobban_keylist))
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
