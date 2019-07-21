// --------------------------------------------
// *** The core objective interface to allow generic handling of objectives ***
// --------------------------------------------
/datum/objective/
	var/name = "An objective to complete"
	var/complete = FALSE
	var/failed = FALSE
	var/active = FALSE
	var/priority = OBJECTIVE_NO_VALUE
	var/list/datum/objective/required_objectives = list()
	var/list/datum/objective/enables_objectives = list()
	var/prerequisites_required = PREREQUISITES_ONE
	var/objective_flags = NONE // functionality related flags
	var/display_flags = NONE // display related flags
	var/display_category // group objectives for round end display

/datum/objective/New()
	GLOB.all_objectives += src

/datum/objective/Destroy()
	GLOB.all_objectives -= src
	STOP_PROCESSING(SSobjectives, src)

	for(var/i in required_objectives)
		var/datum/objective/R = i
		R.enables_objectives -= src
	for(var/i in enables_objectives)
		var/datum/objective/E = i
		E.required_objectives -= src
	return ..()

/datum/objective/proc/initialize() // initial setup after the map has loaded

/datum/objective/proc/pre_round_start() // called by game mode just before the round starts

/datum/objective/proc/post_round_start() // called by game mode on a short delay after round starts

/datum/objective/proc/on_round_end() // called by game mode when round ends

/datum/objective/proc/on_ground_evac() // called when queen launches dropship

/datum/objective/proc/on_ship_boarding() // called when dropship crashes into almayer

/datum/objective/proc/get_completion_status()
	if(is_complete())
		return "<span class='objectivesuccess'>Succeeded!</span>"
	if(is_failed())
		return "<span class='objectivefail'>Failed!</span>"
	return "<span class='objectivebig'>In Progress!</span>"

/datum/objective/proc/get_readable_progress()
	var/dat = "<span class='objectivebig'>[name]: </span>"
	return dat + get_completion_status() + "<br>"

/datum/objective/proc/get_clue() //TODO: change this to an formatted list like above -spookydonut
	return

/datum/objective/process()
	if(!is_prerequisites_completed())
		deactivate()
		return FALSE
	check_completion()
	return TRUE

/datum/objective/proc/is_complete()
	return complete

/datum/objective/proc/complete()
	if(is_complete())
		return FALSE
	complete = TRUE
	if(can_be_deactivated() && !(objective_flags & OBJ_PROCESS_ON_DEMAND))
		deactivate()
	return TRUE

/datum/objective/proc/uncomplete()
	if(!(objective_flags & OBJ_CAN_BE_UNCOMPLETED) || !complete)
		return
	complete = FALSE
	if(can_be_activated())
		activate()

/datum/objective/proc/check_completion()
	if(is_failed())
		return FALSE
	if(complete && !(objective_flags & OBJ_CAN_BE_UNCOMPLETED))
		return TRUE
	return complete

/datum/objective/proc/is_in_progress()
	return active

/datum/objective/proc/fail()
	if(!(objective_flags & OBJ_FAILABLE))
		return
	if(complete && !(objective_flags & OBJ_CAN_BE_UNCOMPLETED))
		return
	failed = TRUE
	uncomplete()
	deactivate()
	for(var/i in enables_objectives)
		var/datum/objective/O = i
		if(O.objective_flags & OBJ_PREREQS_CANT_FAIL)
			O.fail()

/datum/objective/proc/is_failed()
	if(!(objective_flags & OBJ_FAILABLE))
		return FALSE
	if(complete && !(objective_flags & OBJ_CAN_BE_UNCOMPLETED))
		return FALSE
	return failed

/datum/objective/proc/activate(force = FALSE)
	if(force)
		prerequisites_required = PREREQUISITES_NONE // somehow we got the terminal password etc force us active
	if(can_be_activated())
		active = TRUE
		if(!(objective_flags & OBJ_PROCESS_ON_DEMAND))
			START_PROCESSING(SSobjectives, src)
			GLOB.active_objectives += src
			GLOB.inactive_objectives -= src

/datum/objective/proc/deactivate()
	if(can_be_deactivated())
		active = FALSE
		if(!(objective_flags & OBJ_PROCESS_ON_DEMAND))
			STOP_PROCESSING(SSobjectives, src)
			GLOB.active_objectives -= src
			GLOB.inactive_objectives += src

/datum/objective/proc/can_be_activated()
	if(is_active())
		return FALSE
	if(is_failed())
		return FALSE
	if(!is_prerequisites_completed())
		return FALSE
	return TRUE

/datum/objective/proc/can_be_deactivated()
	return !(objective_flags & OBJ_CAN_BE_UNCOMPLETED)

/datum/objective/proc/is_prerequisites_completed()
	var/prereq_complete = FALSE
	for(var/i in required_objectives)
		var/datum/objective/O = i
		if(O.is_complete())
			prereq_complete++
	switch(prerequisites_required)
		if(PREREQUISITES_NONE)
			return TRUE
		if(PREREQUISITES_ONE)
			if(prereq_complete)
				return TRUE
		if(PREREQUISITES_MAJORITY)
			if(prereq_complete > (required_objectives.len/2)) // more than half
				return TRUE
		if(PREREQUISITES_ALL)
			if(prereq_complete >= required_objectives.len)
				return TRUE
	return FALSE

/datum/objective/proc/is_active()
	if(complete && !(objective_flags & OBJ_CAN_BE_UNCOMPLETED))
		return FALSE
	return active

/datum/objective/proc/get_point_value()
	if(is_failed())
		return FALSE
	if(is_complete())
		return priority
	return FALSE

/datum/objective/proc/total_point_value()
	return priority
