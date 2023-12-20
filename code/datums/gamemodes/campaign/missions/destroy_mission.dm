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
		MISSION_OUTCOME_MAJOR_VICTORY = list(10, 0),
		MISSION_OUTCOME_MINOR_VICTORY = list(5, 0),
		MISSION_OUTCOME_DRAW = list(0, 0),
		MISSION_OUTCOME_MINOR_LOSS = list(0, 10),
		MISSION_OUTCOME_MAJOR_LOSS = list(0, 15),
	)
	///The faction trying to destroy objectives
	var/attacking_faction
	///The faction trying to protect objectives
	var/defending_faction
	///Total number of objectives at round start
	var/objectives_total = 3
	///number of targets destroyed for a minor victory
	var/min_destruction_amount = 2 //placeholder number
	///How many objectives currently destroyed
	var/objectives_destroyed = 0
	///Overwatch messages for destroying objectives
	var/list/objective_destruction_messages = list(
		"first" = list(
			MISSION_ATTACKING_FACTION = "First objective destroyed, keep it up!",
			MISSION_DEFENDING_FACTION = "We've lost an objective, regroup and drive them back!",
		),
		"second" = list(
			MISSION_ATTACKING_FACTION = "Another objective destroyed, press the advantage!",
			MISSION_DEFENDING_FACTION = "We've lost another objective, get it together team!",
		),
		"third" = list(
			MISSION_ATTACKING_FACTION = "Objective down, nice work team!",
			MISSION_DEFENDING_FACTION = "We've lost another, shore up those defences!",
		),
		"second_last" = list(
			MISSION_ATTACKING_FACTION = "Scratch another, that's just one to go. Finish them off!",
			MISSION_DEFENDING_FACTION = "Objective destroyed, protect the last objective at all costs!",
		),
		"last" = list(
			MISSION_ATTACKING_FACTION = "All objectives destroyed, outstanding!",
			MISSION_DEFENDING_FACTION = "All objectives destroyed, fallback, fallback!",
		),
	)

/datum/campaign_mission/destroy_mission/New(initiating_faction)
	. = ..()
	set_factions()

/datum/campaign_mission/destroy_mission/load_mission()
	. = ..()
	RegisterSignal(SSdcs, COMSIG_GLOB_CAMPAIGN_OBJECTIVE_DESTROYED, PROC_REF(objective_destroyed))
	objectives_total = length(GLOB.campaign_objectives)
	if(!objectives_total)
		CRASH("Destroy mission loaded with no objectives to destroy!")

/datum/campaign_mission/destroy_mission/unregister_mission_signals()
	. = ..()
	UnregisterSignal(SSdcs, COMSIG_GLOB_CAMPAIGN_OBJECTIVE_DESTROYED)

/datum/campaign_mission/destroy_mission/load_pre_mission_bonuses()
	new /obj/item/storage/box/crate/loot/materials_pack(get_turf(pick(GLOB.campaign_reward_spawners[defending_faction])))

	for(var/i = 1 to objectives_total)
		new /obj/item/explosive/plastique(get_turf(pick(GLOB.campaign_reward_spawners[attacking_faction])))

/datum/campaign_mission/destroy_mission/load_objective_description()
	starting_faction_objective_description = "Major Victory:Destroy all [objectives_total] targets.[min_destruction_amount ? " Minor Victory: Destroy at least [min_destruction_amount] targets." : ""]"
	hostile_faction_objective_description = "Major Victory: Protect all [objectives_total] assets from destruction.[min_destruction_amount ? " Minor Victory: Protect at least [objectives_total - min_destruction_amount + 1] assets." : ""]"

/datum/campaign_mission/destroy_mission/get_status_tab_items(mob/source, list/items)
	. = ..()

	items += "Objectives destroyed: [objectives_destroyed]"
	items += ""
	items += "Objectives remaining: [objectives_total - objectives_destroyed]"
	items += ""

/datum/campaign_mission/destroy_mission/check_mission_progress()
	if(outcome)
		return TRUE

	if(!game_timer)
		return FALSE

	if(!length(GLOB.campaign_objectives))
		message_admins("Mission finished: [attacking_faction == starting_faction ? MISSION_OUTCOME_MAJOR_VICTORY : MISSION_OUTCOME_MAJOR_LOSS]")
		outcome = attacking_faction == starting_faction ? MISSION_OUTCOME_MAJOR_VICTORY : MISSION_OUTCOME_MAJOR_LOSS
		return TRUE

	if(!max_time_reached) //if there is still time on the clock, game continues UNLESS attacking side is completely spent
		if(mode.stat_list[attacking_faction].active_attrition_points)
			return FALSE //attacking team still has more bodies to throw into the fight
		var/list/player_list = count_humans(count_flags = COUNT_IGNORE_ALIVE_SSD)
		if(length(player_list[attacking_faction == starting_faction ? 1 : 3]))
			return FALSE //attacking team still has living guys

	if(min_destruction_amount && objectives_destroyed >= min_destruction_amount) //Destroyed at least the minimum required
		message_admins("Mission finished: [attacking_faction == starting_faction ? MISSION_OUTCOME_MINOR_VICTORY : MISSION_OUTCOME_MINOR_LOSS]")
		outcome = attacking_faction == starting_faction ? MISSION_OUTCOME_MINOR_VICTORY : MISSION_OUTCOME_MINOR_LOSS
	else if(objectives_destroyed > 0) //Destroyed atleast 1 target
		message_admins("Mission finished: [attacking_faction == starting_faction ? MISSION_OUTCOME_MINOR_LOSS : MISSION_OUTCOME_MINOR_VICTORY]")
		outcome = attacking_faction == starting_faction ? MISSION_OUTCOME_MINOR_LOSS : MISSION_OUTCOME_MINOR_VICTORY
	else //Destroyed nothing
		message_admins("Mission finished: [attacking_faction == starting_faction ? MISSION_OUTCOME_MAJOR_LOSS : MISSION_OUTCOME_MAJOR_VICTORY]")
		outcome = attacking_faction == starting_faction ? MISSION_OUTCOME_MAJOR_LOSS : MISSION_OUTCOME_MAJOR_VICTORY
	return TRUE

///Sets the attacking and defending faction. Can be overridden to make the starting faction defenders
/datum/campaign_mission/destroy_mission/proc/set_factions()
	attacking_faction = starting_faction
	defending_faction = hostile_faction

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

	map_text_broadcast(attacking_faction, objective_destruction_messages[message_to_play][MISSION_ATTACKING_FACTION], "[destroyed_objective] destroyed")
	map_text_broadcast(defending_faction, objective_destruction_messages[message_to_play][MISSION_DEFENDING_FACTION], "[destroyed_objective] destroyed")
