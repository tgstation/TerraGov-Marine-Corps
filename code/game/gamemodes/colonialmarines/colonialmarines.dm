/datum/game_mode/colonialmarines
	name = "LV-624"
	config_tag = "LV-624"
	required_players = 1 //Need at least one player, but really we need 2.
	xeno_required_num = 1 //Need at least one xeno.
	flags_round_type = MODE_INFESTATION
	var/fog_blockers[]
	var/lobby_time

////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////

/* Pre-pre-startup */
/datum/game_mode/colonialmarines/can_start()
	initialize_special_clamps()
	initialize_starting_predator_list()
	if(!initialize_starting_xenomorph_list())
		return
	initialize_starting_survivor_list()
	return 1

/datum/game_mode/colonialmarines/announce()
	world << "<span class='round_header'>The current game mode is - LV-624!</span>"

/datum/game_mode/colonialmarines/send_intercept()
	return 1

////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////

/* Pre-setup */
//We can ignore this for now, we don't want to do anything before characters are set up.
/datum/game_mode/colonialmarines/pre_setup()
	fog_blockers = new
	var/obj/effect/blocker/fog/F
	for(F in world) fog_blockers += F
	if(!fog_blockers.len) fog_blockers = null //No blockers?
	return 1

////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////

/* Post-setup */
//This happens after create_character, so our mob SHOULD be valid and built by now, but without job data.
//We move it later with transform_survivor but they might flicker at any start_loc spawn landmark effects then disappear.
//Xenos and survivors should not spawn anywhere until we transform them.
/datum/game_mode/colonialmarines/post_setup()
	initialize_post_predator_list()
	initialize_post_xenomorph_list()
	initialize_post_survivor_list()
	initialize_post_marine_gear_list()

	lobby_time = world.time
	defer_powernet_rebuild = 2 //Build powernets a little bit later, it lags pretty hard.

	spawn (50)
		command_announcement.Announce("An automated distress signal has been received from archaeology site Lazarus Landing, on border world LV-624. A response team from the USS Sulaco will be dispatched shortly to investigate.", "USS Sulaco")

////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////

//This is processed each tick, but check_win is only checked 5 ticks, so we don't go crazy with scanning for mobs.
/datum/game_mode/colonialmarines/process()

#define FOG_DELAY_INTERVAL		27000 // 45 minutes
	//Copy and paste for right now, until we can finalize or abort the implementation.
	if(--round_started > 0) r_FAL //Initial countdown, just to be safe, so that everyone has a chance to spawn before we check anything.

	if(!round_finished)
		if(xeno_queen_timer && --xeno_queen_timer <= 1) xeno_message("The Hive is ready for a new Queen to evolve.")

		// Automated bioscan / Queen Mother message
		if(world.time > bioscan_current_interval) //If world time is greater than required bioscan time.
			announce_bioscans() //Announce the results of the bioscan to both sides.
			bioscan_current_interval += bioscan_ongoing_interval //Add to the interval based on our set interval time.

		if(++round_checkwin >= 5) //Only check win conditions every 5 ticks.
			if(fog_blockers && world.time >= (FOG_DELAY_INTERVAL + lobby_time))
				world << "<span class='boldnotice'>The fog north of the colony is starting to recede.</span>"
				var/i
				for(i in fog_blockers)
					fog_blockers -= i
					cdel(i)
				fog_blockers = null
			check_win()
			round_checkwin = 0

///////////////////////////
//Checks to see who won///
//////////////////////////
/datum/game_mode/colonialmarines/check_win()
	check_win_infestation()

///////////////////////////////
//Checks if the round is over//
///////////////////////////////
/datum/game_mode/colonialmarines/check_finished()
	if(round_finished) return 1

//////////////////////////////////////////////////////////////////////
//Announces the end of the game with all relevant information stated//
//////////////////////////////////////////////////////////////////////
/datum/game_mode/colonialmarines/declare_completion()
	. = declare_completion_infestation()
