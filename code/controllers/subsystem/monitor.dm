SUBSYSTEM_DEF(monitor)
	name = "Monitor"
	init_order = INIT_ORDER_MONITOR
	runlevels = RUNLEVEL_GAME
	///The next world.time for wich the monitor subsystem refresh the state
	var/scheduled = 0
	///The current state
	var/current_state = STATE_BALANCED
	///The last state
	var/last_state = STATE_BALANCED
	///If we consider the state as a stalemate
	var/stalemate = FALSE
	///The current state points
	var/current_points = 0
	///The amount of time we had the same state consecutly
	var/stale_counter = 0


/datum/controller/subsystem/monitor/Initialize(time, zlevel)
	if(CONFIG_GET(flag/monitor_disallowed))
		can_fire = 0
	reschedule()
	return ..()

/datum/controller/subsystem/monitor/fire(resumed = 0)
	if(!resumed)
		check_state() //only check these if we aren't resuming a paused fire


///checks if we should refresh the director state, and reschedules if necessary
/datum/controller/subsystem/monitor/proc/check_state()
    if(scheduled <= world.time)
        etablish_state()
        reschedule()

///decides which world.time we should calculate a new monitor state at.
/datum/controller/subsystem/monitor/proc/reschedule()
	scheduled = world.time + FREQUENCY_STATE_CALCULATION

///Start the calculation
/datum/controller/subsystem/monitor/proc/etablish_state()
	current_points = calculate_state_points() / max(GLOB.alive_human_list.len + GLOB.alive_xeno_list.len,20)//having less than 20 players gives bad results
	set_state(current_points)
	//spam_admins() only for testing

///Messages admin with the current state
/datum/controller/subsystem/monitor/proc/spam_admins()
	message_admins("New state calculated by the monitor, state : [current_state] , exact balance points : [current_points]")

	
///Calculate the points supposedly representating of the situation	
/datum/controller/subsystem/monitor/proc/calculate_state_points()
	var/actualPoints = 0
	var/datum/job/xeno_job = SSjob.GetJobType(/datum/job/xenomorph)
	actualPoints += GLOB.monitor_statistics.Ancient_T2 * ANCIENT_T2_WEIGHT
	actualPoints += GLOB.monitor_statistics.Ancient_T3 * ANCIENT_T3_WEIGHT
	actualPoints += GLOB.monitor_statistics.Elder_T2 * ELDER_T2_WEIGHT
	actualPoints += GLOB.monitor_statistics.Elder_T3 * ELDER_T3_WEIGHT
	actualPoints += GLOB.monitor_statistics.Ancient_Queen * ANCIENT_QUEEN_WEIGHT
	actualPoints += GLOB.monitor_statistics.Elder_Queen * ELDER_QUEEN_WEIGHT
	actualPoints += GLOB.alive_human_list.len * HUMAN_LIFE_WEIGHT
	actualPoints += GLOB.alive_xeno_list.len * XENOS_LIFE_WEIGHT
	actualPoints += (xeno_job.total_positions - xeno_job.current_positions) * BURROWED_LARVA_WEIGHT
	actualPoints += GLOB.monitor_statistics.Miniguns_in_use.len * MINIGUN_PRICE * REQ_POINTS_WEIGHT
	actualPoints += GLOB.monitor_statistics.SADAR_in_use.len * SADAR_PRICE * REQ_POINTS_WEIGHT
	actualPoints += GLOB.monitor_statistics.B17_in_use.len * B17_PRICE * REQ_POINTS_WEIGHT
	actualPoints += GLOB.monitor_statistics.B18_in_use.len * B18_PRICE * REQ_POINTS_WEIGHT
	actualPoints += SSpoints.supply_points * REQ_POINTS_WEIGHT
	actualPoints += GLOB.monitor_statistics.OB_available * OB_AVAILABLE_WEIGHT
	return actualPoints

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
	
	//We check for possible stalemate
	if (current_state == last_state)
		stale_counter++
	if (stale_counter >= STALEMATE_THRESHOLD)
		stalemate = TRUE
	else
		stalemate = FALSE




