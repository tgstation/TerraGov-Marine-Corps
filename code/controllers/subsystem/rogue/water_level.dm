// Smooth HUD updates, but low priority
SUBSYSTEM_DEF(waterlevel)
	name = "waterlevel"
	wait = 30
	flags = SS_NO_INIT
	priority = FIRE_PRIORITY_WATER_LEVEL
	var/list/currentrun = list()
	var/list/processing = list()
	processing_flag = PROCESSING_WATERLEVEL

/datum/controller/subsystem/waterlevel/fire(resumed = 0)
	if (!resumed)
		src.currentrun = processing.Copy()

	//cache for sanic speed (lists are references anyways)
	var/list/currentrun = src.currentrun

	while(currentrun.len)
		var/turf/open/thing = currentrun[currentrun.len]
		currentrun.len--
		if (!thing || QDELETED(thing))
			processing -= thing
			if (MC_TICK_CHECK)
				return
			continue
		if(istype(thing))
			if(thing.update_water())
				STOP_PROCESSING(SSwaterlevel, thing)
		else
			STOP_PROCESSING(SSwaterlevel, thing)
		if(MC_TICK_CHECK)
			return
