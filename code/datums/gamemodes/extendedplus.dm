/datum/game_mode/extendedplus
	name = "Extended Plus"
	config_tag = "Extendedplus"
	silo_scaling = 1.5
	flags_round_type = MODE_INFESTATION|MODE_PSY_POINTS|MODE_PSY_POINTS_ADVANCED|MODE_HIJACK_POSSIBLE|MODE_SILO_RESPAWN|MODE_ALLOW_XENO_QUICKBUILD
	shutters_drop_time = 3 MINUTES
	flags_xeno_abilities = ABILITY_NUCLEARWAR
	valid_job_types = list(
		/datum/job/terragov/command/captain = 1,
		/datum/job/terragov/command/fieldcommander = 1,
		/datum/job/terragov/command/corpseccommander = 1,
		/datum/job/terragov/command/staffofficer = 4,
		/datum/job/terragov/command/pilot = 2,
		/datum/job/terragov/command/mech_pilot = 1,
		/datum/job/terragov/engineering/chief = 1,
		/datum/job/terragov/engineering/tech = 2,
		/datum/job/terragov/requisitions/officer = 2,
		/datum/job/terragov/medical/professor = 1,
		/datum/job/terragov/medical/medicalofficer = 6,
		/datum/job/terragov/security/security_officer = 8,
		/datum/job/terragov/medical/researcher = 3,
		/datum/job/terragov/civilian/liaison = 1,
		/datum/job/terragov/silicon/synthetic = 4,
		/datum/job/terragov/silicon/ai = 1,
		/datum/job/terragov/squad/engineer = 8,
		/datum/job/terragov/squad/corpsman = 8,
		/datum/job/terragov/squad/smartgunner = 4,
		/datum/job/terragov/squad/leader = 4,
		/datum/job/terragov/squad/standard = -1,
		/datum/job/survivor = -1,
		/datum/job/prisoner = -1,
		/datum/job/xenomorph = FREE_XENO_AT_START,
		/datum/job/xenomorph/queen = 1,
		/datum/job/som/command/commander = 1,
		/datum/job/som/command/fieldcommander = 1,
		/datum/job/som/command/staffofficer = 2,
		/datum/job/som/command/pilot = 1,
		/datum/job/job/som/squad/corpsman = 2,
		/datum/job/job/som/squad/engineer = 2,
		/datum/job/job/som/squad/leader = 2,
		/datum/job/job/som/squad/veteran = 2,
		/datum/job/som/squad/standard = 10,
		/datum/job/clf/leader = 1,
		/datum/job/clf/medic = 2,
		/datum/job/clf/specialist = 2,
		/datum/outfit/job/clf/standard = 5
	)
	enable_fun_tads = TRUE
	xenorespawn_time = 15 SECONDS

	/// Time between two bioscan
	var/bioscan_interval = 15 MINUTES

//sets TGMC and SOM squads
/datum/game_mode/hvh/set_valid_squads()
	SSjob.active_squads[FACTION_TERRAGOV] = list()
	SSjob.active_squads[FACTION_SOM] = list()
	for(var/key in SSjob.squads)
		var/datum/squad/squad = SSjob.squads[key]
		if(squad.faction == FACTION_TERRAGOV || squad.faction == FACTION_SOM) //We only want Marine and SOM squads, future proofs if more faction squads are added
			SSjob.active_squads[squad.faction] += squad
	return TRUE

/datum/game_mode/extended/announce()
	to_chat(world, "<b>The current game mode is - Extended Role-Playing!</b>")
	to_chat(world, "<b>Just have fun and role-play!</b>")

/datum/game_mode/extended/check_finished()
	if(!round_finished)
		return FALSE
	return TRUE

/datum/game_mode/extended/declare_completion()
	. = ..()
	to_chat(world, span_round_header("|[round_finished]|"))
	var/sound/S = sound(pick('sound/theme/neutral_hopeful1.ogg','sound/theme/neutral_hopeful2.ogg'), channel = CHANNEL_CINEMATIC)
	SEND_SOUND(world, S)

	log_game("[round_finished]\nGame mode: [name]\nRound time: [duration2text()]\nEnd round player population: [length(GLOB.clients)]\nTotal xenos spawned: [GLOB.round_statistics.total_xenos_created]\nTotal humans spawned: [GLOB.round_statistics.total_humans_created]")
