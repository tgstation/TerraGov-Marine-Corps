
SUBSYSTEM_DEF(soundloopers)
	name = "soundloopers"
	wait = 1
	flags = SS_NO_INIT
	priority = FIRE_PRIORITY_DEFAULT
	var/list/processing = list()
	var/list/currentrun = list()
	var/amt2update = 20

/datum/controller/subsystem/soundloopers/fire(resumed = 0)
	if (!resumed || !currentrun.len)
		src.currentrun = shuffle(processing.Copy())

//	//cache for sanic speed (lists are references anyways)
//	var/list/currentrun = src.currentrun

	var/ye = 0
	while (currentrun.len)
		if(ye > amt2update)
			return
		ye++
		var/datum/looping_sound/thing = currentrun[currentrun.len]
		currentrun.len--
		if (!thing || QDELETED(thing))
			processing -= thing
			if (MC_TICK_CHECK)
				return
			continue
		if(thing.sound_loop())
			STOP_PROCESSING(SSsoundloopers, thing)
		if (MC_TICK_CHECK)
			return