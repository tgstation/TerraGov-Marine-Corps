//Loot capture mission
/datum/campaign_mission/capture_mission
	name = "Capture mission"
	map_name = "Orion Outpost"
	map_file = '_maps/map_files/Campaign maps/jungle_test/jungle_outpost.dmm'
	max_game_time = 20 MINUTES
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

	mission_brief = list(
		"starting_faction" = "Hostile forces have been building a stock pile of valuable phoron in this location. <br>\
		Before they have the chance to ship it out, your forces are being sent to intercept and liberate these supplies to hamper the enemy's war effort. <br>\
		Hostile forces will likely be aiming to evacuate as much phoron out of the ao as well. Get to the phoron first and fulton out as much as you can.",
		"hostile_faction" = "Enemy forces are moving to steal a stockpile of valuable phoron. <br>\
		Send in your forces to fulton out the phoron as quickly as possible, before they can get to it first.",
	)

	additional_rewards = list(
		"starting_faction" = "Additional supplies for every phoron crate captured",
		"hostile_faction" = "Additional supplies for every phoron crate captured",
	)
	///Total number of objectives at round start
	var/objectives_total = 3
	///number of targets to capture for a minor victory
	var/min_capture_amount = 10 //placeholder number
	///How many objectives currently remaining
	var/objectives_remaining = 0
	///How many objects extracted by each team
	var/list/capture_count = list(
		"starting_faction" = 0,
		"hostile_faction" = 0,
	)

/datum/campaign_mission/capture_mission/load_mission()
	. = ..()
	RegisterSignal(SSdcs, COMSIG_GLOB_CAMPAIGN_CAPTURE_OBJECTIVE_CAPTURED, PROC_REF(objective_extracted))
	objectives_total = length(GLOB.campaign_objectives)
	objectives_remaining = objectives_total
	if(!objectives_total)
		CRASH("Destroy mission loaded with no objectives to extract!")

/datum/campaign_mission/capture_mission/load_objective_description()
	objective_description = list(
		"starting_faction" = "Major Victory:Capture all [objectives_total] targets.[min_capture_amount ? " Minor Victory: Capture at least [min_capture_amount] targets." : ""]",
		"hostile_faction" = "Major Victory:Capture all [objectives_total] targets.[min_capture_amount ? " Minor Victory: Capture at least [min_capture_amount] targets." : ""]",
	)

/datum/campaign_mission/capture_mission/end_mission()
	UnregisterSignal(SSdcs, COMSIG_GLOB_CAMPAIGN_CAPTURE_OBJECTIVE_CAPTURED)
	return ..()

/datum/campaign_mission/capture_mission/check_mission_progress()
	if(outcome)
		return TRUE

	if(!game_timer)
		return FALSE

	if(!max_time_reached && objectives_remaining) //todo: maybe a check in case both teams wipe each other out at the same time...
		return FALSE

	if(capture_count["starting_faction"] >= objectives_total)
		message_admins("Mission finished: [MISSION_OUTCOME_MAJOR_VICTORY]")
		outcome = MISSION_OUTCOME_MAJOR_VICTORY
	else if(capture_count["hostile_faction"] >= objectives_total)
		message_admins("Mission finished: [MISSION_OUTCOME_MAJOR_LOSS]")
		outcome = MISSION_OUTCOME_MAJOR_LOSS
	else if(min_capture_amount && (capture_count["starting_faction"] >= min_capture_amount))
		message_admins("Mission finished: [MISSION_OUTCOME_MINOR_VICTORY]")
		outcome = MISSION_OUTCOME_MINOR_VICTORY
	else if(min_capture_amount && (capture_count["hostile_faction"] >= min_capture_amount))
		message_admins("Mission finished: [MISSION_OUTCOME_MINOR_LOSS]")
		outcome = MISSION_OUTCOME_MINOR_LOSS
	else
		message_admins("Mission finished: [MISSION_OUTCOME_DRAW]") //everyone died at the same time, no one wins
		outcome = MISSION_OUTCOME_DRAW
	return TRUE


//todo: add some logic to modify rewards based on crates captured
/datum/campaign_mission/capture_mission/apply_major_victory()
	. = ..()

/datum/campaign_mission/capture_mission/apply_minor_victory()
	. = ..()

/datum/campaign_mission/capture_mission/apply_minor_loss()
	. = ..()

/datum/campaign_mission/capture_mission/apply_major_loss()
	. = ..()

/datum/campaign_mission/capture_mission/proc/objective_extracted(datum/source, obj/structure/campaign_objective/capture_objective/fultonable/objective, mob/living/user)
	SIGNAL_HANDLER
	var/capturing_team
	var/losing_team
	objectives_remaining --
	if(objective.owning_faction == starting_faction)
		capture_count["starting_faction"] ++
		capturing_team = starting_faction
		losing_team = hostile_faction
	else if(objective.owning_faction == hostile_faction)
		capture_count["hostile_faction"] ++
		capturing_team = hostile_faction
		losing_team = starting_faction

	map_text_broadcast(capturing_team, "[objective] secured, well done. [objectives_remaining] left in play!", "Objective extracted")
	map_text_broadcast(losing_team, "We've lost a [objective], secure the remaining [objectives_remaining] objectives!", "Objective lost")
