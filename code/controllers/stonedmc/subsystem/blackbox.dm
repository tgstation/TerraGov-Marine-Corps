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
		log_admin("Database not connected! Attempting to reconnect.")
		message_admins("Database not connected! Attempting to reconnect.")

		SSdbcore.Disconnect()

		if(SSdbcore.Connect())
			log_admin("Database connection re-established!")
			message_admins("Database connection re-established!")
		else
			log_admin("Database connection failed: " + SSdbcore.ErrorMsg())
			message_admins("Database connection failed: " + SSdbcore.ErrorMsg())
			return

	if(!GLOB.round_id)
		SSdbcore.SetRoundID()


	if(!CONFIG_GET(flag/use_exp_tracking))
		return

	update_exp(10, FALSE)


/datum/controller/subsystem/blackbox/vv_edit_var(var_name, var_value)
	return FALSE