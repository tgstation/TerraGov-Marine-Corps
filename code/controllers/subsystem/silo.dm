SUBSYSTEM_DEF(silo)
	name = "Silo"
	wait = 1 MINUTES
	priority = FIRE_PRIORITY_SILO
	can_fire = FALSE
	init_order = INIT_ORDER_SPAWNING_POOL
	///How many larva points are added every minutes in total
	var/current_larva_spawn_rate = 0
	///A temporary buff for larva generation, that comes from the monitor system detecting a stalemate
	var/larva_spawn_rate_temporary_buff = 0

/datum/controller/subsystem/silo/Initialize(timeofday)
	RegisterSignal(SSdcs, list(COMSIG_GLOB_OPEN_TIMED_SHUTTERS_LATE, COMSIG_GLOB_OPEN_TIMED_SHUTTERS_XENO_HIVEMIND, COMSIG_GLOB_OPEN_SHUTTERS_EARLY, COMSIG_GLOB_TADPOLE_LAUNCHED), PROC_REF(start_spawning))
	return ..()

/datum/controller/subsystem/silo/fire(resumed = 0)
	var/datum/job/xeno_job = SSjob.GetJobType(/datum/job/xenomorph)
	//The larval spawn is based on the amount of silo, ponderated with a define. Larval follow a f(x) = (x + a)/(1 + a) * something law, which is smoother that f(x) = x * something
	current_larva_spawn_rate = length_char(GLOB.xeno_resin_silos_by_hive[XENO_HIVE_NORMAL]) ? SILO_OUTPUT_PONDERATION + length_char(GLOB.xeno_resin_silos_by_hive[XENO_HIVE_NORMAL]) : 0
	//We then are normalising with the number of alive marines, so the balance is roughly the same whether or not we are in high pop
	current_larva_spawn_rate *= SILO_BASE_OUTPUT_PER_MARINE * length_char(GLOB.humans_by_zlevel[SSmonitor.gamestate == SHIPSIDE ? "3" : "2"])
	//We normalize the larval output for one silo, so the value for silo = 1 is independant of SILO_OUTPUT_PONDERATION
	current_larva_spawn_rate /=  (1 + SILO_OUTPUT_PONDERATION)
	//We are processing wether we hijacked or not (hijacking gives a bonus)
	current_larva_spawn_rate *= SSmonitor.gamestate == SHIPSIDE ? 3 : 1
	current_larva_spawn_rate *= SSticker.mode.silo_scaling
	//Multiplier based on marines/xenos ratio
	var/spawn_rate_multiplier = length_char(GLOB.humans_by_zlevel[SSmonitor.gamestate == SHIPSIDE ? "3" : "2"]) / ((4 * (xeno_job.total_positions - xeno_job.current_positions) + length_char(GLOB.hive_datums[XENO_HIVE_NORMAL].xenos_by_tier[XENO_TIER_ZERO]) + length_char(GLOB.hive_datums[XENO_HIVE_NORMAL].xenos_by_tier[XENO_TIER_ONE]) + length_char(GLOB.hive_datums[XENO_HIVE_NORMAL].xenos_by_tier[XENO_TIER_TWO]) + length_char(GLOB.hive_datums[XENO_HIVE_NORMAL].xenos_by_tier[XENO_TIER_THREE]) + length_char(GLOB.hive_datums[XENO_HIVE_NORMAL].xenos_by_tier[XENO_TIER_FOUR])) + 1)
	current_larva_spawn_rate *= clamp((spawn_rate_multiplier * spawn_rate_multiplier), 0.1, 2)
	current_larva_spawn_rate += larva_spawn_rate_temporary_buff
	GLOB.round_statistics.larva_from_silo += current_larva_spawn_rate / xeno_job.job_points_needed
	xeno_job.add_job_points(current_larva_spawn_rate)
	var/datum/hive_status/normal_hive = GLOB.hive_datums[XENO_HIVE_NORMAL]
	normal_hive.update_tier_limits()

///Activate the subsystem when shutters open and remove the free spawning when marines are joining
/datum/controller/subsystem/silo/proc/start_spawning()
	SIGNAL_HANDLER
	UnregisterSignal(SSdcs, list(COMSIG_GLOB_OPEN_TIMED_SHUTTERS_LATE, COMSIG_GLOB_OPEN_TIMED_SHUTTERS_XENO_HIVEMIND, COMSIG_GLOB_OPEN_SHUTTERS_EARLY, COMSIG_GLOB_TADPOLE_LAUNCHED))
	if(SSticker.mode?.flags_round_type & MODE_SILO_RESPAWN)
		can_fire = TRUE
