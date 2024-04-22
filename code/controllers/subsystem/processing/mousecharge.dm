// Smooth HUD updates, but low priority
PROCESSING_SUBSYSTEM_DEF(mousecharge)
	name = "mouse charging prog"
	wait = 1
	priority = FIRE_PRIORITY_MOUSECHARGE
	stat_tag = "MOUSE"

/datum/controller/subsystem/processing/mousecharge/fire(resumed = 0)
	if (!resumed)
		currentrun = processing.Copy()
	//cache for sanic speed (lists are references anyways)
	var/list/current_run = currentrun

	while(current_run.len)
		var/client/thing = current_run[current_run.len]
		current_run.len--
		if(QDELETED(thing))
			processing -= thing
		else if(thing.process(wait) == PROCESS_KILL)
			// fully stop so that a future START_PROCESSING will work
			STOP_PROCESSING(src, thing)
		if (MC_TICK_CHECK)
			return