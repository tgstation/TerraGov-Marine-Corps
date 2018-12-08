SUBSYSTEM_DEF(sun)
	name = "Sun"
	wait = 5 SECONDS
	flags = SS_NO_TICK_CHECK
	var/list/solars	= list()

/datum/controller/subsystem/sun/Initialize(timeofday)
	if(!sun)
		sun = new /datum/sun()
	return ..()

/datum/controller/subsystem/sun/stat_entry(msg)
	..("P:[solars.len]")

/datum/controller/subsystem/sun/fire()
	sun.calc_position()
