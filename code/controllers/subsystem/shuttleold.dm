SUBSYSTEM_DEF(shuttleold)
	name = "Shuttleold"
	wait = 5.5 SECONDS
	init_order = INIT_ORDER_SHUTTLE
	flags = SS_KEEP_TIMING|SS_NO_TICK_CHECK
	runlevels = RUNLEVEL_SETUP | RUNLEVEL_GAME

/datum/controller/subsystem/shuttleold/Initialize()
	if(!shuttle_controller)
		shuttle_controller = new /datum/controller/shuttle_controller()

	for(var/obj/effect/landmark/shuttle_loc/L in GLOB.shuttle_locations)
		L.link_location() // hacky fix for the out of order init.

/datum/controller/subsystem/shuttleold/fire()
	shuttle_controller.process()
