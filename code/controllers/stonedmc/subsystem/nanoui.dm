SUBSYSTEM_DEF(nano)
	name     = "Nano UI"
	flags    = SS_NO_INIT
	wait     = 2 SECONDS
	priority = FIRE_PRIORITY_NANOUI
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME | RUNLEVEL_LOBBY

	var/list/currentrun = list()

/datum/controller/subsystem/nano/stat_entry()
	..("P:[nanomanager.processing_uis.len]")

/datum/controller/subsystem/nano/fire(resumed = FALSE)
	if (!resumed)
		currentrun = nanomanager.processing_uis.Copy()

	while (currentrun.len)
		var/datum/nanoui/UI = currentrun[currentrun.len]
		currentrun.len--

		if (!UI || UI.gc_destroyed)
			continue

		UI.process()

		if (MC_TICK_CHECK)
			return
