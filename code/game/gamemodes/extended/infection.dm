//THIS IS A BLANK LABEL ONLY SO PEOPLE CAN SEE WHEN WE RUNNIN DIS BITCH.   Should probably write a real one one day.  Maybe.
/datum/game_mode/infection
	name = "Infection"
	config_tag = "Infection"
	required_players = 0 //otherwise... no zambies
	latejoin_larva_drop = 0
	flags_round_type = MODE_INFECTION //Apparently without this, the game mode checker ignores this as a potential legit game mode.

	uplink_welcome = "IF YOU SEE THIS, SHIT A BRICK AND AHELP"
	uplink_uses = 10

	var/const/waittime_l = 600 //lower bound on time before intercept arrives (in tenths of seconds)
	var/const/waittime_h = 1800

/datum/game_mode/infection/announce()
	world << "<B>The current game mode is - ZOMBIES!</B>"
	world << "<B>Just have fun and role-play!</B>"
	world << "<B>If you die as a zombie, you come back.  NO MATTER HOW MUCH DAMAGE.</B>"
	world << "<B>Don't ahelp asking for specific details, you won't get them.</B>"

/datum/game_mode/infection/pre_setup()
	return 1

/datum/game_mode/infection/post_setup()
	initialize_post_marine_gear_list()
	spawn (rand(waittime_l, waittime_h)) // To reduce extended meta.
		send_intercept()
	..()

/datum/game_mode/infection/can_start()
	initialize_starting_survivor_list()
	return 1

/datum/game_mode/infection/send_intercept()
	return 1

/datum/game_mode/infection/check_win()
	var/living_player_list[] = count_humans_and_xenos(EvacuationAuthority.get_affected_zlevels())
	var/num_humans = living_player_list[1]
	var/zed = living_player_list[2]
//	world << "ZED: [zed]"
//	world << "Humie: [num_humans]"

	if(num_humans <=0 && zed >= 1)
		round_finished = MODE_INFECTION_ZOMBIE_WIN

/datum/game_mode/infection/check_finished()
	if(round_finished) return 1

/datum/game_mode/infection/process()
	if(--round_started > 0) r_FAL //Initial countdown, just to be safe, so that everyone has a chance to spawn before we check anything.

	if(!round_finished)
		if(++round_checkwin >= 5) //Only check win conditions every 5 ticks.
			check_win()
			round_checkwin = 0

/datum/game_mode/infection/declare_completion()
	//world << "<span class='round_header'>[round_finished]</span>"
	world << "<span class='round_header'>|Round Complete|</span>"
	feedback_set_details("round_end_result",round_finished)

	world << "<span class='round_body'>Thus ends the story of the brave men and women of the [MAIN_SHIP_NAME] and their struggle on [map_tag].</span>"
	world << "<span class='round_body'>End of Round Grief (EORG) is an IMMEDIATE 3 hour ban with no warnings, see rule #3 for more details.</span>"
	var/musical_track = pick('sound/theme/sad_loss1.ogg','sound/theme/sad_loss2.ogg')
	world << musical_track
	world << "<span class='round_body'>The zombies have been victorious!</span>"

	var/dat = ""
	//if(flags_round_type & MODE_INFESTATION)
		//var/living_player_list[] = count_humans_and_xenos()
		//dat = "\nXenomorphs remaining: [living_player_list[2]]. Humans remaining: [living_player_list[1]]."
	if(round_stats) round_stats << "[round_finished][dat]\nGame mode: [name]\nRound time: [duration2text()]\nEnd round player population: [clients.len]\nTotal xenos spawned: [round_statistics.total_xenos_created]\nTotal Preds spawned: [predators.len]\nTotal humans spawned: [round_statistics.total_humans_created][log_end]" // Logging to data/logs/round_stats.log

	world << dat

	declare_completion_announce_individual()
	declare_completion_announce_predators()
	declare_completion_announce_xenomorphs()
	declare_completion_announce_survivors()
	declare_completion_announce_medal_awards()
	return 1




/datum/game_mode/infection/post_setup()
	initialize_post_survivor_list()

	spawn (50)
		command_announcement.Announce("We've lost contact with the Weyland-Yutani's research facility, [name]. The [MAIN_SHIP_NAME] has been dispatched to assist.", "[MAIN_SHIP_NAME]")

