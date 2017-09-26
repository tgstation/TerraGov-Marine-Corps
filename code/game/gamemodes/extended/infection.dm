//THIS IS A BLANK LABEL ONLY SO PEOPLE CAN SEE WHEN WE RUNNIN DIS BITCH.   Should probably write a real one one day.  Maybe.
/datum/game_mode/infection
	name = "Infection"
	config_tag = "Infection"
	required_players = 0 //otherwise... no zambies
	flags_round_type = MODE_INFESTATION //Apparently without this, the game mode checker ignores this as a potential legit game mode.

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
	spawn (rand(waittime_l, waittime_h)) // To reduce extended meta.
		send_intercept()
	..()

/datum/game_mode/infection/can_start()
	initialize_starting_survivor_list()
	return 1

/datum/game_mode/infection/send_intercept()
	return 1

/datum/game_mode/infection/check_win()
	check_win_infection()

/datum/game_mode/infection/check_finished()
	if(round_finished) return 1

/datum/game_mode/infection/process()
	if(--round_started > 0) r_FAL //Initial countdown, just to be safe, so that everyone has a chance to spawn before we check anything.

	if(!round_finished)
		if(++round_checkwin >= 5) //Only check win conditions every 5 ticks.
			check_win()
			round_checkwin = 0

/datum/game_mode/infection/declare_completion()
	. = declare_completion_infestation()	//This is a generate declare completion check now, we should probably adjust it one day.





/datum/game_mode/infection/post_setup()
	initialize_post_survivor_list()

	spawn (50)
		command_announcement.Announce("We've lost contact with the Weyland-Yutani's research facility, [name]. The [MAIN_SHIP_NAME] has been dispatched to assist.", "[MAIN_SHIP_NAME]")

