SUBSYSTEM_DEF(monitor)
	name = "Monitor"
	init_order = INIT_ORDER_MONITOR
	runlevels = RUNLEVEL_GAME
	wait = 3 MINUTES
	can_fire = TRUE
	///The current state
	var/current_state = STATE_BALANCED
	///The last state
	var/last_state = STATE_BALANCED
	///The current state points. Negative means xenos are winning, positive points correspond to marine winning
	var/current_points = 0
	/// The raw amount of state points unadjusted for player count.
	var/raw_points = 0
	///The number of humans on ground
	var/human_on_ground = 0
	///The number of humans being in either lz1 or lz2
	var/human_in_FOB = 0
	///The number of humans on the ship
	var/human_on_ship = 0
	///The number of clf on ground
	var/clf_on_ground = 0
	///The number of clf on the ship
	var/clf_on_ship = 0
	///The number of time most of humans are in FOB consecutively
	var/humans_all_in_FOB_counter = 0
	///TRUE if we detect a state of FOB hugging
	var/FOB_hugging = FALSE
	///If the game is currently before shutters drop, after, or shipside
	var/gamestate = SHUTTERS_CLOSED
	///If the automatic balance system is online
	var/is_automatic_balance_on = TRUE
	///Maximum record of how many players were concurrently playing this round
	var/maximum_connected_players_count = 0
	/// An associative list of all items with the component [/datum/component/autobalance_monitor]. Association: [item] = value in requisition points.
	var/list/requisition_item_keys = list()

/datum/controller/subsystem/monitor/Initialize()
	RegisterSignals(SSdcs, list(
		COMSIG_GLOB_OPEN_TIMED_SHUTTERS_LATE,
		COMSIG_GLOB_OPEN_SHUTTERS_EARLY,
		COMSIG_GLOB_TADPOLE_LANDED_OUT_LZ,
		COMSIG_GLOB_TADPOLE_RAPPEL_DEPLOYED_OUT_LZ,
		COMSIG_GLOB_CRASH_SHIP_LANDED,
	), PROC_REF(set_groundside_calculation))
	RegisterSignal(SSdcs, COMSIG_GLOB_DROPSHIP_HIJACKED, PROC_REF(set_shipside_calculation))
	is_automatic_balance_on = CONFIG_GET(flag/is_automatic_balance_on)
	return SS_INIT_SUCCESS

/datum/controller/subsystem/monitor/fire(resumed = 0)
	var/total_living_players = length(GLOB.alive_human_list) + length(GLOB.alive_xeno_list)
	raw_points = calculate_state_points()
	current_points = raw_points / max(total_living_players, 10)//having less than 10 players gives bad results
	maximum_connected_players_count = max(get_active_player_count(), maximum_connected_players_count)
	if(gamestate == GROUNDSIDE)
		process_human_positions()
		FOB_hugging_check()
	set_state(current_points)

	//Automatic buff system for the xeno, if they have too much burrowed yet are still losing
	var/proposed_balance_buff = GLOB.xeno_stat_multiplicator_buff
	if(is_automatic_balance_on)
		proposed_balance_buff = balance_xeno_team()
	if(abs(proposed_balance_buff - GLOB.xeno_stat_multiplicator_buff) >= 0.05 || (proposed_balance_buff == 1 && GLOB.xeno_stat_multiplicator_buff != 1))
		GLOB.xeno_stat_multiplicator_buff = proposed_balance_buff
		apply_balance_changes()

	if(SSticker.mode?.round_type_flags & MODE_SILOS_SPAWN_MINIONS)
		//Balance spawners output
		for(var/silo in GLOB.xeno_resin_silos_by_hive[XENO_HIVE_NORMAL])
			SSspawning.spawnerdata[silo].required_increment = 2 * max(45 SECONDS, 3 MINUTES - SSmonitor.maximum_connected_players_count * SPAWN_RATE_PER_PLAYER) / SSspawning.wait
			SSspawning.spawnerdata[silo].max_allowed_mobs = max(1, MAX_SPAWNABLE_MOB_PER_PLAYER * SSmonitor.maximum_connected_players_count * 0.5)
		for(var/spawner in GLOB.xeno_spawners_by_hive[XENO_HIVE_NORMAL])
			SSspawning.spawnerdata[spawner].required_increment = max(45 SECONDS, 3 MINUTES - SSmonitor.maximum_connected_players_count * SPAWN_RATE_PER_PLAYER) / SSspawning.wait
			SSspawning.spawnerdata[spawner].max_allowed_mobs = max(2, MAX_SPAWNABLE_MOB_PER_PLAYER * SSmonitor.maximum_connected_players_count)

///Sets the gamestate to groundside
/datum/controller/subsystem/monitor/proc/set_groundside_calculation(datum/source)
	SIGNAL_HANDLER
	UnregisterSignal(SSdcs, list(
		COMSIG_GLOB_OPEN_TIMED_SHUTTERS_LATE,
		COMSIG_GLOB_OPEN_SHUTTERS_EARLY,
		COMSIG_GLOB_TADPOLE_LANDED_OUT_LZ,
		COMSIG_GLOB_TADPOLE_RAPPEL_DEPLOYED_OUT_LZ,
		COMSIG_GLOB_CRASH_SHIP_LANDED,
	))
	gamestate = GROUNDSIDE
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_GAMESTATE_GROUNDSIDE)

/datum/controller/subsystem/monitor/proc/set_shipside_calculation()
	SIGNAL_HANDLER
	gamestate = SHIPSIDE
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_GAMESTATE_SHIPSIDE)

/// Calculate the points used to determine which side is winning at the moment.
/datum/controller/subsystem/monitor/proc/calculate_state_points()
	// Humans
	var/alive_human_list_ntf = (GLOB.alive_human_list_faction[FACTION_TERRAGOV] | GLOB.alive_human_list_faction[FACTION_NANOTRASEN])
	switch(gamestate)
		if(SHUTTERS_CLOSED)
			. += length(alive_human_list_ntf) * SHIPSIDE_HUMAN_LIFE_WEIGHT
			. += (SSpoints.supply_points[FACTION_TERRAGOV] + SSpoints.supply_points[FACTION_NANOTRASEN]) * REQ_POINTS_WEIGHT
		if(GROUNDSIDE)
			. += human_on_ground * GROUNDSIDE_HUMAN_LIFE_ON_GROUND_WEIGHT
			. += (length(alive_human_list_ntf) - human_on_ground) * GROUNDSIDE_HUMAN_LIFE_ON_SHIP_WEIGHT
			. += (SSpoints.supply_points[FACTION_TERRAGOV] + SSpoints.supply_points[FACTION_NANOTRASEN]) * REQ_POINTS_WEIGHT
		if(SHIPSIDE)
			. += length(alive_human_list_ntf) * SHIPSIDE_HUMAN_LIFE_WEIGHT
			// Unspent supply points during hijack aren't important as they are likely to stay unspent.
	for(var/atom/movable/item_key in requisition_item_keys)
		if(item_key.faction != FACTION_TERRAGOV && item_key.faction != FACTION_NANOTRASEN)
			continue
		. += requisition_item_keys[item_key] * REQ_POINTS_WEIGHT
	// Xenomorphs
	var/datum/job/xeno_job = SSjob.GetJobType(/datum/job/xenomorph)
	. += (xeno_job.total_positions - xeno_job.current_positions) * BURROWED_LARVA_WEIGHT
	for(var/mob/living/carbon/xenomorph/normal_xenomorph in GLOB.alive_xeno_list_hive[XENO_HIVE_NORMAL])
		if(normal_xenomorph.xeno_caste.caste_flags & CASTE_IS_A_MINION)
			. += MINION_XENO_LIFE_WEIGHT
			continue
		switch(normal_xenomorph.tier)
			if(XENO_TIER_MINION)
				. += MINION_XENO_LIFE_WEIGHT
				continue // Shouldn't ever happen, but you never know.
			if(XENO_TIER_ZERO)
				. += T0_XENO_LIFE_WEIGHT
				continue // Shouldn't have access to primos.
			if(XENO_TIER_ONE)
				. += T1_XENO_LIFE_WEIGHT
			if(XENO_TIER_TWO)
				. += T2_XENO_LIFE_WEIGHT
			if(XENO_TIER_THREE)
				. += T3_XENO_LIFE_WEIGHT
			if(XENO_TIER_FOUR)
				. += T4_XENO_LIFE_WEIGHT
		if(normal_xenomorph.upgrade == XENO_UPGRADE_PRIMO)
			. += PRIMO_XENO_BONUS_WEIGHT
	. += SSpoints.xeno_strategic_points_by_hive[XENO_HIVE_NORMAL] * PSY_STRATEGIC_POINT_WEIGHT
	. += SSpoints.xeno_tactical_points_by_hive[XENO_HIVE_NORMAL] * PSY_TACTICAL_POINT_WEIGHT
	. += length(GLOB.xeno_resin_silos_by_hive[XENO_HIVE_NORMAL]) * RESIN_SILO_WEIGHT
	. += length(GLOB.hive_datums[XENO_HIVE_NORMAL].evotowers) * EVOLUTION_TOWER_WEIGHT
	. += length(GLOB.hive_datums[XENO_HIVE_NORMAL].psychictowers) * PSYCHIC_RELAY_WEIGHT
	. += length(GLOB.hive_datums[XENO_HIVE_NORMAL].pherotowers) * PHEROMONE_TOWER_WEIGHT
	. += length(GLOB.xeno_spawners_by_hive[XENO_HIVE_NORMAL]) * SPAWNER_WEIGHT
	. += length(GLOB.xeno_acid_pools_by_hive[XENO_HIVE_NORMAL]) * ACID_POOL_WEIGHT
	. += length(GLOB.xeno_acid_jaws_by_hive[XENO_HIVE_NORMAL]) * ACID_JAWS_WEIGHT
	for(var/obj/structure/xeno/xeno_turret/xeno_turret AS in GLOB.xeno_resin_turrets_by_hive[XENO_HIVE_NORMAL])
		if(xeno_turret.type == /obj/structure/xeno/xeno_turret) // Strict because we want the base acid turret.
			. += XENO_ACID_TURRET_WEIGHT
			continue
		if(istype(xeno_turret, /obj/structure/xeno/xeno_turret/sticky))
			. += XENO_RESIN_TURRET_WEIGHT

	switch(gamestate)
		if(SHUTTERS_CLOSED)
			. -= length(GLOB.alive_human_list_faction[FACTION_CLF]) * SHIPSIDE_HUMAN_LIFE_WEIGHT
			. -= SSpoints.supply_points[FACTION_CLF] * REQ_POINTS_WEIGHT
		if(GROUNDSIDE)
			. -= clf_on_ground * GROUNDSIDE_HUMAN_LIFE_ON_GROUND_WEIGHT
			. -= (length(GLOB.alive_human_list_faction[FACTION_CLF]) - clf_on_ground) * GROUNDSIDE_HUMAN_LIFE_ON_SHIP_WEIGHT
			. -= SSpoints.supply_points[FACTION_CLF] * REQ_POINTS_WEIGHT
		if(SHIPSIDE)
			. -= length(GLOB.alive_human_list_faction[FACTION_CLF]) * SHIPSIDE_HUMAN_LIFE_WEIGHT
			// Unspent supply points during hijack aren't important as they are likely to stay unspent.
	for(var/atom/movable/item_key in requisition_item_keys)
		if(item_key.faction != FACTION_CLF)
			continue
		. -= requisition_item_keys[item_key] * REQ_POINTS_WEIGHT
	// Xenomorphs
	xeno_job = SSjob.GetJobType(/datum/job/xenomorph)
	. -= (xeno_job.total_positions - xeno_job.current_positions) * BURROWED_LARVA_WEIGHT
	for(var/mob/living/carbon/xenomorph/normal_xenomorph in GLOB.alive_xeno_list_hive[XENO_HIVE_CORRUPTED])
		if(normal_xenomorph.xeno_caste.caste_flags & CASTE_IS_A_MINION)
			. -= MINION_XENO_LIFE_WEIGHT
			continue
		switch(normal_xenomorph.tier)
			if(XENO_TIER_MINION)
				. -= MINION_XENO_LIFE_WEIGHT
				continue // Shouldn't ever happen, but you never know.
			if(XENO_TIER_ZERO)
				. -= T0_XENO_LIFE_WEIGHT
				continue // Shouldn't have access to primos.
			if(XENO_TIER_ONE)
				. -= T1_XENO_LIFE_WEIGHT
			if(XENO_TIER_TWO)
				. -= T2_XENO_LIFE_WEIGHT
			if(XENO_TIER_THREE)
				. -= T3_XENO_LIFE_WEIGHT
			if(XENO_TIER_FOUR)
				. -= T4_XENO_LIFE_WEIGHT
		if(normal_xenomorph.upgrade == XENO_UPGRADE_PRIMO)
			. -= PRIMO_XENO_BONUS_WEIGHT
	. -= SSpoints.xeno_strategic_points_by_hive[XENO_HIVE_CORRUPTED] * PSY_STRATEGIC_POINT_WEIGHT
	. -= SSpoints.xeno_tactical_points_by_hive[XENO_HIVE_CORRUPTED] * PSY_TACTICAL_POINT_WEIGHT
	. -= length(GLOB.xeno_resin_silos_by_hive[XENO_HIVE_CORRUPTED]) * RESIN_SILO_WEIGHT
	. -= length(GLOB.hive_datums[XENO_HIVE_CORRUPTED].evotowers) * EVOLUTION_TOWER_WEIGHT
	. -= length(GLOB.hive_datums[XENO_HIVE_CORRUPTED].psychictowers) * PSYCHIC_RELAY_WEIGHT
	. -= length(GLOB.hive_datums[XENO_HIVE_CORRUPTED].pherotowers) * PHEROMONE_TOWER_WEIGHT
	. -= length(GLOB.xeno_spawners_by_hive[XENO_HIVE_CORRUPTED]) * SPAWNER_WEIGHT
	. -= length(GLOB.xeno_acid_pools_by_hive[XENO_HIVE_CORRUPTED]) * ACID_POOL_WEIGHT
	. -= length(GLOB.xeno_acid_jaws_by_hive[XENO_HIVE_CORRUPTED]) * ACID_JAWS_WEIGHT
	for(var/obj/structure/xeno/xeno_turret/xeno_turret AS in GLOB.xeno_resin_turrets_by_hive[XENO_HIVE_CORRUPTED])
		if(xeno_turret.type == /obj/structure/xeno/xeno_turret) // Strict because we want the base acid turret.
			. -= XENO_ACID_TURRET_WEIGHT
			continue
		if(istype(xeno_turret, /obj/structure/xeno/xeno_turret/sticky))
			. -= XENO_RESIN_TURRET_WEIGHT

///Keep the monitor informed about the position of humans
/datum/controller/subsystem/monitor/proc/process_human_positions()
	human_on_ground = 0
	human_in_FOB = 0
	human_on_ship = 0
	clf_on_ground = 0
	clf_on_ship = 0
	for(var/human in (GLOB.alive_human_list_faction[FACTION_TERRAGOV] | GLOB.alive_human_list_faction[FACTION_NANOTRASEN]))
		var/turf/TU = get_turf(human)
		var/area/myarea = TU.loc
		if(is_ground_level(TU.z))
			human_on_ground++
			if(myarea.area_flags & NEAR_FOB)
				human_in_FOB++
		else if(is_mainship_level(TU.z))
			human_on_ship++
	for(var/human in GLOB.alive_human_list_faction[FACTION_CLF])
		var/turf/TU = get_turf(human)
		if(is_ground_level(TU.z))
			human_on_ground++
		else if(is_mainship_level(TU.z))
			human_on_ship++

///Check if we are in a FOB camping situation
/datum/controller/subsystem/monitor/proc/FOB_hugging_check()
	if (human_on_ground && human_in_FOB/(human_on_ground) >= PROPORTION_MARINE_FOB_HUGGING_THRESHOLD)
		humans_all_in_FOB_counter++
		if (humans_all_in_FOB_counter == 3)
			FOB_hugging = TRUE
			return
		return
	humans_all_in_FOB_counter = 0
	FOB_hugging = FALSE

///Etablish the new monitor state of the game, and update the GLOB values
/datum/controller/subsystem/monitor/proc/set_state(actualPoints)
	//We set the actual state
	if (actualPoints > XENOS_DELAYING_THRESHOLD)
		current_state = XENOS_DELAYING
	else if (actualPoints > XENOS_LOSING_THRESHOLD)
		current_state = XENOS_LOSING
	else if (actualPoints > MARINES_LOSING_THRESHOLD)
		current_state = STATE_BALANCED
	else if (actualPoints > MARINES_DELAYING_THRESHOLD)
		current_state = MARINES_LOSING
	else
		current_state = MARINES_DELAYING

/**
 * Return the proposed xeno buff calculated with the number of burrowed, and the state of the game
 */
/datum/controller/subsystem/monitor/proc/balance_xeno_team()
	var/datum/job/xenomorph/xeno_job = SSjob.GetJobType(/datum/job/xenomorph)
	if(current_state >= STATE_BALANCED || length(GLOB.xeno_resin_silos_by_hive[XENO_HIVE_NORMAL]) == 0)
		return 1
	var/burrowed = xeno_job.total_positions - xeno_job.current_positions
	var/datum/hive_status/normal/HN = GLOB.hive_datums[XENO_HIVE_NORMAL]
	var/xeno_alive_plus_burrowed = HN.total_xenos_for_evolving()
	var/xeno_alive_excl_burrowed = xeno_alive_plus_burrowed - burrowed
	var/buff_needed_estimation = min(MAXIMUM_XENO_BUFF_POSSIBLE, max(1, xeno_alive_plus_burrowed/((xeno_alive_excl_burrowed + xeno_job.free_xeno_at_start)*2)))
	// No need to ask admins every time
	if(buff_needed_estimation == 1)
		return buff_needed_estimation
	if(GLOB.xeno_stat_multiplicator_buff != 1)
		return buff_needed_estimation
	var/admin_response = admin_approval("<span color='prefix'>AUTO BALANCE SYSTEM:</span> An excessive amount of burrowed was detected, while the balance system consider that marines are winning. [span_boldnotice("Considering the amount of burrowed larvas, a stat buff of [buff_needed_estimation * 100]% will be applied to health, health recovery, and melee damages.")]",
		options = list("approve" = "approve", "deny" = "deny", "shutdown balance system" = "shutdown balance system"),
		admin_sound = sound('sound/effects/sos-morse-code.ogg', channel = CHANNEL_ADMIN))
	if(admin_response != "approve")
		if(admin_response == "shutdown balance system")
			is_automatic_balance_on = FALSE
		return 1
	return buff_needed_estimation


/**
 * Will multiply every base health, regen and melee damage stat on all xeno by GLOB.xeno_stat_multiplicator_buff
 */
/datum/controller/subsystem/monitor/proc/apply_balance_changes()
	GLOB.hive_datums[XENO_HIVE_NORMAL].set_health_multiplier(GLOB.xeno_stat_multiplicator_buff)
	GLOB.hive_datums[XENO_HIVE_NORMAL].set_melee_multiplier(GLOB.xeno_stat_multiplicator_buff)
