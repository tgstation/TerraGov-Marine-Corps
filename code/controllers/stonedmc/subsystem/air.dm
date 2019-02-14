SUBSYSTEM_DEF(air)
	name = "Atmospherics"
	init_order = INIT_ORDER_AIR
	priority = FIRE_PRIORITY_AIR
	wait = 2.5 SECONDS
	flags = SS_NO_FIRE
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME

	var/list/networks = list()
	var/list/obj/machinery/atmos_machinery = list()

	var/list/pipe_init_dirs_cache = list()

/datum/controller/subsystem/air/Initialize(timeofday)
	for (var/obj/machinery/atmospherics/machine in GLOB.machines)
		machine.build_network()

	for (var/obj/machinery/atmospherics/components/unary/U in GLOB.machines)
		if (istype(U, /obj/machinery/atmospherics/components/unary/vent_pump))
			var/obj/machinery/atmospherics/components/unary/vent_pump/T = U
			T.broadcast_status()

		else if (istype(U, /obj/machinery/atmospherics/components/unary/vent_scrubber))
			var/obj/machinery/atmospherics/components/unary/vent_scrubber/T = U
			T.broadcast_status()
	return ..()

/datum/controller/subsystem/air/proc/get_init_dirs(type, dir)
	if(!pipe_init_dirs_cache[type])
		pipe_init_dirs_cache[type] = list()

	if(!pipe_init_dirs_cache[type]["[dir]"])
		var/obj/machinery/atmospherics/temp = new type(null, FALSE, dir)
		pipe_init_dirs_cache[type]["[dir]"] = temp.GetInitDirections()
		qdel(temp)

	return pipe_init_dirs_cache[type]["[dir]"]
