///round code
/datum/game_round
	///name of the round
	var/name
	///map name for this round
	var/map_name
	///path of map for this round
	var/map_file
	///faction that chose the round
	var/starting_faction
	///faction that did not choose the round
	var/hostile_faction
	///current state of the round
	var/round_state = GAME_ROUND_STATE_NEW
	///winning faction of the round
	var/winning_faction
	///specific round outcome
	var/outcome
	///The current gamemode. Var as its referred to often
	var/datum/game_mode/hvh/campaign/mode
	///The victory conditions for this round, for display purposes
	var/list/objective_description = list(
		"starting_faction" = "starting faction objectives here",
		"hostile_faction" = "hostile faction objectives here",
	)
	///Victory point rewards for the round type
	var/list/victory_point_rewards = list(
		GAME_ROUND_OUTCOME_MAJOR_VICTORY = list(0, 0),
		GAME_ROUND_OUTCOME_MINOR_VICTORY = list(0, 0),
		GAME_ROUND_OUTCOME_DRAW = list(0, 0),
		GAME_ROUND_OUTCOME_MINOR_LOSS = list(0, 0),
		GAME_ROUND_OUTCOME_MAJOR_LOSS = list(0, 0),
	)
	///attrition point rewards for the round type
	var/list/attrition_point_rewards = list(
		GAME_ROUND_OUTCOME_MAJOR_VICTORY = list(0, 0),
		GAME_ROUND_OUTCOME_MINOR_VICTORY = list(0, 0),
		GAME_ROUND_OUTCOME_DRAW = list(0, 0),
		GAME_ROUND_OUTCOME_MINOR_LOSS = list(0, 0),
		GAME_ROUND_OUTCOME_MAJOR_LOSS = list(0, 0),
	)
	///Any additional reward flags, for display purposes
	var/additional_rewards = null //maybe getting ugh, but might need some reward datum, so they're not tied to a specific round type

	/// Timer used to calculate how long till round ends
	var/game_timer
	///The length of time until round ends, if timed
	var/max_game_time = null
	///Whether the max game time has been reached
	var/max_time_reached = FALSE
	///Delay from shutter drop until game timer starts
	var/game_timer_delay = 1 MINUTES //test num

/datum/game_round/New(initiating_faction)
	. = ..()

	mode = SSticker.mode
	if(!istype(mode))
		CRASH("game_round loaded without campaign game mode")

	starting_faction = initiating_faction
	for(var/faction in mode.factions) //this is pretty clunky but eh
		if(faction == starting_faction)
			continue
		hostile_faction = faction

	play_selection_intro()
	load_map()

/datum/game_round/Destroy(force, ...)
	STOP_PROCESSING(SSslowprocess, src)
	return ..()

/datum/game_round/process()
	if(!check_round_progress())
		return
	end_round()
	return PROCESS_KILL

///Generates a new z level for the round
/datum/game_round/proc/load_map()
	var/datum/space_level/new_level = load_new_z_level(map_file, map_name)
	mode.set_lighting(new_level.z_value)

///Checks round end criteria, and ends the round if met
/datum/game_round/proc/check_round_progress()
	return FALSE

///sets up the timer for the round
/datum/game_round/proc/set_round_timer()
	if(!iscampaigngamemode(SSticker.mode))
		return

	game_timer = addtimer(VARSET_CALLBACK(src, max_time_reached, TRUE), max_game_time, TIMER_STOPPABLE)

///accesses the timer for status panel
/datum/game_round/proc/round_end_countdown()
	if(max_time_reached)
		return "Mission finished"
	var/eta = timeleft(game_timer) * 0.1
	if(eta > 0)
		return "[(eta / 60) % 60]:[add_leading(num2text(eta % 60), 2, "0")]"

///Round start proper
/datum/game_round/proc/start_round()
	SHOULD_CALL_PARENT(TRUE)
	START_PROCESSING(SSslowprocess, src) //this may be excessive
	send_global_signal(COMSIG_GLOB_OPEN_TIMED_SHUTTERS_LATE)
	play_start_intro()

	if(max_game_time)
		addtimer(CALLBACK(src, TYPE_PROC_REF(/datum/game_round, set_round_timer)), game_timer_delay)

	round_state = GAME_ROUND_STATE_ACTIVE

///Round end wrap up
/datum/game_round/proc/end_round()
	SHOULD_CALL_PARENT(TRUE)
	STOP_PROCESSING(SSslowprocess, src)
	apply_outcome() //figure out where best to put this
	play_outro()
	round_state = GAME_ROUND_STATE_FINISHED
	mode.end_current_round()

///Intro when the round is selected
/datum/game_round/proc/play_selection_intro()
	to_chat(world, span_round_header("|[name]|"))
	to_chat(world, span_round_body("Next round selected by [starting_faction] as [name] on the battlefield of [map_name]."))

///Intro when the round is started
/datum/game_round/proc/play_start_intro() //todo: make generic
	var/op_name_tgmc = GLOB.operation_namepool[/datum/operation_namepool].get_random_name()
	var/op_name_som = GLOB.operation_namepool[/datum/operation_namepool].get_random_name()
	for(var/mob/living/carbon/human/human AS in GLOB.alive_human_list)
		if(human.faction == FACTION_TERRAGOV)
			human.play_screen_text("<span class='maptext' style=font-size:24pt;text-align:left valign='top'><u>[op_name_tgmc]</u></span><br>" + "[map_name]<br>" + "[GAME_YEAR]-[time2text(world.realtime, "MM-DD")] [stationTimestamp("hh:mm")]<br>" + "Territorial Defense Force Platoon<br>" + "[human.job.title], [human]<br>", /atom/movable/screen/text/screen_text/picture/tdf)
		else
			human.play_screen_text("<span class='maptext' style=font-size:24pt;text-align:left valign='top'><u>[op_name_som]</u></span><br>" + "[map_name]<br>" + "[GAME_YEAR]-[time2text(world.realtime, "MM-DD")] [stationTimestamp("hh:mm")]<br>" + "Shokk Infantry Platoon<br>" + "[human.job.title], [human]<br>", /atom/movable/screen/text/screen_text/picture/shokk)


///Outro when the round is finished
/datum/game_round/proc/play_outro() //todo: make generic
	to_chat(world, span_round_header("|[starting_faction] [outcome]|"))
	log_game("[outcome]\nRound: [name]")
	to_chat(world, span_round_body("Thus ends the story of the brave men and women of both the [starting_faction] and [hostile_faction], and their struggle on [map_name]."))

///Applies the correct outcome for the round
/datum/game_round/proc/apply_outcome()
	switch(outcome)
		if(GAME_ROUND_OUTCOME_MAJOR_VICTORY)
			apply_major_victory()
		if(GAME_ROUND_OUTCOME_MINOR_VICTORY)
			apply_minor_victory()
		if(GAME_ROUND_OUTCOME_DRAW)
			apply_draw()
		if(GAME_ROUND_OUTCOME_MINOR_LOSS)
			apply_minor_loss()
		if(GAME_ROUND_OUTCOME_MAJOR_LOSS)
			apply_major_loss()
		else
			CRASH("game round ended with no outcome set")

	modify_attrition_points(attrition_point_rewards[outcome][1], attrition_point_rewards[outcome][2])
	apply_victory_points(victory_point_rewards[outcome][1], victory_point_rewards[outcome][2])

///Apply outcomes for major win
/datum/game_round/proc/apply_major_victory()
	winning_faction = starting_faction

///Apply outcomes for minor win
/datum/game_round/proc/apply_minor_victory()
	winning_faction = starting_faction

///Apply outcomes for draw
/datum/game_round/proc/apply_draw()
	winning_faction = hostile_faction

///Apply outcomes for minor loss
/datum/game_round/proc/apply_minor_loss()
	winning_faction = hostile_faction

///Apply outcomes for major loss
/datum/game_round/proc/apply_major_loss()
	winning_faction = hostile_faction

///gives any victory points earned in the round
/datum/game_round/proc/apply_victory_points(start_team_points, hostile_team_points)
	mode.stat_list[starting_faction].victory_points += start_team_points
	mode.stat_list[hostile_faction].victory_points += hostile_team_points

///Modifies a faction's attrition points
/datum/game_round/proc/modify_attrition_points(start_team_points, hostile_team_points)
	mode.stat_list[starting_faction].total_attrition_points += start_team_points
	mode.stat_list[hostile_faction].total_attrition_points += hostile_team_points

///checks how many marines and SOM are still alive
/datum/game_round/proc/count_humans(list/z_levels = SSmapping.levels_by_trait(ZTRAIT_AWAY), count_flags) //todo: make new Z's not away levels, or ensure ground and away is consistant in behavior
	var/list/team_one_alive = list()
	var/list/team_one_dead = list()
	var/list/team_two_alive = list()
	var/list/team_two_dead = list()

	for(var/z in z_levels)
		//counts the live marines and SOM
		for(var/i in GLOB.humans_by_zlevel["[z]"])
			var/mob/living/carbon/human/H = i
			if(!istype(H))
				continue
			if(count_flags & COUNT_IGNORE_HUMAN_SSD && !H.client)
				continue
			if(H.faction == starting_faction)
				team_one_alive += H
			else //assumption here that there is only 2 teams
				team_two_alive += H
	//counts the dead marines and SOM
	for(var/i in GLOB.dead_human_list)
		var/mob/living/carbon/human/H = i
		if(!istype(H))
			continue
		if(H.faction == starting_faction)
			team_one_dead += H
		else
			team_two_dead += H

	return list(team_one_alive, team_two_alive, team_one_dead, team_two_dead)

/////basic tdm round - i.e. combat patrol
/datum/game_round/tdm
	name = "Combat patrol"
	map_name = "Orion Outpost"
	map_file = '_maps/map_files/Orion_Military_Outpost/orionoutpost.dmm'
	objective_description = list(
		"starting_faction" = "<U>Major Victory</U>: Wipe out all hostiles in the area of operation.<br> <U>Minor Victory</U>: Eliminate more hostiles than you lose.",
		"hostile_faction" = "<U>Major Victory</U>: Wipe out all hostiles in the area of operation.<br> <U>Minor Victory</U>: Eliminate more hostiles than you lose.",
	)
	max_game_time = 20 MINUTES
	victory_point_rewards = list(
		GAME_ROUND_OUTCOME_MAJOR_VICTORY = list(3, 0),
		GAME_ROUND_OUTCOME_MINOR_VICTORY = list(1, 0),
		GAME_ROUND_OUTCOME_DRAW = list(0, 0),
		GAME_ROUND_OUTCOME_MINOR_LOSS = list(0, 1),
		GAME_ROUND_OUTCOME_MAJOR_LOSS = list(0, 3),
	)
	attrition_point_rewards = list(
		GAME_ROUND_OUTCOME_MAJOR_VICTORY = list(20, 5),
		GAME_ROUND_OUTCOME_MINOR_VICTORY = list(15, 10),
		GAME_ROUND_OUTCOME_DRAW = list(10, 10),
		GAME_ROUND_OUTCOME_MINOR_LOSS = list(10, 15),
		GAME_ROUND_OUTCOME_MAJOR_LOSS = list(5, 20),
	)

/datum/game_round/tdm/check_round_progress()
	if(outcome)
		return TRUE

	if(!game_timer)
		return

	///pulls the number of both factions, dead or alive
	var/list/player_list = count_humans(count_flags = COUNT_IGNORE_ALIVE_SSD)
	var/num_team_one = length(player_list[1])
	var/num_team_two = length(player_list[2])
	var/num_dead_team_one = length(player_list[3])
	var/num_dead_team_two = length(player_list[4])

	if(num_team_two && num_team_one && !max_time_reached)
		return //fighting is ongoing

	//major victor for wiping out the enemy, or draw if both sides wiped simultaneously somehow
	if(!num_team_two)
		if(!num_team_one)
			message_admins("Round finished: [GAME_ROUND_OUTCOME_DRAW]") //everyone died at the same time, no one wins
			outcome = GAME_ROUND_OUTCOME_DRAW
			return TRUE
		message_admins("Round finished: [GAME_ROUND_OUTCOME_MAJOR_VICTORY]") //starting team wiped the hostile team
		outcome = GAME_ROUND_OUTCOME_MAJOR_VICTORY
		return TRUE

	if(!num_team_one)
		message_admins("Round finished: [GAME_ROUND_OUTCOME_MAJOR_LOSS]") //hostile team wiped the starting team
		outcome = GAME_ROUND_OUTCOME_MAJOR_LOSS
		return TRUE

	//minor victories for more kills or draw for equal kills
	if(num_dead_team_two > num_dead_team_one)
		message_admins("Round finished: [GAME_ROUND_OUTCOME_MINOR_VICTORY]") //starting team got more kills
		outcome = GAME_ROUND_OUTCOME_MINOR_VICTORY
		return TRUE
	if(num_dead_team_one > num_dead_team_two)
		message_admins("Round finished: [GAME_ROUND_OUTCOME_MINOR_LOSS]") //hostile team got more kills
		outcome = GAME_ROUND_OUTCOME_MINOR_LOSS
		return TRUE

	message_admins("Round finished: [GAME_ROUND_OUTCOME_DRAW]") //equal number of kills, or any other edge cases
	outcome = GAME_ROUND_OUTCOME_DRAW
	return TRUE

//todo: remove these if nothing new is added
/datum/game_round/tdm/apply_major_victory()
	. = ..()

/datum/game_round/tdm/apply_minor_victory()
	. = ..()

/datum/game_round/tdm/apply_draw()
	winning_faction = pick(starting_faction, hostile_faction)

/datum/game_round/tdm/apply_minor_loss()
	. = ..()

/datum/game_round/tdm/apply_major_loss()
	. = ..()

///test rounds
/datum/game_round/tdm/lv624
	name = "Combat patrol 2"
	map_name = "LV-624"
	map_file = '_maps/map_files/LV624/LV624.dmm' //todo: make modulars work with late load

/datum/game_round/tdm/desparity
	name = "Combat patrol 3"
	map_name = "Desparity"
	map_file = '_maps/map_files/desparity/desparity.dmm'
