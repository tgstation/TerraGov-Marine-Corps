SUBSYSTEM_DEF(silo)
	name = "silo"
	wait = 1 MINUTES
	can_fire = FALSE
	init_order = INIT_ORDER_SPAWNING_POOL
	///The max amount of silos that can spawn free larvas
	var/max_silo_spawning = 0
	///How many larva points each pool gives per minute
	var/larva_spawn_rate = 0.5


/datum/controller/subsystem/silo/Initialize(timeofday)
	RegisterSignal(SSdcs, list(COMSIG_GLOB_OPEN_TIMED_SHUTTERS_LATE, COMSIG_GLOB_OPEN_TIMED_SHUTTERS_XENO_HIVEMIND, COMSIG_GLOB_OPEN_SHUTTERS_EARLY), .proc/start_spawning)
	return ..()

/datum/controller/subsystem/silo/fire(resumed = 0)
	var/datum/job/xeno_job = SSjob.GetJobType(/datum/job/xenomorph)
	xeno_job.add_job_points(GLOB.xeno_resin_silos.len * larva_spawn_rate)

///Activate the subsystem when shutters open and remove the free spawning when marines are joining
/datum/controller/subsystem/silo/proc/start_spawning()
	SIGNAL_HANDLER
	UnregisterSignal(SSdcs, list(COMSIG_GLOB_OPEN_TIMED_SHUTTERS_LATE, COMSIG_GLOB_OPEN_TIMED_SHUTTERS_XENO_HIVEMIND, COMSIG_GLOB_OPEN_SHUTTERS_EARLY))
	can_fire = TRUE
	for(var/job in SSjob.occupations)
		var/datum/job/j = job
		j.jobworth[/datum/job/xenomorph] = 0
