/datum/game_mode/extended
	name = "extended"
	config_tag = "extended"
	required_players = 0

	var/const/waittime_l = 600 //lower bound on time before intercept arrives (in tenths of seconds)
	var/const/waittime_h = 1800

/datum/game_mode/announce()
	to_chat(world, "<B>The current game mode is - Extended Role-Playing!</B>")
	to_chat(world, "<B>Just have fun and role-play!</B>")

/datum/game_mode/extended/pre_setup()
	return 1

/datum/game_mode/extended/post_setup()
	initialize_post_marine_gear_list()

	round_time_lobby = world.time
	defer_powernet_rebuild = 2 //Build powernets a little bit later, it lags pretty hard.

	..()

/datum/game_mode/extended/check_finished()
	if(round_finished) return 1

/datum/game_mode/extended/check_win()

/datum/game_mode/extended/declare_completion()
	. = ..()
	to_chat(world, "<span class='round_header'>|Round Complete|</span>")

	to_chat(world, "<span class='round_body'>Thus ends the story of the brave men and women of the [MAIN_SHIP_NAME] and their struggle on [SSmapping.config.map_name].</span>")
	var/musical_track = pick('sound/theme/neutral_hopeful1.ogg','sound/theme/neutral_hopeful2.ogg')
	to_chat(world, musical_track)
	log_game("[round_finished]\nGame mode: [name]\nRound time: [duration2text()]\nEnd round player population: [GLOB.clients.len]\nTotal xenos spawned: [round_statistics.total_xenos_created]\nTotal Preds spawned: [predators.len]\nTotal humans spawned: [round_statistics.total_humans_created]")

	declare_completion_announce_individual()
	declare_completion_announce_predators()
	declare_completion_announce_medal_awards()
	declare_completion_announce_round_stats()
	return TRUE