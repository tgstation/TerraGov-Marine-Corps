//placeholder
/datum/campaign_mission/final_mission
	name = "Combat patrol"
	map_name = "Orion Outpost"
	map_file = '_maps/map_files/Campaign maps/jungle_outpost/jungle_outpost.dmm'
	starting_faction_objective_description = null
	hostile_faction_objective_description = null
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

	starting_faction_mission_brief = null
	hostile_faction_mission_brief = null
	starting_faction_additional_rewards = null
	hostile_faction_additional_rewards = null

/datum/campaign_mission/final_mission/play_start_intro()
	intro_message = list(
		MISSION_STARTING_FACTION = "[map_name]<br>" + "[GAME_YEAR]-[time2text(world.realtime, "MM-DD")] [stationTimestamp("hh:mm")]<br>" + "Eliminate all [hostile_faction] resistance in the AO. Reinforcements are limited so preserve your forces as best you can. Good hunting!",
		MISSION_HOSTILE_FACTION = "[map_name]<br>" + "[GAME_YEAR]-[time2text(world.realtime, "MM-DD")] [stationTimestamp("hh:mm")]<br>" + "Eliminate all [starting_faction] resistance in the AO. Reinforcements are limited so preserve your forces as best you can. Good hunting!",
	)
	. = ..()

/datum/campaign_mission/final_mission/check_mission_progress()
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
/datum/campaign_mission/final_mission/apply_major_victory()
	. = ..()

/datum/campaign_mission/final_mission/apply_minor_victory()
	. = ..()

/datum/campaign_mission/final_mission/apply_draw()
	winning_faction = pick(starting_faction, hostile_faction)

/datum/campaign_mission/final_mission/apply_minor_loss()
	. = ..()

/datum/campaign_mission/final_mission/apply_major_loss()
	. = ..()
