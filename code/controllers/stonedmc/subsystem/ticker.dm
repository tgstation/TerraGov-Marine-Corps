SUBSYSTEM_DEF(ticking)
	name = "Ticking"
	init_order = INIT_ORDER_TICKER

	priority = FIRE_PRIORITY_TICKER
	flags = SS_KEEP_TIMING
	runlevels = RUNLEVEL_LOBBY | RUNLEVEL_SETUP | RUNLEVEL_GAME

/datum/controller/subsystem/ticking/Initialize(timeofday)
	if(!SSticker)
		SSticker = new /datum/controller/gameticker()

	spawn(0)
		if(SSticker)
			SSticker.pregame()

	return ..()

/datum/controller/subsystem/ticking/fire()
	SSticker.process()
