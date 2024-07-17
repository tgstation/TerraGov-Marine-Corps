SUBSYSTEM_DEF(blackbox)
	name = "Blackbox"
	wait = 10 MINUTES
	runlevels = RUNLEVEL_GAME

	var/list/feedback = list()
	var/sealed = FALSE

/datum/controller/subsystem/blackbox/Initialize()
	record_feedback("amount", "random_seed", Master.random_seed)
	record_feedback("amount", "dm_version", DM_VERSION)
	record_feedback("amount", "dm_build", DM_BUILD)
	record_feedback("amount", "byond_version", world.byond_version)
	record_feedback("amount", "byond_build", world.byond_build)
	return SS_INIT_SUCCESS

/datum/controller/subsystem/blackbox/Recover()
	feedback = SSblackbox.feedback
	sealed = SSblackbox.sealed


/datum/controller/subsystem/blackbox/fire()
	set waitfor = FALSE

	if(!CONFIG_GET(flag/sql_enabled))
		return

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

	if(!GLOB.round_id)
		SSdbcore.InitializeRound()


	if(CONFIG_GET(flag/use_exp_tracking))
		update_exp(10, FALSE)


/datum/controller/subsystem/blackbox/vv_get_var(var_name)
	if(var_name == "feedback")
		return debug_variable(var_name, deepCopyList(feedback), 0, src)
	return ..()


/datum/controller/subsystem/blackbox/vv_edit_var(var_name, var_value)
	switch(var_name)
		if("feedback")
			return FALSE
		if("sealed")
			if(var_value)
				return Seal()
			return FALSE
	return ..()


/datum/controller/subsystem/blackbox/Shutdown()
	sealed = FALSE

	if (!SSdbcore.Connect())
		return

	var/list/special_columns = list(
		"datetime" = "NOW()"
	)
	var/list/sqlrowlist = list()
	for (var/datum/feedback_variable/FV in feedback)
		sqlrowlist += list(list(
			"round_id" = GLOB.round_id,
			"key_name" = FV.key,
			"key_type" = FV.key_type,
			"version" = FV.version,
			"json" = json_encode(FV.json)
		))

	if (!length(sqlrowlist))
		return

	SSdbcore.MassInsert(format_table_name("feedback"), sqlrowlist, ignore_errors = TRUE, delayed = TRUE, special_columns = special_columns)


/datum/controller/subsystem/blackbox/proc/Seal()
	if(sealed)
		return FALSE
	if(IsAdminAdvancedProcCall())
		message_admins("[ADMIN_TPMONTY(usr)] sealed the blackbox.")
	log_game("Blackbox sealed[IsAdminAdvancedProcCall() ? " by [key_name(usr)]" : ""].")
	sealed = TRUE
	return TRUE


#define FEEDBACK_TEXT "text"
#define FEEDBACK_AMOUNT "amount"
#define FEEDBACK_TALLY "tally"
#define FEEDBACK_NESTED_TALLY "nested_tally"
#define FEEDBACK_ASSOCIATIVE "associative"

/datum/controller/subsystem/blackbox/proc/record_feedback(key_type, key, increment, data, overwrite, version = 1)
	if(sealed || !key_type || !istext(key) || !isnum(increment || !data))
		return
	var/datum/feedback_variable/FV = find_feedback_datum(key, key_type, version)
	switch(key_type)
		if(FEEDBACK_TEXT)
			if(!istext(data))
				return
			if(!islist(FV.json["data"]))
				FV.json["data"] = list()
			if(overwrite)
				FV.json["data"] = data
			else
				FV.json["data"] |= data
		if(FEEDBACK_AMOUNT)
			FV.json["data"] += increment
		if(FEEDBACK_TALLY)
			if(!islist(FV.json["data"]))
				FV.json["data"] = list()
			FV.json["data"]["[data]"] += increment
		if(FEEDBACK_NESTED_TALLY)
			if(!islist(data))
				return
			if(!islist(FV.json["data"]))
				FV.json["data"] = list()
			FV.json["data"] = record_feedback_recurse_list(FV.json["data"], data, increment)
		if(FEEDBACK_ASSOCIATIVE)
			if(!islist(data))
				return
			if(!islist(FV.json["data"]))
				FV.json["data"] = list()
			var/pos = length(FV.json["data"]) + 1
			FV.json["data"]["[length(FV.json["data"]) + 1]"] = list()
			for(var/i in data)
				if(islist(data[i]))
					FV.json["data"]["[length(FV.json["data"])]"]["[i]"] = data[i]
				else
					FV.json["data"]["[pos]"]["[i]"] = "[data[i]]"
		else
			CRASH("Invalid feedback key_type: [key_type]")


/datum/controller/subsystem/blackbox/proc/find_feedback_datum(key, key_type, version)
	for(var/i in feedback)
		var/datum/feedback_variable/FV = i
		if(FV.key == key)
			return FV

	var/datum/feedback_variable/FV = new(key, key_type, version)
	feedback += FV
	return FV


/datum/controller/subsystem/blackbox/proc/record_feedback_recurse_list(list/L, list/key_list, increment, depth = 1)
	if(depth == length(key_list))
		if(L.Find(key_list[depth]))
			L["[key_list[depth]]"] += increment
		else
			var/list/LFI = list(key_list[depth] = increment)
			L += LFI
	else
		if(!L.Find(key_list[depth]))
			var/list/LGD = list(key_list[depth] = list())
			L += LGD
		L["[key_list[depth - 1]]"] = .(L["[key_list[depth]]"], key_list, increment, ++depth)
	return L


/datum/feedback_variable
	var/key
	var/key_type
	var/version
	var/list/json


/datum/feedback_variable/New(new_key, new_key_type, new_version)
	key = new_key
	key_type = new_key_type
	version = new_version
	json = list()


/datum/controller/subsystem/blackbox/proc/ReportDeath(mob/living/L)
	set waitfor = FALSE
	if(sealed)
		return
	if(!L?.key || !L.mind)
		return
	if(!SSdbcore.Connect())
		return

	var/datum/db_query/query_report_death = SSdbcore.NewQuery({"
		INSERT INTO [format_table_name("death")] (pod, x_coord, y_coord, z_coord, mapname, server_ip, server_port, round_id, tod, job, special, name, byondkey, laname, lakey, bruteloss, fireloss, brainloss, oxyloss, toxloss, cloneloss, staminaloss, last_words, suicide)
		VALUES (:pod, :x_coord, :y_coord, :z_coord, :map, INET_ATON(:internet_address), :port, :round_id, :time, :job, :special, :name, :key, :laname, :lakey, :brute, :fire, :brain, :oxy, :tox, :clone, :stamina, :last_words, :suicide)
		"}, list(
			"name" = L.real_name,
			"key" = L.ckey,
			"job" = L.job ? L.job.title : "Unassigned",
			"special" = "unused",
			"pod" = get_area_name(L, TRUE) || "",
			"laname" = L.real_name,
			"lakey" = L.ckey,
			"brute" = L.getBruteLoss(),
			"fire" = L.getFireLoss(),
			"brain" = L.getBrainLoss(),
			"oxy" = L.getOxyLoss(),
			"tox" = L.getToxLoss(),
			"clone" = L.getCloneLoss(),
			"stamina" = L.getStaminaLoss(),
			"x_coord" = L.x,
			"y_coord" = L.y,
			"z_coord" = L.z,
			"last_words" = "no last words",
			"suicide" = L.suiciding,
			"map" = SSmapping.configs[GROUND_MAP].map_name,
			"internet_address" = world.internet_address || "0",
			"port" = "[world.port]",
			"round_id" = GLOB.round_id,
			"time" = SQLtime(),
		)
	)

	if(query_report_death)
		query_report_death.Execute(async = TRUE)
		qdel(query_report_death)
