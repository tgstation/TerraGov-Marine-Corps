//Handles the state_process() side of action_states
PROCESSING_SUBSYSTEM_DEF(actionstate)
	name = "AI action states"
	flags = SS_NO_INIT
	wait = 0.5 SECONDS
	var/list/action_states = list()

/datum/controller/subsystem/processing/actionstate/Initialize()
	for(var/datum/element/action_state/action in subtypesof(/datum/element/action_state))
		action_states += new action(src)

	return ..()

/datum/controller/subsystem/processing/actionstate/fire()
	if (!resumed)
		src.currentrun = processing.Copy()
	var/list/currentrun = src.currentrun
	while(currentrun.len)
		var/datum/element/action_state/thing = current_run[current_run.len]
		current_run.len--
		if(QDELETED(thing))
			processing -= thing
		state_process(thing)
		if (MC_TICK_CHECK)
			return
