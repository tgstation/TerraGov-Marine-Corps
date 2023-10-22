//Loot capture mission
/datum/campaign_mission/capture_mission
	name = "Phoron retrieval"
	mission_icon = "phoron_raid"
	map_name = "Jungle outpost SR-422"
	map_file = '_maps/map_files/Campaign maps/jungle_outpost/jungle_outpost.dmm'
	map_traits = list(ZTRAIT_AWAY = TRUE, ZTRAIT_RAIN = TRUE)
	map_light_colours = list(LIGHT_COLOR_PALE_GREEN, LIGHT_COLOR_PALE_GREEN, LIGHT_COLOR_PALE_GREEN, LIGHT_COLOR_PALE_GREEN)
	max_game_time = 12 MINUTES
	mission_flags = MISSION_DISALLOW_DROPPODS|MISSION_DISALLOW_TELEPORT
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
	intro_message = list(
		"starting_faction" = "Locate and extract all phoron crates in the ao before the enemy does.",
		"hostile_faction" = "Locate and extract all phoron crates in the ao before the enemy does.",
	)
	starting_faction_mission_brief = "Hostile forces have been building a stock pile of valuable phoron in this location. \
		Before they have the chance to ship it out, your forces are being sent to intercept and liberate these supplies to hamper the enemy's war effort. \
		Hostile forces will likely be aiming to evacuate as much phoron out of the ao as well. Get to the phoron first and fulton out as much as you can."
	hostile_faction_mission_brief = "Enemy forces are moving to steal a stockpile of valuable phoron. \
		Send in your forces to fulton out the phoron as quickly as possible, before they can get to it first."
	starting_faction_additional_rewards = "Additional supplies for every phoron crate captured"
	hostile_faction_additional_rewards = "Additional supplies for every phoron crate captured"
	///Total number of objectives at round start
	var/objectives_total = 11
	///number of targets to capture for a minor victory
	var/min_capture_amount = 7 //placeholder number
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
	RegisterSignal(SSdcs, COMSIG_GLOB_CAMPAIGN_CAPTURE_OBJECTIVE_CAP_STARTED, PROC_REF(objective_cap_started))
	objectives_total = length(GLOB.campaign_objectives)
	objectives_remaining = objectives_total
	if(!objectives_total)
		CRASH("Destroy mission loaded with no objectives to extract!")

/datum/campaign_mission/capture_mission/load_objective_description()
	starting_faction_objective_description = "Major Victory:Capture all [objectives_total] targets.[min_capture_amount ? " Minor Victory: Capture at least [min_capture_amount] targets." : ""]"
	hostile_faction_objective_description = "Major Victory:Capture all [objectives_total] targets.[min_capture_amount ? " Minor Victory: Capture at least [min_capture_amount] targets." : ""]"

/datum/campaign_mission/capture_mission/get_status_tab_items(mob/source, list/items)
	. = ..()

	items += "[starting_faction] objectives captured: [capture_count["starting_faction"]]"
	items += "[hostile_faction] objectives captured: [capture_count["hostile_faction"]]"
	items += ""
	items += "Objectives remaining: [objectives_remaining]"
	items += ""


/datum/campaign_mission/capture_mission/end_mission()
	. = ..()
	UnregisterSignal(SSdcs, list(COMSIG_GLOB_CAMPAIGN_CAPTURE_OBJECTIVE_CAPTURED, COMSIG_GLOB_CAMPAIGN_CAPTURE_OBJECTIVE_CAP_STARTED))

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
		message_admins("Mission finished: [MISSION_OUTCOME_DRAW]")
		outcome = MISSION_OUTCOME_DRAW
	return TRUE

/datum/campaign_mission/capture_mission/apply_major_victory()
	. = ..()
	objective_reward_bonus()

/datum/campaign_mission/capture_mission/apply_minor_victory()
	. = ..()
	objective_reward_bonus()

/datum/campaign_mission/capture_mission/apply_minor_loss()
	. = ..()
	objective_reward_bonus()

/datum/campaign_mission/capture_mission/apply_major_loss()
	. = ..()
	objective_reward_bonus()

/datum/campaign_mission/capture_mission/apply_draw()
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
		capture_count["starting_faction"] ++
		capturing_team = starting_faction
		losing_team = hostile_faction
	else if(objective.owning_faction == hostile_faction)
		capture_count["hostile_faction"] ++
		capturing_team = hostile_faction
		losing_team = starting_faction

	map_text_broadcast(capturing_team, "[objective] secured, well done. [objectives_remaining] left in play!", "Objective extracted")
	map_text_broadcast(losing_team, "We've lost a [objective], secure the remaining [objectives_remaining] objectives!", "Objective lost")

///The addition rewards for capturing objectives, regardless of outcome
/datum/campaign_mission/capture_mission/proc/objective_reward_bonus()
	var/starting_team_bonus = capture_count["starting_faction"] * 4
	var/hostile_team_bonus = capture_count["hostile_faction"] * 2

	modify_attrition_points(starting_team_bonus, hostile_team_bonus)
	map_text_broadcast(starting_faction, "[starting_team_bonus] bonus attrition points awarded for the capture of [capture_count["starting_faction"]] objectives", "Bonus reward")
	map_text_broadcast(hostile_faction, "[hostile_team_bonus] bonus attrition points awarded for the capture of [capture_count["hostile_faction"]] objectives", "Bonus reward")
