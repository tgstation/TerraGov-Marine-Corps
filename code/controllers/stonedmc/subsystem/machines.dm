SUBSYSTEM_DEF(machines)
	name = "Machines"
	init_order = INIT_ORDER_MACHINES
	flags = SS_KEEP_TIMING

	var/list/currentrun = list()
	var/list/processing = list()
	var/list/powernets = list()
	var/list/cable_list = list()
	var/list/zlevel_cables = list() //up or down cables
	var/list/currentrunareas = list()

/datum/controller/subsystem/machines/Initialize()
	makepowernets()
	fire()
	return ..()

/datum/controller/subsystem/machines/proc/makepowernets()
	for(var/datum/powernet/PN in powernets)
		qdel(PN)
	powernets.Cut()

	for(var/obj/structure/cable/PC in cable_list)
		if(!PC.powernet)
			var/datum/powernet/NewPN = new()
			NewPN.add_cable(PC)
			propagate_network(PC,PC.powernet)

/datum/controller/subsystem/machines/stat_entry()
	..("PA:[length(currentrunareas)]|PN:[length(powernets)]|PM:[length(processing)]")

/datum/controller/subsystem/machines/fire(resumed = FALSE)
	if (!resumed)
		for(var/datum/powernet/Powernet in powernets)
			Powernet.reset() //reset the power state.
		src.currentrun = processing.Copy()
		src.currentrunareas = active_areas.Copy()

	//cache for sanic speed (lists are references anyways)
	var/list/currentrun = src.currentrun
	var/list/currentrunareas = src.currentrunareas

	var/seconds = wait * 0.1
	while(length(currentrun))
		var/obj/machinery/thing = currentrun[length(currentrun)]
		currentrun.len--
		if(QDELETED(thing) || thing.process(seconds) == PROCESS_KILL)
			processing -= thing
			if(!QDELETED(thing))
				thing.datum_flags &= ~DF_ISPROCESSING
		if(MC_TICK_CHECK)
			return

	while(length(currentrunareas))
		var/area/A = currentrunareas[length(currentrunareas)]
		currentrunareas.len--

		if(A.master == A)
			if(A.powerupdate)
				A.powerupdate -= 1
				A.clear_usage()
				for(var/obj/machinery/M in A.area_machines) // should take it to O(n^2) and hopefully less expensive.
					if(M)
						//check if the area has power for M's channel
						//this will keep stat updated in case the machine is moved from one area to another.
						M.power_change(A)	//we've already made sure A is a master area, above.

						if(!(M.machine_stat & NOPOWER) && M.use_power)
							M.auto_use_power()

			if(length(A.apc))
				if (MC_TICK_CHECK)
					return
				continue

		A.powerupdate = 0

		if (MC_TICK_CHECK)
			return

/datum/controller/subsystem/machines/proc/setup_template_powernets(list/cables)
	for(var/A in cables)
		var/obj/structure/cable/PC = A
		if(!PC.powernet)
			var/datum/powernet/NewPN = new()
			NewPN.add_cable(PC)
			propagate_network(PC,PC.powernet)


/datum/controller/subsystem/machines/Recover()
	if(istype(SSmachines.processing))
		processing = SSmachines.processing

	if(istype(SSmachines.powernets))
		powernets = SSmachines.powernets