SUBSYSTEM_DEF(strings)
	name = "Strings"
	init_order = INIT_ORDER_STRINGS
	flags = SS_NO_FIRE

/datum/controller/subsystem/strings/Initialize(timeofday)
	for(var/i in GLOB.string_files)
		GLOB.vars[i] = file2list(GLOB.string_files[i])
		CHECK_TICK

	return ..()
