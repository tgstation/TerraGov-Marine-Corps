#define GAME_ROUND_STATE_START "game round state start"
///round code
/datum/game_round
	///name of the round
	var/name
	///faction that chose the round
	var/faction
	///map name for this round
	var/map_name
	///path of map for this round
	var/map_file
	///current state of the round
	var/round_state = GAME_ROUND_STATE_START
	///winning faction of the round
	var/winning_faction
	///specific round outcome
	var/outcome
	///how long until shutters open after this round is selected
	var/shutter_delay = 2 MINUTES

/datum/game_round/Initialize(initiating_faction)
	SHOULD_CALL_PARENT(TRUE)
	faction = initiating_faction

///Generates a new z level for the round
/datum/game_round/proc/load_map()
	var/datum/space_level/new_level = load_new_z_level(map_file, map_name)
	SSminimaps.generate_minimap(new_level.z_value)
	return new_level

/datum/game_round/Destroy(force, ...)
	STOP_PROCESSING(SSslowprocess, src)
	return ..()

/datum/game_round/process()
	if(!check_round_progress())
		return
	return PROCESS_KILL

///Checks round end criteria, and ends the round if met
/datum/game_round/proc/check_round_progress()
	return FALSE

///Round start setup
/datum/game_round/proc/start_round()
	SHOULD_CALL_PARENT(TRUE)
	START_PROCESSING(SSslowprocess, src) //this may be excessive

///Round end wrap up
/datum/game_round/proc/end_round()
	SHOULD_CALL_PARENT(TRUE)
	STOP_PROCESSING(SSslowprocess, src)

/datum/game_round/proc/apply_outcome() //maybe not needed
	return

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
