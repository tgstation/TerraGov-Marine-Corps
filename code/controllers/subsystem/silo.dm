SUBSYSTEM_DEF(silo)
	name = "Silo"
	wait = 1 MINUTES
	priority = FIRE_PRIORITY_SILO
	can_fire = FALSE
	init_order = INIT_ORDER_SPAWNING_POOL
	///How many larva points are added every minutes in total
	var/current_larva_spawn_rate = 0

/datum/controller/subsystem/silo/Initialize()
	RegisterSignals(SSdcs, list(COMSIG_GLOB_OPEN_TIMED_SHUTTERS_LATE, COMSIG_GLOB_OPEN_SHUTTERS_EARLY, COMSIG_GLOB_TADPOLE_LAUNCHED), PROC_REF(start_spawning))
	return SS_INIT_SUCCESS

/datum/controller/subsystem/silo/fire(resumed = 0)
	var/current_z = SSmonitor.gamestate == SHIPSIDE ? 3 : 2
	var/active_humans = length(GLOB.humans_by_zlevel["[current_z]"])
	for(var/obj/vehicle/sealed/armored/tank AS in GLOB.tank_list)
		if(tank.z != current_z)
			continue
		if(tank.armored_flags & ARMORED_IS_WRECK)
			continue
		active_humans += tank.larva_value
	for(var/hivenumber in GLOB.hive_datums)
		var/datum/job/xeno_job = SSjob.GetJobType(GLOB.hivenumber_to_job_type[hivenumber])
		var/active_xenos = xeno_job.total_positions - xeno_job.current_positions //burrowed
		for(var/mob/living/carbon/xenomorph/xeno AS in GLOB.alive_xeno_list_hive[hivenumber])
			if(xeno.xeno_caste.caste_flags & CASTE_IS_A_MINION)
				continue
			active_xenos ++
		//The larval spawn is based on the amount of silo, ponderated with a define. Larval follow a f(x) = (x + a)/(1 + a) * something law, which is smoother that f(x) = x * something
		current_larva_spawn_rate = length(GLOB.xeno_resin_silos_by_hive[hivenumber]) ? SILO_OUTPUT_PONDERATION + length(GLOB.xeno_resin_silos_by_hive[hivenumber]) : 0
		//We then are normalising with the number of alive marines, so the balance is roughly the same whether or not we are in high pop
		current_larva_spawn_rate *= SILO_BASE_OUTPUT_PER_MARINE * active_humans
		//We normalize the larval output for one silo, so the value for silo = 1 is independant of SILO_OUTPUT_PONDERATION
		current_larva_spawn_rate /=  (1 + SILO_OUTPUT_PONDERATION)
		//We are processing wether we hijacked or not (hijacking gives a bonus)
		current_larva_spawn_rate *= SSmonitor.gamestate == SHIPSIDE ? 3 : 1
		current_larva_spawn_rate *= SSticker.mode.silo_scaling
		//We scale the rate based on the current ratio of humans to xenos
		var/current_human_to_xeno_ratio = active_humans / max(active_xenos,1)
		current_larva_spawn_rate *= clamp(current_human_to_xeno_ratio / XENO_MARINE_RATIO , 0.7, 1)

		GLOB.round_statistics.larva_from_silo += current_larva_spawn_rate / xeno_job.job_points_needed

		xeno_job.add_job_points(current_larva_spawn_rate)

		var/datum/hive_status/current_hive = GLOB.hive_datums[hivenumber]
		current_hive.update_tier_limits()

///Activate the subsystem when shutters open and remove the free spawning when marines are joining
/datum/controller/subsystem/silo/proc/start_spawning()
	SIGNAL_HANDLER
	UnregisterSignal(SSdcs, list(COMSIG_GLOB_OPEN_TIMED_SHUTTERS_LATE, COMSIG_GLOB_OPEN_SHUTTERS_EARLY, COMSIG_GLOB_TADPOLE_LAUNCHED))
	if(SSticker.mode?.round_type_flags & MODE_SILO_RESPAWN)
		can_fire = TRUE
