SUBSYSTEM_DEF(resinshaping)
	name = "Resin Shaping"
	flags = SS_NO_FIRE
	/// Counter for quickbuilds, as long as this is above 0 building is instant.
	var/quickbuilds = 0
	/// Whether or not quickbuild is enabled. Set to FALSE when the game starts.
	var/active = TRUE

/datum/controller/subsystem/resinshaping/stat_entry()
	..("QUICKBUILDS=[quickbuilds]")

/datum/controller/subsystem/resinshaping/proc/toggle_off()
	SIGNAL_HANDLER
	active = FALSE
	UnregisterSignal(SSdcs, list(COMSIG_GLOB_OPEN_SHUTTERS_EARLY, COMSIG_GLOB_OPEN_TIMED_SHUTTERS_LATE,COMSIG_GLOB_OPEN_TIMED_SHUTTERS_XENO_HIVEMIND,COMSIG_GLOB_TADPOLE_LAUNCHED,COMSIG_GLOB_DROPPOD_LANDED))

/datum/controller/subsystem/resinshaping/Initialize()
	quickbuilds = SSmapping.configs[GROUND_MAP].quickbuilds
	RegisterSignals(SSdcs, list(COMSIG_GLOB_OPEN_SHUTTERS_EARLY, COMSIG_GLOB_OPEN_TIMED_SHUTTERS_LATE,COMSIG_GLOB_OPEN_TIMED_SHUTTERS_XENO_HIVEMIND,COMSIG_GLOB_TADPOLE_LAUNCHED,COMSIG_GLOB_DROPPOD_LANDED), PROC_REF(toggle_off))
	return SS_INIT_SUCCESS
