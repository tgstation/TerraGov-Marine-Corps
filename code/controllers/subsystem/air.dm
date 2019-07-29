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
	setup_atmos_machinery()
	setup_pipenets()
	return ..()

/datum/controller/subsystem/air/proc/get_init_dirs(type, dir)
	if(!pipe_init_dirs_cache[type])
		pipe_init_dirs_cache[type] = list()

	if(!pipe_init_dirs_cache[type]["[dir]"])
		var/obj/machinery/atmospherics/temp = new type(null, FALSE, dir)
		pipe_init_dirs_cache[type]["[dir]"] = temp.GetInitDirections()
		qdel(temp)

	return pipe_init_dirs_cache[type]["[dir]"]

/datum/controller/subsystem/air/proc/setup_atmos_machinery()
	for (var/obj/machinery/atmospherics/AM in atmos_machinery)
		AM.atmosinit()
		CHECK_TICK

/datum/controller/subsystem/air/proc/setup_pipenets()
	for (var/obj/machinery/atmospherics/AM in atmos_machinery)
		AM.build_network()
		CHECK_TICK

/datum/controller/subsystem/air/proc/setup_template_machinery(list/atmos_machines)
	for(var/A in atmos_machines)
		var/obj/machinery/atmospherics/AM = A
		AM.atmosinit()
		CHECK_TICK

	for(var/A in atmos_machines)
		var/obj/machinery/atmospherics/AM = A
		AM.build_network()
		CHECK_TICK
