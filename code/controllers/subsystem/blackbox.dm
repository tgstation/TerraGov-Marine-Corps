SUBSYSTEM_DEF(blackbox)
	name = "Blackbox"
	wait = 10 MINUTES
	flags = SS_NO_TICK_CHECK
	runlevels = RUNLEVEL_GAME|RUNLEVEL_POSTGAME
	init_order = INIT_ORDER_BLACKBOX

	var/list/feedback = list()	//list of datum/feedback_variable
	var/triggertime = 0
	var/sealed = FALSE	//time to stop tracking stats?

	// associative list of any feedback variables that have had their format 
	// changed since creation and their current version, remember to update this
	var/list/versions = list() 


/datum/controller/subsystem/blackbox/Initialize()
	triggertime = world.time
	record_feedback("amount", "random_seed", Master.random_seed)
	record_feedback("amount", "dm_version", DM_VERSION)
	record_feedback("amount", "dm_build", DM_BUILD)
	record_feedback("amount", "byond_version", world.byond_version)
	record_feedback("amount", "byond_build", world.byond_build)
	. = ..()


/datum/controller/subsystem/blackbox/proc/ensure_sql()
	if(!SSdbcore.IsConnected(TRUE))
		log_sql("Database not connected! Attempting to reconnect.")
		message_admins("Database not connected! Attempting to reconnect.")

		SSdbcore.Disconnect()

		if(SSdbcore.Connect())
			log_sql("Database connection re-established!")
			message_admins("Database connection re-established!")
		else
			log_sql("Database connection failed: " + SSdbcore.ErrorMsg())
			message_admins("Database connection failed: " + SSdbcore.ErrorMsg())
			return

/datum/controller/subsystem/blackbox/fire()
	set waitfor = FALSE

	if(!CONFIG_GET(flag/sql_enabled))
		return

	ensure_sql()

	if(!GLOB.round_id)
		SSdbcore.SetRoundID()


	if(!CONFIG_GET(flag/use_exp_tracking))
		return

	update_exp(10, FALSE)


/datum/controller/subsystem/blackbox/Recover()
	feedback = SSblackbox.feedback
	sealed = SSblackbox.sealed


//Recorded on subsystem shutdown
/datum/controller/subsystem/blackbox/proc/FinalFeedback()
	record_feedback("tally", "ahelp_stats", GLOB.ahelp_tickets.active_tickets.len, "unresolved")
	for(var/player_key in GLOB.player_details)
		var/datum/player_details/PD = GLOB.player_details[player_key]
		record_feedback("tally", "client_byond_version", 1, PD.byond_version)


/datum/controller/subsystem/blackbox/Shutdown()
	sealed = FALSE
	FinalFeedback()

	if (!SSdbcore.Connect())
		return

	var/list/sqlrowlist = list()

	for (var/datum/feedback_variable/FV in feedback)
		var/sqlversion = 1
		if(FV.key in versions)
			sqlversion = versions[FV.key]
		sqlrowlist += list(list("datetime" = "Now()", "round_id" = GLOB.round_id, "key_name" =  "'[sanitizeSQL(FV.key)]'", "key_type" = "'[FV.key_type]'", "version" = "[sqlversion]", "json" = "'[sanitizeSQL(json_encode(FV.json))]'"))

	if (!length(sqlrowlist))
		return

	SSdbcore.MassInsert(format_table_name("feedback"), sqlrowlist, ignore_errors = TRUE, delayed = TRUE)


/datum/controller/subsystem/blackbox/proc/Seal()
	if(sealed)
		return FALSE
	if(IsAdminAdvancedProcCall())
		message_admins("[key_name_admin(usr)] sealed the blackbox!")
	log_game("Blackbox sealed[IsAdminAdvancedProcCall() ? " by [key_name(usr)]" : ""].")
	sealed = TRUE
	return TRUE


/datum/controller/subsystem/blackbox/proc/find_feedback_datum(key, key_type)
	for(var/datum/feedback_variable/FV in feedback)
		if(FV.key == key)
			return FV

	var/datum/feedback_variable/FV = new(key, key_type)
	feedback += FV
	return FV


/datum/controller/subsystem/blackbox/proc/record_feedback(key_type, key, increment, data, overwrite)
	if(sealed || !key_type || !istext(key) || !isnum(increment || !data))
		return
	var/datum/feedback_variable/FV = find_feedback_datum(key, key_type)
	switch(key_type)
		if("text")
			if(!istext(data))
				return
			if(!islist(FV.json["data"]))
				FV.json["data"] = list()
			if(overwrite)
				FV.json["data"] = data
			else
				FV.json["data"] |= data
		if("amount")
			FV.json["data"] += increment
		if("tally")
			if(!islist(FV.json["data"]))
				FV.json["data"] = list()
			FV.json["data"]["[data]"] += increment
		if("nested tally")
			if(!islist(data))
				return
			if(!islist(FV.json["data"]))
				FV.json["data"] = list()
			FV.json["data"] = record_feedback_recurse_list(FV.json["data"], data, increment)
		if("associative")
			if(!islist(data))
				return
			if(!islist(FV.json["data"]))
				FV.json["data"] = list()
			var/pos = length(FV.json["data"]) + 1
			FV.json["data"]["[pos]"] = list() //in 512 "pos" can be replaced with "[FV.json["data"].len+1]"
			for(var/i in data)
				if(islist(data[i]))
					FV.json["data"]["[pos]"]["[i]"] = data[i] //and here with "[FV.json["data"].len]"
				else
					FV.json["data"]["[pos]"]["[i]"] = "[data[i]]"
		else
			CRASH("Invalid feedback key_type: [key_type]")


/datum/controller/subsystem/blackbox/proc/record_feedback_recurse_list(list/L, list/key_list, increment, depth = 1)
	if(depth == key_list.len)
		if(L.Find(key_list[depth]))
			L["[key_list[depth]]"] += increment
		else
			var/list/LFI = list(key_list[depth] = increment)
			L += LFI
	else
		if(!L.Find(key_list[depth]))
			var/list/LGD = list(key_list[depth] = list())
			L += LGD
		L["[key_list[depth-1]]"] = .(L["[key_list[depth]]"], key_list, increment, ++depth)
	return L

/datum/feedback_variable
	var/key
	var/key_type
	var/list/json = list()

/datum/feedback_variable/New(new_key, new_key_type)
	key = new_key
	key_type = new_key_type



/datum/controller/subsystem/blackbox/vv_edit_var(var_name, var_value)
	return FALSE

/datum/controller/subsystem/blackbox/vv_get_var(var_name)
	if(var_name == "feedback")
		return debug_variable(var_name, deepCopyList(feedback), 0, src)
	return ..()
