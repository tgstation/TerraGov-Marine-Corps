/datum/game_mode/colonialmarines
	name = "LV-624"
	config_tag = "LV-624"
	required_players = 1 //Need at least one player, but really we need 2.
	xeno_required_num = 1 //Need at least one xeno.
	var/checkwin_counter = 0
	var/finished = 0
	var/has_started_timer = 5 //This is a simple timer so we don't accidently check win conditions right in post-game

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
	world << "<B>The current game mode is - LV-624!</B>"

/datum/game_mode/colonialmarines/send_intercept()
	return 1

////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////

/* Pre-setup */
//We can ignore this for now, we don't want to do anything before characters are set up.
/datum/game_mode/colonialmarines/pre_setup()
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

	defer_powernet_rebuild = 2 //Build powernets a little bit later, it lags pretty hard.

	spawn (50)
		command_announcement.Announce("An automated distress signal has been received from archaeology site Lazarus Landing, on border world LV-624. A response team from the USS Sulaco will be dispatched shortly to investigate.", "USS Sulaco")

////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////

//This is processed each tick, but check_win is only checked 5 ticks, so we don't go crazy with scanning for mobs.
/datum/game_mode/colonialmarines/process()

	if(queen_death_timer && !finished)
		queen_death_timer--
		if(queen_death_timer == 1)
			xeno_message("The Hive is ready for a new Queen to evolve.")

	checkwin_counter++

	if(has_started_timer > 0) //Initial countdown, just to be safe, so that everyone has a chance to spawn before we check anything.
		has_started_timer--

	if(checkwin_counter >= 5) //Only check win conditions every 5 ticks.
		if(!finished)
			ticker.mode.check_win()
		checkwin_counter = 0
	return 0

//Count up surviving humans.
//This checks for humans that are:
//Played by a person, is not dead, is not infected, is not in a closet/mech, and is not in space.
//It does NOT check for valid species or marines. vs. survivors.
/datum/game_mode/colonialmarines/proc/count_humans()
	var/human_count = 0
	for(var/mob/living/carbon/human/H in player_list)
		if(H) //Prevent any runtime errors
			if(istype(H) && H.stat != DEAD && !(H.status_flags & XENO_HOST) && H.z != 0 && !istype(H.loc,/turf/space) && !istype(get_area(H.loc),/area/centcom) && !istype(get_area(H.loc),/area/tdome) && !istype(get_area(H.loc),/area/shuttle/distress_start))
				if(!isYautja(H)) // Preds don't count in round end.
					human_count += 1 //Add them to the amount of people who're alive.
		else
			log_debug("ERROR! NULL MOB IN LIVING MOB LIST! COUNT_HUMANS()")

	return human_count

//Count up surviving xenos.
//This checks xenos that are:
//Played by a person, is not dead, is not in a closet, is not in space.
/datum/game_mode/colonialmarines/proc/count_xenos()
	var/xeno_count = 0
	for(var/mob/living/carbon/Xenomorph/X in player_list)
		if(X) //Prevent any runtime errors
			if(istype(X) && X.stat != DEAD && X.z != 0 && !istype(X.loc,/turf/space) && !istype(get_area(X.loc),/area/shuttle/distress_start)) // If they're connected/unghosted and alive and not debrained
				xeno_count += 1 //Add them to the amount of people who're alive.
		else
			log_debug("WARNING! NULL MOB IN LIVING MOB LIST! COUNT_XENOS()")

	return xeno_count

///////////////////////////
//Checks to see who won///
//////////////////////////
/datum/game_mode/colonialmarines/check_win()
	if(has_started_timer) //Let's hold off on checking win conditions till everyone has spawned.
		finished = 0
		return

	//Count up our player controlled mobs.
	var/count_h = count_humans()
	var/count_x = count_xenos()

	if(count_h == 0 && count_x > 0) //No humans, some xenos
		finished = 1
	else if(count_h > 0 && count_x == 0) //Some humans, no xenos
		finished = 2
	else if(!count_h && !count_x) //No survivors!
		finished = 3
	else if(emergency_shuttle.returned()) //Emergency shuttle finished
		emergency_shuttle.evac = 1
		finished = 4
	else if(station_was_nuked) //Boom!
		finished = 5
	else
		finished = 0

	return

///////////////////////////////
//Checks if the round is over//
///////////////////////////////
/datum/game_mode/colonialmarines/check_finished()
	if(finished != 0)
		return 1

	return 0

//////////////////////////////////////////////////////////////////////
//Announces the end of the game with all relevant information stated//
//////////////////////////////////////////////////////////////////////
/datum/game_mode/colonialmarines/declare_completion()
	var/result = ""
	if(finished == 1)
		feedback_set_details("round_end_result","alien major victory - marine incursion fails")
		world << "\red <FONT size = 4><B>Alien major victory!</B></FONT>"
		world << "<FONT size = 3><B>The aliens have successfully wiped out the marines and will live to spread the infestation!</B></FONT>"
		result = "alien major victory - marine incursion fails"
		if(prob(50))
			world << 'sound/misc/Game_Over_Man.ogg'
		else
			world << 'sound/misc/asses_kicked.ogg'
		if(round_stats) // Logging to data/logs/round_stats.log
			round_stats << "Alien major victory\nXenos Remaining: [count_xenos()]. Humans remaining: [count_humans()]\nRound time: [worldtime2text()][log_end]"

	else if(finished == 2)
		feedback_set_details("round_end_result","marine major victory - xenomorph infestation eradicated")
		world << "\red <FONT size = 4><B>Marines major victory!</B></FONT>"
		world << "<FONT size = 3><B>The marines managed to wipe out the aliens and stop the infestation!</B></FONT>"
		result = "marine major victory - xenomorph infestation eradicated"
		if(prob(50))
			world << 'sound/misc/hardon.ogg'
		else
			world << 'sound/misc/hell_march.ogg'
		if(round_stats) // Logging to data/logs/round_stats.log
			round_stats << "Marine major victory\nXenos Remaining: [count_xenos()]. Humans remaining: [count_humans()]\nRound time: [worldtime2text()][log_end]"

	else if(finished == 3)
		feedback_set_details("round_end_result","marine minor victory - infestation stopped at a great cost")
		world << "\red <FONT size = 3><B>Marine minor victory.</B></FONT>"
		world << "<FONT size = 3><B>Both the marines and the aliens have been terminated. At least the infestation has been eradicated!</B></FONT>"
		result = "marine minor victory - infestation stopped at a great cost"
		world << 'sound/misc/sadtrombone.ogg'
		if(round_stats) // Logging to data/logs/round_stats.log
			round_stats << "Marine minor victory (Both dead)\nXenos Remaining: [count_xenos()]. Humans remaining: [count_humans()]\nRound time: [worldtime2text()][log_end]"

	else if(finished == 4)
		feedback_set_details("round_end_result","alien minor victory - infestation survives")
		world << "\red <FONT size = 3><B>Alien minor victory.</B></FONT>"
		world << "<FONT size = 3><B>The Sulaco has been evacuated... but the infestation remains!</B></FONT>"
		result = "alien minor victory - infestation survives"
		if(round_stats) // Logging to data/logs/round_stats.log
			round_stats << "Alien minor victory (Evac)\nXenos Remaining: [count_xenos()]. Humans remaining: [count_humans()]\nRound time: [worldtime2text()][log_end]"

	else if(finished == 5)
		feedback_set_details("round_end_result","draw - the station has been nuked")
		world << "\red <FONT size = 3><B>Draw.</B></FONT>"
		world << "<FONT size = 3><B>The station has blown by a nuclear fission device... there are no winners!</B></FONT>"
		result = "draw - the station has been nuked"
		world << 'sound/misc/sadtrombone.ogg'
		if(round_stats) // Logging to data/logs/round_stats.log
			round_stats << "Draw (Nuke)\nXenos Remaining: [count_xenos()]. Humans remaining: [count_humans()]\nRound time: [worldtime2text()][log_end]"
	else
		world << "\red Whoops, something went wrong with declare_completion(), finished: [finished]. Blame the coders!"
		result = "broken round end! Finished value: [finished]"

	world << "Xenos Remaining: [count_xenos()]. Humans remaining: [count_humans()]."
	if(config.use_slack && config.slack_send_round_info)
		slackMessage("generic", "Round is over!  Result: [result]")
	spawn(45)
		if(aliens.len)
			var/text = "<FONT size = 3><B>The Queen(s) were:</B></FONT>"
			for(var/datum/mind/A in aliens)
				if(A)
					var/mob/M = A.current
					if(!M)
						M = A.original

					if(M && istype(M,/mob/living/carbon/Xenomorph/Queen))
						text += "<br>[M.key] was "
						text += "[M.name] ("
						if(M.stat == DEAD)
							text += "died"
						else
							text += "survived"
						text += ")"
			world << text
		if(survivors.len)
			var/text = "<br><FONT size = 3><B>The survivors were:</B></FONT>"
			for(var/datum/mind/A in survivors)
				if(A)
					var/mob/M = A.current
					if(!M)
						M = A.original

					if(M)
						text += "<br>[M.key] was "
						text += "[M.real_name] ("
						if(M.stat == DEAD)
							text += "died"
						else
							text += "survived"
						text += ")"
					else
						text += "<BR>[A.key] was Unknown! (body destroyed)"

			world << text
		if(predators.len)
			var/text = "<br><FONT size = 3><B>The Predators were:</B></FONT>"
			for(var/datum/mind/A in predators)
				if(A)
					var/mob/M = A.current
					if(!M)
						M = A.original

					if(M)
						text += "<br>[M.key] was "
						text += "[M.name] ("
						if(M.stat == DEAD)
							text += "died"
						else
							text += "survived"
						text += ")"
					else
						text += "<BR>[A.key] was Unknown! (body destroyed)"

			world << text

//	..()
	return 1

/datum/game_mode/proc/auto_declare_completion_colonialmarines()
	return
