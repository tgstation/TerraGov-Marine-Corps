/datum/admins/proc/unforbid()
	set category = "Admin"
	set name = "Unforbid"

	if(!check_rights(R_ADMIN))
		return

	if(GLOB.hive_datums[XENO_HIVE_NORMAL])
		GLOB.hive_datums[XENO_HIVE_NORMAL].unforbid_all_castes(TRUE)
		log_game("[key_name(usr)] unforbid all castes in [GLOB.hive_datums[XENO_HIVE_NORMAL].name] hive")
		message_admins("[ADMIN_TPMONTY(usr)] unforbid all castes in [GLOB.hive_datums[XENO_HIVE_NORMAL].name] hive")
	else
		log_game("[key_name(usr)] failed to unforbid")
		message_admins("[ADMIN_TPMONTY(usr)] failed to unforbid")
