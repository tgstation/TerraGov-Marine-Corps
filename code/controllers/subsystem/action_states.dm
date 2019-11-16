//Handles the state_process() side of action_states
SUBSYSTEM_DEF(actionstate)
	name = "AI action states processing"
	wait = 1 SECONDS
	priority = FIRE_PRIORITY_ACTION_STATES
	var/list/action_states = list()

	var/list/processing = list()
	var/list/currentrun = list()

/datum/controller/subsystem/actionstate/fire(resumed = FALSE)
	if(!resumed)
		src.currentrun = processing.Copy()
	var/list/current_run = src.currentrun
	while(current_run.len)
		var/datum/element/action_state/thing = current_run[current_run.len]
		current_run.len--
		if(QDELETED(thing))
			processing -= thing
		thing.state_process()
		if (MC_TICK_CHECK)
			return
