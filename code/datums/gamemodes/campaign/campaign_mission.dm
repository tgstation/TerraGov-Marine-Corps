/datum/campaign_mission
	///name of the mission
	var/name
	///map name for this mission
	var/map_name
	///path of map for this mission
	var/map_file
	///how long until shutters open after this mission is selected
	var/shutter_delay = 2 MINUTES
	///faction that chose the mission
	var/starting_faction
	///faction that did not choose the mission
	var/hostile_faction
	///current state of the mission
	var/mission_state = MISSION_STATE_NEW
	///winning faction of the mission
	var/winning_faction
	///specific mission outcome
	var/outcome
	///The current gamemode. Var as its referred to often
	var/datum/game_mode/hvh/campaign/mode
	///The victory conditions for this mission, for display purposes
	var/list/objective_description = list(
		"starting_faction" = "starting faction objectives here",
		"hostile_faction" = "hostile faction objectives here",
	)
	///Detailed mission description
	var/list/mission_brief = list(
		"starting_faction" = "starting faction mission brief here",
		"hostile_faction" = "hostile faction mission brief here",
	)
	///Victory point rewards for the mission type
	var/list/victory_point_rewards = list(
		MISSION_OUTCOME_MAJOR_VICTORY = list(0, 0),
		MISSION_OUTCOME_MINOR_VICTORY = list(0, 0),
		MISSION_OUTCOME_DRAW = list(0, 0),
		MISSION_OUTCOME_MINOR_LOSS = list(0, 0),
		MISSION_OUTCOME_MAJOR_LOSS = list(0, 0),
	)
	///attrition point rewards for the mission type
	var/list/attrition_point_rewards = list(
		MISSION_OUTCOME_MAJOR_VICTORY = list(0, 0),
		MISSION_OUTCOME_MINOR_VICTORY = list(0, 0),
		MISSION_OUTCOME_DRAW = list(0, 0),
		MISSION_OUTCOME_MINOR_LOSS = list(0, 0),
		MISSION_OUTCOME_MAJOR_LOSS = list(0, 0),
	)
	///Any additional reward flags, for display purposes
	var/additional_rewards = list(
		"starting_faction" = "starting faction mission rewards here",
		"hostile_faction" = "hostile faction mission rewards here",
	) //todo: list of the actual reward datums, or just a desc?

	/// Timer used to calculate how long till mission ends
	var/game_timer
	///The length of time until mission ends, if timed
	var/max_game_time = null
	///Whether the max game time has been reached
	var/max_time_reached = FALSE
	///Delay from shutter drop until game timer starts
	var/game_timer_delay = 1 MINUTES //test num
	///Map text intro message for the start of the mission
	var/list/intro_message = list(
		"starting_faction" = "starting faction intro text here",
		"hostile_faction" = "hostile faction intro text here",
	)

/datum/campaign_mission/New(initiating_faction)
	. = ..()

	mode = SSticker.mode
	if(!istype(mode))
		CRASH("campaign_mission loaded without campaign game mode")

	starting_faction = initiating_faction
	for(var/faction in mode.factions) //this is pretty clunky but eh
		if(faction == starting_faction)
			continue
		hostile_faction = faction

	play_selection_intro()
	load_map()

	addtimer(CALLBACK(src, TYPE_PROC_REF(/datum/campaign_mission, start_mission)), shutter_delay)

/datum/campaign_mission/Destroy(force, ...)
	STOP_PROCESSING(SSslowprocess, src)
	return ..()

/datum/campaign_mission/process()
	if(!check_mission_progress())
		return
	end_mission()
	return PROCESS_KILL

///Generates a new z level for the mission
/datum/campaign_mission/proc/load_map()
	var/datum/space_level/new_level = load_new_z_level(map_file, map_name)
	mode.set_lighting(new_level.z_value)

///Checks mission end criteria, and ends the mission if met
/datum/campaign_mission/proc/check_mission_progress()
	return FALSE

///sets up the timer for the mission
/datum/campaign_mission/proc/set_mission_timer()
	if(!iscampaigngamemode(SSticker.mode))
		return

	game_timer = addtimer(VARSET_CALLBACK(src, max_time_reached, TRUE), max_game_time, TIMER_STOPPABLE)

///accesses the timer for status panel
/datum/campaign_mission/proc/mission_end_countdown()
	if(max_time_reached)
		return "Mission finished"
	var/eta = timeleft(game_timer) * 0.1
	if(eta > 0)
		return "[(eta / 60) % 60]:[add_leading(num2text(eta % 60), 2, "0")]"

///Mission start proper
/datum/campaign_mission/proc/start_mission()
	SHOULD_CALL_PARENT(TRUE)
	START_PROCESSING(SSslowprocess, src) //this may be excessive
	send_global_signal(COMSIG_GLOB_OPEN_TIMED_SHUTTERS_LATE)
	play_start_intro()

	if(max_game_time)
		addtimer(CALLBACK(src, TYPE_PROC_REF(/datum/campaign_mission, set_mission_timer)), game_timer_delay)

	mission_state = MISSION_STATE_ACTIVE

///Mission end wrap up
/datum/campaign_mission/proc/end_mission()
	SHOULD_CALL_PARENT(TRUE)
	STOP_PROCESSING(SSslowprocess, src)
	apply_outcome() //figure out where best to put this
	play_outro()
	mission_state = MISSION_STATE_FINISHED
	mode.end_current_mission()

///Intro when the mission is selected
/datum/campaign_mission/proc/play_selection_intro()
	to_chat(world, span_round_header("|[name]|"))
	to_chat(world, span_round_body("Next mission selected by [starting_faction] as [name] on the battlefield of [map_name]."))

///Intro when the mission is started
/datum/campaign_mission/proc/play_start_intro()
	var/op_name_starting = GLOB.operation_namepool[/datum/operation_namepool].get_random_name()
	var/op_name_hostile = GLOB.operation_namepool[/datum/operation_namepool].get_random_name()

	map_text_broadcast(starting_faction, intro_message["starting_faction"], op_name_starting)
	map_text_broadcast(hostile_faction, intro_message["hostile_faction"], op_name_hostile)

	//todo: use some of the below stuff
	//for(var/mob/living/carbon/human/human AS in GLOB.alive_human_list)
	//	if(human.faction == FACTION_TERRAGOV)
	//		human.play_screen_text("<span class='maptext' style=font-size:24pt;text-align:left valign='top'><u>[op_name_tgmc]</u></span><br>" + "[map_name]<br>" + "[GAME_YEAR]-[time2text(world.realtime, "MM-DD")] [stationTimestamp("hh:mm")]<br>" + "Territorial Defense Force Platoon<br>" + "[human.job.title], [human]<br>", /atom/movable/screen/text/screen_text/picture/tdf)
	//	else
	//		human.play_screen_text("<span class='maptext' style=font-size:24pt;text-align:left valign='top'><u>[op_name_som]</u></span><br>" + "[map_name]<br>" + "[GAME_YEAR]-[time2text(world.realtime, "MM-DD")] [stationTimestamp("hh:mm")]<br>" + "Shokk Infantry Platoon<br>" + "[human.job.title], [human]<br>", /atom/movable/screen/text/screen_text/picture/shokk)


///Outro when the mission is finished
/datum/campaign_mission/proc/play_outro() //todo: make generic
	to_chat(world, span_round_header("|[starting_faction] [outcome]|"))
	log_game("[outcome]\nMission: [name]")
	to_chat(world, span_round_body("Thus ends the story of the brave men and women of both the [starting_faction] and [hostile_faction], and their struggle on [map_name]."))

///Applies the correct outcome for the mission
/datum/campaign_mission/proc/apply_outcome()
	switch(outcome)
		if(MISSION_OUTCOME_MAJOR_VICTORY)
			apply_major_victory()
		if(MISSION_OUTCOME_MINOR_VICTORY)
			apply_minor_victory()
		if(MISSION_OUTCOME_DRAW)
			apply_draw()
		if(MISSION_OUTCOME_MINOR_LOSS)
			apply_minor_loss()
		if(MISSION_OUTCOME_MAJOR_LOSS)
			apply_major_loss()
		else
			CRASH("mission ended with no outcome set")

	modify_attrition_points(attrition_point_rewards[outcome][1], attrition_point_rewards[outcome][2])
	apply_victory_points(victory_point_rewards[outcome][1], victory_point_rewards[outcome][2])

///Apply outcomes for major win
/datum/campaign_mission/proc/apply_major_victory()
	winning_faction = starting_faction

///Apply outcomes for minor win
/datum/campaign_mission/proc/apply_minor_victory()
	winning_faction = starting_faction

///Apply outcomes for draw
/datum/campaign_mission/proc/apply_draw()
	winning_faction = hostile_faction

///Apply outcomes for minor loss
/datum/campaign_mission/proc/apply_minor_loss()
	winning_faction = hostile_faction

///Apply outcomes for major loss
/datum/campaign_mission/proc/apply_major_loss()
	winning_faction = hostile_faction

///gives any victory points earned in the mission
/datum/campaign_mission/proc/apply_victory_points(start_team_points, hostile_team_points)
	mode.stat_list[starting_faction].victory_points += start_team_points
	mode.stat_list[hostile_faction].victory_points += hostile_team_points

///Modifies a faction's attrition points
/datum/campaign_mission/proc/modify_attrition_points(start_team_points, hostile_team_points)
	mode.stat_list[starting_faction].total_attrition_points += start_team_points
	mode.stat_list[hostile_faction].total_attrition_points += hostile_team_points

///checks how many marines and SOM are still alive
/datum/campaign_mission/proc/count_humans(list/z_levels = SSmapping.levels_by_trait(ZTRAIT_AWAY), count_flags) //todo: make new Z's not away levels, or ensure ground and away is consistant in behavior
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

///Sends a maptext message to a specified faction
/datum/campaign_mission/proc/map_text_broadcast(faction, message, title = "OVERWATCH", atom/movable/screen/text/screen_text/picture/display_picture, sound_effect = "sound/effects/CIC_order.ogg")
	if(!faction || !message)
		return
	if(!display_picture)
		display_picture = GLOB.faction_to_portrait[faction] ? GLOB.faction_to_portrait[faction] : /atom/movable/screen/text/screen_text/picture/potrait/unknown

	for(var/mob/living/carbon/human/human AS in GLOB.alive_human_list)
		if(human.faction != faction)
			continue
		human.playsound_local(null, sound_effect, 10, 1)
		human.play_screen_text("<span class='maptext' style=font-size:24pt;text-align:left valign='top'><u>[title]</u></span><br>" + "[message]", display_picture)

/////basic tdm mission - i.e. combat patrol
/datum/campaign_mission/tdm
	name = "Combat patrol"
	map_name = "Orion Outpost"
	map_file = '_maps/map_files/Orion_Military_Outpost/orionoutpost.dmm'
	objective_description = list(
		"starting_faction" = "<U>Major Victory</U>: Wipe out all hostiles in the area of operation.<br> <U>Minor Victory</U>: Eliminate more hostiles than you lose.",
		"hostile_faction" = "<U>Major Victory</U>: Wipe out all hostiles in the area of operation.<br> <U>Minor Victory</U>: Eliminate more hostiles than you lose.",
	)
	max_game_time = 20 MINUTES
	victory_point_rewards = list(
		MISSION_OUTCOME_MAJOR_VICTORY = list(3, 0),
		MISSION_OUTCOME_MINOR_VICTORY = list(1, 0),
		MISSION_OUTCOME_DRAW = list(0, 0),
		MISSION_OUTCOME_MINOR_LOSS = list(0, 1),
		MISSION_OUTCOME_MAJOR_LOSS = list(0, 3),
	)
	attrition_point_rewards = list(
		MISSION_OUTCOME_MAJOR_VICTORY = list(20, 5),
		MISSION_OUTCOME_MINOR_VICTORY = list(15, 10),
		MISSION_OUTCOME_DRAW = list(10, 10),
		MISSION_OUTCOME_MINOR_LOSS = list(10, 15),
		MISSION_OUTCOME_MAJOR_LOSS = list(5, 20),
	)

	mission_brief = list(
		"starting_faction" = "Hostile forces have been attempting to expand the territory under their control in this area. <br>\
		Although this territory is of limited direct strategic value, \
		to prevent them from establishing a permanent presence in the area command has ordered your battalion to execute force recon patrols to locate and eliminate any hostile presence. <br>\
		Eliminate all hostiles you come across while preserving your own forces. Good hunting.",
		"hostile_faction" = "Intelligence indicates that hostile forces are massing for a coordinated push to dislodge us from territory where we are aiming to establish a permanent presence. <br>\
		Your battalion has been issued orders to regroup and counter attack the enemy push before they can make any progress, and kill their ambitions in this region. <br>\
		Eliminate all hostiles you come across while preserving your own forces. Good hunting.",
	)

	additional_rewards = list(
		"starting_faction" = "If the enemy force is wiped out entirely, additional supplies can be diverted to your battalion.",
		"hostile_faction" = "If the enemy force is wiped out entirely, additional supplies can be diverted to your battalion.",
	)

/datum/campaign_mission/tdm/play_start_intro()
	intro_message = list(
		"starting_faction" = "[map_name]<br>" + "[GAME_YEAR]-[time2text(world.realtime, "MM-DD")] [stationTimestamp("hh:mm")]<br>" + "Eliminate all [hostile_faction] resistance in the AO. Reinforcements are limited so preserve your forces as best you can. Good hunting!",
		"hostile_faction" = "[map_name]<br>" + "[GAME_YEAR]-[time2text(world.realtime, "MM-DD")] [stationTimestamp("hh:mm")]<br>" + "Eliminate all [starting_faction] resistance in the AO. Reinforcements are limited so preserve your forces as best you can. Good hunting!",
	)
	. = ..()

/datum/campaign_mission/tdm/check_mission_progress()
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
			message_admins("Mission finished: [MISSION_OUTCOME_DRAW]") //everyone died at the same time, no one wins
			outcome = MISSION_OUTCOME_DRAW
			return TRUE
		message_admins("Mission finished: [MISSION_OUTCOME_MAJOR_VICTORY]") //starting team wiped the hostile team
		outcome = MISSION_OUTCOME_MAJOR_VICTORY
		return TRUE

	if(!num_team_one)
		message_admins("Mission finished: [MISSION_OUTCOME_MAJOR_LOSS]") //hostile team wiped the starting team
		outcome = MISSION_OUTCOME_MAJOR_LOSS
		return TRUE

	//minor victories for more kills or draw for equal kills
	if(num_dead_team_two > num_dead_team_one)
		message_admins("Mission finished: [MISSION_OUTCOME_MINOR_VICTORY]") //starting team got more kills
		outcome = MISSION_OUTCOME_MINOR_VICTORY
		return TRUE
	if(num_dead_team_one > num_dead_team_two)
		message_admins("Mission finished: [MISSION_OUTCOME_MINOR_LOSS]") //hostile team got more kills
		outcome = MISSION_OUTCOME_MINOR_LOSS
		return TRUE

	message_admins("Mission finished: [MISSION_OUTCOME_DRAW]") //equal number of kills, or any other edge cases
	outcome = MISSION_OUTCOME_DRAW
	return TRUE

//todo: remove these if nothing new is added
/datum/campaign_mission/tdm/apply_major_victory()
	. = ..()

/datum/campaign_mission/tdm/apply_minor_victory()
	. = ..()

/datum/campaign_mission/tdm/apply_draw()
	winning_faction = pick(starting_faction, hostile_faction)

/datum/campaign_mission/tdm/apply_minor_loss()
	. = ..()

/datum/campaign_mission/tdm/apply_major_loss()
	. = ..()

///test missions
/datum/campaign_mission/tdm/lv624
	name = "Combat patrol 2"
	map_name = "LV-624"
	map_file = '_maps/map_files/LV624/LV624.dmm' //todo: make modulars work with late load

/datum/campaign_mission/tdm/desparity
	name = "Combat patrol 3"
	map_name = "Desparity"
	map_file = '_maps/map_files/desparity/desparity.dmm'

/////basic destroy stuff mission////////
/datum/campaign_mission/destroy_mission
	name = "Target Destruction" //(tm)
	map_name = "Ice Caves"
	map_file = '_maps/map_files/icy_caves/icy_caves.dmm'
	objective_description = list( //update
		"starting_faction" = "<U>Major Victory</U>:Destroy all targets.<br> <U>Minor Victory</U>: Destroy at least X targets.",
		"hostile_faction" = "<U>Major Victory</U>: Protect all assets from destruction.<br> <U>Minor Victory</U>: Protect at least X assets.",
	)
	max_game_time = 20 MINUTES
	victory_point_rewards = list(
		MISSION_OUTCOME_MAJOR_VICTORY = list(3, 0),
		MISSION_OUTCOME_MINOR_VICTORY = list(1, 0),
		MISSION_OUTCOME_DRAW = list(0, 0),
		MISSION_OUTCOME_MINOR_LOSS = list(0, 1),
		MISSION_OUTCOME_MAJOR_LOSS = list(0, 3),
	)
	attrition_point_rewards = list(
		MISSION_OUTCOME_MAJOR_VICTORY = list(20, 5),
		MISSION_OUTCOME_MINOR_VICTORY = list(15, 10),
		MISSION_OUTCOME_DRAW = list(10, 10),
		MISSION_OUTCOME_MINOR_LOSS = list(10, 15),
		MISSION_OUTCOME_MAJOR_LOSS = list(5, 20),
	)
	///All objectives to be destroyed
	var/list/object/target_list = list() //the objectives are added to the list when they init
	///number of targets destroyed for a minor victory
	var/min_destruction_amount = 3 //placeholder number

/datum/campaign_mission/destroy_mission/check_mission_progress()
	if(outcome)
		return TRUE

	if(!game_timer)
		return

//todo: remove these if nothing new is added
/datum/campaign_mission/destroy_mission/apply_major_victory()
	. = ..()

/datum/campaign_mission/destroy_mission/apply_minor_victory()
	. = ..()

/datum/campaign_mission/destroy_mission/apply_minor_loss()
	. = ..()

/datum/campaign_mission/destroy_mission/apply_major_loss()
	. = ..()
