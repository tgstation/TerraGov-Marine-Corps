/datum/game_mode/bigred
	name = "Solaris Ridge"
	config_tag = "Big-Red"
	required_players = 1 //Need at least one player, but really we need 2.
	xeno_required_num = 1 //Need at least one xeno.
	flags_round_type = MODE_INFESTATION

////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////

/* Pre-pre-startup */
/datum/game_mode/bigred/can_start()
	initialize_special_clamps()
	initialize_starting_predator_list()
	if(!initialize_starting_xenomorph_list())
		return
	initialize_starting_survivor_list()
	return 1

/datum/game_mode/bigred/announce()
	world << "<span class='round_header'>The current map is - Solaris Ridge!</span>"

/datum/game_mode/bigred/send_intercept()
	return 1

////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////

/* Pre-setup */
//We can ignore this for now, we don't want to do anything before characters are set up.
/datum/game_mode/bigred/pre_setup()
	return 1

////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////

/* Post-setup */
//This happens after create_character, so our mob SHOULD be valid and built by now, but without job data.
//We move it later with transform_survivor but they might flicker at any start_loc spawn landmark effects then disappear.
//Xenos and survivors should not spawn anywhere until we transform them.
/datum/game_mode/bigred/post_setup()
	initialize_post_predator_list()
	initialize_post_xenomorph_list()
	initialize_post_survivor_list()
	initialize_post_marine_gear_list()

	defer_powernet_rebuild = 2 //Build powernets a little bit later, it lags pretty hard.

	spawn (50)
		command_announcement.Announce("We've lost contact with the Weyland-Yutani's research facility, [name]. The [MAIN_SHIP_NAME] has been dispatched to assist.", "[MAIN_SHIP_NAME]")

////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////

//This is processed each tick, but check_win is only checked 5 ticks, so we don't go crazy with scanning for mobs.
/datum/game_mode/bigred/process()
	process_infestation()

///////////////////////////
//Checks to see who won///
//////////////////////////
/datum/game_mode/bigred/check_win()
	check_win_infestation()

///////////////////////////////
//Checks if the round is over//
///////////////////////////////
/datum/game_mode/bigred/check_finished()
	if(round_finished) return 1

//////////////////////////////////////////////////////////////////////
//Announces the end of the game with all relevant information stated//
//////////////////////////////////////////////////////////////////////
/datum/game_mode/bigred/declare_completion()
	. = declare_completion_infestation()
