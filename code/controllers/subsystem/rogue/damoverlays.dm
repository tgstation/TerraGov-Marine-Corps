SUBSYSTEM_DEF(damoverlays)
	name = "damoverlays"
	wait = 20
	flags = SS_NO_INIT
	priority = 1
	var/list/currentrun = list()
	var/list/processing = list()
	processing_flag = PROCESSING_DAMOVERLAYS
	var/amt2update = 5

/datum/controller/subsystem/damoverlays/fire(resumed = 0)
	if (!resumed || !currentrun.len)
		currentrun = processing.Copy()

//	//cache for sanic speed (lists are references anyways)
//	var/list/currentrun = src.currentrun

	var/ye = 0
	while(currentrun.len)
		if(ye > amt2update)
			return
		ye++
		var/mob/living/carbon/human/thing = currentrun[currentrun.len]
		currentrun.len--
		if (!thing || QDELETED(thing))
			processing -= thing
			if(MC_TICK_CHECK)
				return
			continue
		if(istype(thing))
			thing.update_damage_overlays_real()
		STOP_PROCESSING(SSdamoverlays, thing)
		if(MC_TICK_CHECK)
			return
