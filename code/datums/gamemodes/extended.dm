/datum/game_mode/extended
	name = "Extended"
	config_tag = "Extended"
	silo_scaling = 1.5
	round_type_flags = MODE_INFESTATION|MODE_PSY_POINTS|MODE_XENO_RULER|MODE_PSY_POINTS|MODE_PSY_POINTS_ADVANCED|MODE_HIJACK_POSSIBLE|MODE_SILO_RESPAWN|MODE_SILOS_SPAWN_MINIONS|MODE_ALLOW_XENO_QUICKBUILD
	shutters_drop_time = 3 MINUTES
	xeno_abilities_flags = ABILITY_NUCLEARWAR
	valid_job_types = list(
		/datum/job/terragov/command/captain = 1,
		/datum/job/terragov/command/fieldcommander = 1,
		/datum/job/terragov/command/staffofficer = 4,
		/datum/job/terragov/command/pilot = 1,
		/datum/job/terragov/command/transportofficer = 1,
		/datum/job/terragov/command/mech_pilot = 0,
		/datum/job/terragov/command/assault_crewman = 2,
		/datum/job/terragov/command/transport_crewman = 1,
		/datum/job/terragov/engineering/chief = 1,
		/datum/job/terragov/engineering/tech = 2,
		/datum/job/terragov/requisitions/officer = 2,
		/datum/job/terragov/medical/professor = 1,
		/datum/job/terragov/medical/medicalofficer = 6,
		/datum/job/terragov/medical/researcher = 3,
		/datum/job/terragov/civilian/liaison = 1,
		/datum/job/terragov/silicon/synthetic = 4,
		/datum/job/terragov/silicon/ai = 1,
		/datum/job/terragov/squad/engineer = 8,
		/datum/job/terragov/squad/corpsman = 8,
		/datum/job/terragov/squad/smartgunner = 4,
		/datum/job/terragov/squad/leader = 4,
		/datum/job/terragov/squad/standard = -1,
		/datum/job/survivor/assistant = 5,
		/datum/job/survivor/scientist = 4,
		/datum/job/survivor/doctor = 6,
		/datum/job/survivor/liaison = 1,
		/datum/job/survivor/security = 6,
		/datum/job/survivor/civilian = -1,
		/datum/job/survivor/chef = 1,
		/datum/job/survivor/botanist = 1,
		/datum/job/survivor/atmos = 2,
		/datum/job/survivor/chaplain = 1,
		/datum/job/survivor/miner = 6,
		/datum/job/survivor/salesman = 2,
		/datum/job/survivor/marshal = 2,
		/datum/job/xenomorph = FREE_XENO_AT_START,
		/datum/job/xenomorph/queen = 1
	)
	enable_fun_tads = TRUE
	xenorespawn_time = 15 SECONDS
	time_between_round_group = 0
	time_between_round_group_name = "GROUP_Extended"

	/// Time between two bioscan
	var/bioscan_interval = 15 MINUTES

/datum/game_mode/extended/announce()
	to_chat(world, "<b>The current game mode is - Extended Role-Playing!</b>")
	to_chat(world, "<b>Just have fun and role-play!</b>")

/datum/game_mode/extended/check_finished()
	if(!round_finished)
		return FALSE
	return TRUE

/datum/game_mode/extended/declare_completion()
	. = ..()
	log_game("[round_finished]\nGame mode: [name]\nRound time: [duration2text()]\nEnd round player population: [length(GLOB.clients)]\nTotal xenos spawned: [GLOB.round_statistics.total_xenos_created]\nTotal humans spawned: [GLOB.round_statistics.total_humans_created]")

/datum/game_mode/extended/end_round_fluff()
	to_chat(world, span_round_header("|[round_finished]|"))
	var/sound/S = sound(pick('sound/theme/neutral_hopeful1.ogg','sound/theme/neutral_hopeful2.ogg'), channel = CHANNEL_CINEMATIC)
	SEND_SOUND(world, S)
