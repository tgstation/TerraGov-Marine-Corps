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
	world << "<B>The current game mode is - Extended Role-Playing!</B>"
	world << "<B>Just have fun and role-play!</B>"

/datum/game_mode/extended/pre_setup()
	return 1

/datum/game_mode/extended/post_setup()
	initialize_post_marine_gear_list()

	round_time_lobby = world.time
	defer_powernet_rebuild = 2 //Build powernets a little bit later, it lags pretty hard.

	spawn (rand(waittime_l, waittime_h)) // To reduce extended meta.
		send_intercept()
	..()

/datum/game_mode/extended/check_finished()
	if(round_finished) return 1

/datum/game_mode/extended/check_win()

/datum/game_mode/extended/declare_completion()
	//world << "<span class='round_header'>[round_finished]</span>"
	world << "<span class='round_header'>|Round Complete|</span>"
	feedback_set_details("round_end_result",round_finished)

	world << "<span class='round_body'>Thus ends the story of the brave men and women of the [MAIN_SHIP_NAME] and their struggle on [map_tag].</span>"
	world << "<span class='round_body'>End of Round Grief (EORG) is an IMMEDIATE 3 hour ban with no warnings, see rule #3 for more details.</span>"
	var/musical_track = pick('sound/theme/neutral_hopeful1.ogg','sound/theme/neutral_hopeful2.ogg')
	world << musical_track
	var/dat = ""
	//if(flags_round_type & MODE_INFESTATION)
		//var/living_player_list[] = count_humans_and_xenos()
		//dat = "\nXenomorphs remaining: [living_player_list[2]]. Humans remaining: [living_player_list[1]]."
	if(round_stats) round_stats << "[round_finished][dat]\nGame mode: [name]\nRound time: [duration2text()]\nEnd round player population: [clients.len]\nTotal xenos spawned: [round_statistics.total_xenos_created]\nTotal Preds spawned: [predators.len]\nTotal humans spawned: [round_statistics.total_humans_created][log_end]" // Logging to data/logs/round_stats.log

	world << dat

	declare_completion_announce_individual()
	declare_completion_announce_predators()
	declare_completion_announce_medal_awards()
	return 1
