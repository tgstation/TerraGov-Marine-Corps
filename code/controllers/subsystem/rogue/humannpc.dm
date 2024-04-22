
SUBSYSTEM_DEF(humannpc)
	name = "humannpc"
	wait = 5
	flags = SS_KEEP_TIMING
	priority = 50
	var/list/processing = list()
	var/list/currentrun = list()
	processing_flag = PROCESSING_HUMANNPC
	var/amt2update = 10

/datum/controller/subsystem/humannpc/fire(resumed = 0)
	if (!currentrun.len)
		currentrun = shuffle(processing.Copy())

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
			if (MC_TICK_CHECK)
				return
			continue
		if(thing.process_ai())
			STOP_PROCESSING(SShumannpc, thing)
		if (MC_TICK_CHECK)
			return

/datum/controller/subsystem/humannpc/proc/process_ai(mob/living/carbon/human/mobinput)
	if(!mobinput)
		return
	if(QDELETED(mobinput))
		return
//	if(mobinput.action_skip)
//		mobinput.action_skip = FALSE
//	else
//		if(prob(50))
//			mobinput.action_skip = TRUE
	if(mobinput.process_ai())
		return TRUE
