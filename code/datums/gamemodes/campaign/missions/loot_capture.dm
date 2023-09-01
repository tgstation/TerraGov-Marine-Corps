//Loot capture mission
/datum/campaign_mission/loot_capture
	name = "Capture mission"
	map_name = "Orion Outpost"
	map_file = '_maps/map_files/Campaign maps/jungle_test/jungle_outpost.dmm'
	objective_description = list(
		"starting_faction" = "Major Victory: Wipe out all hostiles in the area of operation. Minor Victory: Eliminate more hostiles than you lose.",
		"hostile_faction" = "Major Victory: Wipe out all hostiles in the area of operation. Minor Victory: Eliminate more hostiles than you lose.",
	)
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
		"starting_faction" = "Hostile forces have been attempting to expand the territory under their control in this area. <br>\
		Although this territory is of limited direct strategic value, \
		to prevent them from establishing a permanent presence in the area command has ordered your battalion to execute force recon patrols to locate and eliminate any hostile presence. <br>\
		Eliminate all hostiles you come across while preserving your own forces. Good hunting.",
		"hostile_faction" = "Intelligence indicates that hostile forces are massing for a coordinated push to dislodge us from territory where we are aiming to establish a permanent presence. <br>\
		Your battalion has been issued orders to regroup and counter attack the enemy push before they can make any progress, and kill their ambitions in this region. <br>\
		Eliminate all hostiles you come across while preserving your own forces. Good hunting.",
	)

	additional_rewards = list(
		"starting_faction" = "If the enemy force is wiped out entirely, additional supplies can be diverted to your battalion.",
		"hostile_faction" = "If the enemy force is wiped out entirely, additional supplies can be diverted to your battalion.",
	)
	///Total number of objectives at round start
	var/objectives_total = 3
	///number of targets destroyed for a minor victory
	var/min_capture_amount = 2 //placeholder number
	///How many objectives currently destroyed
	var/objectives_remaining = 0

	var/list/extracted_count = list(
		"starting_faction" = 0,
		"hostile_faction" = 0,
	)

/datum/campaign_mission/loot_capture/load_mission()
	. = ..()
	RegisterSignal(SSdcs, COMSIG_GLOB_CAMPAIGN_FULTON_OBJECTIVE_EXTRACTED, PROC_REF(objective_extracted))
	objectives_total = length(GLOB.campaign_objectives)
	objectives_remaining = objectives_total
	if(!objectives_total)
		CRASH("Destroy mission loaded with no objectives to extract!")

/datum/campaign_mission/loot_capture/load_objective_description()
	objective_description = list(
		"starting_faction" = "Major Victory:Capture all [objectives_total] targets.[min_capture_amount ? " Minor Victory: Capture at least [min_capture_amount] targets." : ""]",
		"hostile_faction" = "Major Victory:Capture all [objectives_total] targets.[min_capture_amount ? " Minor Victory: Capture at least [min_capture_amount] targets." : ""]",
	)

/datum/campaign_mission/loot_capture/end_mission()
	UnregisterSignal(SSdcs, COMSIG_GLOB_CAMPAIGN_FULTON_OBJECTIVE_EXTRACTED)
	return ..()

/datum/campaign_mission/loot_capture/check_mission_progress()
	if(outcome)
		return TRUE

	if(!game_timer)
		return FALSE

	if(!max_time_reached && objectives_remaining) //todo: maybe a check in case both teams wipe each other out at the same time...
		return FALSE

	if(extracted_count["starting_faction"] >= objectives_total)
		message_admins("Mission finished: [MISSION_OUTCOME_MAJOR_VICTORY]")
		outcome = MISSION_OUTCOME_MAJOR_VICTORY
	else if(extracted_count["hostile_faction"] >= objectives_total)
		message_admins("Mission finished: [MISSION_OUTCOME_MAJOR_LOSS]")
		outcome = MISSION_OUTCOME_MAJOR_LOSS
	else if(min_capture_amount && (extracted_count["starting_faction"] >= min_capture_amount))
		message_admins("Mission finished: [MISSION_OUTCOME_MINOR_VICTORY]")
		outcome = MISSION_OUTCOME_MINOR_VICTORY
	else if(min_capture_amount && (extracted_count["hostile_faction"] >= min_capture_amount))
		message_admins("Mission finished: [MISSION_OUTCOME_MINOR_LOSS]")
		outcome = MISSION_OUTCOME_MINOR_LOSS
	else
		message_admins("Mission finished: [MISSION_OUTCOME_DRAW]") //everyone died at the same time, no one wins
		outcome = MISSION_OUTCOME_DRAW
	return TRUE


//todo: remove these if nothing new is added
/datum/campaign_mission/loot_capture/apply_major_victory()
	. = ..()

/datum/campaign_mission/loot_capture/apply_minor_victory()
	. = ..()

/datum/campaign_mission/loot_capture/apply_minor_loss()
	. = ..()

/datum/campaign_mission/loot_capture/apply_major_loss()
	. = ..()

/datum/campaign_mission/loot_capture/proc/objective_extracted(obj/structure/campaign/fulton_objective/objective, mob/living/user)
	SIGNAL_HANDLER
	var/capturing_team
	var/losing_team
	objectives_remaining --
	if(user.faction == starting_faction)
		extracted_count["starting_faction"] ++
		capturing_team = starting_faction
		losing_team = hostile_faction
	else if(user.faction == hostile_faction)
		extracted_count["hostile_faction"] ++
		capturing_team = hostile_faction
		losing_team = starting_faction

	map_text_broadcast(capturing_team, "[objective] secured, well done. [objectives_remaining] left in play!", "Objective extracted")
	map_text_broadcast(losing_team, "We've lost a [objective], secure the remaining [objectives_remaining] objectives!", "Objective lost")
