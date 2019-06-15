SUBSYSTEM_DEF(blackbox)
	name = "Blackbox"
	wait = 10 MINUTES
	flags = SS_NO_TICK_CHECK
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME
	init_order = INIT_ORDER_BLACKBOX


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
		SSdbcore.SetRoundID()


	if(!CONFIG_GET(flag/use_exp_tracking))
		return

	update_exp(10, FALSE)


/datum/controller/subsystem/blackbox/vv_edit_var(var_name, var_value)
	return FALSE

/datum/controller/subsystem/blackbox/proc/send_pr_stats()
	var/bot_url = CONFIG_GET(string/github_pr_bot)
	if(!bot_url)
		stack_trace("Warning: `string/github_pr_bot` not set")
		return FALSE

	var/round_id = GLOB.round_id
	var/datum/getrev/revdata = GLOB.revdata

	var/total_runtimes = GLOB.total_runtimes
	var/unique_runtimes = total_runtimes - GLOB.total_runtimes_skipped

	var/list/prs = list()
	for(var/line in revdata.testmerge)
		var/datum/tgs_revision_information/test_merge/tm = line
		prs.Add(tm.number)


	world.Export("http://[bot_url]?roundId=[round_id]&commit=[revdata.commit]&prs=[prs.Join(",")]&totalRuntimes=[total_runtimes]&uniqueRuntimes=[unique_runtimes]")
	return TRUE