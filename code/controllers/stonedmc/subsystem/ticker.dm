var/global/datum/global_init/init

SUBSYSTEM_DEF(ticker)
	name = "Ticker"
	init_order = INIT_ORDER_TICKER

	priority = FIRE_PRIORITY_TICKER
	flags = SS_KEEP_TIMING
	runlevels = RUNLEVEL_LOBBY | RUNLEVEL_SETUP | RUNLEVEL_GAME

/datum/controller/subsystem/ticker/Initialize(timeofday)
	init = new ()
	if(!ticker)
		ticker = new /datum/controller/gameticker()

	spawn(0)
		if(ticker)
			ticker.pregame()

	return ..()

/datum/controller/subsystem/ticker/fire()
	ticker.process()
