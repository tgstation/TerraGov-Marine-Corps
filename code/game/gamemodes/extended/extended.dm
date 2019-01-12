/datum/game_mode/extended
	name = "extended"
	config_tag = "extended"
	required_players = 0
	latejoin_larva_drop = 0

	uplink_welcome = "Syndicate Uplink Console:"
	uplink_uses = 10

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
	//to_chat(world, "<span class='round_header'>[round_finished]</span>")
	to_chat(world, "<span class='round_header'>|Round Complete|</span>")
	feedback_set_details("round_end_result",round_finished)

	to_chat(world, "<span class='round_body'>Thus ends the story of the brave men and women of the [MAIN_SHIP_NAME] and their struggle on [map_tag].</span>")
	var/musical_track = pick('sound/theme/neutral_hopeful1.ogg','sound/theme/neutral_hopeful2.ogg')
	to_chat(world, musical_track)
	var/dat = ""
	//if(flags_round_type & MODE_INFESTATION)
		//var/living_player_list[] = count_humans_and_xenos()
		//dat = "\nXenomorphs remaining: [living_player_list[2]]. Humans remaining: [living_player_list[1]]."
	log_game("[round_finished][dat]\nGame mode: [name]\nRound time: [duration2text()]\nEnd round player population: [clients.len]\nTotal xenos spawned: [round_statistics.total_xenos_created]\nTotal Preds spawned: [predators.len]\nTotal humans spawned: [round_statistics.total_humans_created]")

	to_chat(world, dat)

	declare_completion_announce_individual()
	declare_completion_announce_predators()
	declare_completion_announce_medal_awards()
	declare_completion_announce_round_stats()
	return 1
