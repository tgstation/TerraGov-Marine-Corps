/datum/game_mode/civil_war
	name = "Civil War"
	config_tag = "Civil War"
	flags_round_type = MODE_LZ_SHUTTERS|MODE_TWO_HUMAN_FACTIONS|MODE_HUMAN_ONLY
	flags_landmarks = MODE_LANDMARK_SPAWN_SPECIFIC_SHUTTLE_CONSOLE
	valid_job_types = list(
		/datum/job/terragov/command/captain = 1,
		/datum/job/terragov/command/fieldcommander = 1,
		/datum/job/terragov/command/staffofficer = 4,
		/datum/job/terragov/command/pilot = 2,
		/datum/job/terragov/engineering/chief = 1,
		/datum/job/terragov/engineering/tech = 1,
		/datum/job/terragov/requisitions/officer = 1,
		/datum/job/terragov/medical/professor = 1,
		/datum/job/terragov/medical/medicalofficer = 6,
		/datum/job/terragov/medical/researcher = 2,
		/datum/job/terragov/civilian/liaison = 1,
		/datum/job/terragov/silicon/synthetic = 1,
		/datum/job/terragov/squad/engineer = 8,
		/datum/job/terragov/squad/corpsman = 8,
		/datum/job/terragov/squad/smartgunner = 1,
		/datum/job/terragov/squad/leader = 4,
		/datum/job/terragov/squad/standard = -1,
		/datum/job/terragov/command/captain/rebel = 1,
		/datum/job/terragov/command/fieldcommander/rebel = 1,
		/datum/job/terragov/command/staffofficer/rebel = 4,
		/datum/job/terragov/command/pilot/rebel = 2,
		/datum/job/terragov/engineering/chief/rebel = 1,
		/datum/job/terragov/engineering/tech/rebel = 1,
		/datum/job/terragov/requisitions/officer/rebel = 1,
		/datum/job/terragov/medical/professor/rebel = 1,
		/datum/job/terragov/medical/medicalofficer/rebel = 6,
		/datum/job/terragov/medical/researcher/rebel = 2,
		/datum/job/terragov/silicon/synthetic/rebel = 1,
		/datum/job/terragov/squad/engineer/rebel = 8,
		/datum/job/terragov/squad/corpsman/rebel = 8,
		/datum/job/terragov/squad/smartgunner/rebel = 1,
		/datum/job/terragov/squad/leader/rebel = 4,
		/datum/job/terragov/squad/standard/rebel = -1
	)
	///How many points do you need to win
	var/points_needed = 25

/datum/game_mode/civil_war/announce()
	to_chat(world, "<b>The current game mode is - Civil War!</b>")
	to_chat(world, "<b>Capture and defend the constested zones to win. They are in blue on the minimap. Every 5 minutes (starting at 12:35), every controlled zone gives one point to your faction. The first to 30 wins!</b>")
	to_chat(world, "<b>WIP, report bugs on the github!</b>")

/datum/game_mode/civil_war/set_valid_squads()
	SSjob.active_squads[FACTION_TERRAGOV] = list()
	SSjob.active_squads[FACTION_TERRAGOV_REBEL] = list()
	for(var/key in SSjob.squads)
		var/datum/squad/squad = SSjob.squads[key]
		SSjob.active_squads[squad.faction] += squad
	return TRUE

/datum/game_mode/civil_war/get_joinable_factions()
	if(length(GLOB.alive_human_list_faction[FACTION_TERRAGOV]) > length(GLOB.alive_human_list_faction[FACTION_TERRAGOV_REBEL]) * MAX_UNBALANCED_RATIO_TWO_HUMAN_FACTIONS)
		return list(FACTION_TERRAGOV_REBEL)
	if(length(GLOB.alive_human_list_faction[FACTION_TERRAGOV_REBEL]) > length(GLOB.alive_human_list_faction[FACTION_TERRAGOV]) * MAX_UNBALANCED_RATIO_TWO_HUMAN_FACTIONS)
		return list(FACTION_TERRAGOV)
	return list(FACTION_TERRAGOV, FACTION_TERRAGOV_REBEL)

/datum/game_mode/civil_war/check_finished()
	if(round_finished)
		return TRUE

	if(LAZYACCESS(SSmonitor.points_per_faction, FACTION_TERRAGOV) >= points_needed)
		if(LAZYACCESS(SSmonitor.points_per_faction, FACTION_TERRAGOV_REBEL) >= points_needed)
			message_admins("Round finished: [MODE_CIVIL_WAR_DRAW]") //everyone got enough points at the same time, no one wins
			round_finished = MODE_CIVIL_WAR_DRAW
			return TRUE
		message_admins("Round finished: [MODE_CIVIL_WAR_LOYALIST_MAJOR]")
		round_finished = MODE_CIVIL_WAR_LOYALIST_MAJOR
		return TRUE
	if(LAZYACCESS(SSmonitor.points_per_faction, FACTION_TERRAGOV_REBEL) >= points_needed)
		message_admins("Round finished: [MODE_CIVIL_WAR_REBEL_MAJOR]")
		round_finished = MODE_CIVIL_WAR_REBEL_MAJOR
		return TRUE
	return FALSE

/datum/game_mode/civil_war/declare_completion()
	. = ..()
	to_chat(world, span_round_header("|[round_finished]|"))
	to_chat(world, span_round_body("Thus ends the story of the brave men and women of the [SSmapping.configs[SHIP_MAP].map_name] and their struggle on [SSmapping.configs[GROUND_MAP].map_name]."))

	log_game("[round_finished]\nGame mode: [name]\nRound time: [duration2text()]\nEnd round player population: [length(GLOB.clients)]\nTotal xenos spawned: [GLOB.round_statistics.total_xenos_created]\nTotal humans spawned: [GLOB.round_statistics.total_humans_created]")

	announce_medal_awards()
	announce_round_stats()
