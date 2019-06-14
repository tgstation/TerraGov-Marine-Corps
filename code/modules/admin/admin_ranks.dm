/datum/admin_rank
	var/name = "NoRank"
	var/rights
	var/exclude_rights = NONE
	var/include_rights = NONE
	var/can_edit_rights = NONE


/datum/admin_rank/New(init_name, init_rights, init_exclude_rights, init_edit_rights)
	if(IsAdminAdvancedProcCall())
		log_admin("[key_name(usr)] has tried to elevate permissions!")
		message_admins("[ADMIN_TPMONTY(usr)] has tried to elevate permissions!")
		if(name == "NoRank") //only del if this is a true creation (and not just a New() proc call), other wise trialmins/coders could abuse this to deadmin other admins
			QDEL_IN(src, 0)
			CRASH("Admin proc call creation of admin datum")
		return
	name = init_name
	if(!name)
		qdel(src)
		throw EXCEPTION("Admin rank created without name.")
		return
	if(init_rights)
		rights = init_rights
	include_rights = rights
	if(init_exclude_rights)
		exclude_rights = init_exclude_rights
		rights &= ~exclude_rights
	if(init_edit_rights)
		can_edit_rights = init_edit_rights


/datum/admin_rank/Destroy()
	if(IsAdminAdvancedProcCall())
		log_admin("[key_name(usr)] has tried to elevate permissions!")
		message_admins("[ADMIN_TPMONTY(usr)] has tried to elevate permissions!")
		return QDEL_HINT_LETMELIVE
	return ..()


/datum/admin_rank/vv_edit_var(var_name, var_value)
	return FALSE


/datum/admin_rank/proc/process_keyword(group, group_count, datum/admin_rank/previous_rank)
	if(IsAdminAdvancedProcCall())
		log_admin("[key_name(usr)] has tried to elevate permissions!")
		message_admins("[ADMIN_TPMONTY(usr)] has tried to elevate permissions!")
		return
	var/list/keywords = splittext(group, " ")
	var/flag = 0
	for(var/k in keywords)
		switch(k)
			if("ADMIN")
				flag = R_ADMIN
			if("MENTOR")
				flag = R_MENTOR
			if("ASAY")
				flag = R_ASAY
			if("ADMINTICKET")
				flag = R_ADMINTICKET
			if("BAN")
				flag = R_BAN
			if("FUN")
				flag = R_FUN
			if("SERVER")
				flag = R_SERVER
			if("DEBUG")
				flag = R_DEBUG
			if("PERMISSIONS")
				flag = R_PERMISSIONS
			if("COLOR")
				flag = R_COLOR
			if("VAREDIT")
				flag = R_VAREDIT
			if("SOUND")
				flag = R_SOUND
			if("SPAWN")
				flag = R_SPAWN
			if("DBRANKS")
				flag = R_DBRANKS
			if("EVERYTHING")
				flag = R_EVERYTHING
			if("@")
				if(previous_rank)
					switch(group_count)
						if(1)
							flag = previous_rank.include_rights
						if(2)
							flag = previous_rank.exclude_rights
						if(3)
							flag = previous_rank.can_edit_rights
				else
					continue
		switch(group_count)
			if(1)
				rights |= flag
				include_rights	|= flag
			if(2)
				rights &= ~flag
				exclude_rights	|= flag
			if(3)
				can_edit_rights |= flag


/proc/sync_ranks_with_db()
	set waitfor = FALSE

	if(IsAdminAdvancedProcCall())
		log_admin("[key_name(usr)] has tried to elevate permissions!")
		message_admins("[ADMIN_TPMONTY(usr)] has tried to elevate permissions!")
		return

	var/list/sql_ranks = list()
	for(var/datum/admin_rank/R in GLOB.protected_ranks)
		var/sql_rank = sanitizeSQL(R.name)
		var/sql_flags = sanitizeSQL(R.include_rights)
		var/sql_exclude_flags = sanitizeSQL(R.exclude_rights)
		var/sql_can_edit_flags = sanitizeSQL(R.can_edit_rights)
		sql_ranks += list(list("rank" = "'[sql_rank]'", "flags" = "[sql_flags]", "exclude_flags" = "[sql_exclude_flags]", "can_edit_flags" = "[sql_can_edit_flags]"))
	SSdbcore.MassInsert(format_table_name("admin_ranks"), sql_ranks, duplicate_key = TRUE)


//load our rank - > rights associations
/proc/load_admin_ranks(dbfail, no_update)
	if(IsAdminAdvancedProcCall())
		log_admin("[key_name(usr)] has tried to elevate permissions!")
		message_admins("[ADMIN_TPMONTY(usr)] has tried to elevate permissions!")
		return
	GLOB.admin_ranks.Cut()
	GLOB.protected_ranks.Cut()
	//load text from file and process each entry
	var/ranks_text = file2text("config/admin_ranks.txt")
	var/datum/admin_rank/previous_rank
	var/regex/admin_ranks_regex = new(@"^Name\s*=\s*(.+?)\s*\n+Include\s*=\s*([\l @]*?)\s*\n+Exclude\s*=\s*([\l @]*?)\s*\n+Edit\s*=\s*([\l @]*?)\s*\n*$", "gm")
	while(admin_ranks_regex.Find(ranks_text))
		var/datum/admin_rank/R = new(admin_ranks_regex.group[1])
		if(!R)
			continue
		var/count = 1
		for(var/i in admin_ranks_regex.group - admin_ranks_regex.group[1])
			if(i)
				R.process_keyword(i, count, previous_rank)
			count++
		GLOB.admin_ranks += R
		GLOB.protected_ranks += R
		previous_rank = R
	if(!CONFIG_GET(flag/admin_legacy_system) || dbfail)
		if(CONFIG_GET(flag/load_legacy_ranks_only))
			if(!no_update)
				sync_ranks_with_db()
		else
			var/datum/DBQuery/query_load_admin_ranks = SSdbcore.NewQuery("SELECT rank, flags, exclude_flags, can_edit_flags FROM [format_table_name("admin_ranks")]")
			if(!query_load_admin_ranks.Execute())
				message_admins("Error loading admin ranks from database. Loading from backup.")
				log_sql("Error loading admin ranks from database. Loading from backup.")
				dbfail = TRUE
			else
				while(query_load_admin_ranks.NextRow())
					var/skip
					var/rank_name = query_load_admin_ranks.item[1]
					for(var/datum/admin_rank/R in GLOB.admin_ranks)
						if(R.name == rank_name) //this rank was already loaded from txt override
							skip = TRUE
							break
					if(!skip)
						var/rank_flags = text2num(query_load_admin_ranks.item[2])
						var/rank_exclude_flags = text2num(query_load_admin_ranks.item[3])
						var/rank_can_edit_flags = text2num(query_load_admin_ranks.item[4])
						var/datum/admin_rank/R = new(rank_name, rank_flags, rank_exclude_flags, rank_can_edit_flags)
						if(!R)
							continue
						GLOB.admin_ranks += R
			qdel(query_load_admin_ranks)
	//load ranks from backup file
	if(dbfail)
		var/backup_file = file2text("data/admins_backup.json")
		if(backup_file == null)
			log_world("Unable to locate admins backup file.")
			return FALSE
		var/list/json = json_decode(backup_file)
		for(var/J in json["ranks"])
			var/skip
			for(var/datum/admin_rank/R in GLOB.admin_ranks)
				if(R.name == "[J]") //this rank was already loaded from txt override
					skip = TRUE
			if(skip)
				continue
			var/datum/admin_rank/R = new("[J]", json["ranks"]["[J]"]["include rights"], json["ranks"]["[J]"]["exclude rights"], json["ranks"]["[J]"]["can edit rights"])
			if(!R)
				continue
			GLOB.admin_ranks += R
		return json


/proc/load_admins(no_update)
	var/dbfail
	if(!CONFIG_GET(flag/admin_legacy_system) && !SSdbcore.Connect())
		message_admins("Failed to connect to database while loading admins. Loading from backup.")
		log_sql("Failed to connect to database while loading admins. Loading from backup.")
		dbfail = TRUE
	//clear the datums references
	GLOB.admin_datums.Cut()
	for(var/client/C in GLOB.admins)
		C.remove_admin_verbs()
		C.holder = null
	GLOB.admins.Cut()
	GLOB.protected_admins.Cut()
	GLOB.deadmins.Cut()
	var/list/backup_file_json = load_admin_ranks(dbfail, no_update)
	dbfail = backup_file_json != null
	//Clear profile access
	for(var/A in world.GetConfig("admin"))
		world.SetConfig("APP/admin", A, null)
	var/list/rank_names = list()
	for(var/datum/admin_rank/R in GLOB.admin_ranks)
		rank_names[R.name] = R
	//ckeys listed in admins.txt are always made admins before sql loading is attempted
	var/admins_text = file2text("config/admins.txt")
	var/regex/admins_regex = new(@"^(?!#)(.+?)\s+=\s+(.+)", "gm")
	while(admins_regex.Find(admins_text))
		new /datum/admins(rank_names[admins_regex.group[2]], ckey(admins_regex.group[1]), TRUE)
	if(!CONFIG_GET(flag/admin_legacy_system) || dbfail)
		var/datum/DBQuery/query_load_admins = SSdbcore.NewQuery("SELECT ckey, rank FROM [format_table_name("admin")] ORDER BY rank")
		if(!query_load_admins.Execute())
			message_admins("Error loading admins from database. Loading from backup.")
			log_sql("Error loading admins from database. Loading from backup.")
			dbfail = TRUE
		else
			while(query_load_admins.NextRow())
				var/admin_ckey = ckey(query_load_admins.item[1])
				var/admin_rank = query_load_admins.item[2]
				var/skip
				if(rank_names[admin_rank] == null)
					message_admins("[admin_ckey] loaded with invalid admin rank [admin_rank].")
					skip = TRUE
				if(GLOB.admin_datums[admin_ckey] || GLOB.deadmins[admin_ckey])
					skip = TRUE
				if(!skip)
					new /datum/admins(rank_names[admin_rank], admin_ckey)
		qdel(query_load_admins)
	//load admins from backup file
	if(dbfail)
		if(!backup_file_json)
			if(backup_file_json != null)
				//already tried
				return
			var/backup_file = file2text("data/admins_backup.json")
			if(backup_file == null)
				log_world("Unable to locate admins backup file.")
				return
			backup_file_json = json_decode(backup_file)
		for(var/J in backup_file_json["admins"])
			var/skip
			for(var/A in GLOB.admin_datums + GLOB.deadmins)
				if(A == "[J]") //this admin was already loaded from txt override
					skip = TRUE
			if(skip)
				continue
			new /datum/admins(rank_names[backup_file_json["admins"]["[J]"]], ckey("[J]"))
