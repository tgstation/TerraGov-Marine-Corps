#define ROUND_START_MUSIC_LIST "strings/round_start_sounds.txt"

SUBSYSTEM_DEF(ticker)
	name = "Ticker"
	init_order = INIT_ORDER_TICKER

	priority = FIRE_PRIORITY_TICKER
	flags = SS_KEEP_TIMING
	runlevels = RUNLEVEL_LOBBY | RUNLEVEL_SETUP | RUNLEVEL_GAME

/datum/controller/subsystem/ticker/Initialize(timeofday)
	if(!ticker)
		ticker = new /datum/controller/gameticker()

	ticker.pregame()

	return ..()

/datum/controller/subsystem/ticker/fire()
	ticker.process()
