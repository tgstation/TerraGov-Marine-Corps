
SUBSYSTEM_DEF(todchange)
	name = "todchange"
	flags = SS_NO_INIT
	priority = 1
	var/list/processing = list()
	var/list/currentrun = list()
	processing_flag = PROCESSING_TODCHANGE
	var/amt2update = 100

/datum/controller/subsystem/todchange/fire(resumed = 0)
	if (!resumed || !currentrun.len)
		src.currentrun = shuffle(processing.Copy())

//	//cache for sanic speed (lists are references anyways)
//	var/list/currentrun = src.currentrun

//	if(!currentrun.len)
//		testing("nothing to update [rand(1,9)]")

	var/ye = 0
	while(currentrun.len)
		if(ye > amt2update)
			return
		ye++
		var/obj/effect/sunlight/L = currentrun[currentrun.len]
		currentrun.len--
		if (!L || QDELETED(L))
			processing -= L
			if (MC_TICK_CHECK)
				return
			continue
		L.update()
		STOP_PROCESSING(SStodchange, L)
		if (MC_TICK_CHECK)
			return
