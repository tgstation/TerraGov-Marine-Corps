SUBSYSTEM_DEF(monitor)
	name = "Monitor"
	init_order = INIT_ORDER_MONITOR
	runlevels = RUNLEVEL_GAME
	wait = 5 MINUTES
	can_fire = TRUE


	///The next world.time for wich the monitor subsystem refresh the state
	var/scheduled = 0
	///The current state
	var/current_state = STATE_BALANCED
	///The last state
	var/last_state = STATE_BALANCED
	///If we consider the state as a stalemate
	var/stalemate = FALSE
	///The current state points. Negative means xenos are winning, positive points correspond to marine winning
	var/current_points = 0
	///The number of time we had the same state consecutively
	var/stale_counter = 0
	///The number of humans on ground
	var/human_on_ground = 0
	///The number of humans being in either lz1 or lz2
	var/human_in_FOB = 0
	///The number of time most of humans are in FOB consecutively
	var/humans_all_in_FOB_counter = 0
	///TRUE if we detect a state of FOB hugging
	var/FOB_hugging = FALSE
	///List of all int stats
	var/datum/monitor_statistics/stats = new
	///If the game is currently before shutters drop, after, or shipside
	var/gamestate = SHUTTERS_CLOSED
	
/datum/monitor_statistics
	var/ancient_queen = 0
	var/elder_queen = 0
	var/ancient_T3 = 0
	var/elder_T3 = 0
	var/ancient_T2 = 0
	var/elder_T2 = 0
	var/list/miniguns_in_use = list()
	var/list/sadar_in_use = list()
	var/list/b18_in_use = list()
	var/list/b17_in_use = list()
	var/OB_available = 0

/datum/controller/subsystem/monitor/Initialize(start_timeofday)
	. = ..()
	RegisterSignal(SSdcs, COMSIG_GLOB_OPEN_TIMED_SHUTTERS_LATE, .proc/set_groundside_calculation)
	RegisterSignal(SSdcs, COMSIG_GLOB_DROPSHIP_HIJACKED, .proc/set_shipside_calculation)

/datum/controller/subsystem/monitor/fire(resumed = 0)
	current_points = calculate_state_points() / max(GLOB.alive_human_list.len + GLOB.alive_xeno_list.len, 10)//having less than 10 players gives bad results
	if(gamestate == GROUNDSIDE)
		process_human_positions()
		FOB_hugging_check()
	set_state(current_points)

/datum/controller/subsystem/monitor/proc/set_groundside_calculation()
	SIGNAL_HANDLER
	gamestate = GROUNDSIDE

/datum/controller/subsystem/monitor/proc/set_shipside_calculation()
	SIGNAL_HANDLER
	gamestate = SHIPSIDE
	
///Calculate the points supposedly representating of the situation	
/datum/controller/subsystem/monitor/proc/calculate_state_points()
	var/datum/job/xeno_job = SSjob.GetJobType(/datum/job/xenomorph)
	switch(gamestate)
		if(GROUNDSIDE)
			. += stats.ancient_T2 * ANCIENT_T2_WEIGHT
			. += stats.ancient_T3 * ANCIENT_T3_WEIGHT
			. += stats.elder_T2 * ELDER_T2_WEIGHT
			. += stats.elder_T3 * ELDER_T3_WEIGHT
			. += stats.ancient_queen * ANCIENT_QUEEN_WEIGHT
			. += stats.elder_queen * ELDER_QUEEN_WEIGHT
			. += human_on_ground * HUMAN_LIFE_ON_GROUND_WEIGHT
			. += (GLOB.alive_human_list.len - human_on_ground) * HUMAN_LIFE_ON_SHIP_WEIGHT
			. += GLOB.alive_xeno_list.len * XENOS_LIFE_WEIGHT
			. += (xeno_job.total_positions - xeno_job.current_positions) * BURROWED_LARVA_WEIGHT
			. += stats.miniguns_in_use.len * MINIGUN_PRICE * REQ_POINTS_WEIGHT
			. += stats.sadar_in_use.len * SADAR_PRICE * REQ_POINTS_WEIGHT
			. += stats.b17_in_use.len * B17_PRICE * REQ_POINTS_WEIGHT
			. += stats.b18_in_use.len * B18_PRICE * REQ_POINTS_WEIGHT
			. += SSpoints.supply_points * REQ_POINTS_WEIGHT
			. += stats.OB_available * OB_AVAILABLE_WEIGHT
			. += GLOB.xeno_resin_silos.len * SPAWNING_POOL_WEIGHT
		if(SHUTTERS_CLOSED)	
			. += GLOB.alive_human_list.len * HUMAN_LIFE_WEIGHT_PREGAME
			. += GLOB.alive_xeno_list.len * XENOS_LIFE_WEIGHT_PREGAME
		if(SHIPSIDE)	
			. += GLOB.alive_human_list.len * HUMAN_LIFE_WEIGHT_SHIPSIDE
			. += GLOB.alive_xeno_list.len * XENOS_LIFE_WEIGHT_SHIPSIDE

///Keep the monitor informed about the position of humans
/datum/controller/subsystem/monitor/proc/process_human_positions()
	human_on_ground = 0
	human_in_FOB = 0
	for(var/human in GLOB.alive_human_list)
		var/turf/TU = get_turf(human)
		var/area/myarea = TU.loc
		if(is_ground_level(TU.z))
			human_on_ground++
			if(myarea.flags_area & NEAR_FOB)
				human_in_FOB++

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
	
	if(!gamestate == GROUNDSIDE)
		return
	//We check for possible stalemate
	if (current_state == last_state)
		stale_counter++
	if (stale_counter >= STALEMATE_THRESHOLD)
		stalemate = TRUE
	else
		stalemate = FALSE
