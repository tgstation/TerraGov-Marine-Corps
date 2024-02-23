//ASAT capture mission
/datum/campaign_mission/capture_mission/asat
	name = "ASAT capture"
	mission_icon = "asat_capture"
	map_name = "Lawanka Outpost"
	map_file = '_maps/map_files/Lawanka_Outpost/LawankaOutpost.dmm'
	map_traits = list(ZTRAIT_AWAY = TRUE, ZTRAIT_RAIN = TRUE)
	map_light_colours = list(LIGHT_COLOR_PALE_GREEN, LIGHT_COLOR_PALE_GREEN, LIGHT_COLOR_PALE_GREEN, LIGHT_COLOR_PALE_GREEN)
	mission_flags = MISSION_DISALLOW_TELEPORT
	max_game_time = 10 MINUTES
	shutter_open_delay = list(
		MISSION_STARTING_FACTION = 90 SECONDS,
		MISSION_HOSTILE_FACTION = 0,
	)
	victory_point_rewards = list(
		MISSION_OUTCOME_MAJOR_VICTORY = list(2, 0),
		MISSION_OUTCOME_MINOR_VICTORY = list(1, 0),
		MISSION_OUTCOME_DRAW = list(0, 0),
		MISSION_OUTCOME_MINOR_LOSS = list(0, 1),
		MISSION_OUTCOME_MAJOR_LOSS = list(0, 2),
	)
	attrition_point_rewards = list(
		MISSION_OUTCOME_MAJOR_VICTORY = list(10, 0),
		MISSION_OUTCOME_MINOR_VICTORY = list(5, 0),
		MISSION_OUTCOME_DRAW = list(0, 0),
		MISSION_OUTCOME_MINOR_LOSS = list(0, 10),
		MISSION_OUTCOME_MAJOR_LOSS = list(0, 15),
	)
	intro_message = list(
		MISSION_STARTING_FACTION = "Locate and recover all ASAT systems in the AO before the enemy has time to respond.",
		MISSION_HOSTILE_FACTION = "Protect all ASAT systems in the AO from the SOM attack.",
	)
	starting_faction_mission_brief = "A TGMC ASAT battery has been detected in this location. It forms part if their space defense grid across the planet and so is a valuable installation to them. \
		Although the destruction of this site is unlikely to weaken their space defenses appreciably, \
		the capture of these weapons would provide us with a unique opportunity to bypass parts of their own ship defenses. \
		Capture as many of the weapons as possible so we can put them to proper use."
	hostile_faction_mission_brief = "SOM forces are moving towards one our our ASAT installations in this location. \
		The loss of this installation would weaken our space defense grid which currently guarantees our orbital superiority. \
		Protect the ASAT weapons at all costs. Do not allow them to be destroyed or to fall into enemy hands."
	starting_faction_additional_rewards = "Additional ICC support, ability to counteract TGMC drop pod usage"
	hostile_faction_additional_rewards = "Preserve the ability to use drop pods uncontested"

	objectives_total = 6
	min_capture_amount = 5

/datum/campaign_mission/capture_mission/asat/load_pre_mission_bonuses()
	. = ..()
	spawn_mech(hostile_faction, 0, 0, 5)
	spawn_mech(starting_faction, 0, 1, 1)

	var/datum/faction_stats/attacking_team = mode.stat_list[starting_faction]
	attacking_team.add_asset(/datum/campaign_asset/asset_disabler/som_cas/instant)

/datum/campaign_mission/capture_mission/asat/load_objective_description()
	starting_faction_objective_description = "Major Victory:Capture all [objectives_total] ASAT systems.[min_capture_amount ? " Minor Victory: Capture at least [min_capture_amount] ASAT systems." : ""]"
	hostile_faction_objective_description = "Major Victory:Prevent the capture of all [objectives_total] ASAT systems.[min_capture_amount ? " Minor Victory: Prevent the capture of atleast [objectives_total - min_capture_amount + 1] ASAT systems." : ""]"

/datum/campaign_mission/capture_mission/asat/check_mission_progress()
	if(outcome)
		return TRUE

	if(!game_timer)
		return FALSE

	if(!max_time_reached && objectives_remaining)
		return FALSE

	if(capture_count[MISSION_STARTING_FACTION] >= objectives_total)
		message_admins("Mission finished: [MISSION_OUTCOME_MAJOR_VICTORY]")
		outcome = MISSION_OUTCOME_MAJOR_VICTORY
	else if(min_capture_amount && (capture_count[MISSION_STARTING_FACTION] >= min_capture_amount))
		message_admins("Mission finished: [MISSION_OUTCOME_MINOR_VICTORY]")
		outcome = MISSION_OUTCOME_MINOR_VICTORY
	else if(capture_count[MISSION_STARTING_FACTION] > 0)
		message_admins("Mission finished: [MISSION_OUTCOME_MINOR_LOSS]")
		outcome = MISSION_OUTCOME_MINOR_LOSS
	else
		message_admins("Mission finished: [MISSION_OUTCOME_MAJOR_LOSS]")
		outcome = MISSION_OUTCOME_MAJOR_LOSS
	return TRUE

/datum/campaign_mission/capture_mission/asat/apply_major_victory()
	. = ..()
	var/datum/faction_stats/som_team = mode.stat_list[starting_faction]
	som_team.add_asset(/datum/campaign_asset/droppod_disable)
	som_team.add_asset(/datum/campaign_asset/bonus_job/icc)
	som_team.add_asset(/datum/campaign_asset/bonus_job/icc)

/datum/campaign_mission/capture_mission/asat/apply_minor_victory()
	. = ..()
	var/datum/faction_stats/som_team = mode.stat_list[starting_faction]
	som_team.add_asset(/datum/campaign_asset/droppod_disable)
	som_team.add_asset(/datum/campaign_asset/bonus_job/icc)

/datum/campaign_mission/capture_mission/asat/apply_minor_loss()
	. = ..()
	var/datum/faction_stats/tgmc_team = mode.stat_list[hostile_faction]
	tgmc_team.add_asset(/datum/campaign_asset/equipment/power_armor)

/datum/campaign_mission/capture_mission/asat/apply_major_loss()
	. = ..()
	var/datum/faction_stats/tgmc_team = mode.stat_list[hostile_faction]
	tgmc_team.add_asset(/datum/campaign_asset/equipment/power_armor)

/datum/campaign_mission/capture_mission/asat/objective_reward_bonus()
	return
