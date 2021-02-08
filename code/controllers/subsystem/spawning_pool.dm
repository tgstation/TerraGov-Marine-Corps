SUBSYSTEM_DEF(spawning_pool)
	name = "spawning pool"
	wait = 1 MINUTES
	can_fire = FALSE
	init_order = INIT_ORDER_SPAWNING_POOL
	///The max amount of spawning pools that can spawn free larvas
	var/max_spawning_pool_spawning = 0
	///How many larva points each pool gives per minute
	var/larva_spawn_rate = 0.5


/datum/controller/subsystem/spawning_pool/Initialize(timeofday)
	RegisterSignal(SSdcs, list(COMSIG_GLOB_OPEN_TIMED_SHUTTERS_LATE, COMSIG_GLOB_OPEN_TIMED_SHUTTERS_CRASH, COMSIG_GLOB_OPEN_TIMED_SHUTTERS_XENO_HIVEMIND, COMSIG_GLOB_OPEN_SHUTTERS_EARLY), .proc/start_spawning)
	return ..()

/datum/controller/subsystem/spawning_pool/fire(resumed = 0)

	if(iscrashgamemode(SSticker.mode) && (SSmonitor.current_state == MARINES_LOSING || SSmonitor.current_state == MARINES_DELAYING))
		return //In crash, marine can't kill pools. So we limit the production of larvas if xenos are already winning
	
	var/datum/job/xeno_job = SSjob.GetJobType(/datum/job/xenomorph)
	xeno_job.add_job_points(GLOB.xeno_resin_spawning_pools.len * larva_spawn_rate)	

///Activate the subsystem when shutters open and remove the free spawning when marines are joining
/datum/controller/subsystem/spawning_pool/proc/start_spawning()
	SIGNAL_HANDLER
	UnregisterSignal(SSdcs, list(COMSIG_GLOB_OPEN_TIMED_SHUTTERS_LATE, COMSIG_GLOB_OPEN_TIMED_SHUTTERS_CRASH, COMSIG_GLOB_OPEN_TIMED_SHUTTERS_XENO_HIVEMIND, COMSIG_GLOB_OPEN_SHUTTERS_EARLY))
	can_fire = TRUE
	for(var/job in SSjob.occupations)
		var/datum/job/j = job
		j.jobworth[/datum/job/xenomorph] = 0
