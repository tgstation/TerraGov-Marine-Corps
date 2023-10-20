
/client/proc/facehugger_exp_update(stat = 0)
	if(!CONFIG_GET(flag/use_exp_tracking))
		return -1
	if(!SSdbcore.Connect())
		return -1
	if(!isnum(stat) || !stat)
		return -1

	LAZYINITLIST(GLOB.exp_to_update)
	GLOB.exp_to_update.Add(list(list(
			"job" = EXP_TYPE_FACEHUGGER_STAT,
			"ckey" = ckey,
			"minutes" = stat)))
	prefs.exp[EXP_TYPE_FACEHUGGER_STAT] += stat
