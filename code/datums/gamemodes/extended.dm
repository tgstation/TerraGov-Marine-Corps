/datum/game_mode/extended
	name = "Extended"
	config_tag = "Extended"
	required_players = 0
	votable = FALSE

//we need seperate gamemodes for urf/covvies
	valid_job_types = list(
		/datum/job/unsc/marine/basic = -1,
		/datum/job/unsc/marine/medic = 6,
		/datum/job/unsc/marine/engineer = 6,
		/datum/job/unsc/marine/leader = 1,
		/datum/job/insurrectionist/basic = -1,
		/datum/job/insurrectionist/medic = 6,
		/datum/job/insurrectionist/engineer = 6,
		/datum/job/insurrectionist/leader = 1,
		/datum/job/gcpd/chief = 1,
		/datum/job/gcpd/cop = 2,
		/datum/job/civ/colonist = 4
		/*
		/datum/job/covenant/sangheili/minor = -1,
		/datum/job/covenant/sangheili/ranger = -1,
		/datum/job/covenant/sangheili/officer = -1,
		/datum/job/covenant/sangheili/specops = -1,
		/datum/job/covenant/sangheili/ultra = -1,
		/datum/job/covenant/sangheili/general = -1
		*/
	)

/datum/game_mode/extended/announce()
	to_chat(world, "<b>The current game mode is - Extended Role-Playing!</b>")
	to_chat(world, "<b>Just have fun and role-play!</b>")

/datum/game_mode/extended/check_finished()
	if(!round_finished)
		return FALSE
	return TRUE

/datum/game_mode/extended/declare_completion()
	. = ..()
	to_chat(world, "<span class='round_header'>|Round Complete|</span>")
	to_chat(world, "<span class='round_body'>Thus ends the story of the brave men and women of the [SSmapping.configs[SHIP_MAP].map_name] and their struggle on [SSmapping.configs[GROUND_MAP].map_name].</span>")
	var/sound/S = sound(pick('sound/theme/neutral_hopeful1.ogg','sound/theme/neutral_hopeful2.ogg'), channel = CHANNEL_CINEMATIC)
	SEND_SOUND(world, S)

	log_game("[round_finished]\nGame mode: [name]\nRound time: [duration2text()]\nEnd round player population: [length(GLOB.clients)]\nTotal xenos spawned: [GLOB.round_statistics.total_xenos_created]\nTotal humans spawned: [GLOB.round_statistics.total_humans_created]")

	announce_medal_awards()
	announce_round_stats()


