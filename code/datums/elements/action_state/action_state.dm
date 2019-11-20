//A singleton action state; AI components are added to the list and a subsystem will periodically call the process() for this
/datum/element/action_state
	element_flags = ELEMENT_DETACH //Detach on attached's QDEL

/datum/element/action_state/New()
	. = ..()
	START_PROCESSING(SSactionstate, src)

/datum/element/action_state/Destroy()
	STOP_PROCESSING(SSactionstate, src)
	return ..()

/datum/element/action_state/process()
