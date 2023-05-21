#define GAME_ROUND_STATE_START "game round state start"
///round code
/datum/game_round
	///name of the round
	var/name
	///faction that chose the round
	var/faction
	///path and name of map for this round
	var/list/round_map
	///current state of the round
	var/round_state = GAME_ROUND_STATE_START
	///winning faction of the round
	var/winning_faction
	///specific round outcome
	var/outcome

/datum/game_round/Initialize()
	//

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
