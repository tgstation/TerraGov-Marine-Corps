SUBSYSTEM_DEF(silo)
	name = "Silo"
	wait = 1 MINUTES
	can_fire = FALSE
	init_order = INIT_ORDER_SPAWNING_POOL
	///How many larva points each pool gives per minute with a maturity of zero
	var/base_larva_spawn_rate = 0.4
	///How many larva points are added every minutes in total
	var/current_larva_spawn_rate = 0
	///If the silos are maturing
	var/silos_do_mature = FALSE
	///How many psych points one corrupted generator gives
	var/corrupted_gen_output


/datum/controller/subsystem/silo/Initialize(timeofday)
	RegisterSignal(SSdcs, list(COMSIG_GLOB_OPEN_TIMED_SHUTTERS_LATE, COMSIG_GLOB_OPEN_TIMED_SHUTTERS_XENO_HIVEMIND, COMSIG_GLOB_OPEN_SHUTTERS_EARLY), .proc/start_spawning)
	return ..()

/datum/controller/subsystem/silo/fire(resumed = 0)
	var/datum/job/xeno_job = SSjob.GetJobType(/datum/job/xenomorph)
	current_larva_spawn_rate = 0
	for(var/obj/structure/resin/silo/silo AS in GLOB.xeno_resin_silos)
		current_larva_spawn_rate += clamp(base_larva_spawn_rate * (1 + silo.maturity/(5400)), base_larva_spawn_rate, 2 * base_larva_spawn_rate)
	xeno_job.add_job_points(current_larva_spawn_rate)
	corrupted_gen_output = TGS_CLIENT_COUNT * BASE_PSYCH_POINT_OUTPUT

///Activate the subsystem when shutters open and remove the free spawning when marines are joining
/datum/controller/subsystem/silo/proc/start_spawning()
	SIGNAL_HANDLER
	UnregisterSignal(SSdcs, list(COMSIG_GLOB_OPEN_TIMED_SHUTTERS_LATE, COMSIG_GLOB_OPEN_TIMED_SHUTTERS_XENO_HIVEMIND, COMSIG_GLOB_OPEN_SHUTTERS_EARLY))
	can_fire = TRUE
	silos_do_mature = TRUE
