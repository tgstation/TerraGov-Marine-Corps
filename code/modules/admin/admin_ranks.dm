var/list/admin_ranks = list()

/proc/load_admin_ranks()
	admin_ranks.Cut()

	var/previous_rights = 0

	var/list/Lines = file2list("config/admin_ranks.txt")

	//process each line seperately
	for(var/line in Lines)
		if(!length(line))
			continue
		if(copytext(line, 1, 2) == "#")
			continue

		var/list/List = text2list(line, "+")
		if(!List.len)
			continue

		var/rank = ckeyEx(List[1])
		switch(rank)
			if(null, "")
				continue
			if("Removed")
				continue

		var/rights = 0
		for(var/i = 2, i <= List.len, i++)
			switch(ckey(List[i]))
				if("@", "prev")					rights |= previous_rights
				if("asay", "adminsay")			rights |= R_ASAY
				if("admin")						rights |= R_ADMIN
				if("ban")						rights |= R_BAN
				if("fun")						rights |= R_FUN
				if("server")					rights |= R_SERVER
				if("debug")						rights |= R_DEBUG
				if("permissions", "rights")		rights |= R_PERMISSIONS
				if("color")						rights |= R_COLOR
				if("varedit")					rights |= R_VAREDIT
				if("sound", "sounds")			rights |= R_SOUND
				if("spawn", "create")			rights |= R_SPAWN
				if("mentor")					rights |= R_MENTOR
				if("everything", "host", "all")	rights |= R_EVERYTHING

		admin_ranks[rank] = rights
		previous_rights = rights


/hook/startup/proc/loadAdmins()
	load_admins()
	return TRUE


/proc/load_admins()
	admin_datums.Cut()

	for(var/client/C in admins)
		C.remove_admin_verbs()
		C.holder = null

	admins.Cut()

	//Clear profile access
	for(var/A in world.GetConfig("admin"))
		world.SetConfig("APP/admin", A, null)

	if(CONFIG_GET(flag/admin_legacy_system))
		load_admin_ranks()

		//load text from file
		var/list/Lines = file2list("config/admins.txt")

		//process each line seperately
		for(var/line in Lines)
			if(!length(line))
				continue
			if(copytext(line,1,2) == "#")
				continue

			//Split the line at every "-"
			var/list/List = text2list(line, "-")
			if(!List.len)
				continue

			//ckey is before the first "-"
			var/ckey = ckey(List[1])
			if(!ckey)						\
				continue

			//rank follows the first "-"
			var/rank = ""
			if(List.len >= 2)
				rank = ckeyEx(List[2])

			//load permissions associated with this rank
			var/rights = admin_ranks[rank]

			//create the admin datum and store it for later use
			var/datum/admins/D = new /datum/admins(rank, rights, ckey)

			//find the client for a ckey if they are connected and associate them with the new admin datum
			D.associate(directory[ckey])
		return
	else
		//The current admin system uses SQL
		establish_db_connection()
		if(!dbcon.IsConnected())
			stack_trace("Failed to connect to database in load_admins(). Reverting to legacy system.")
			log_sql("Failed to connect to database in load_admins(). Reverting to legacy system.")
			CONFIG_SET(flag/admin_legacy_system, TRUE)
			load_admins()

		var/DBQuery/query = dbcon.NewQuery("SELECT ckey, rank, level, flags FROM erro_admin")
		query.Execute()
		while(query.NextRow())
			var/ckey = query.item[1]
			var/rank = query.item[2]
			if(rank == "Removed")
				continue	//This person was de-adminned. They are only in the admin list for archive purposes.

			var/rights = query.item[4]
			if(istext(rights))	rights = text2num(rights)
			var/datum/admins/D = new /datum/admins(rank, rights, ckey)

			//find the client for a ckey if they are connected and associate them with the new admin datum
			D.associate(directory[ckey])

		if(!admin_datums)
			stack_trace("The database query in load_admins() resulted in no admins being added to the list. Reverting to legacy system.")
			log_sql("The database query in load_admins() resulted in no admins being added to the list. Reverting to legacy system.")
			CONFIG_SET(flag/admin_legacy_system, TRUE)
			load_admins()