//Loot capture mission
/datum/campaign_mission/capture_mission
	name = "BASE CAPTURE MISSION"
	max_game_time = 12 MINUTES
	///Total number of objectives at round start
	var/objectives_total = 11
	///number of targets to capture for a minor victory
	var/min_capture_amount = 7 //placeholder number
	///How many objectives currently remaining
	var/objectives_remaining = 0
	///How many objects extracted by each team
	var/list/capture_count = list(
		MISSION_STARTING_FACTION = 0,
		MISSION_HOSTILE_FACTION = 0,
	)

/datum/campaign_mission/capture_mission/load_mission()
	. = ..()
	RegisterSignal(SSdcs, COMSIG_GLOB_CAMPAIGN_CAPTURE_OBJECTIVE_CAPTURED, PROC_REF(objective_extracted))
	RegisterSignal(SSdcs, COMSIG_GLOB_CAMPAIGN_CAPTURE_OBJECTIVE_CAP_STARTED, PROC_REF(objective_cap_started))
	objectives_total = length(GLOB.campaign_objectives)
	objectives_remaining = objectives_total
	if(!objectives_total)
		CRASH("Destroy mission loaded with no objectives to extract!")

/datum/campaign_mission/capture_mission/unregister_mission_signals()
	. = ..()
	UnregisterSignal(SSdcs, list(COMSIG_GLOB_CAMPAIGN_CAPTURE_OBJECTIVE_CAPTURED, COMSIG_GLOB_CAMPAIGN_CAPTURE_OBJECTIVE_CAP_STARTED))

/datum/campaign_mission/capture_mission/load_objective_description()
	starting_faction_objective_description = "Major Victory:Capture all [objectives_total] targets.[min_capture_amount ? " Minor Victory: Capture at least [min_capture_amount] targets." : ""]"
	hostile_faction_objective_description = "Major Victory:Capture all [objectives_total] targets.[min_capture_amount ? " Minor Victory: Capture at least [min_capture_amount] targets." : ""]"

/datum/campaign_mission/capture_mission/get_status_tab_items(mob/source, list/items)
	. = ..()

	items += "[starting_faction] objectives captured: [capture_count[MISSION_STARTING_FACTION]]"
	items += "[hostile_faction] objectives captured: [capture_count[MISSION_HOSTILE_FACTION]]"
	items += ""
	items += "Objectives remaining: [objectives_remaining]"
	items += ""

/datum/campaign_mission/capture_mission/check_mission_progress()
	if(outcome)
		return TRUE

	if(!game_timer)
		return FALSE

	if(!max_time_reached && objectives_remaining) //todo: maybe a check in case both teams wipe each other out at the same time...
		return FALSE

	if(capture_count[MISSION_STARTING_FACTION] >= objectives_total)
		message_admins("Mission finished: [MISSION_OUTCOME_MAJOR_VICTORY]")
		outcome = MISSION_OUTCOME_MAJOR_VICTORY
	else if(capture_count[MISSION_HOSTILE_FACTION] >= objectives_total)
		message_admins("Mission finished: [MISSION_OUTCOME_MAJOR_LOSS]")
		outcome = MISSION_OUTCOME_MAJOR_LOSS
	else if(min_capture_amount && (capture_count[MISSION_STARTING_FACTION] >= min_capture_amount))
		message_admins("Mission finished: [MISSION_OUTCOME_MINOR_VICTORY]")
		outcome = MISSION_OUTCOME_MINOR_VICTORY
	else if(min_capture_amount && (capture_count[MISSION_HOSTILE_FACTION] >= min_capture_amount))
		message_admins("Mission finished: [MISSION_OUTCOME_MINOR_LOSS]")
		outcome = MISSION_OUTCOME_MINOR_LOSS
	else
		message_admins("Mission finished: [MISSION_OUTCOME_DRAW]")
		outcome = MISSION_OUTCOME_DRAW
	return TRUE

/datum/campaign_mission/capture_mission/apply_outcome()
	. = ..()
	objective_reward_bonus()

///An objective capture cycle was started
/datum/campaign_mission/capture_mission/proc/objective_cap_started(datum/source, obj/structure/campaign_objective/capture_objective/fultonable/objective, mob/living/user)
	SIGNAL_HANDLER
	var/capturing_team = user.faction
	var/losing_team = objective.capturing_faction

	map_text_broadcast(capturing_team, "[objective] is activating, hold it down until its finished!", "Objective activated")

	if(!losing_team) //no cap was interupted
		losing_team = starting_faction == user.faction ? hostile_faction : starting_faction
		map_text_broadcast(losing_team, "[objective] activation was overridden, take it back!", "Activation cancelled")
	else
		map_text_broadcast(losing_team, "[objective] is being activated by the enemy. Get in there and stop them!", "Enemy activation")

///Handles the effect of an objective being claimed
/datum/campaign_mission/capture_mission/proc/objective_extracted(datum/source, obj/structure/campaign_objective/capture_objective/fultonable/objective, mob/living/user)
	SIGNAL_HANDLER
	var/capturing_team
	var/losing_team
	objectives_remaining --
	if(objective.owning_faction == starting_faction)
		capture_count[MISSION_STARTING_FACTION] ++
		capturing_team = starting_faction
		losing_team = hostile_faction
	else if(objective.owning_faction == hostile_faction)
		capture_count[MISSION_HOSTILE_FACTION] ++
		capturing_team = hostile_faction
		losing_team = starting_faction

	map_text_broadcast(capturing_team, "[objective] secured, well done. [objectives_remaining] left in play!", "Objective extracted")
	map_text_broadcast(losing_team, "We've lost a [objective], secure the remaining [objectives_remaining] objectives!", "Objective lost")

///The addition rewards for capturing objectives, regardless of outcome
/datum/campaign_mission/capture_mission/proc/objective_reward_bonus()
	var/starting_team_bonus = capture_count[MISSION_STARTING_FACTION] * 3
	var/hostile_team_bonus = capture_count[MISSION_HOSTILE_FACTION] * 3

	modify_attrition_points(starting_team_bonus, hostile_team_bonus)
	map_text_broadcast(starting_faction, "[starting_team_bonus] bonus attrition points awarded for the capture of [capture_count[MISSION_STARTING_FACTION]] objectives", "Bonus reward")
	map_text_broadcast(hostile_faction, "[hostile_team_bonus] bonus attrition points awarded for the capture of [capture_count[MISSION_HOSTILE_FACTION]] objectives", "Bonus reward")
