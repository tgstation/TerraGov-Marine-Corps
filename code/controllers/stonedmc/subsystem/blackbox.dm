SUBSYSTEM_DEF(blackbox)
	name = "Blackbox"
	wait = 10 MINUTES
	flags = SS_NO_TICK_CHECK
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME
	init_order = INIT_ORDER_BLACKBOX


/datum/controller/subsystem/blackbox/fire()
	set waitfor = FALSE

	if(!CONFIG_GET(flag/use_exp_tracking))
		return

	update_exp(10, FALSE)

	if(!GLOB.round_id)
		SSdbcore.SetRoundID()


/datum/controller/subsystem/blackbox/vv_edit_var(var_name, var_value)
	return FALSE