SUBSYSTEM_DEF(silo)
	name = "Silo"
	wait = 1 MINUTES
	priority = FIRE_PRIORITY_SILO
	can_fire = FALSE
	init_order = INIT_ORDER_SPAWNING_POOL
	///How many larva points are added every minutes in total
	var/current_larva_spawn_rate = 0

/datum/controller/subsystem/silo/Initialize()
	RegisterSignal(SSdcs, COMSIG_GLOB_GAMESTATE_GROUNDSIDE, PROC_REF(start_spawning))
	return SS_INIT_SUCCESS

/datum/controller/subsystem/silo/fire(resumed = 0)
	var/list/active_zs = list()
	if(SSmonitor.gamestate == SHIPSIDE)
		active_zs += SSmapping.levels_by_trait(ZTRAIT_MARINE_MAIN_SHIP)
	else
		active_zs += SSmapping.levels_by_trait(ZTRAIT_GROUND)
	var/active_humans = 0
	var/list/human_list = list()
	for(var/active_z in active_zs)
		human_list += GLOB.humans_by_zlevel["[active_z]"]
	for(var/obj/vehicle/sealed/armored/tank AS in GLOB.tank_list)
		if(!(tank.z in active_zs))
			continue
		if(tank.armored_flags & ARMORED_IS_WRECK)
			continue
		active_humans += tank.larva_value
		human_list += tank.occupants

	list_clear_nulls(human_list)
	for(var/mob/living/carbon/human/human AS in human_list)
		if(!human.key && !human.has_ai())
			continue
		active_humans ++
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
	UnregisterSignal(SSdcs, COMSIG_GLOB_GAMESTATE_GROUNDSIDE)
	if(SSticker.mode?.round_type_flags & MODE_SILO_RESPAWN)
		can_fire = TRUE
