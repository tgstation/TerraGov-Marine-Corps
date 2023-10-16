/////basic destroy stuff mission////////
/datum/campaign_mission/destroy_mission
	name = "Target Destruction" //(tm)
	map_name = "Ice Caves"
	map_file = '_maps/map_files/icy_caves/icy_caves.dmm'
	max_game_time = 12 MINUTES
	victory_point_rewards = list(
		MISSION_OUTCOME_MAJOR_VICTORY = list(3, 0),
		MISSION_OUTCOME_MINOR_VICTORY = list(1, 0),
		MISSION_OUTCOME_DRAW = list(0, 0),
		MISSION_OUTCOME_MINOR_LOSS = list(0, 1),
		MISSION_OUTCOME_MAJOR_LOSS = list(0, 3),
	)
	attrition_point_rewards = list(
		MISSION_OUTCOME_MAJOR_VICTORY = list(20, 5),
		MISSION_OUTCOME_MINOR_VICTORY = list(15, 10),
		MISSION_OUTCOME_DRAW = list(10, 10),
		MISSION_OUTCOME_MINOR_LOSS = list(10, 15),
		MISSION_OUTCOME_MAJOR_LOSS = list(5, 20),
	)
	///Total number of objectives at round start
	var/objectives_total = 3
	///number of targets destroyed for a minor victory
	var/min_destruction_amount = 2 //placeholder number
	///How many objectives currently destroyed
	var/objectives_destroyed = 0
	///Overwatch messages for destroying objectives
	var/list/objective_destruction_messages = list(
		"first" = list(
			"starting_faction" = "First objective destroyed, keep it up!",
			"hostile_faction" = "We've lost an objective, regroup and drive them back!",
		),
		"second" = list(
			"starting_faction" = "Another objective destroyed, press the advantage!",
			"hostile_faction" = "We've lost another objective, get it together team!",
		),
		"third" = list(
			"starting_faction" = "Objective down, nice work team!",
			"hostile_faction" = "We've lost another, shore up those defences!",
		),
		"second_last" = list(
			"starting_faction" = "Scratch another, that's just one to go. Finish them off!",
			"hostile_faction" = "Objective destroyed, protect the last objective at all costs!",
		),
		"last" = list(
			"starting_faction" = "All objectives destroyed, outstanding!",
			"hostile_faction" = "All objectives destroyed, fallback, fallback!",
		),
	)

/datum/campaign_mission/destroy_mission/load_mission()
	. = ..()
	RegisterSignal(SSdcs, COMSIG_GLOB_CAMPAIGN_OBJECTIVE_DESTROYED, PROC_REF(objective_destroyed))
	objectives_total = length(GLOB.campaign_objectives)
	if(!objectives_total)
		CRASH("Destroy mission loaded with no objectives to destroy!")

/datum/campaign_mission/destroy_mission/load_pre_mission_bonuses()
	new /obj/item/storage/box/crate/loot/materials_pack(get_turf(pick(GLOB.campaign_reward_spawners[hostile_faction])))

	for(var/i = 1 to objectives_total)
		new /obj/item/explosive/plastique(get_turf(pick(GLOB.campaign_reward_spawners[starting_faction])))

/datum/campaign_mission/destroy_mission/load_objective_description()
	starting_faction_objective_description = "Major Victory:Destroy all [objectives_total] targets.[min_destruction_amount ? " Minor Victory: Destroy at least [min_destruction_amount] targets." : ""]"
	hostile_faction_objective_description = "Major Victory: Protect all [objectives_total] assets from destruction.[min_destruction_amount ? " Minor Victory: Protect at least [objectives_total - min_destruction_amount + 1] assets." : ""]"

/datum/campaign_mission/destroy_mission/get_status_tab_items(mob/source, list/items)
	. = ..()

	items += "Objectives destroyed: [objectives_destroyed]"
	items += ""
	items += "Objectives remaining: [objectives_total - objectives_destroyed]"
	items += ""

/datum/campaign_mission/destroy_mission/end_mission()
	UnregisterSignal(SSdcs, COMSIG_GLOB_CAMPAIGN_OBJECTIVE_DESTROYED)
	return ..()

/datum/campaign_mission/destroy_mission/check_mission_progress()
	if(outcome)
		return TRUE

	if(!game_timer)
		return FALSE

	if(!length(GLOB.campaign_objectives))
		message_admins("Mission finished: [MISSION_OUTCOME_MAJOR_VICTORY]")
		outcome = MISSION_OUTCOME_MAJOR_VICTORY
		return TRUE

	if(!max_time_reached) //if there is still time on the clock, game continues UNLESS attacking side is completely spent
		if(mode.stat_list[starting_faction].active_attrition_points)
			return FALSE //attacking team still has more bodies to throw into the fight
		var/list/player_list = count_humans(count_flags = COUNT_IGNORE_ALIVE_SSD)
		if(length(player_list[1]))
			return FALSE //attacking team still has living guys

	if(min_destruction_amount && objectives_destroyed >= min_destruction_amount) //Destroyed at least the minimum required
		message_admins("Mission finished: [MISSION_OUTCOME_MINOR_VICTORY]")
		outcome = MISSION_OUTCOME_MINOR_VICTORY
	else if(objectives_destroyed > 0) //Destroyed atleast 1 target
		message_admins("Mission finished: [MISSION_OUTCOME_MINOR_LOSS]")
		outcome = MISSION_OUTCOME_MINOR_LOSS
	else //Destroyed nothing
		message_admins("Mission finished: [MISSION_OUTCOME_MAJOR_LOSS]")
		outcome = MISSION_OUTCOME_MAJOR_LOSS
	return TRUE

//todo: remove these if nothing new is added
/datum/campaign_mission/destroy_mission/apply_major_victory()
	. = ..()

/datum/campaign_mission/destroy_mission/apply_minor_victory()
	. = ..()

/datum/campaign_mission/destroy_mission/apply_minor_loss()
	. = ..()

/datum/campaign_mission/destroy_mission/apply_major_loss()
	. = ..()

///Handles the destruction of an objective
/datum/campaign_mission/destroy_mission/proc/objective_destroyed(datum/source, atom/destroyed_objective)
	SIGNAL_HANDLER
	objectives_destroyed ++
	var/message_to_play
	if(objectives_destroyed == objectives_total)
		message_to_play = "last"
	else if(objectives_destroyed == objectives_total - 1)
		message_to_play = "second_last"
	else if(objectives_destroyed == 1)
		message_to_play = "first"
	else if(objectives_destroyed == 2)
		message_to_play = "second"
	else //catch all if a mission has a million objectives
		message_to_play = "third"

	map_text_broadcast(starting_faction, objective_destruction_messages[message_to_play]["starting_faction"], "[destroyed_objective] destroyed")
	map_text_broadcast(hostile_faction, objective_destruction_messages[message_to_play]["hostile_faction"], "[destroyed_objective] destroyed")
