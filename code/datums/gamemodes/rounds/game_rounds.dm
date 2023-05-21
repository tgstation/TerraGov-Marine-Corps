#define GAME_ROUND_STATE_NEW "game round state new"

#define GAME_ROUND_STATE_ACTIVE "game round state active"

#define GAME_ROUND_STATE_FINISHED "game round state finished"

#define GAME_ROUND_OUTCOME_MAJOR_VICTORY "game round outcome major victory"
#define GAME_ROUND_OUTCOME_MINOR_VICTORY "game round outcome minor victory"
#define GAME_ROUND_OUTCOME_DRAW "game round outcome draw"
#define GAME_ROUND_OUTCOME_MINOR_LOSS "game round outcome minor loss"
#define GAME_ROUND_OUTCOME_MAJOR_LOSS "game round outcome major loss"

///round code
/datum/game_round
	///name of the round
	var/name
	///map name for this round
	var/map_name
	///path of map for this round
	var/map_file
	///how long until shutters open after this round is selected
	var/shutter_delay = 2 MINUTES
	///faction that chose the round
	var/faction
	///current state of the round
	var/round_state = GAME_ROUND_STATE_NEW
	///winning faction of the round
	var/winning_faction
	///specific round outcome
	var/outcome

/datum/game_round/Initialize(initiating_faction)
	SHOULD_CALL_PARENT(TRUE)
	faction = initiating_faction
	play_selection_intro()

/datum/game_round/Destroy(force, ...)
	STOP_PROCESSING(SSslowprocess, src)
	return ..()

/datum/game_round/process()
	if(!check_round_progress())
		return
	return PROCESS_KILL

///Generates a new z level for the round
/datum/game_round/proc/load_map()
	var/datum/space_level/new_level = load_new_z_level(map_file, map_name)
	SSminimaps.generate_minimap(new_level.z_value)
	return new_level

///Checks round end criteria, and ends the round if met
/datum/game_round/proc/check_round_progress()
	return FALSE

///Round start proper
/datum/game_round/proc/start_round()
	SHOULD_CALL_PARENT(TRUE)
	START_PROCESSING(SSslowprocess, src) //this may be excessive
	send_global_signal(COMSIG_GLOB_OPEN_TIMED_SHUTTERS_LATE)
	play_start_intro()

///Round end wrap up
/datum/game_round/proc/end_round()
	SHOULD_CALL_PARENT(TRUE)
	STOP_PROCESSING(SSslowprocess, src)

///Intro when the round is selected
/datum/game_round/proc/play_selection_intro()
	return

///Intro when the round is started
/datum/game_round/proc/play_start_intro()
	return


///Applies the correct outcome for the round
/datum/game_round/proc/apply_outcome()
	switch(outcome)
		if(GAME_ROUND_OUTCOME_MAJOR_VICTORY)
			return apply_major_victory()
		if(GAME_ROUND_OUTCOME_MINOR_VICTORY)
			return apply_minor_victory()
		if(GAME_ROUND_OUTCOME_DRAW)
			return apply_draw()
		if(GAME_ROUND_OUTCOME_MINOR_LOSS)
			return apply_minor_loss()
		if(GAME_ROUND_OUTCOME_MAJOR_LOSS)
			return apply_major_loss()
		else
			CRASH("game round ended with no outcome set")

///Apply outcomes for major win
/datum/game_round/proc/apply_major_victory()
	return

///Apply outcomes for minor win
/datum/game_round/proc/apply_minor_victory()
	return

///Apply outcomes for draw
/datum/game_round/proc/apply_draw()
	return

///Apply outcomes for minor loss
/datum/game_round/proc/apply_minor_loss()
	return

///Apply outcomes for major loss
/datum/game_round/proc/apply_major_loss()
	return
