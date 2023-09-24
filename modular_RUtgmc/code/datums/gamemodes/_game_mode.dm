/datum/game_mode/post_setup()
	if(flags_round_type & MODE_SILO_RESPAWN)
		var/datum/hive_status/normal/HN = GLOB.hive_datums[XENO_HIVE_NORMAL]
		HN.RegisterSignals(SSdcs, list(COMSIG_GLOB_OPEN_TIMED_SHUTTERS_LATE, COMSIG_GLOB_OPEN_SHUTTERS_EARLY), TYPE_PROC_REF(/datum/hive_status/normal, set_siloless_collapse_timer))
	return ..()

/// called to check for updates that might require starting/stopping the siloless collapse timer
/datum/game_mode/proc/update_silo_death_timer(datum/hive_status/silo_owner)
	return

///starts the timer to end the round when no silo is left
/datum/game_mode/proc/get_siloless_collapse_countdown()
	return
