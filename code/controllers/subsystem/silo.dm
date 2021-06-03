SUBSYSTEM_DEF(silo)
	name = "Silo"
	wait = 1 MINUTES
	can_fire = FALSE
	init_order = INIT_ORDER_SPAWNING_POOL
	///A boost in larva spawn rate, changed when hijacking
	var/larva_rate_boost = 1
	///How many larva points are added every minutes in total
	var/current_larva_spawn_rate = 0

/datum/controller/subsystem/silo/Initialize(timeofday)
	RegisterSignal(SSdcs, list(COMSIG_GLOB_OPEN_TIMED_SHUTTERS_LATE, COMSIG_GLOB_OPEN_TIMED_SHUTTERS_XENO_HIVEMIND, COMSIG_GLOB_OPEN_SHUTTERS_EARLY, COMSIG_GLOB_TADPOLE_LAUNCHED), .proc/start_spawning)
	return ..()

/datum/controller/subsystem/silo/fire(resumed = 0)
	var/datum/job/xeno_job = SSjob.GetJobType(/datum/job/xenomorph)
	current_larva_spawn_rate = 0
	for(var/obj/structure/xeno/resin/silo/silo AS in GLOB.xeno_resin_silos)
		current_larva_spawn_rate += silo.larva_spawn_rate
	current_larva_spawn_rate *= larva_rate_boost
	xeno_job.add_job_points(current_larva_spawn_rate, SILO_ORIGIN)

///Activate the subsystem when shutters open and remove the free spawning when marines are joining
/datum/controller/subsystem/silo/proc/start_spawning()
	SIGNAL_HANDLER
	UnregisterSignal(SSdcs, list(COMSIG_GLOB_OPEN_TIMED_SHUTTERS_LATE, COMSIG_GLOB_OPEN_TIMED_SHUTTERS_XENO_HIVEMIND, COMSIG_GLOB_OPEN_SHUTTERS_EARLY, COMSIG_GLOB_TADPOLE_LAUNCHED))
	if(SSticker.mode?.flags_round_type & MODE_SILO_RESPAWN)
		can_fire = TRUE
